# GrainTrack Suite Changelog

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
