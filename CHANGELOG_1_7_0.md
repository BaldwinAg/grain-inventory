# GrainTrack Suite - Changelog v1.7.0

**Date:** January 22, 2026  
**Version:** 1.7.0  
**Release Name:** POY Import & Transfers

---

## Overview

v1.7.0 adds three major inventory management capabilities:

1. **POY Import** - Import grain delivery data from elevator Proof of Yield PDFs using Claude API
2. **Inventory Adjustments** - Record shrink, reconciliation, and other adjustments
3. **Transfers** - Track grain moving between parties (family swaps, etc.)

---

## New Features

### 1. Proof of Yield Import

- Upload PDF files from grain elevators
- Claude API parses and extracts structured delivery data
- Automatic ticket-level duplicate detection (prevents double-counting)
- Elevator location mapping (one-time setup per location name)
- Preview extracted data before import
- Groups deliveries by date/location/commodity for cleaner transaction history
- Records ticket numbers for audit trail

**User Flow:**
1. Click "Import POY" button
2. Select PDF file
3. Click "Parse Document" - Claude extracts data
4. Map any unmapped elevator locations to GrainTrack locations
5. Review totals and any duplicate warnings
6. Click "Import" to create inventory records

### 2. Inventory Adjustments

Two adjustment types:

| Type | Use Case | Bushels |
|------|----------|---------|
| **SHRINK** | Moisture loss, handling loss | Always negative |
| **RECONCILIATION** | Physical count ≠ book balance | + or - |

- Required reason field for audit trail
- Date selection for backdating adjustments
- Automatic balance update and transaction recording

### 3. Transfers

Two transfer modes:

| Mode | Use Case |
|------|----------|
| **Single** | Transfer IN (receive) or OUT (give) |
| **Swap** | Simultaneous IN and OUT between locations |

**The "Dad Swap" Scenario:**
Dad deposits 5,000 bu in your on-farm bin. You transfer him 5,000 bu from ADM.

Creates two linked transactions:
```
TRANSFER_IN   | On-Farm Bin | +5,000 | Dwight Baldwin
TRANSFER_OUT  | ADM Lyons   | -5,000 | Dwight Baldwin
```

Net inventory: unchanged. Paper trail: clear.

### 4. Transaction History

- Click any inventory row to expand transaction history
- See all movements: deposits, withdrawals, transfers, adjustments
- Color-coded transaction types
- Shows counterparty for transfers
- Displays reason for adjustments
- Shows ticket numbers for POY imports

### 5. Add Grain

Simple manual deposit:
- Select location, commodity, bushels
- Optionally add date and notes
- Creates DEPOSIT transaction with audit trail

---

## Database Changes

### New Tables

#### `inventory_transactions`
Full audit trail for all inventory movements.

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| location_id | UUID | FK to grain_locations |
| commodity_id | UUID | FK to commodities |
| crop_year | INTEGER | Crop year |
| transaction_type | VARCHAR(20) | DEPOSIT, WITHDRAWAL, SALE, TRANSFER_IN, TRANSFER_OUT, SHRINK, RECONCILIATION |
| bushels | DECIMAL(12,2) | + for in, - for out |
| transaction_date | DATE | When transaction occurred |
| counterparty | VARCHAR(200) | For transfers |
| reason | VARCHAR(500) | For adjustments |
| ticket_numbers | TEXT | Comma-separated ticket numbers |
| linked_contract_id | UUID | FK to contracts |
| linked_transaction_id | UUID | For linking transfer pairs |
| import_id | UUID | FK to poy_imports |
| notes | TEXT | Additional notes |

#### `elevator_location_mappings`
Maps elevator names from POY to GrainTrack locations.

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| elevator_name | VARCHAR(200) | Name from POY (unique) |
| location_id | UUID | FK to grain_locations |

#### `poy_imports`
Tracks import batches.

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| file_name | VARCHAR(500) | Original filename |
| crop_year | INTEGER | Crop year from document |
| producer_name | VARCHAR(200) | Producer name from document |
| total_bushels_imported | DECIMAL(12,2) | Sum of all tickets |
| total_tickets_imported | INTEGER | Count of tickets |
| tickets_skipped | INTEGER | Duplicates skipped |
| commodities_imported | TEXT[] | Array of commodity names |
| locations_imported | TEXT[] | Array of location names |
| raw_response | JSONB | Claude's full response |

