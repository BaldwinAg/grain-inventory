// =====================================================
// GRAIN PULSE - Google Apps Script
// Parses Barchart CSV emails and updates Supabase
// Also checks/sends Twilio alerts
// =====================================================
//
// SETUP INSTRUCTIONS:
// 1. Go to script.google.com and create a new project
// 2. Paste this entire script
// 3. Update the CONFIG section below with your credentials
// 4. Run 'setupTrigger' once to create the time-based trigger
// 5. Authorize the script when prompted
//
// The script will then automatically run every 15 minutes,
// check for new Barchart emails, and update your database.
// =====================================================

// =====================================================
// CONFIGURATION - UPDATE THESE VALUES
// =====================================================

const CONFIG = {
  // Supabase credentials (from your project settings > API)
  SUPABASE_URL: 'https://xehapaasizntuzqzvwej.supabase.co',
  SUPABASE_ANON_KEY: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhlaGFwYWFzaXpudHV6cXp2d2VqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjgzMTkwOTksImV4cCI6MjA4Mzg5NTA5OX0.JTtRaVRfZ4DNddTdT2BsKgCNabErgsCB0rBCHlK0mbA',

  // Twilio credentials (from twilio.com/console)
  TWILIO_ACCOUNT_SID: 'YOUR_TWILIO_ACCOUNT_SID',
  TWILIO_AUTH_TOKEN: 'YOUR_TWILIO_AUTH_TOKEN',
  TWILIO_PHONE_FROM: '+1 YOUR_TWILIO_NUMBER',  // Your Twilio number

  // Your phone number for alerts
  DEFAULT_PHONE_TO: '+1 YOUR_PHONE_NUMBER',   // Your cell phone

  // Email settings
  EMAIL_SEARCH_QUERY: 'from:noreply@barchart.com subject:"Watchlist Summary" has:attachment',
  PROCESSED_LABEL: 'GrainPulse/Processed',

  // How many emails to process per run (prevents timeout)
  MAX_EMAILS_PER_RUN: 5
};

// =====================================================
// MAIN FUNCTION - Run this on a trigger
// =====================================================

function processNewBarchartEmails() {
  console.log('Starting Grain Pulse email processing...');

  // Search for unprocessed Barchart emails
  const threads = GmailApp.search(CONFIG.EMAIL_SEARCH_QUERY + ' -label:' + CONFIG.PROCESSED_LABEL, 0, CONFIG.MAX_EMAILS_PER_RUN);

  if (threads.length === 0) {
    console.log('No new Barchart emails found.');
    return;
  }

  console.log(`Found ${threads.length} new email(s) to process.`);

  // Ensure the processed label exists
  let processedLabel = GmailApp.getUserLabelByName(CONFIG.PROCESSED_LABEL);
  if (!processedLabel) {
    processedLabel = GmailApp.createLabel(CONFIG.PROCESSED_LABEL);
  }

  // Process each thread
  for (const thread of threads) {
    try {
      const messages = thread.getMessages();
      const latestMessage = messages[messages.length - 1];

      console.log(`Processing: ${latestMessage.getSubject()}`);

      // Get CSV attachment
      const attachments = latestMessage.getAttachments();
      const csvAttachment = attachments.find(a =>
        a.getName().toLowerCase().endsWith('.csv') &&
        a.getName().toLowerCase().includes('watchlist')
      );

      if (!csvAttachment) {
        console.log('No CSV attachment found, skipping.');
        thread.addLabel(processedLabel);
        continue;
      }

      // Parse CSV
      const csvData = csvAttachment.getDataAsString();
      const records = parseCSV(csvData);

      console.log(`Parsed ${records.length} records from CSV.`);

      // Determine snapshot type from email time
      const emailDate = latestMessage.getDate();
      const snapshotType = getSnapshotType(emailDate);

      // Update Supabase
      const updateResults = updateSupabase(records, emailDate, snapshotType);

      console.log(`Updated ${updateResults.success} records, ${updateResults.failed} failed.`);

      // Check alerts for updated symbols
      const alertsTriggered = checkAndSendAlerts(records);

      if (alertsTriggered > 0) {
        console.log(`Sent ${alertsTriggered} alert(s).`);
      }

      // Mark as processed
      thread.addLabel(processedLabel);

    } catch (error) {
      console.error(`Error processing thread: ${error.message}`);
    }
  }

  console.log('Grain Pulse processing complete.');
}

// =====================================================
// CSV PARSING
// =====================================================

