# Quick Fix - Reprocess Recent Emails

## Problem
Script reports "No new Barchart emails found" because all emails are already labeled as processed.

## Solution
Remove the "GrainPulse/Processed" label from recent emails, then reprocess them.

---

## Step 1: Add This Function to Your Script

Open your Apps Script editor and paste this function:

```javascript
/**
 * QUICK FIX: Remove processed labels from recent Barchart emails
 * This will allow them to be processed again
 */
function removeProcessedLabelsFromRecentEmails() {
  console.log('Removing processed labels from recent Barchart emails...');

  // Find recent Barchart emails that have been processed
  const threads = GmailApp.search(
    'from:noreply@barchart.com subject:Watchlist has:attachment label:GrainPulse/Processed newer_than:14d',
    0,
    20
  );

  console.log(`Found ${threads.length} processed emails from last 14 days`);

  if (threads.length === 0) {
    console.log('No processed emails found. Checking if any Barchart emails exist at all...');

    const anyBarchart = GmailApp.search('from:noreply@barchart.com subject:Watchlist has:attachment newer_than:14d', 0, 5);
    console.log(`Total Barchart emails (last 14 days): ${anyBarchart.length}`);

    if (anyBarchart.length > 0) {
      console.log('Emails exist but are not labeled as processed. Try running testProcessEmails() now.');
    } else {
      console.log('No Barchart emails found in last 14 days. Check:');
      console.log('1. Email address: noreply@barchart.com');
      console.log('2. Subject contains: Watchlist');
      console.log('3. Has CSV attachment');
    }
    return;
  }

  // Get the label
  const label = GmailApp.getUserLabelByName('GrainPulse/Processed');

  if (!label) {
    console.log('Label "GrainPulse/Processed" does not exist - emails should be ready to process!');
    return;
  }

  // Remove label from all threads
  let removed = 0;
  for (const thread of threads) {
    thread.removeLabel(label);
    removed++;

    // Show details of first email
    if (removed === 1) {
      const message = thread.getMessages()[thread.getMessages().length - 1];
      console.log(`\nMost recent email:`);
      console.log(`  Subject: ${message.getSubject()}`);
      console.log(`  Date: ${message.getDate()}`);
      console.log(`  From: ${message.getFrom()}`);
    }
  }

  console.log(`\nRemoved label from ${removed} emails.`);
  console.log('Now run testProcessEmails() to process them.');
}
```

---

## Step 2: Run the Function

1. In Apps Script editor, select `removeProcessedLabelsFromRecentEmails` from function dropdown
2. Click **Run** (▶️)
3. Check the logs (View → Logs or Ctrl/Cmd + Enter)
4. You should see how many emails had labels removed

---

## Step 3: Reprocess Emails

1. Select `testProcessEmails` from function dropdown
2. Click **Run** (▶️)
3. Check logs - should see "Found X new email(s) to process"
4. Should see "Updated X records"

---

## Step 4: Verify in Supabase

Check your Supabase dashboard:
- Go to Table Editor → barchart_technicals
- Look at the `updated_at` column
- Should see today's date (2026-01-27) on multiple rows

---

## If Still No Emails Found

If you still see "No new Barchart emails found", run this diagnostic:

```javascript
function checkEmailFormat() {
  console.log('=== Checking Email Format ===');

  // Search for ANY Barchart emails (no filters)
  const threads = GmailApp.search('from:noreply@barchart.com newer_than:7d', 0, 5);

  console.log(`Found ${threads.length} Barchart emails in last 7 days`);

  if (threads.length === 0) {
    console.log('\nNo Barchart emails found at all!');
    console.log('Check your Gmail for emails from: noreply@barchart.com');
    return;
  }

  // Check each email
  for (let i = 0; i < threads.length; i++) {
    const thread = threads[i];
    const message = thread.getMessages()[thread.getMessages().length - 1];

    console.log(`\n--- Email ${i + 1} ---`);
    console.log(`From: ${message.getFrom()}`);
    console.log(`Subject: ${message.getSubject()}`);
    console.log(`Date: ${message.getDate()}`);

    const attachments = message.getAttachments();
    console.log(`Attachments: ${attachments.length}`);

    if (attachments.length > 0) {
      attachments.forEach(att => {
        console.log(`  - ${att.getName()}`);
      });
    }

    // Check if subject contains "Watchlist"
    const hasWatchlist = message.getSubject().toLowerCase().includes('watchlist');
    console.log(`Has "Watchlist" in subject: ${hasWatchlist}`);

    // Check if has CSV
    const hasCsv = attachments.some(a => a.getName().toLowerCase().endsWith('.csv'));
    console.log(`Has CSV attachment: ${hasCsv}`);
  }
}
```

This will show you:
- The exact subject line of recent emails
- Whether they have attachments
- Whether they match your search criteria

---

## Common Issues

### Issue: Subject line changed
**Fix:** If the subject doesn't contain "Watchlist Summary", update the CONFIG:

```javascript
const CONFIG = {
  // ... other config ...
  EMAIL_SEARCH_QUERY: 'from:noreply@barchart.com subject:"New Subject Here" has:attachment',
  // ...
};
```

### Issue: Sender email changed
**Fix:** If emails come from a different address, update the search query.

### Issue: No attachments
**Fix:** Check if Barchart changed their email format - they might not be sending CSV attachments anymore.

---

## Expected Output

After running `removeProcessedLabelsFromRecentEmails()` and then `testProcessEmails()`, you should see:

```
Starting Grain Pulse email processing...
Found 5 new email(s) to process.
Processing: Watchlist Summary
Parsed 12 records from CSV.
Updated 12 records, 0 failed.
Grain Pulse processing complete.
```

Then check Supabase - the `updated_at` timestamps should be current.
