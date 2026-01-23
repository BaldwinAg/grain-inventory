# GrainTrack Development Roadmap

## Overview
This roadmap outlines the planned improvements to GrainTrack Suite, organized into phases that build on each other.

---

## Phase 1: Foundation (Security & Structure)
**Goal:** Make the app production-ready and maintainable

### 1.1 Authentication
- [ ] Add Supabase Auth integration
- [ ] Login/logout flow
- [ ] Password reset via email
- [ ] Protect all database operations with RLS (Row Level Security)
- [ ] Session persistence

### 1.2 Module Architecture
Split the monolithic HTML into organized modules:

```
grain-inventory/
├── index.html              # Shell with script imports
├── js/
│   ├── config.js           # Supabase config, constants
│   ├── auth.js             # Authentication logic
│   ├── api/
│   │   ├── contracts.js    # Contract CRUD
│   │   ├── production.js   # Production CRUD
│   │   ├── inventory.js    # Inventory CRUD
│   │   ├── buyers.js       # Buyer CRUD
│   │   └── market.js       # Barchart integration
│   ├── components/
│   │   ├── Dashboard.js
│   │   ├── AddSale.js
│   │   ├── Contracts.js
│   │   ├── Production.js
│   │   ├── Inventory.js
│   │   ├── Insurance.js
│   │   └── shared/         # Reusable components
│   │       ├── Icon.js
│   │       ├── Modal.js
│   │       └── Table.js
│   └── app.js              # Main app, routing
├── css/
│   └── styles.css          # Custom styles (Tailwind via CDN)
└── mobile/
    └── index.html          # Mobile PWA (standalone)
```

### 1.3 Input Validation
- [ ] Required field validation
- [ ] Numeric range validation (no negative bushels)
- [ ] Date logic (delivery end >= start)
- [ ] Price sanity checks (warn on unusual values)
- [ ] Form-level error display

---

## Phase 2: Data Integrity & History
**Goal:** Track changes and protect data

### 2.1 Audit Trail
- [ ] Create `audit_log` table in Supabase
- [ ] Log all create/update/delete operations
- [ ] Store: user_id, table_name, record_id, action, old_values, new_values, timestamp
- [ ] View audit history in app (admin only)

### 2.2 Soft Delete Everything
- [ ] Add `deleted_at` column to all tables
- [ ] Update queries to filter deleted records
- [ ] Add "Trash" view to restore deleted items
- [ ] Auto-purge after 30 days (optional)

### 2.3 Undo/Confirmation
- [ ] Confirmation modals for destructive actions
- [ ] Toast notifications with "Undo" button
- [ ] 5-second undo window before hard commit

---

## Phase 3: Export & Reporting
**Goal:** Get data out of the system

### 3.1 CSV Export
- [ ] Export contracts by crop year
- [ ] Export production data
- [ ] Export inventory snapshots
- [ ] Column selection UI
- [ ] Date range filters

### 3.2 PDF Reports
- [ ] Marketing summary by commodity
- [ ] Contract listing with totals
- [ ] Inventory position report
- [ ] Use jsPDF or similar library

### 3.3 Print Styles
- [ ] Print-friendly CSS
- [ ] Print individual contracts
- [ ] Print dashboard summary

---

## Phase 4: Notifications & Automation
**Goal:** Proactive alerts and reminders

### 4.1 Delivery Reminders
- [ ] Flag contracts approaching delivery window
- [ ] Dashboard alerts for upcoming deliveries
- [ ] Email notifications (via Supabase Edge Functions)

### 4.2 Price Alerts
- [ ] Set target prices per commodity
- [ ] Alert when market hits target
- [ ] Integrate with Barchart data

### 4.3 Contract Expiration
- [ ] Track option expiration dates
- [ ] Warn 7/14/30 days before expiry
- [ ] Dashboard widget for expiring options