function parseCSV(csvString) {
  const lines = csvString.trim().split('\n');
  if (lines.length < 2) return [];

  // Parse header row
  const headers = parseCSVLine(lines[0]);

  // Parse data rows
  const records = [];
  for (let i = 1; i < lines.length; i++) {
    const values = parseCSVLine(lines[i]);
    if (values.length !== headers.length) continue;

    const record = {};
    headers.forEach((header, index) => {
      record[header] = values[index];
    });

    // Clean up the record
    records.push(cleanRecord(record));
  }

  return records;
}

function parseCSVLine(line) {
  const values = [];
  let current = '';
  let inQuotes = false;

  for (let i = 0; i < line.length; i++) {
    const char = line[i];

    if (char === '"') {
      inQuotes = !inQuotes;
    } else if (char === ',' && !inQuotes) {
      values.push(current.trim());
      current = '';
    } else {
      current += char;
    }
  }
  values.push(current.trim());

  return values;
}

function cleanRecord(record) {
  // Map Barchart columns to our schema
  return {
    symbol: record['Symbol'] || '',
    name: record['Name'] || '',
    latest_price: parseFloat(record['Latest']) || null,
    price_change: parseFloat(record['Change']) || null,
    rsi_14d: parseFloat(record['14D Rel Str']) || null,
    stoch_14d_pct_d: parsePercentage(record['14D Stoch %D']),
    stoch_9d_pct_k: parsePercentage(record['9D Stoch %K']),
    support_1: parseFloat(record['1st Sup']) || null,
    resistance_1: parseFloat(record['1st Res']) || null,
    atr_14d: parseFloat(record['14D ATR']) || null,
    plus_di_9d: parseFloat(record['9D +DI']) || null,
    expiration_date: parseExpirationDate(record['Exp Date']),
    trend_signal: record['Trend'] || null
  };
}

function parsePercentage(str) {
  if (!str) return null;
  const cleaned = str.replace('%', '').trim();
  return parseFloat(cleaned) || null;
}

function parseExpirationDate(str) {
  if (!str || str === 'N/A') return null;

  // Format: MM/DD/YY
  const parts = str.split('/');
  if (parts.length !== 3) return null;

  const month = parseInt(parts[0]);
  const day = parseInt(parts[1]);
  let year = parseInt(parts[2]);

  // Handle 2-digit year
  if (year < 100) {
    year += 2000;
  }

  // Return ISO format
  return `${year}-${String(month).padStart(2, '0')}-${String(day).padStart(2, '0')}`;
}

function getSnapshotType(emailDate) {
  const hours = emailDate.getHours();

  if (hours < 6) return 'overnight';      // 3am CT
  if (hours < 14) return 'midday';        // 12pm CT
  if (hours < 18) return 'close';         // 3pm CT
  return 'eod';                           // 4:45pm CT
}

// =====================================================
// SUPABASE INTEGRATION
// =====================================================

function updateSupabase(records, emailDate, snapshotType) {
  const results = { success: 0, failed: 0 };

  for (const record of records) {
    // Skip non-futures (like IBM in the test data)
    if (!isFuturesSymbol(record.symbol)) {
      console.log(`Skipping non-futures symbol: ${record.symbol}`);
      continue;
    }

    try {
      // Prepare payload (without symbol for PATCH)
      const payload = {
        name: record.name,
        latest_price: record.latest_price,
        price_change: record.price_change,
        rsi_14d: record.rsi_14d,
        stoch_14d_pct_d: record.stoch_14d_pct_d,
        stoch_9d_pct_k: record.stoch_9d_pct_k,
        support_1: record.support_1,
        resistance_1: record.resistance_1,
        atr_14d: record.atr_14d,
        plus_di_9d: record.plus_di_9d,
        expiration_date: record.expiration_date,
        trend_signal: record.trend_signal,
        data_timestamp: emailDate.toISOString(),
        updated_at: new Date().toISOString()
      };

      // Try to update existing record first
      const response = UrlFetchApp.fetch(
        `${CONFIG.SUPABASE_URL}/rest/v1/barchart_technicals?symbol=eq.${encodeURIComponent(record.symbol)}`,
        {
          method: 'PATCH',
          headers: {
            'apikey': CONFIG.SUPABASE_ANON_KEY,
            'Authorization': `Bearer ${CONFIG.SUPABASE_ANON_KEY}`,
            'Content-Type': 'application/json',
            'Prefer': 'return=representation'
          },
          payload: JSON.stringify(payload),
          muteHttpExceptions: true
        }
      );

      if (response.getResponseCode() >= 200 && response.getResponseCode() < 300) {
        const result = JSON.parse(response.getContentText());

        // If no record was updated (result array is empty), insert new record
        if (result.length === 0) {
          const insertResponse = UrlFetchApp.fetch(
            `${CONFIG.SUPABASE_URL}/rest/v1/barchart_technicals`,
            {
              method: 'POST',
              headers: {
                'apikey': CONFIG.SUPABASE_ANON_KEY,
                'Authorization': `Bearer ${CONFIG.SUPABASE_ANON_KEY}`,
                'Content-Type': 'application/json'
              },
              payload: JSON.stringify({
                symbol: record.symbol,
                ...payload
              }),
              muteHttpExceptions: true
            }
          );

          if (insertResponse.getResponseCode() >= 200 && insertResponse.getResponseCode() < 300) {
            console.log(`Inserted new record for ${record.symbol}`);
            results.success++;
            saveToHistory(record, emailDate, snapshotType);
          } else {
            console.error(`Failed to insert ${record.symbol}: ${insertResponse.getContentText()}`);
            results.failed++;
          }
        } else {
          console.log(`Updated existing record for ${record.symbol}`);
          results.success++;
          saveToHistory(record, emailDate, snapshotType);
        }
      } else {
        console.error(`Failed to update ${record.symbol}: ${response.getContentText()}`);
        results.failed++;
      }

    } catch (error) {
      console.error(`Error updating ${record.symbol}: ${error.message}`);
      results.failed++;
    }
  }

  return results;
}

