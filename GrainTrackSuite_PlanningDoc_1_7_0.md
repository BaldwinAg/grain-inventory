# GrainTrack Suite v1.7.0 Planning Document
## POY Import, Inventory Adjustments & Transfers

**Created:** January 22, 2026  
**Status:** Ready for development  
**Previous Version:** v1.6.0 (Barchart Integration, Basis Management)

---

## Overview

v1.7.0 adds three major inventory management capabilities:

1. **POY Import** - Import grain delivery data from elevator Proof of Yield PDFs using Claude API
2. **Inventory Adjustments** - Record shrink, reconciliation, and other adjustments
3. **Transfers** - Track grain moving between parties (swaps with family, etc.)

### Building on v1.6.0

v1.6.0 introduced:
- Barchart/Grain Pulse integration for futures prices and technical indicators
- Basis management with `location_basis` table
- Current inventory uses `grain_inventory` table (balance only, no transaction history)

v1.7.0 adds:
- `inventory_transactions` table for full audit trail
- Transaction history view per location/commodity
- POY import with ticket-level duplicate detection
- Adjustment and transfer functionality

---

## Feature 1: Proof of Yield Import

### Business Problem

Currently, users must manually enter production and inventory data. Elevators provide "Proof of Yield" reports with all this data, but in PDF format. Manual transcription is time-consuming and error-prone.

### Solution

Use Claude API (via PHP proxy) to parse uploaded PDF files and extract structured delivery data, then import into inventory with proper dates and ticket-level duplicate detection.

---

## Business Problem

Currently, users must manually enter:
1. Production actuals (total bushels harvested)
2. Inventory deposits (bushels at each storage location)

Elevators provide "Proof of Yield" reports with all this data, but in PDF format with complex layouts. Manual transcription is time-consuming and error-prone.

---

## Solution

Use Claude API (via Anthropic) to parse uploaded PDF/CSV files and extract structured delivery data, then import into GrainTrack's inventory system with proper dates and locations.

---

## Data Structure from Producer Ag POY Report

### PDF Layout
```
COMMODITY @ LOCATION BUSHELS
Ticket# | Date | Crop Year | Gross | Tare | Scale | Dock | Net | Net Units | Discount$ | Factors
        Customer Portion: [lbs] | [dock] | [net lbs] | [bushels] | [discount$]

[Repeats for each ticket]

Commodity Totals: ...
Customer Portion Totals: [total lbs] | [total bushels] | [total discount$]
```

### Sample Extracted Data (Adam Baldwin's Share)

| Date | Commodity | Location | Tickets | Your Bushels |
|------|-----------|----------|---------|--------------|
| 9/4-9/9/2025 | Corn | Groveland | 5 | 4,369.65 |
| 10/1-10/2/2025 | Corn | Groveland | 26 | 9,843.23 |
| 10/1-10/2/2025 | Corn | Groveland Bunker | 11 | 4,519.61 |
| 10/4/2025 | Corn | Groveland | 6 | 2,046.95 |
| 10/4/2025 | Corn | Groveland Bunker | 5 | 1,562.44 |
| 10/8-10/11/2025 | Corn | Groveland | 22 | 10,881.94 |
| 10/8-10/11/2025 | Corn | Groveland Bunker | 15 | 8,046.11 |
| 10/13-10/17/2025 | Corn | Groveland | 13 | 6,262.22 |
| 10/22/2025 | Corn | Groveland | 1 | 178.75 |
| 10/15-10/21/2025 | Soybeans | Groveland | 12 | 3,880.14 |
| 10/20/2025 | Soybeans | Groveland | 8 | 2,669.43 |
| 11/5-11/10/2025 | Soybeans | Groveland | 24 | 11,130.10 |
| 11/7/2025 | Soybeans | Canton Terminal | 4 | 2,910.58 |
| 11/15-11/17/2025 | Milo | Groveland | 22 | 10,985.97 |

