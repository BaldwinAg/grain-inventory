# GrainTrack Feature Backlog

Future enhancements and feature ideas for GrainTrack Suite.

---

## 🔮 Future Features

### Revenue Protection (RP) Harvest Price Adjustment
**Priority:** Medium
**Status:** Planned
**Complexity:** Medium

**Description:**
Implement dynamic insured bushel calculation for RP policies based on harvest price movements.

**Current Behavior:**
- Insured bushels calculated as: APH × Coverage × Acres
- Uses reference price only for revenue guarantee
- Bushel coverage stays fixed regardless of price changes

**Proposed Behavior:**
- Revenue guarantee stays fixed: APH × Coverage % × Reference Price
- Insured bushels adjust with harvest/market price
- Formula: (APH × Coverage % × Reference Price) / Harvest Price
- Example: 100 bu APH × 80% × $5.00 = $400 guarantee
  - At $5.00: 80 bu/ac covered
  - At $4.50: 88.8 bu/ac covered
  - At $5.50: 72.7 bu/ac covered

**Implementation Requirements:**
1. Add "Harvest Price" field to insurance settings or auto-use market price
2. Two calculation modes based on policy type:
   - **RP/RP-HPE**: Revenue ÷ Harvest Price = Insured Bushels (dynamic)
   - **YP**: APH × Coverage = Insured Bushels (fixed)
3. Dashboard displays:
   - Insured Revenue (fixed): $400/ac
   - Insured Bushels (dynamic): 89 bu @ $4.50
4. Auto-update when market prices change
5. Manual override option for actual harvest price

**Benefits:**
- More accurate marketing floor price calculations
- Better decision-making when prices drop (know true bushel protection)
- Realistic view of insurance coverage during marketing season
- Helps optimize marketing strategy based on price movements

**User Workflow:**
1. Set reference price on Insurance page (done at policy purchase)
2. System tracks current market price from Dashboard
3. Dashboard Insurance view shows adjusted bushel coverage
4. User can override with actual harvest price when known

**Technical Notes:**
- Need to distinguish RP vs YP policies (already have policy_type field)
- Could use Dashboard market prices as default harvest price
- Allow manual harvest price entry per commodity per year
- Need clear UI indication that bushel coverage is price-dependent for RP

---

## 📋 Other Feature Ideas

### Performance Optimization
**Priority:** Medium
**Status:** Backlog

- Implement data caching for frequently accessed data
- Optimize production page loading for large datasets
- Add lazy loading for farm/field lists
- Consider database indexing improvements

### Mobile Optimization
**Priority:** Low
**Status:** Backlog

- Improve mobile layout for Production page
- Touch-friendly controls for data entry
- Mobile-optimized tables with horizontal scrolling
- Simplified mobile navigation

### Bulk Operations
**Priority:** Low
**Status:** Backlog

- Bulk edit estimated yields across multiple crops
- Bulk update APH from CSV import
- Mass apply insurance settings to multiple crops

### Advanced Reporting
**Priority:** Low
**Status:** Backlog

- Multi-year comparison reports
- Insurance claim analysis (actual vs insured)
- Marketing efficiency metrics
- Export to Excel with formatting

---

## 🎯 Completed Features

### Insurance System Redesign (v1.8.0)
**Completed:** 2025-01-26
- Moved insurance settings to centralized Insurance page
- Added APH yields at field level
- Coverage levels by commodity or practice (IR/DL/FS/DC)
- Reference prices per commodity
- Correct calculation: APH × Coverage × Acres

### Production Page Filters (v1.8.0)
**Completed:** 2025-01-26
- Filter by commodity (Corn, Soybeans, Wheat, Milo)
- Filter by practice (Irrigated, Dryland, Double Crop)
- Search by farm or field name
- Clear filters button

---

## 📝 Notes

- Features are prioritized based on user impact and implementation complexity
- Status values: Planned, Backlog, In Progress, Completed
- Priority values: Critical, High, Medium, Low
- Add new feature ideas to this document as they arise