function saveToHistory(record, emailDate, snapshotType) {
  try {
    UrlFetchApp.fetch(
      `${CONFIG.SUPABASE_URL}/rest/v1/barchart_technicals_history`,
      {
        method: 'POST',
        headers: {
          'apikey': CONFIG.SUPABASE_ANON_KEY,
          'Authorization': `Bearer ${CONFIG.SUPABASE_ANON_KEY}`,
          'Content-Type': 'application/json'
        },
        payload: JSON.stringify({
          symbol: record.symbol,
          latest_price: record.latest_price,
          rsi_14d: record.rsi_14d,
          stoch_14d_pct_d: record.stoch_14d_pct_d,
          stoch_9d_pct_k: record.stoch_9d_pct_k,
          trend_signal: record.trend_signal,
          snapshot_time: emailDate.toISOString(),
          snapshot_type: snapshotType
        }),
        muteHttpExceptions: true
      }
    );
  } catch (error) {
    console.error(`Error saving history for ${record.symbol}: ${error.message}`);
  }
}

function isFuturesSymbol(symbol) {
  // Futures and options symbols start with commodity codes
  // Common grain futures: ZC (corn), ZS (soybeans), ZW (wheat), KE (KC wheat)
  // Options are included (e.g., ZCH6|445P)
  const futuresPattern = /^(ZC|ZS|ZW|ZM|ZL|ZO|KE|KW|MWE|HE|LE|GF|CL|NG|GC|SI)/i;
  return futuresPattern.test(symbol);
}

// =====================================================
// ALERT CHECKING & TWILIO SMS
// =====================================================

function checkAndSendAlerts(records) {
  let alertsTriggered = 0;

  for (const record of records) {
    if (!isFuturesSymbol(record.symbol)) continue;

    try {
      // Fetch active alerts for this symbol
      const alertsResponse = UrlFetchApp.fetch(
        `${CONFIG.SUPABASE_URL}/rest/v1/barchart_alerts?symbol=eq.${record.symbol}&is_active=eq.true`,
        {
          method: 'GET',
          headers: {
            'apikey': CONFIG.SUPABASE_ANON_KEY,
            'Authorization': `Bearer ${CONFIG.SUPABASE_ANON_KEY}`,
            'Content-Type': 'application/json'
          },
          muteHttpExceptions: true
        }
      );

      if (alertsResponse.getResponseCode() !== 200) continue;

      const alerts = JSON.parse(alertsResponse.getContentText());

      for (const alert of alerts) {
        const shouldFire = evaluateAlert(alert, record);

        if (shouldFire) {
          // Send SMS
          const message = formatAlertMessage(alert, record);
          const sent = sendTwilioSMS(alert.phone_number || CONFIG.DEFAULT_PHONE_TO, message);

          if (sent) {
            alertsTriggered++;

            // Log to history and update alert
            logAlertTriggered(alert, record, message);
          }
        }

        // Update last_value for crossover detection
        updateAlertLastValue(alert, record);
      }

    } catch (error) {
      console.error(`Error checking alerts for ${record.symbol}: ${error.message}`);
    }
  }

  return alertsTriggered;
}

