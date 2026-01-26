# Farm Management Suite Changelog

All notable changes to the Farm Management Suite applications.

---

## Breakeven Calculator [2.2.0] - 2026-01-24

### GrainTrack Integration - Marketing & Profit/Loss

**Real Profit/Loss Tracking**
- Pull contracted bushels and blended average price from GrainTrack contracts
- Calculate contracted vs uncontracted bushels per commodity
- Set target prices for uncontracted bushels
- Real-time profit/loss calculation: (Revenue - Costs)
- Display on dashboard commodity cards with marketing position breakdown
- Database: `be_target_prices` table for storing target prices

**What-If Yield Analysis**
- Edit yields directly on dashboard commodity cards
- Instant recalculation of breakeven price when yield changes
- Test scenarios: "What if yield is 10% higher/lower?"
- Non-destructive - doesn't modify actual production data

**Dashboard Profit/Loss Display**
- Marketing Position section on each commodity card
- Shows: Contracted bushels @ blended avg, Uncontracted bushels @ target price
- Estimated Profit/Loss with per-bushel breakdown
- Color-coded: Green for profit, Red for loss
- "Set Target" button for quick price adjustments

## Breakeven Calculator [2.1.0] - 2026-01-24

### Phase 7: Dashboard & Analysis Charts

Major redesign to make Breakeven the central cost planning application.

**Phase 1: Bug Fixes & Overhead Enhancement** ✅ COMPLETE
- Fixed duplicate overhead category tabs (client-side deduplication)
- Added entry_mode (TOTAL vs PER_ACRE) to overhead expenses
- Toggle UI in overhead modal for entry mode selection
- Per-acre totals calculated automatically

**Phase 2-3: Comprehensive Crop Plans** ✅ COMPLETE
- New comprehensive crop plan system with 5-tab editor:
  - Info (name, commodity, practice type)
  - Seed (brand, hybrid, seeds/bag, price, seeding rate)
  - Field Operations (harvest, planting, tillage, drying, custom hire)
  - Fertilizer passes (multiple applications with products/rates)
  - Chemical passes (multiple applications with products/rates)
- Next/Back navigation through tabs with progress dots
- Quick-add buttons for common field operations
- Clone plan feature
- Link to Spray-Suite tank_mixes
- Database: 7 new tables (be_crop_plans, be_crop_plan_seed, etc.)

**Phase 4: Field Assignments** ✅ COMPLETE
- Redesigned field assignments page using comprehensive crop plans
- Filter out non-owned fields (adams_grain_share = 0)
- Show effective share (tenant_share × adams_grain_share)
- Seed override capability per field (brand, hybrid, rate, price)
- Bulk assignment modal for assigning plan to multiple fields
- Status tracking (Planned, In Progress, Completed)
- Summary cards showing assignment progress
- Database: be_field_plan_assignments table

**Phase 5: Special Categories & Field Expenses** ✅ COMPLETE
- **Family Living Category**
  - Special overhead category for personal draw/salary
  - Toggle on dashboard to include/exclude from breakeven
  - `is_family_living` flag in database
- **Debt Service Category**
  - Track loan payments spread across all acres
  - `is_debt_service` flag in database
- **Field-Level Expenses**
  - New `SPECIFIC_FIELD` allocation type
  - Assign expenses to individual fields (conservation, taxes, tile)
  - Field expenses average across all acres in farm reports
- **Overhead Expense UX Improvements**
  - "Add Another" checkbox to quickly add multiple expenses
  - Quick-add button at bottom of expense table
  - Active category tab pre-selected in modal
- **Database & Security**
  - Added RLS policies for authenticated users on overhead tables
  - Fixed base overhead categories insertion
  - Migration includes all required categories

**Phase 6: Seed Products Catalog** ✅ COMPLETE
- **New Seed Products Page**
  - Catalog of seed products with brand, hybrid, maturity, traits
  - Pricing and default seeding rates per product
  - Practice type tagging (Irrigated, Dryland, or Any)
  - Filter by crop and brand
  - "Add Another" feature for quick data entry
  - Database: `be_seed_products` table
