# GrainTrack Suite - Continuation Prompt v1.7.0
## POY Import, Inventory Adjustments & Transfers

## Current State

**Version:** 1.6.0 deployed  
**Database:** Supabase Chemical Project (xehapaasizntuzqzvwej.supabase.co)  
**Deployment:** Hostinger at /portal/grain/

### What's in v1.6.0
- Dashboard with Barchart technical analysis integration (RSI, Stochastics, price from Grain Pulse)
- Production page with Irrigated/Double Crop checkboxes
- Contracts page with full CRUD
- **Basis Management page** (location_basis table with crop year support)
- Inventory page (read-only display, uses `grain_inventory` table)
- Storage page with CRUD
- Buyers page with CRUD

### What's Missing (Build in v1.7.0)
- Inventory transactions (audit trail) - currently just balance tracking
- POY Import from elevator PDFs
- Shrink/reconciliation adjustments
- Transfer functionality for family grain swaps

---

## Task: Build v1.7.0

**Read `GrainTrackSuite_PlanningDoc_1_7_0.md` for complete requirements with UI mockups.**

### Three Features to Build

1. **POY Import** - Import grain delivery data from elevator PDFs via Claude API
2. **Inventory Adjustments** - Shrink and reconciliation
3. **Transfers** - Track grain moving between parties (family swaps)

---

## Feature 1: POY Import

### Flow
1. User clicks "Import POY" → uploads PDF
2. System sends to Claude API (via PHP proxy)
3. Claude returns JSON with ticket-level delivery data
4. **Check for duplicate tickets** (critical: prevent double-counting)
5. User maps elevator locations to GrainTrack locations (one-time)
6. User previews and confirms
7. System creates DEPOSIT transactions with actual dates
8. System records ticket numbers to prevent future duplicates

### Key Extraction Points
- **Ticket Number**: For duplicate detection
- **Date**: From ticket row
- **Commodity**: From section header ("CORN @ GROVELAND")
- **Location**: From section header ("GROVELAND")
- **Your Bushels**: From "Customer Portion" line (after landlord splits)

---

## Feature 2: Inventory Adjustments

### Transaction Types
| Type | Use Case | Bushels |
|------|----------|---------|
| `SHRINK` | Moisture/handling loss | Always negative |
| `RECONCILIATION` | Physical count ≠ book | + or - |

### UI Flow
1. Select location, commodity, crop year
2. Show current book balance
3. Enter new physical count OR adjustment amount
4. System calculates difference and %
5. Require reason/note
6. Create transaction

---

## Feature 3: Transfers

### Transaction Types
| Type | Use Case | Bushels |
|------|----------|---------|
| `TRANSFER_IN` | Receive grain from someone | + |
| `TRANSFER_OUT` | Give grain to someone | - |

### The "Dad Swap" Scenario
Dad deposits 5,000 bu in my on-farm bin. I transfer him 5,000 bu from ADM.

**Creates two transactions:**
```
TRANSFER_IN   | On-Farm Bin | +5,000 | Dwight Baldwin | Dad's corn
TRANSFER_OUT  | ADM Lyons   | -5,000 | Dwight Baldwin | Swapped for on-farm
```

Net inventory: unchanged. Paper trail: clear.

### Swap UI
- Single form that creates both transactions
- Auto-match bushels
- Requires counterparty name

---

## Database Schema

### Existing Tables (from v1.6.0)
```sql
-- grain_inventory: Current balance per location/commodity/crop_year
-- grain_locations: Storage locations
-- location_basis: Basis by location/commodity/crop_year
-- barchart_technicals: Futures prices from Grain Pulse
```

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
    reason VARCHAR(500),  -- For shrink/reconciliation
    ticket_number VARCHAR(50),  -- For POY imports
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

-- Track imports for audit
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