### Totals Summary
| Commodity | Total (Your Share) |
|-----------|--------------------|
| Corn | 57,357.30 bu |
| Soybeans | 20,590.25 bu |
| Milo | 10,985.97 bu |
| **TOTAL** | **88,933.52 bu** |

---

## Feature Design

### User Flow

1. **Navigate to Inventory page** (or new "Import" page)
2. **Click "Import Proof of Yield"** button
3. **Upload file** (PDF, CSV, or image)
4. **System processes** via Claude API
5. **Preview extracted data** in table format:
   - Date, Commodity, Location, Bushels, Ticket Count
   - Show any unmatched locations for user to map
6. **Map locations** (one-time): Match elevator names to GrainTrack locations
   - "Groveland" → Select from dropdown
   - "Groveland Bunker" → Select from dropdown
   - "Canton Terminal" → Select from dropdown
7. **Choose import mode:**
   - ☑️ Create inventory deposits (with actual dates)
   - ☑️ Update production actuals (total per commodity)
8. **Confirm and import**
9. **Show success summary** with totals

### Location Mapping

Elevator names in POY don't match GrainTrack location names exactly. Solution:

```sql
-- New table to store elevator name → GrainTrack location mappings
CREATE TABLE IF NOT EXISTS elevator_location_mappings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    elevator_name VARCHAR(200) NOT NULL UNIQUE,
    location_id UUID REFERENCES grain_locations(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

Once mapped, future imports auto-match.

### API Integration

**PHP Proxy Approach (Secure)**

API key stays server-side, never exposed to browser or stored in database.

**File structure:**
```
/portal/grain/
├── index.html          (the app)
├── .htaccess
└── api/
    ├── config.php      (API key - NOT in version control)
    └── claude-proxy.php
```

**config.php** (create manually on server, never commit):
```php
<?php
define('ANTHROPIC_KEY', 'sk-ant-api03-xxxxx');
```

**claude-proxy.php**:
```php
<?php
require_once 'config.php';

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

// Handle preflight
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    die(json_encode(['error' => 'POST only']));
}

$input = file_get_contents('php://input');

$ch = curl_init('https://api.anthropic.com/v1/messages');
curl_setopt_array($ch, [
    CURLOPT_POST => true,
    CURLOPT_POSTFIELDS => $input,
    CURLOPT_RETURNTRANSFER => true,
    CURLOPT_HTTPHEADER => [
        'Content-Type: application/json',
        'x-api-key: ' . ANTHROPIC_KEY,
        'anthropic-version: 2023-06-01'
    ]
]);

$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

http_response_code($httpCode);
echo $response;
```

**JavaScript call from app:**
```javascript
async function parseWithClaude(file) {
  const base64 = await fileToBase64(file);
  
  const response = await fetch('/portal/grain/api/claude-proxy.php', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      model: 'claude-sonnet-4-20250514',
      max_tokens: 4096,
      messages: [{
        role: 'user',
        content: [
          {
            type: 'document',
            source: {
              type: 'base64',
              media_type: 'application/pdf',
              data: base64
            }
          },
          {
            type: 'text',
            text: EXTRACTION_PROMPT
          }
        ]
      }]
    })
  });
  
  const data = await response.json();
  return JSON.parse(data.content[0].text);
}
```
```

---

## Database Changes

### Existing Tables (from v1.6.0)
- `grain_inventory` - Current balance per location/commodity/crop_year
- `grain_locations` - Storage locations  
- `location_basis` - Basis by location/commodity/crop_year
- `barchart_technicals` - Futures prices from Grain Pulse

### New Tables for v1.7.0