- **Crop Plans Integration**
  - Select seed from product catalog in Crop Plan editor
  - Auto-fill brand, hybrid, price, rate from product
  - Still supports manual entry for flexibility
- **Renamed "Field Assignments" → "Field Applications"**
  - Better reflects the purpose (applying plans to fields)
- **Removed Old Seed Costs Page**
  - Replaced with Seed Products catalog
  - Seed now managed at plan level, not field level
- **Database RLS Fixes**
  - Comprehensive RLS policy migration for all breakeven tables
  - Fixed 403 errors for authenticated users
- **Future: Seed Calculator Standalone App** (noted in ROADMAP)

**Phase 5: Misc Income** ✅ COMPLETE (Note: This was completed earlier)
- Track government payments (ARC-CO, PLC, MFP)
- Track conservation payments (CRP, EQIP, CSP)
- Income allocation logic
- Net cost calculation (costs - income)

**Phase 6: Planned vs Actual & Visibility** ✅ COMPLETE (Note: This was completed earlier)
- Added cost_type column for planned/actual tracking
- Pull actual chemical costs from Spray-Suite applications
- Be_field_settings table for visibility control
- Field Visibility settings UI in Settings page
- Cascading report filters (Farm → Landlord → Fields)
- Field multi-select in reports
- Cost view toggle (Planned/Actual/Variance)
- Variance report with category breakdown
- Profitability pricing configuration
- Price source selection (Market/Insurance/Manual)
- Profit calculations in reports
- Migration: `breakeven_phase3_planned_actual.sql`

**Phase 7: Dashboard & Analysis** ✅ COMPLETE
- **Dashboard Enhancements**
  - Planned/Actual/Variance toggle for cost view modes
  - Summary cards update dynamically based on selected view
  - Variance alert banner for commodities over budget by >10%
  - Overall budget status card showing total variance
  - Variance badges on commodity cards showing percentage over/under budget
  - Color-coded variance indicators (red = over, green = under, yellow = minor variance)
- **Commodity Cards**
  - Display planned costs, actual costs, or variance based on toggle
  - Per-acre variance calculations
  - Budget status badges with percentage variance
  - Contextual cost breakdown by view mode
- **Analysis Page Enhancements**
  - NEW: Charts tab with interactive visualizations using Chart.js
  - NEW: Planned vs Actual bar chart comparing costs by commodity
  - NEW: Variance chart showing over/under budget by commodity
  - NEW: Cost breakdown doughnut charts for each commodity
  - NEW: Overall cost allocation pie charts (planned vs actual)
  - Existing: Variance by Commodity table with detailed metrics
  - Existing: Field Detail table with crop plan assignments
  - Highlighting for fields with >10% variance

**Phase 8: Reports & Polish** ✅ PARTIALLY COMPLETE
- [x] Profit/Loss integration with GrainTrack contracts
- [x] What-if yield scenarios
- [x] Target price management for uncontracted bushels
- [ ] Update Landlord Report with income (deferred)
- [ ] Field Cost Summary PDF (deferred)
- [ ] Export functionality enhancements (deferred)

---

## Breakeven Calculator [1.1.0] - 2026-01-24

### Added - Landlord Reports & GrainTrack Integration

