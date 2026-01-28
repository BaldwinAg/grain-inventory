// Add this function to your Apps Script to debug CSV parsing

function debugLatestEmail() {
  console.log('=== Debugging Latest Barchart Email ===');

  const threads = GmailApp.search('from:noreply@barchart.com subject:Watchlist has:attachment newer_than:1d', 0, 1);

  if (threads.length === 0) {
    console.log('No recent emails found!');
    return;
  }

  const thread = threads[0];
  const messages = thread.getMessages();
  const latestMessage = messages[messages.length - 1];

  console.log(`Email Date: ${latestMessage.getDate()}`);
  console.log(`Subject: ${latestMessage.getSubject()}`);

  const attachments = latestMessage.getAttachments();
  const csvAttachment = attachments.find(a => a.getName().toLowerCase().endsWith('.csv'));

  if (!csvAttachment) {
    console.log('No CSV found!');
    return;
  }

  const csvData = csvAttachment.getDataAsString();
  const lines = csvData.trim().split('\n');

  console.log('\n=== CSV HEADER ===');
  console.log(lines[0]);

  console.log('\n=== FIRST DATA ROW (raw) ===');
  console.log(lines[1]);

  console.log('\n=== PARSED RECORDS ===');
  const records = parseCSV(csvData);

  records.slice(0, 3).forEach(record => {
    console.log(`\nSymbol: ${record.symbol}`);
    console.log(`Name: ${record.name}`);
    console.log(`Latest Price: ${record.latest_price}`);
    console.log(`Price Change: ${record.price_change}`);
    console.log(`RSI: ${record.rsi_14d}`);
  });
}
