# GrainTrack Suite Changelog

## [1.8.0] - 2026-01-23

### Added - Contract Lifecycle Enhancements
- **SPOT and FORWARD cash sales** (replaces generic CASH)
  - FORWARD: Futures reference + Basis = Net price (no discounts yet)
  - SPOT: Futures reference + Basis - Discounts - Checkoff - Storage = Net price
  - Real-time net price calculation in form
- **Position closing for futures/options**
  - `closeFuturesPosition()` - Record exit date, exit price, calculate P&L
  - `closeOptionsPosition()` - Record exit date, exit premium, calculate P&L
  - `expireOption()` - Handle worthless/exercised options
- **Realized P&L tracking**
  - P&L from closed positions stored on each contract
  - Realized P&L factors into blended average calculation
  - Separate tracking for hedging gains/losses
- **New contract fields**
  - `futures_reference` - Futures price component of cash sales
  - `discounts` - Quality discounts ($/bu)
  - `checkoff` - Commodity checkoff fees ($/bu)
  - `storage_charges` - Storage costs ($/bu)
  - `exit_date`, `exit_price`, `exit_premium` - Position closing
  - `realized_pnl` - Calculated gain/loss
  - `linked_exit_id` - Links offsetting trades

### Changed
- Contract type buttons: FORWARD, SPOT, FUTURES, OPTIONS, HTA, BASIS
- Add Sale form shows contextual help for each contract type
- Summary calculations include realized P&L from closed positions
- Filter dropdowns updated for new contract types

### Database
New columns on `contracts` table:
- `futures_reference`, `discounts`, `checkoff`, `storage_charges`
- `exit_date`, `exit_price`, `exit_premium`, `realized_pnl`, `linked_exit_id`
- New statuses: CLOSED, EXPIRED

---

## [1.7.3] - 2026-01-22

### Added - Export & Reporting (Phase 3)
- **CSV Export** for contracts and production data
  - Export button with dropdown menu
  - Full data export with all fields
  - Filename includes crop year
- **PDF Reports** using jsPDF
  - Marketing Summary PDF from Dashboard
  - Contracts List PDF from Contracts page
  - Professional formatting with tables
  - Baldwin Ag green color scheme
- **Print-friendly styles**
  - Hides navigation and controls when printing
  - Tables formatted for paper
  - Progress bars preserve colors
  - Page break handling

### Changed
- Dashboard has "PDF Report" button for marketing summary
- Contracts page has Export dropdown (CSV/PDF options)
- Production page has Export button for CSV

---

## [1.7.2] - 2026-01-22

### Added - Data Integrity (Phase 2)
- **Audit logging** - All create/update/delete operations logged to `audit_log` table
  - Captures user, table, action, old/new values, timestamp
- **Soft delete** for grain-specific tables
  - Records marked with `deleted_at` instead of permanent removal
  - Contracts, buyers, field_crop_years, etc.
- **Toast notifications** with undo functionality
  - 5-second undo window after delete actions
  - Success, warning, and error message types
- **Confirmation modals** for destructive actions
  - Replaces native `confirm()` dialogs
  - Better UX with clear messaging
- **Restore functions** for undoing deletes
  - `restoreContract()`, `restoreProduction()`, etc.
  - Audit logged as 'RESTORE' action

### Changed
- Delete actions now show toast with "Undo" button
- All queries filter out soft-deleted records by default
- ContractsPage, ProductionPage, BuyersPage use new confirmation/toast system

### Database
New table:
- `audit_log` - Stores all data change history

New columns:
- `deleted_at` (TIMESTAMPTZ) added to: contracts, buyers, commodities, field_crop_years, grain_field_settings, insurance_settings, location_basis, market_prices

---

## [1.7.1] - 2026-01-22

### Added - Options Enhancements
- **LONG/SHORT positions** for OPTIONS contracts
  - LONG (Buy) - paying premium
  - SHORT (Sell) - receiving premium
- **Position badges** on Contracts page (green for LONG, red for SHORT)
- **Strategy linking** - link multiple OPTIONS for collar strategies
  - Collar detection: Long PUT(s) + Short CALL(s)
  - Multi-leg support (e.g., 1 put + 2 calls)
  - Strategy badge with linked contract count
- **Number of contracts** input for OPTIONS (replaces bushels)
  - 1 contract = 5,000 bushels
  - Auto-calculates total bushels
- **Futures month display** as badge in Type column for OPTIONS
- **Options Summary section** on Contracts page
  - Premium paid vs received
  - Net premium calculation
  - Unrealized P&L from live quotes
- **Edit modal** for all contract types
  - Full field editing support
  - Number of contracts for OPTIONS

### Changed
- **Add Sale page** now has crop year dropdown
- **Bushels column** shows "X contracts (Y bu)" format for OPTIONS
- **Premium field** shows +/- indicator based on position type

### Fixed
- `resetForm()` now clears `numContracts`
- Form submission uses `selectedCropYear` correctly
- `onYearChange` prop passed to AddSalePage

### Database
New columns added to `contracts` table:
- `position_type` (VARCHAR) - 'LONG' or 'SHORT'
- `strategy_group_id` (UUID) - links multi-leg strategies
- `strategy_type` (VARCHAR) - 'COLLAR' or null

---

## [1.7.0] - Previous Release
- Initial GrainTrack Suite release
- Dashboard with marketing progress
- Contract management (CASH, FUTURES, OPTIONS, HTA, BASIS)
- Production tracking
- Inventory management
- Insurance settings
- Buyer management
- Basis tracking
- Barchart integration for market data