- **Landlord Report Page**
  - New dedicated page for landlord expense reporting
  - Fields grouped by landlord with expandable cards
  - Shows fertilizer and split herbicide costs (landlord's share)
  - Excludes burndowns, overhead, seed, rent (tenant responsibility)
  - CSV export for all landlords
  - PDF export for full report or individual landlord statements

- **GrainTrack Integration**
  - Breakeven prices now displayed on GrainTrack dashboard
  - Shows profit/loss margin vs current market price
  - Green/red color coding for above/below breakeven
  - Link to Breakeven Calculator from dashboard

- **Seed Cost Calculator Enhancements**
  - Commodity-specific defaults (Corn: $300/bag, 80K seeds, 32K rate; Beans: $65/unit, 140K seeds, 120K rate)
  - Bags needed calculation with breakdown display
  - Cost per acre display

- **Overhead Allocation Improvements**
  - Practice type selection (Irrigated/Dryland)
  - Visual checkbox UI for crop/practice selection
  - Better allocation display on expense cards

- **Dashboard Enhancements**
  - Cost breakdown bar chart with category colors
  - Category icons (building, seedling, home, flask, spray-can)
  - Per-commodity mini cost breakdown

- **Herbicide Plan Builder**
  - Shows linked tank mix products when available
  - Products display with rates from Spray-Suite

- **Copy Year Forward**
  - Copy overhead expenses to next year with one click
  - Copy land rent to next year
  - Preserves all settings and values

### Fixed
- Field Assignments page now correctly shows tenant_share from field data
- All app links now use full domain (baldwinag.com/portal/...)

---

## GrainTrack [1.9.2] - 2026-01-24

### Added
- **Breakeven Integration**
  - Dashboard shows breakeven price per commodity
  - Profit/loss margin calculation vs market price
  - Color-coded indicators (green = profitable, red = below breakeven)
  - Quick link to Breakeven Calculator

### Fixed
- App links now use full domain URLs (baldwinag.com)

---

## Fertilizer App [1.0.1] - 2026-01-24

### Fixed
- App links now use full domain URLs (baldwinag.com)

---

## Fertilizer App [1.0.0] - 2026-01-23

### Added - Initial Release
- **Application Logging**
  - Farm > Field cascading selection (select farm first, then filter fields)
  - Date, applicator, plan selection
  - Multiple products per application with rates
  - Total cost calculation

- **Blend Calculator** (integrated from standalone fertcalc.html)
  - Liquid blends: 10-34-0, UAN (28%/32%), ATS, Chelated Zn
  - Dry blends: MAP, DAP, MES-Z, Urea, Potash
  - Solve order: P first → S/Zn → finish with N
  - Load builder for tender calculations
  - Saved blends with localStorage
  - Configurable product prices

- **Prepaid Inventory**
  - Track fertilizer purchased ahead
  - Quantity remaining tracking (FIFO ready)
  - Supplier and invoice tracking

- **Fertilizer Plans**
  - Template recipes for applications
  - Product rates and timing
  - Commodity-specific plans

- **Total Needs Calculator**
  - Assign plans to field/crop years
  - Calculate total product needs
  - PDF export for COOP ordering

- **Reports**
  - Filter by date, farm, field, product, landlord, tenant
  - By Landlord view with cost split
  - Adjustment % for estimated vs actual reconciliation
  - Auto-calculate adjustment from actual product pulled
  - PDF export

### Database
New tables (in `migrations/farm_management_suite.sql`):
- `fert_products` - Fertilizer product catalog
- `fert_prepaid` - Prepaid inventory lots
- `fert_plans` - Application plan templates
- `fert_plan_products` - Products in plans
- `fert_applications` - Application records
- `fert_application_products` - Products used in applications
- `fert_split_imports` - COOP split report imports
- `fert_split_costs` - Split report cost items

---

## Breakeven Calculator [1.0.0] - 2026-01-23

### Added - Initial Release
- **Cost Aggregator Architecture**
  - Pulls fertilizer costs from Fertilizer App
  - Pulls herbicide costs from Spray-Suite
  - Manages overhead, seed, and land rent directly

- **Overhead Expenses**
  - Category-based organization (Equipment, Labor, Fixed, Misc)
  - Allocation types: All acres or specific crops/practices
  - Per-acre allocation calculations

- **Seed Costs**
  - Variety tracking per field
  - Price per bag, seeds per bag, seeding rate
  - Total cost calculation

- **Land Rent**
  - Cash rent tracking by field
  - Crop year specific

- **Inputs Page**
  - Combined seed and rent management
  - Tab-based interface

- **Breakeven Analysis**
  - Per-field breakeven calculation
  - Per-commodity weighted average
  - Planned vs actual cost toggle
  - Cost breakdown by category

- **Dashboard**
  - Commodity breakeven cards
  - Cost breakdown pie chart
  - Planned vs actual comparison

### Database
New tables (in `migrations/farm_management_suite.sql`):
- `be_overhead_categories` - Overhead expense categories
- `be_overhead_expenses` - Overhead expense records
- `be_overhead_allocations` - Allocation rules
- `be_seed_costs` - Seed cost by field/year
- `be_land_rent` - Land rent by field/year
- `be_herbicide_plans` - Herbicide plan templates
- `be_field_crop_plans` - Plan assignments to fields
- `be_field_herbicide_passes` - Herbicide passes
- `be_field_breakeven` - Cached breakeven calculations

---

## GrainTrack [1.9.1] - 2026-01-23

### Changed - Market Signal Dashboard

- **Replaced aggregate summary panes with per-commodity market signal cards**
  - Each commodity shows: Futures price, Cash price, Support 1 (S1), Resistance 1 (R1)
  - Cards turn green with "SELL" badge when sell signals trigger
  - Cards turn red with "BUY" badge when buy signals trigger
  - Neutral (white) when no signals active

- **Signal detection logic**
  - Sell signals: RSI > 70, Stoch %K > 80, Stoch %D > 80, or bearish trend
  - Buy signals: RSI < 30, Stoch %K < 20, Stoch %D < 20, or bullish trend
  - Shows which indicators triggered the signal

- **Reference location basis for cash price**
  - Pre-harvest cash price uses reference location's basis (e.g., Groveland)
  - Set reference location via Storage page (is_basis_reference flag)
  - Dashboard shows: Futures + Basis = Cash price per commodity
  - `getReferenceBasis()` function fetches default location's basis

- **Technical data from Barchart**
  - Added support_1 and resistance_1 to market data
  - Real-time technical indicators displayed per commodity

---

## [1.9.0] - 2026-01-23

### Added - Data Integrity & Feature Enhancements (Phase 5)

- **Over-contracting warning**
  - Dashboard shows red warning banner when any commodity is over-contracted
  - Progress bars display >100% with red coloring for over-contracted commodities
  - Over-contracted bushels displayed per commodity

- **Bushels filled tracking**
  - Track delivery progress on contracts (bushels_filled, filled_status)
  - Status badges: NOT_FILLED (gray), PARTIALLY_FILLED (yellow), FILLED (green)
  - "Record Delivery" button on Contracts page with modal interface
  - Progress displayed as X / Y bushels in contracts table

- **Quality fields on inventory**
  - Moisture %, Test Weight, and Grade tracking
  - Quality fields on grain_inventory and inventory_transactions tables
  - Weighted average calculation when adding grain to existing inventory
  - Quality columns in inventory table and transaction history

- **Buyer-specific basis**
  - New buyer_basis table for tracking basis by buyer
  - "Buyer Basis" tab in Basis Management page
  - Grid interface: buyers (rows) x commodities (columns)
  - Supports buyers without physical delivery locations

- **Delivery method option**
  - New delivery_method field: DELIVERY, PICKUP_FIELD, PICKUP_BIN
  - Delivery method buttons in Add Sale page
  - Delivery method badge displayed in contracts table
  - Mobile version updated with delivery method support

- **Soft delete filtering fixes**
  - Added `.is('deleted_at', null)` to all query functions
  - Fixed: getCommodities, getGrainFieldSettings, getInsuranceSettings
  - Fixed: getLocationBasis, getInventory, getGrainLocations

### Database Migration
New file: `migrations/phase5_data_integrity.sql`
- Quality fields on grain_inventory (moisture, test_weight, grade, deleted_at)
- Quality fields on inventory_transactions (moisture, test_weight, grade)
- buyer_basis table with RLS policies
- delivery_method and filled_status columns on contracts
- Soft delete indexes on all grain tables

---

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