```sql
-- Full transaction audit trail (supplements grain_inventory balance)
CREATE TABLE IF NOT EXISTS inventory_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    location_id UUID NOT NULL REFERENCES grain_locations(id),
    commodity_id UUID NOT NULL REFERENCES commodities(id),
    crop_year INTEGER NOT NULL,
    transaction_type VARCHAR(20) NOT NULL,  -- DEPOSIT, WITHDRAWAL, SALE, TRANSFER_IN, TRANSFER_OUT, SHRINK, RECONCILIATION
    bushels DECIMAL(12,2) NOT NULL,  -- positive for in, negative for out
    transaction_date DATE NOT NULL DEFAULT CURRENT_DATE,
    counterparty VARCHAR(200),  -- For transfers: who grain went to/from
    reason VARCHAR(500),  -- For shrink/reconciliation: explanation
    ticket_number VARCHAR(50),  -- For POY imports: elevator ticket #
    linked_contract_id UUID REFERENCES contracts(id),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_inv_trans_location ON inventory_transactions(location_id, commodity_id, crop_year);
CREATE INDEX idx_inv_trans_date ON inventory_transactions(transaction_date);

-- Map elevator names to GrainTrack locations
CREATE TABLE IF NOT EXISTS elevator_location_mappings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    elevator_name VARCHAR(200) NOT NULL UNIQUE,
    location_id UUID REFERENCES grain_locations(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Track imports for duplicate detection
CREATE TABLE IF NOT EXISTS poy_imports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    file_name VARCHAR(500),
    crop_year INTEGER NOT NULL,
    producer_name VARCHAR(200),
    total_bushels_imported DECIMAL(12,2),
    commodities_imported TEXT[],
    import_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    raw_response JSONB
);

-- Track every imported ticket to prevent duplicates
CREATE TABLE IF NOT EXISTS imported_tickets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ticket_number VARCHAR(50) NOT NULL,
    import_id UUID REFERENCES poy_imports(id),
    delivery_date DATE,
    commodity_id UUID REFERENCES commodities(id),
    location_id UUID REFERENCES grain_locations(id),
    bushels DECIMAL(12,2),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(ticket_number)  -- Can't import same ticket twice
);

-- RLS policies
ALTER TABLE inventory_transactions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow all on inventory_transactions" ON inventory_transactions FOR ALL USING (true) WITH CHECK (true);
GRANT ALL ON inventory_transactions TO anon, authenticated;

ALTER TABLE elevator_location_mappings ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow all on elevator_location_mappings" ON elevator_location_mappings FOR ALL USING (true) WITH CHECK (true);
GRANT ALL ON elevator_location_mappings TO anon, authenticated;

ALTER TABLE poy_imports ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow all on poy_imports" ON poy_imports FOR ALL USING (true) WITH CHECK (true);
GRANT ALL ON poy_imports TO anon, authenticated;

ALTER TABLE imported_tickets ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow all on imported_tickets" ON imported_tickets FOR ALL USING (true) WITH CHECK (true);
GRANT ALL ON imported_tickets TO anon, authenticated;
```

Note: API key is stored in PHP config file on server, not in database.

### Inventory Strategy
- `grain_inventory` remains the **balance table** (current bushels per location/commodity)
- `inventory_transactions` is the **audit trail** (history of all movements)
- When adding/removing grain, update BOTH tables
- Balance = sum of all transactions (can verify against grain_inventory)

---

## Transaction Types Reference

| Type | Use Case | Bushels | Counterparty |
|------|----------|---------|--------------|
| `DEPOSIT` | Grain delivered to storage (harvest, POY import) | + | Elevator name |
| `WITHDRAWAL` | Grain physically removed | - | - |
| `SALE` | Grain sold against contract | - | Buyer name |
| `TRANSFER_IN` | Receive grain from another party | + | Who it came from |
| `TRANSFER_OUT` | Give grain to another party | - | Who it went to |
| `SHRINK` | Moisture loss, handling loss | - | - |
| `RECONCILIATION` | Physical count adjustment | +/- | - |