### 4.4 Technical Signal Alerts (Twilio SMS)
- [ ] Supabase Edge Function to monitor signal changes
- [ ] Twilio integration for SMS notifications
- [ ] Alert when RSI crosses overbought (>70) or oversold (<30)
- [ ] Alert when Stochastic crosses overbought (>80) or oversold (<20)
- [ ] Alert when Barchart trend_signal changes to buy/sell
- [ ] Configurable alert thresholds per user
- [ ] Rate limiting to prevent spam (max alerts per hour)

### 4.5 Inventory Cash Price by Location
- [ ] Fetch location-specific basis for each storage location
- [ ] Calculate cash price per inventory row (futures + location basis)
- [ ] Show inventory value (bushels * cash price) per location
- [ ] Total portfolio value across all locations

---

## Phase 5: Multi-User & Permissions
**Goal:** Support farm teams

### 5.1 User Management
- [ ] Invite users via email
- [ ] User roles: Admin, Manager, Viewer
- [ ] Role-based UI (hide edit buttons for viewers)

### 5.2 Row-Level Security
- [ ] Tie all data to organization_id
- [ ] RLS policies per role
- [ ] Viewers see all, edit nothing
- [ ] Managers edit contracts, not settings
- [ ] Admins full access

### 5.3 Activity Feed
- [ ] "John added 5,000 bu CASH contract"
- [ ] Recent activity on dashboard
- [ ] Filter by user

---

## Phase 6: Advanced Features
**Goal:** Power user functionality

### 6.1 Profit/Loss Tracking
- [ ] Record final settlement price per contract
- [ ] Calculate P&L vs contracted price
- [ ] Crop year P&L summary
- [ ] Historical performance charts

### 6.2 What-If Scenarios
- [ ] "What if corn hits $5.00?"
- [ ] Recalculate blended average at different prices
- [ ] Compare current position to scenarios

### 6.3 Mobile App Enhancements
- [ ] Offline support with sync
- [ ] Push notifications
- [ ] Quick actions (widgets)

---

## Technical Decisions

### Why Not a Build Process (Yet)?
The current single-file approach works for Hostinger static hosting. Phase 1.2 uses ES modules with `<script type="module">` which modern browsers support natively. No bundler needed initially.

If complexity grows, we can add Vite:
- Fast dev server
- Bundles for production
- Still deploys as static files to Hostinger

### Database Schema Changes Needed

```sql
-- Phase 1: Authentication
-- (Handled by Supabase Auth, just enable it)

-- Phase 2: Audit Trail
CREATE TABLE audit_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id),
  table_name TEXT NOT NULL,
  record_id UUID NOT NULL,
  action TEXT NOT NULL, -- INSERT, UPDATE, DELETE
  old_values JSONB,
  new_values JSONB,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Phase 2: Soft Delete
ALTER TABLE contracts ADD COLUMN deleted_at TIMESTAMPTZ;
ALTER TABLE buyers ADD COLUMN deleted_at TIMESTAMPTZ;
-- etc.

-- Phase 5: Multi-User
CREATE TABLE organizations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE user_roles (
  user_id UUID REFERENCES auth.users(id),
  organization_id UUID REFERENCES organizations(id),
  role TEXT NOT NULL, -- admin, manager, viewer
  PRIMARY KEY (user_id, organization_id)
);

-- Add org_id to all tables
ALTER TABLE contracts ADD COLUMN organization_id UUID REFERENCES organizations(id);
-- etc.
```

---

## Immediate Next Steps

1. **Set up Supabase Auth** - Enable in dashboard, add login UI
2. **Split into modules** - Start with api/ folder, keep components in main file initially
3. **Add validation** - Low-hanging fruit, immediate quality improvement
4. **CSV export** - High value, relatively easy

---

## Timeline Estimate

| Phase | Effort | Priority |
|-------|--------|----------|
| Phase 1 | 2-3 sessions | Critical |
| Phase 2 | 1-2 sessions | High |
| Phase 3 | 1-2 sessions | High |
| Phase 4 | 2-3 sessions | Medium |
| Phase 5 | 3-4 sessions | Medium |
| Phase 6 | Ongoing | Low |

---

*Last updated: 2026-01-23*
