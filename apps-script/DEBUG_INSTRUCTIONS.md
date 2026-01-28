# Debugging Grain Pulse Apps Script

## Problem
Barchart data last updated 1/22/26, but script claims to be running. Need to diagnose why emails aren't being processed.

## Steps to Debug

### 1. Access the Apps Script

1. Go to https://script.google.com/home
2. Find your "Grain Pulse" project (or similar name)
3. Click to open it

OR

1. Open Google Sheet at https://docs.google.com/spreadsheets/d/1sSgT70Jd87su7ZUBGQMXOcNolBehzC4vNpBJnH31Ngo/edit
2. Click **Extensions → Apps Script**

### 2. Add This Debug Function

Copy and paste this function at the bottom of your script:

```javascript
/**
 * DEBUG: Check email search and labels
 */
function debugEmailSearch() {
  console.log('=== Email Search Debug ===');

  // Check for emails with the label
  const withLabel = GmailApp.search(CONFIG.EMAIL_SEARCH_QUERY + ' label:' + CONFIG.PROCESSED_LABEL, 0, 10);
  console.log(`Emails WITH GrainPulse/Processed label: ${withLabel.length}`);

  // Check for emails without the label
  const withoutLabel = GmailApp.search(CONFIG.EMAIL_SEARCH_QUERY + ' -label:' + CONFIG.PROCESSED_LABEL, 0, 10);
  console.log(`Emails WITHOUT GrainPulse/Processed label: ${withoutLabel.length}`);

  // Check all emails matching search (no label filter)
  const allEmails = GmailApp.search(CONFIG.EMAIL_SEARCH_QUERY, 0, 10);
  console.log(`Total emails matching search: ${allEmails.length}`);

  // Show details of most recent email
  if (allEmails.length > 0) {
    const thread = allEmails[0];
    const message = thread.getMessages()[thread.getMessages().length - 1];
    console.log('\n=== Most Recent Email ===');
    console.log(`Subject: ${message.getSubject()}`);
    console.log(`Date: ${message.getDate()}`);
    console.log(`From: ${message.getFrom()}`);
    console.log(`Labels: ${thread.getLabels().map(l => l.getName()).join(', ') || 'None'}`);

    // Check attachments
    const attachments = message.getAttachments();
    console.log(`Attachments: ${attachments.length}`);
    attachments.forEach(att => {
      console.log(`  - ${att.getName()} (${att.getContentType()})`);
    });
  }

  // Check if label exists
  const label = GmailApp.getUserLabelByName(CONFIG.PROCESSED_LABEL);
  console.log(`\nLabel "${CONFIG.PROCESSED_LABEL}" exists: ${label !== null}`);

  // Search variations
  console.log('\n=== Search Variations ===');
  const search1 = GmailApp.search('from:noreply@barchart.com', 0, 5);
  console.log(`Any Barchart emails (last 7 days): ${search1.length}`);

  const search2 = GmailApp.search('from:noreply@barchart.com has:attachment', 0, 5);
  console.log(`Barchart emails with attachments: ${search2.length}`);

  const search3 = GmailApp.search('from:noreply@barchart.com subject:Watchlist', 0, 5);
  console.log(`Barchart "Watchlist" emails: ${search3.length}`);
}
```

### 3. Run the Debug Function

1. In the script editor, select `debugEmailSearch` from the function dropdown at the top
2. Click the **Run** button (▶️)
3. If prompted, authorize the script
4. Click **View → Logs** (or Ctrl/Cmd + Enter)
5. Copy the log output and share it

### 4. Check Execution History

1. In the script editor, click the **clock icon** (⏱️) on the left sidebar
2. Look at recent executions of `processNewBarchartEmails`
3. Click on any execution to see:
   - Status (Success/Failed)
   - Logs
   - Error messages
4. Share any error messages you see

### 5. Check Triggers

1. In the script editor, click the **clock icon** (⏱️) then switch to **Triggers** tab
2. Verify there's an active trigger for `processNewBarchartEmails`
3. Check:
   - Is it enabled?
   - When does it run? (should be every 15 minutes)
   - When was last run?
   - Any failures?

## Common Fixes

### Fix 1: Remove All Processed Labels

If all emails are labeled as "processed" and you want to reprocess them:

```javascript
function removeAllProcessedLabels() {
  const threads = GmailApp.search('label:' + CONFIG.PROCESSED_LABEL);
  const label = GmailApp.getUserLabelByName(CONFIG.PROCESSED_LABEL);

  if (label) {
    console.log(`Removing label from ${threads.length} threads...`);
    for (const thread of threads) {
      thread.removeLabel(label);
    }
    console.log('Done!');
  }
}
```

Run this, then run `testProcessEmails()` to reprocess recent emails.

### Fix 2: Force Process Latest Email

If you want to manually process the most recent email regardless of labels:

```javascript
function forceProcessLatestEmail() {
  // Search for ANY Barchart email (ignore label)
  const threads = GmailApp.search('from:noreply@barchart.com subject:"Watchlist Summary" has:attachment', 0, 1);

  if (threads.length === 0) {
    console.log('No emails found!');
    return;
  }

  const thread = threads[0];
  const messages = thread.getMessages();
  const latestMessage = messages[messages.length - 1];

  console.log(`Force processing: ${latestMessage.getSubject()}`);
  console.log(`Date: ${latestMessage.getDate()}`);

  // Get CSV attachment
  const attachments = latestMessage.getAttachments();
  const csvAttachment = attachments.find(a =>
    a.getName().toLowerCase().endsWith('.csv')
  );

  if (!csvAttachment) {
    console.log('No CSV found!');
    return;
  }

  // Parse CSV
  const csvData = csvAttachment.getDataAsString();
  const records = parseCSV(csvData);

  console.log(`Parsed ${records.length} records`);

  // Update Supabase
  const emailDate = latestMessage.getDate();
  const snapshotType = getSnapshotType(emailDate);
  const results = updateSupabase(records, emailDate, snapshotType);

  console.log(`Updated ${results.success} records, ${results.failed} failed`);
}
```

### Fix 3: Check if Email Subject Changed

If Barchart changed their email format:

1. Go to your Gmail
2. Find recent Barchart emails
3. Check the exact subject line
4. Update `CONFIG.EMAIL_SEARCH_QUERY` in the script if different

## What to Share

After running the debug function, share:

1. **Log output** from `debugEmailSearch()`
2. **Recent execution logs** (last 5 executions of `processNewBarchartEmails`)
3. **Any error messages** from failed executions
4. **Trigger status** - is it active? when did it last run?

This will help identify exactly why emails stopped being processed.