-- For POY imports, we'll create DEPOSIT transactions with:
-- - transaction_date = actual delivery date from POY
-- - notes = "POY Import: Ticket #XXXX" or "POY Import: 5 tickets"
-- - ticket_number = for duplicate detection
```

---

## Feature 2: Inventory Adjustments

### Use Cases

1. **Shrink** - Grain loses weight over time due to moisture loss and handling
   - Typically 1-3% for on-farm storage
   - Record when doing physical inventory count

2. **Reconciliation** - Physical count doesn't match book records
   - Could be positive (found more than expected) or negative
   - Measurement errors at harvest, scale calibration issues

### Adjustment Flow

1. User selects location and commodity
2. System shows current book balance
3. User enters new physical count OR adjustment amount
4. System calculates difference and % change
5. User provides reason
6. System creates SHRINK or RECONCILIATION transaction

### Business Rules

- Shrink transactions are always negative
- Reconciliation can be positive or negative
- Both require a reason/note for audit trail
- Display as separate line items in transaction history

---

## Feature 3: Transfers

### Use Cases

1. **Transfer Out** - Give grain to another party
   - Dad deposits his grain in my on-farm bin
   - I transfer ownership of commercial storage to him
   - Net: I now own the on-farm grain, he owns the commercial grain

2. **Transfer In** - Receive grain from another party
   - Taking possession of grain someone else stored
   - Family swaps, partnership arrangements

3. **Swap Transaction** - Simultaneous transfer in + transfer out
   - Most common scenario for family operations
   - Creates two linked transactions for clean paper trail

### The "Dad Swap" Example

**Scenario:** Dad puts 5,000 bu corn in my on-farm bin. I transfer him 5,000 bu from my commercial storage at ADM.

**Transactions created:**

| Date | Type | Location | Bushels | Counterparty | Notes |
|------|------|----------|---------|--------------|-------|
| 1/15 | TRANSFER_IN | On-Farm Bin | +5,000 | Dwight Baldwin | Dad's corn deposited to my bin |
| 1/15 | TRANSFER_OUT | ADM Lyons | -5,000 | Dwight Baldwin | Swapped for on-farm grain |

**Result:**
- My on-farm inventory: +5,000 bu
- My ADM inventory: -5,000 bu
- My total inventory: unchanged
- Clear paper trail of the swap

### Transfer Business Rules

- Counterparty is required for all transfers
- TRANSFER_IN is always positive bushels
- TRANSFER_OUT is always negative bushels
- Swaps create two transactions with same date and counterparty
- Commodity and crop year must match for swaps

---

## UI Components

### Inventory Page Action Buttons

```
┌─────────────────────────────────────────────────────────────────┐
│ Inventory                                          2025 ▼       │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│ [📄 Import POY]  [± Adjust]  [↔ Transfer]  [+ Add Grain]        │
│                                                                 │
│ ┌─────────────────────────────────────────────────────────────┐ │
│ │ Location          │ Commodity │ Bushels  │ Last Activity    │ │
│ ├───────────────────┼───────────┼──────────┼──────────────────┤ │
│ │ On-Farm Bin #1    │ Corn      │ 12,450   │ 2025-10-15       │ │
│ │ ADM Lyons         │ Corn      │ 25,000   │ 2025-10-20       │ │
│ │ Producer Ag       │ Soybeans  │ 18,500   │ 2025-11-05       │ │
│ └───────────────────┴───────────┴──────────┴──────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