-- Track every ticket to prevent duplicates
CREATE TABLE IF NOT EXISTS imported_tickets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ticket_number VARCHAR(50) NOT NULL,
    import_id UUID REFERENCES poy_imports(id),
    delivery_date DATE,
    commodity_id UUID REFERENCES commodities(id),
    location_id UUID REFERENCES grain_locations(id),
    bushels DECIMAL(12,2),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(ticket_number)
);
```

### Inventory Strategy
- `grain_inventory` remains the **balance table** (current bushels per location/commodity)
- `inventory_transactions` is the **audit trail** (history of all movements)
- When adding/removing grain, update BOTH tables
- Balance = sum of all transactions (can verify against grain_inventory)

---

## Inventory Page UI

```
┌─────────────────────────────────────────────────────────────────┐
│ Inventory                                          2025 ▼       │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│ [📄 Import POY]  [± Adjust]  [↔ Transfer]  [+ Add Grain]        │
│                                                                 │
│ ┌───────────────────┬───────────┬──────────┬──────────────────┐ │
│ │ Location          │ Commodity │ Bushels  │ Last Activity    │ │
│ ├───────────────────┼───────────┼──────────┼──────────────────┤ │
│ │ ▶ On-Farm Bin #1  │ Corn      │ 12,450   │ 2025-10-15       │ │
│ │ ▶ ADM Lyons       │ Corn      │ 25,000   │ 2025-10-20       │ │
│ └───────────────────┴───────────┴──────────┴──────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

Clicking ▶ expands to show transaction history for that location/commodity.

---

## PHP Proxy for Claude API

**File structure:**
```
/portal/grain/
├── index.html
├── .htaccess
└── api/
    ├── config.php      (API key - create manually, never commit)
    └── claude-proxy.php
```

**config.php** (create manually on server):
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

---

## Extraction Prompt for Claude

```javascript
const EXTRACTION_PROMPT = `Extract grain delivery data from this Proof of Yield document.

Return ONLY valid JSON (no markdown, no explanation) in this format:
{
  "crop_year": 2025,
  "producer_name": "NAME FROM DOCUMENT",
  "deliveries": [
    {
      "ticket_number": "BI 110366",
      "date": "2025-10-01",
      "commodity": "Corn",
      "location": "Groveland",
      "your_bushels": 510.89
    }
  ],
  "summary_by_location": [
    {
      "commodity": "Corn",
      "location": "Groveland",
      "total_your_bushels": 39452.75,
      "ticket_count": 77
    }
  ],
  "totals_by_commodity": {
    "Corn": 57357.30,
    "Soybeans": 20590.25,
    "Milo": 10985.97
  }
}

Important rules:
1. Extract EVERY ticket number for duplicate detection
2. Use "Customer Portion" bushels (producer's share after landlord splits)
3. Location is from section headers like "CORN @ GROVELAND" → "Groveland"
4. Dates in ISO format (YYYY-MM-DD)
5. Normalize commodity names: "Corn", "Soybeans", "Milo", "Wheat"
`;
```

---

## Duplicate Detection Logic

```javascript
// Before import, check for existing tickets
const ticketNumbers = extracted.deliveries.map(d => d.ticket_number);
const { data: existing } = await supabase
  .from('imported_tickets')
  .select('ticket_number')
  .in('ticket_number', ticketNumbers);

const duplicates = existing?.map(t => t.ticket_number) || [];

if (duplicates.length > 0) {
  // Show warning: "5 tickets already imported: BI 110366, BI 110377..."
  // Options: [Skip duplicates & continue] [Cancel]
}

// Filter out duplicates before importing
const newDeliveries = extracted.deliveries.filter(
  d => !duplicates.includes(d.ticket_number)
);
```

---

## Deliverables

1. `graintrack_1_7_0.html` - Complete app with all three features (build on graintrack_1_6_0.html)
2. `migration_1_7_0.sql` - Database schema changes (new tables only)
3. `claude-proxy.php` - PHP proxy for Anthropic API
4. `CHANGELOG_1_7_0.md` - Release notes

**Manual setup:** Create `/api/config.php` with API key on server

---

## Starting Point

Use `graintrack_1_6_0.html` from the project files as the base. Key things to preserve:
- Barchart integration and BARCHART_COMMODITY_MAP
- Basis page and location_basis functionality
- All existing CRUD for Storage, Buyers, Contracts
- Dashboard with technical indicators

Key things to enhance:
- InventoryPage: Add action buttons, transaction history, modals
- Add new service functions for inventory_transactions table

---

## Test Data

Use the Producer Ag POY report (Adam Baldwin, 2025 crop year):
- 178 total tickets
- 3 commodities: Corn, Soybeans, Milo
- 3 locations: Groveland, Groveland Bunker, Canton Terminal
- Total your share: 88,933.52 bushels

Expected after import:
- Corn: 57,357 bu
- Soybeans: 20,590 bu
- Milo: 10,986 bu

---

## Technical Notes

- Single HTML file with embedded React/Babel
- Tailwind CSS via CDN
- Supabase JS client for database
- Lucide icons
- User prefers incremental changes over rewrites
- Keep UI simple and functional