#### `imported_tickets`
Prevents duplicate ticket imports.

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| ticket_number | VARCHAR(50) | Ticket number (unique) |
| import_id | UUID | FK to poy_imports |
| delivery_date | DATE | Date from ticket |
| commodity_id | UUID | FK to commodities |
| location_id | UUID | FK to grain_locations |
| bushels | DECIMAL(12,2) | Bushels from ticket |
| elevator_name | VARCHAR(200) | Original location name |

---

## Files Included

| File | Description |
|------|-------------|
| `graintrack_1_7_0.html` | Complete application |
| `migration_1_7_0.sql` | Database schema changes |
| `claude-proxy.php` | PHP proxy for Claude API |
| `CHANGELOG_1_7_0.md` | This file |

---

## Deployment Instructions

### 1. Database Migration

Run `migration_1_7_0.sql` in Supabase SQL Editor:
1. Go to Supabase Dashboard → SQL Editor
2. Paste contents of `migration_1_7_0.sql`
3. Click "Run"

### 2. PHP Proxy Setup

On Hostinger:

1. Create folder: `/portal/grain/api/`

2. Create `config.php` (manually, never commit):
```php
<?php
define('ANTHROPIC_KEY', 'sk-ant-api03-YOUR-KEY-HERE');
```

3. Upload `claude-proxy.php` to `/portal/grain/api/`

4. Test with curl:
```bash
curl -X POST https://yourdomain.com/portal/grain/api/claude-proxy.php
# Should return: {"error":"Empty request body"}
```

### 3. Application Update

1. Backup existing `index.html`
2. Rename `graintrack_1_7_0.html` to `index.html`
3. Upload to `/portal/grain/`

---

## Inventory Strategy

The system maintains two complementary tables:

- **`grain_inventory`** - Current balance per location/commodity/crop_year (fast lookups)
- **`inventory_transactions`** - Full history of all movements (audit trail)

When recording changes, both tables are updated:
1. Balance adjusted in `grain_inventory`
2. Transaction recorded in `inventory_transactions`

To verify data integrity:
```sql
-- Compare balance table vs sum of transactions
SELECT 
  gi.location_id,
  gi.commodity_id,
  gi.crop_year,
  gi.bushels as balance_table,
  COALESCE(SUM(it.bushels), 0) as transaction_sum
FROM grain_inventory gi
LEFT JOIN inventory_transactions it 
  ON gi.location_id = it.location_id 
  AND gi.commodity_id = it.commodity_id 
  AND gi.crop_year = it.crop_year
GROUP BY gi.location_id, gi.commodity_id, gi.crop_year, gi.bushels
HAVING gi.bushels != COALESCE(SUM(it.bushels), 0);
```

---

## API Cost Estimate

Claude API pricing (as of Jan 2026):
- Claude Sonnet: ~$3/M input, $15/M output

A typical POY PDF (11 pages, ~15KB text):
- Input: ~5,000 tokens
- Output: ~2,000 tokens
- **Cost per import: ~$0.05-0.10**

Annual cost for 10-20 imports: **< $2**

---

## Testing Checklist

### POY Import
- [ ] PHP proxy responds (test with curl)
- [ ] Upload PDF, verify Claude extracts data correctly
- [ ] Map new elevator location to GrainTrack location
- [ ] Verify mapped location is remembered for future imports
- [ ] Import creates inventory transactions with correct dates
- [ ] Import creates transactions with correct bushel amounts
- [ ] Duplicate ticket detection works (re-import same file)
- [ ] Skip duplicates option works
- [ ] Verify totals match POY report totals

### Inventory Adjustments
- [ ] Shrink adjustment reduces inventory
- [ ] Reason field is required
- [ ] Transaction appears in history with SHRINK type
- [ ] Reconciliation can be positive or negative

### Transfers
- [ ] Single Transfer In adds to inventory
- [ ] Single Transfer Out removes from inventory
- [ ] Counterparty is required
- [ ] Swap creates two transactions (IN + OUT)
- [ ] Transaction history shows counterparty

### Transaction History
- [ ] Click row to expand history
- [ ] History shows all transaction types
- [ ] Correct color coding by type
- [ ] Notes/reason/tickets displayed correctly

---

## Known Limitations

1. **PDF Only** - POY import currently only supports PDF files
2. **One Crop Year** - Import assumes single crop year per document
3. **Manual Location Mapping** - First import requires mapping elevator names
4. **No Undo** - Transactions cannot be deleted (by design - use adjustments)

---

## Future Enhancements (v1.8+)

1. Scale ticket photo upload (camera → Claude)
2. Settlement sheet parsing (pricing data)
3. Quality data tracking (moisture, test weight)
4. Allocate production to fields
5. CSV export of transaction history