function evaluateAlert(alert, record) {
  const currentValue = getMetricValue(alert.metric, record);
  if (currentValue === null) return false;

  const threshold = parseFloat(alert.threshold);
  const lastValue = alert.last_value !== null ? parseFloat(alert.last_value) : null;

  // Check cooldown
  if (alert.last_triggered_at) {
    const lastTriggered = new Date(alert.last_triggered_at);
    const cooldownMs = (alert.cooldown_hours || 4) * 60 * 60 * 1000;
    if (Date.now() - lastTriggered.getTime() < cooldownMs) {
      return false;  // Still in cooldown
    }
  }

  switch (alert.condition) {
    case 'above':
      return currentValue > threshold;

    case 'below':
      return currentValue < threshold;

    case 'crosses_above':
      return lastValue !== null && lastValue <= threshold && currentValue > threshold;

    case 'crosses_below':
      return lastValue !== null && lastValue >= threshold && currentValue < threshold;

    case 'equals':
      // For trend signals
      if (alert.metric === 'trend') {
        return record.trend_signal === alert.threshold_text &&
               (lastValue === null || lastValue !== record.trend_signal);
      }
      return currentValue === threshold;

    default:
      return false;
  }
}

function getMetricValue(metric, record) {
  switch (metric) {
    case 'price': return record.latest_price;
    case 'rsi_14d': return record.rsi_14d;
    case 'stoch_14d': return record.stoch_14d_pct_d;
    case 'stoch_9d': return record.stoch_9d_pct_k;
    case 'trend': return record.trend_signal;
    default: return null;
  }
}

function formatAlertMessage(alert, record) {
  const metricNames = {
    'price': 'Price',
    'rsi_14d': 'RSI',
    'stoch_14d': '14D Stoch',
    'stoch_9d': '9D Stoch',
    'trend': 'Trend'
  };

  const metricName = metricNames[alert.metric] || alert.metric;
  const currentValue = getMetricValue(alert.metric, record);

  let conditionText = '';
  switch (alert.condition) {
    case 'above': conditionText = `above ${alert.threshold}`; break;
    case 'below': conditionText = `below ${alert.threshold}`; break;
    case 'crosses_above': conditionText = `crossed above ${alert.threshold}`; break;
    case 'crosses_below': conditionText = `crossed below ${alert.threshold}`; break;
    case 'equals': conditionText = `is now ${alert.threshold_text || alert.threshold}`; break;
  }

  return `🌾 GRAIN PULSE ALERT\n${record.symbol} ${metricName} ${conditionText}\nCurrent: ${currentValue}\nPrice: ${record.latest_price}`;
}

function sendTwilioSMS(toNumber, message) {
  if (!CONFIG.TWILIO_ACCOUNT_SID || CONFIG.TWILIO_ACCOUNT_SID === 'YOUR_TWILIO_SID') {
    console.log(`[TEST MODE] Would send SMS to ${toNumber}: ${message}`);
    return true;  // Pretend success in test mode
  }

  try {
    const twilioUrl = `https://api.twilio.com/2010-04-01/Accounts/${CONFIG.TWILIO_ACCOUNT_SID}/Messages.json`;

    const response = UrlFetchApp.fetch(twilioUrl, {
      method: 'POST',
      headers: {
        'Authorization': 'Basic ' + Utilities.base64Encode(`${CONFIG.TWILIO_ACCOUNT_SID}:${CONFIG.TWILIO_AUTH_TOKEN}`)
      },
      payload: {
        'To': toNumber,
        'From': CONFIG.TWILIO_PHONE_FROM,
        'Body': message
      },
      muteHttpExceptions: true
    });

    const responseCode = response.getResponseCode();
    if (responseCode >= 200 && responseCode < 300) {
      console.log(`SMS sent to ${toNumber}`);
      return true;
    } else {
      console.error(`Twilio error: ${response.getContentText()}`);
      return false;
    }

  } catch (error) {
    console.error(`Error sending SMS: ${error.message}`);
    return false;
  }
}

