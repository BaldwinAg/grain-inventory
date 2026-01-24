# Farm Management Suite - Planning & Roadmap

## Overview

The Farm Management Suite is a collection of interconnected web applications for managing agricultural operations at Baldwin Farms. The suite is designed as a unified system where all apps share a common database and can exchange data.

## Current Status

### Released Applications

| App | Version | Status | Description |
|-----|---------|--------|-------------|
| GrainTrack | 1.9.1 | Production | Grain marketing, contracts, inventory |
| Spray-Suite | 3.7.3 | Production | Chemical applications, FIFO inventory |
| Fertilizer App | 1.0.0 | New | Fertilizer applications, prepaid, calculator |
| Breakeven Calculator | 1.0.0 | New | Cost aggregation, breakeven analysis |
| Fertilizer Calculator | 1.0.0 | Public Tool | Standalone blend calculator |

### Public Tools

- **fertcalc.html** - Free public fertilizer blend calculator for website

---

## Architecture

### Data Flow

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           FARM MANAGEMENT SUITE                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│                              SHARED TABLES                                   │
│                     ┌─────────────────────────────┐                         │
│                     │  farms, fields, commodities  │                         │
│                     │  applicators, field_crop_years │                       │
│                     └─────────────────────────────┘                         │
│                                   │                                          │
│        ┌──────────────────────────┼──────────────────────────┐              │
│        ▼                          ▼                          ▼              │
│  ┌─────────────┐          ┌─────────────┐          ┌─────────────┐         │
│  │ GRAINTRACK  │          │ SPRAY-SUITE │          │ FERTILIZER  │         │
│  │             │          │             │          │     APP     │         │
│  │ contracts   │          │ applications│          │ fert_apps   │         │
│  │ grain_inv   │          │ inventory   │          │ fert_prepaid│         │
│  │ production  │          │ tank_mixes  │          │ fert_plans  │         │
│  └──────┬──────┘          └──────┬──────┘          └──────┬──────┘         │
│         │                        │                        │                 │
│         │                        │  herbicide costs       │  fert costs    │
│         │                        └────────────┬───────────┘                 │
│         │                                     ▼                             │
│         │                         ┌─────────────────────┐                   │
│         │                         │     BREAKEVEN       │                   │
│         │                         │     CALCULATOR      │                   │
│         │                         │                     │                   │
│         │                         │ be_overhead_expenses│                   │
│         │                         │ be_seed_costs       │                   │
│         │                         │ be_land_rent        │                   │
│         │                         │ be_field_breakeven  │                   │
│         │                         └──────────┬──────────┘                   │
│         │                                    │                              │
│         │      weighted breakeven            │                              │
│         └────────────────◄───────────────────┘                              │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Technology Stack

| Layer | Technology |
|-------|------------|
| Frontend | React 18 (CDN), Tailwind CSS, Lucide Icons |
| Backend | Supabase (PostgreSQL + Auth + RLS) |
| PDF | jsPDF + AutoTable |
| AI Integration | Claude API (via PHP proxy) for POY import |
| Hosting | Hostinger (static files) |

### Design Principles

1. **Single-File Apps** - Each app is a single HTML file with embedded React/Babel
2. **No Build Step** - Direct browser execution, easy deployment
3. **Shared Database** - All apps use the same Supabase instance
4. **Hotlinks** - Apps link to each other via Settings pages
5. **Soft Delete** - Records use `deleted_at` instead of hard delete
6. **Audit Logging** - All changes logged to `audit_log` table

---

## Roadmap

### Phase 1: Foundation (COMPLETE)
- [x] GrainTrack core features
- [x] Spray-Suite core features
- [x] Shared database schema
- [x] Authentication via Supabase

### Phase 2: Fertilizer & Breakeven (COMPLETE)
- [x] Fertilizer App with application logging
- [x] Prepaid inventory tracking
- [x] Blend calculator integration
- [x] Breakeven Calculator with cost aggregation
- [x] Reports with landlord/tenant splits