### Import POY Modal
```
┌─────────────────────────────────────────────────────────────────┐
│ Import Proof of Yield                                     [X]   │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │     📄 Drop PDF here or click to browse                 │   │
│  │                                                         │   │
│  │     Supported: PDF, CSV, PNG/JPG (scale tickets)        │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  [Processing... ████████░░ 80%]                                 │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Preview/Mapping Screen
```
┌─────────────────────────────────────────────────────────────────┐
│ Import Preview - 2025 Crop Year                           [X]   │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│ Map Locations:                                                  │
│ ┌───────────────────┬─────────────────────────────────────────┐│
│ │ Groveland         │ [▼ Producer Ag - Groveland           ]  ││
│ │ Groveland Bunker  │ [▼ On-Farm Bunker                    ]  ││
│ │ Canton Terminal   │ [▼ Producer Ag - Canton              ]  ││
│ └───────────────────┴─────────────────────────────────────────┘│
│                                                                 │
│ Deliveries to Import:                                           │
│ ┌────────────┬───────────┬──────────────────┬─────────────────┐│
│ │ Date       │ Commodity │ Location         │ Your Bushels    ││
│ ├────────────┼───────────┼──────────────────┼─────────────────┤│
│ │ 2025-10-01 │ Corn      │ Groveland        │ 5,043.23        ││
│ │ 2025-10-01 │ Corn      │ Groveland Bunker │ 2,719.61        ││
│ │ 2025-10-02 │ Corn      │ Groveland        │ 4,800.00        ││
│ │ ...        │ ...       │ ...              │ ...             ││
│ └────────────┴───────────┴──────────────────┴─────────────────┘│
│                                                                 │
│ Summary:                                                        │
│   Corn: 57,357.30 bu | Soybeans: 20,590.25 bu | Milo: 10,985 bu│
│   Total: 88,933.52 bu                                           │
│                                                                 │
│ Import Options:                                                 │
│   ☑️ Create inventory deposits (with delivery dates)            │
│   ☑️ Update production actuals                                  │
│                                                                 │
│                              [Cancel]  [Import 178 Transactions]│
└─────────────────────────────────────────────────────────────────┘
```

### Adjust Inventory Modal
```
┌─────────────────────────────────────────────────────────────────┐
│ Adjust Inventory                                          [X]   │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│ Location:     [▼ On-Farm Bin #1                         ]       │
│ Commodity:    [▼ Corn                                   ]       │
│ Crop Year:    [▼ 2025                                   ]       │
│                                                                 │
│ Current Book Balance: 12,450 bu                                 │
│                                                                 │
│ Adjustment Type:                                                │
│   ○ Shrink (moisture/handling loss)                             │
│   ○ Reconciliation (physical count doesn't match)               │
│                                                                 │
│ ┌─────────────────────────────────────────────────────────────┐ │
│ │ Enter new physical count:  [12,200          ] bu            │ │
│ │                        OR                                   │ │
│ │ Enter adjustment amount:   [-250            ] bu            │ │
│ └─────────────────────────────────────────────────────────────┘ │
│                                                                 │
│ Change: -250 bu (2.0% shrink)                                   │
│                                                                 │
│ Reason: [2% moisture shrink over winter storage     ]           │
│ Date:   [2026-01-15                                 ]           │
│                                                                 │
│                                [Cancel]  [Save Adjustment]      │
└─────────────────────────────────────────────────────────────────┘
```

### Transfer Modal
```
┌─────────────────────────────────────────────────────────────────┐
│ Transfer Grain                                            [X]   │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│ Transfer Type:                                                  │
│   ○ Transfer In (receive grain from someone)                    │
│   ○ Transfer Out (give grain to someone)                        │
│   ● Swap (exchange grain with someone)                          │
│                                                                 │
│ ═══════════════════════════════════════════════════════════════ │
│                                                                 │
│ Counterparty: [Dwight Baldwin                           ]       │
│ Date:         [2026-01-15                               ]       │
│ Commodity:    [▼ Corn                                   ]       │
│ Crop Year:    [▼ 2025                                   ]       │
│                                                                 │
│ ── I'M RECEIVING ──────────────────────────────────────────     │
│ Location:  [▼ On-Farm Bin #1                    ]               │
│ Bushels:   [5,000                               ]               │
│                                                                 │
│ ── I'M GIVING ─────────────────────────────────────────────     │
│ Location:  [▼ ADM Lyons                         ]               │
│ Bushels:   [5,000                               ] (auto-match)  │
│                                                                 │
│ Notes: [Swapped commercial storage for Dad's grain  ]           │
│                                                                 │
│ Summary:                                                        │
│   On-Farm Bin #1: +5,000 bu                                     │
│   ADM Lyons:      -5,000 bu                                     │
│   Net change:      0 bu                                         │
│                                                                 │
│                                [Cancel]  [Record Transfer]      │
└─────────────────────────────────────────────────────────────────┘
```

### Transaction History View (expandable from inventory row)
```
┌─────────────────────────────────────────────────────────────────┐
│ On-Farm Bin #1 - Corn (2025)                    Balance: 12,200 │
├─────────────────────────────────────────────────────────────────┤
│ Date       │ Type          │ Bushels  │ Counterparty │ Notes    │
├────────────┼───────────────┼──────────┼──────────────┼──────────┤
│ 2025-10-15 │ DEPOSIT       │ +7,450   │ -            │ POY: 5tk │
│ 2025-10-20 │ DEPOSIT       │ +5,000   │ -            │ POY: 3tk │
│ 2026-01-15 │ TRANSFER_IN   │ +5,000   │ D. Baldwin   │ Dad swap │
│ 2026-01-15 │ SHRINK        │ -250     │ -            │ 2% moist │
│ 2026-01-20 │ TRANSFER_OUT  │ -5,000   │ D. Baldwin   │ Dad swap │
└─────────────┴───────────────┴──────────┴──────────────┴──────────┘
```

---

## Import Logic

### Granularity Options

**Option A: One transaction per ticket**
- Most granular audit trail
- 178 transactions for Adam's 2025 harvest
- Matches elevator records exactly

**Option B: One transaction per date/location/commodity**
- Aggregates same-day deliveries
- ~30-40 transactions
- Cleaner inventory view
- Notes field lists ticket numbers

**Recommended: Option B** (cleaner, still has audit trail via ticket # in notes)

### Algorithm

```javascript
async function importPOY(file, mappings, options) {
  // 1. Send file to Claude API
  const extracted = await parseWithClaude(file);
  
  // 2. Check for duplicate tickets
  const existingTickets = await getExistingTickets(extracted.deliveries.map(d => d.ticket_number));
  const duplicates = extracted.deliveries.filter(d => existingTickets.includes(d.ticket_number));
  
  if (duplicates.length > 0) {
    // Show warning: "X tickets already imported: BI 110366, BI 110377..."
    // Let user choose: Skip duplicates / Cancel import
    if (!options.skipDuplicates) {
      throw new Error(`${duplicates.length} tickets already imported`);
    }
  }
  
  // 3. Filter out duplicates
  const newDeliveries = extracted.deliveries.filter(d => !existingTickets.includes(d.ticket_number));
  
  // 4. Group by date + location + commodity
  const grouped = groupDeliveries(newDeliveries);
  
  // 5. Create import record first (for linking tickets)
  const importId = await createImportRecord(file.name, extracted);
  
  // 6. For each group, create inventory transaction
  for (const group of grouped) {
    const locationId = mappings[group.location];
    const commodityId = await getCommodityByName(group.commodity);
    
    if (options.createInventory) {
      await createInventoryTransaction({
        location_id: locationId,
        commodity_id: commodityId,
        crop_year: extracted.crop_year,
        transaction_type: 'DEPOSIT',
        bushels: Math.round(group.total_bushels),
        transaction_date: group.date,
        notes: `POY Import: ${group.ticket_count} tickets (${group.ticket_numbers.join(', ')})`
      });
      
      // 7. Record each ticket to prevent future duplicates
      for (const ticket of group.tickets) {
        await recordImportedTicket({
          ticket_number: ticket.ticket_number,
          import_id: importId,
          delivery_date: ticket.date,
          commodity_id: commodityId,
          location_id: locationId,
          bushels: ticket.bushels
        });
      }
    }
  }
  
  // 8. Optionally update production actuals
  if (options.updateProduction) {
    for (const [commodity, totalBu] of Object.entries(extracted.totals_by_commodity)) {
      // Update field_crop_years.actual_yield for this commodity
      // This may need user input to allocate across fields
    }
  }
  
  return { 
    imported: newDeliveries.length,
    skipped: duplicates.length,
    totalBushels: newDeliveries.reduce((sum, d) => sum + d.bushels, 0)
  };
}
```

### Duplicate Detection Query

```javascript
async function getExistingTickets(ticketNumbers) {
  const { data } = await supabase
    .from('imported_tickets')
    .select('ticket_number')
    .in('ticket_number', ticketNumbers);
  
  return data?.map(t => t.ticket_number) || [];
}
```

---

## Cost Estimate

Claude API pricing (as of Jan 2026):
- Claude Haiku: ~$0.25/M input, $1.25/M output
- Claude Sonnet: ~$3/M input, $15/M output

A typical POY PDF (11 pages, ~15KB text):
- Input: ~5,000 tokens
- Output: ~2,000 tokens
- Cost per import: **~$0.05-0.10** (Sonnet) or **~$0.01** (Haiku)

Annual cost for 10-20 imports: **<$2**

---

## Error Handling

1. **API call fails**
   - Show error message with retry button
   - Log error for debugging
   - Check if PHP proxy is accessible

2. **Unrecognized location**
   - Prompt user to map before import
   - Store mapping for future imports

3. **Duplicate tickets detected**
   - Show list of already-imported ticket numbers
   - Options: "Skip duplicates and continue" or "Cancel"
   - Prevents double-counting grain

4. **Parsing errors**
   - Show what Claude returned
   - Allow manual editing before import

---

## Files to Create

1. `graintrack_1_7_0.html` - Complete app with POY import, adjustments, transfers (build on graintrack_1_6_0.html)
2. `migration_1_7_0.sql` - New tables (inventory_transactions, elevator_location_mappings, poy_imports, imported_tickets)
3. `claude-proxy.php` - PHP proxy for Anthropic API calls
4. `CHANGELOG_1_7_0.md` - Release notes

**Manual setup on server:**
- Create `/portal/grain/api/` folder
- Create `config.php` with: `<?php define('ANTHROPIC_KEY', 'sk-ant-xxxxx');`
- Upload `claude-proxy.php` to `/portal/grain/api/`

**Starting Point:**
Use `graintrack_1_6_0.html` from the project files as the base. Preserve all existing functionality including Barchart integration and Basis management.

---

## Testing Checklist

### POY Import
- [ ] PHP proxy responds (test with curl)
- [ ] Upload PDF, verify Claude extracts data correctly
- [ ] Map new elevator location to GrainTrack location
- [ ] Verify mapped location is remembered for future imports
- [ ] Import creates inventory transactions with correct dates
- [ ] Import creates transactions with correct bushel amounts (your share)
- [ ] Duplicate ticket detection works (re-import same file, get warning)
- [ ] Skip duplicates option works
- [ ] Ticket numbers stored in imported_tickets table
- [ ] Verify totals match POY report totals

### Inventory Adjustments
- [ ] Shrink adjustment reduces inventory
- [ ] Shrink shows % calculation
- [ ] Reconciliation can be positive or negative
- [ ] Reason/note is required
- [ ] Transaction appears in history with correct type

### Transfers
- [ ] Transfer In adds to inventory
- [ ] Transfer Out removes from inventory
- [ ] Counterparty is required
- [ ] Swap creates two linked transactions (TRANSFER_IN + TRANSFER_OUT)
- [ ] Swap auto-matches bushels
- [ ] Transaction history shows counterparty

### General
- [ ] Transaction history is expandable per location/commodity
- [ ] All transaction types display correctly
- [ ] Inventory totals calculate correctly across all transaction types

---

## Future Enhancements (v1.8+)

1. **Scale ticket photo upload** - Take photo of paper ticket, Claude extracts data
2. **Auto-fetch from elevator portal** - If elevator has API (unlikely)
3. **Allocate to fields** - Distribute production across fields by expected yield ratio
4. **Quality data tracking** - Store moisture, test weight, dockage per delivery
5. **Settlement sheet parsing** - Extract pricing/payment data in addition to bushels