function logAlertTriggered(alert, record, message) {
  try {
    // Log to barchart_alert_history
    UrlFetchApp.fetch(
      `${CONFIG.SUPABASE_URL}/rest/v1/barchart_alert_history`,
      {
        method: 'POST',
        headers: {
          'apikey': CONFIG.SUPABASE_ANON_KEY,
          'Authorization': `Bearer ${CONFIG.SUPABASE_ANON_KEY}`,
          'Content-Type': 'application/json'
        },
        payload: JSON.stringify({
          alert_id: alert.id,
          symbol: record.symbol,
          metric: alert.metric,
          condition: alert.condition,
          threshold: alert.threshold,
          actual_value: getMetricValue(alert.metric, record),
          message_text: message,
          phone_number: alert.phone_number || CONFIG.DEFAULT_PHONE_TO,
          delivery_status: 'sent'
        }),
        muteHttpExceptions: true
      }
    );

    // Update alert's last_triggered_at
    UrlFetchApp.fetch(
      `${CONFIG.SUPABASE_URL}/rest/v1/barchart_alerts?id=eq.${alert.id}`,
      {
        method: 'PATCH',
        headers: {
          'apikey': CONFIG.SUPABASE_ANON_KEY,
          'Authorization': `Bearer ${CONFIG.SUPABASE_ANON_KEY}`,
          'Content-Type': 'application/json'
        },
        payload: JSON.stringify({
          last_triggered_at: new Date().toISOString(),
          trigger_count: (alert.trigger_count || 0) + 1
        }),
        muteHttpExceptions: true
      }
    );

  } catch (error) {
    console.error(`Error logging alert: ${error.message}`);
  }
}

function updateAlertLastValue(alert, record) {
  const currentValue = getMetricValue(alert.metric, record);
  if (currentValue === null) return;

  try {
    UrlFetchApp.fetch(
      `${CONFIG.SUPABASE_URL}/rest/v1/barchart_alerts?id=eq.${alert.id}`,
      {
        method: 'PATCH',
        headers: {
          'apikey': CONFIG.SUPABASE_ANON_KEY,
          'Authorization': `Bearer ${CONFIG.SUPABASE_ANON_KEY}`,
          'Content-Type': 'application/json'
        },
        payload: JSON.stringify({
          last_value: currentValue,
          updated_at: new Date().toISOString()
        }),
        muteHttpExceptions: true
      }
    );
  } catch (error) {
    console.error(`Error updating last_value: ${error.message}`);
  }
}

// =====================================================
// SETUP FUNCTIONS - Run these manually once
// =====================================================

/**
 * Sets up a time-based trigger to run every 15 minutes
 * Run this function once manually to set up automatic processing
 */
function setupTrigger() {
  // Remove existing triggers first
  const triggers = ScriptApp.getProjectTriggers();
  for (const trigger of triggers) {
    if (trigger.getHandlerFunction() === 'processNewBarchartEmails') {
      ScriptApp.deleteTrigger(trigger);
    }
  }

  // Create new trigger - every 15 minutes
  ScriptApp.newTrigger('processNewBarchartEmails')
    .timeBased()
    .everyMinutes(15)
    .create();

  console.log('Trigger set up successfully! Will run every 15 minutes.');
}

/**
 * Removes all triggers - use if you need to stop processing
 */
function removeTriggers() {
  const triggers = ScriptApp.getProjectTriggers();
  for (const trigger of triggers) {
    ScriptApp.deleteTrigger(trigger);
  }
  console.log('All triggers removed.');
}

/**
 * Test function - manually process emails without trigger
 */
function testProcessEmails() {
  processNewBarchartEmails();
}

/**
 * Test function - send a test SMS
 */
function testSendSMS() {
  const sent = sendTwilioSMS(CONFIG.DEFAULT_PHONE_TO, '🌾 GRAIN PULSE TEST\nIf you see this, alerts are working!');
  console.log(sent ? 'Test SMS sent!' : 'Test SMS failed.');
}

/**
 * Test function - check your configuration
 */
function testConfig() {
  console.log('=== Configuration Check ===');
  console.log(`Supabase URL: ${CONFIG.SUPABASE_URL.substring(0, 30)}...`);
  console.log(`Supabase Key: ${CONFIG.SUPABASE_ANON_KEY.substring(0, 20)}...`);
  console.log(`Twilio SID: ${CONFIG.TWILIO_ACCOUNT_SID.substring(0, 10)}...`);
  console.log(`Phone From: ${CONFIG.TWILIO_PHONE_FROM}`);
  console.log(`Phone To: ${CONFIG.DEFAULT_PHONE_TO}`);

  // Test Supabase connection
  try {
    const response = UrlFetchApp.fetch(
      `${CONFIG.SUPABASE_URL}/rest/v1/barchart_technicals?limit=1`,
      {
        method: 'GET',
        headers: {
          'apikey': CONFIG.SUPABASE_ANON_KEY,
          'Authorization': `Bearer ${CONFIG.SUPABASE_ANON_KEY}`
        },
        muteHttpExceptions: true
      }
    );
    console.log(`Supabase connection: ${response.getResponseCode() === 200 ? 'OK' : 'FAILED'}`);
  } catch (e) {
    console.log(`Supabase connection: FAILED - ${e.message}`);
  }
}