### Phase 3: Integration Enhancements (PLANNED)
- [ ] Breakeven pulls actual herbicide costs from Spray-Suite
- [ ] Breakeven pulls actual fertilizer costs from Fertilizer App
- [ ] GrainTrack dashboard shows breakeven per commodity
- [ ] Cross-app notifications (e.g., low inventory alerts)

### Phase 4: Mobile Optimization (PLANNED)
- [ ] Responsive improvements for all apps
- [ ] PWA capabilities (offline support)
- [ ] Touch-friendly interfaces
- [ ] Mobile-specific layouts

### Phase 5: Reporting & Analytics (PLANNED)
- [ ] Farm-wide P&L report
- [ ] Multi-year comparison reports
- [ ] Export to QuickBooks/accounting formats
- [ ] Custom report builder

### Phase 6: Advanced Features (FUTURE)
- [ ] Weather data integration
- [ ] Yield mapping integration
- [ ] Precision ag data import
- [ ] Equipment tracking

---

## Database Tables

### Shared Tables
- `farms` - Farm/operation entities
- `fields` - Individual fields (linked to farms)
- `commodities` - Crop types (corn, soybeans, wheat, etc.)
- `applicators` - People who apply chemicals/fertilizer
- `field_crop_years` - Annual field assignments

### GrainTrack Tables
- `contracts` - Grain sales contracts
- `grain_inventory` - Current grain inventory
- `grain_locations` - Storage locations
- `inventory_transactions` - Inventory change log
- `buyers` - Grain buyers/elevators
- `location_basis` - Basis by location
- `buyer_basis` - Basis by buyer
- `market_prices` - Cached market data

### Spray-Suite Tables
- `products` - Chemical products
- `container_types` - Container types for FIFO
- `inventory` - Chemical inventory lots
- `inventory_transactions` - Usage/purchase log
- `tank_mixes` - Spray recipes
- `tank_mix_products` - Products in recipes
- `applications` - Application records
- `application_products` - Products used

### Fertilizer App Tables
- `fert_products` - Fertilizer products
- `fert_prepaid` - Prepaid inventory
- `fert_plans` - Application templates
- `fert_plan_products` - Products in plans
- `fert_applications` - Application records
- `fert_application_products` - Products used
- `fert_split_imports` - COOP split imports
- `fert_split_costs` - Split cost items

### Breakeven Tables
- `be_overhead_categories` - Expense categories
- `be_overhead_expenses` - Overhead costs
- `be_overhead_allocations` - Allocation rules
- `be_seed_costs` - Seed costs by field
- `be_land_rent` - Land rent by field
- `be_herbicide_plans` - Herbicide templates
- `be_field_crop_plans` - Plan assignments
- `be_field_herbicide_passes` - Spray passes
- `be_field_breakeven` - Cached breakeven

---

## Development Guidelines

### Code Style
- Use React functional components with hooks
- Keep components small and focused
- Use Tailwind CSS for styling
- Follow existing patterns in codebase

### Database Changes
1. Create migration file in `migrations/`
2. Run in Supabase SQL Editor
3. Update relevant HTML files
4. Document in CHANGELOG.md

### Deployment
1. Test locally in browser
2. Commit to GitHub
3. Upload to Hostinger via FTP
4. Verify in production

### Version Numbering
- MAJOR.MINOR.PATCH format
- MAJOR: Breaking changes or major features
- MINOR: New features, backward compatible
- PATCH: Bug fixes, small improvements

---

## Known Issues

1. **Large file sizes** - Single-file apps can exceed 150KB
2. **No offline support** - Requires internet connection
3. **Browser-only** - No native mobile app

---

## Future Considerations

1. **Component library** - Extract common components
2. **API layer** - Move business logic to Edge Functions
3. **Mobile apps** - React Native or PWA
4. **Multi-tenant** - Support multiple farm operations
