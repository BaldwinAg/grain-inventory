# Farm Management Suite

A comprehensive set of web applications for agricultural operations management, built for Baldwin Farms.

## Applications

| App | File | Description |
|-----|------|-------------|
| **GrainTrack** | `graintrack.html` | Grain marketing, contracts, inventory tracking, and production management |
| **Spray-Suite** | `spray-suite/` | Chemical application logging with FIFO inventory tracking |
| **Fertilizer App** | `fertilizer.html` | Fertilizer applications, prepaid inventory, blend calculator, and reporting |
| **Fertilizer Calculator** | `fertcalc.html` | Standalone public blend calculator tool |
| **Breakeven Calculator** | `breakeven.html` | Cost aggregation and breakeven analysis per field/commodity |

## Architecture

All applications share a common Supabase database with interconnected tables:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        FARM MANAGEMENT SUITE                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│   ┌─────────────────┐        ┌─────────────────┐        ┌─────────────────┐ │
│   │   GRAINTRACK    │        │  SPRAY-SUITE    │        │ FERTILIZER APP  │ │
│   │   (Marketing)   │        │  (Chemicals)    │        │ (Fertilizer)    │ │
│   │                 │        │                 │        │                 │ │
│   │ • Contracts     │        │ • Applications  │        │ • Applications  │ │
│   │ • Inventory     │        │ • FIFO Inv.     │        │ • Prepaid Inv.  │ │
│   │ • Production    │        │ • Tank Mixes    │        │ • Plans         │ │
│   │ • Dashboard     │        │ • Field Logger  │        │ • Calculator    │ │
│   └────────┬────────┘        └────────┬────────┘        └────────┬────────┘ │
│            │                          │                          │          │
│            └──────────────────────────┴──────────────────────────┘          │
│                                       │                                      │
│                                       ▼                                      │
│                          ┌─────────────────────────┐                        │
│                          │   BREAKEVEN CALCULATOR  │                        │
│                          │   (Cost Aggregator)     │                        │
│                          │                         │                        │
│                          │ • Overhead costs        │                        │
│                          │ • Seed costs            │                        │
│                          │ • Land rent             │                        │
│                          │ • Fertilizer (PULLED)   │◄── From Fertilizer App │
│                          │ • Herbicide (PULLED)    │◄── From Spray-Suite    │
│                          └─────────────────────────┘                        │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

## Shared Database Tables

| Table | Used By |
|-------|---------|
| `farms` | All apps |
| `fields` | All apps |
| `commodities` | GrainTrack, Fertilizer, Breakeven |
| `applicators` | Spray-Suite, Fertilizer |
| `field_crop_years` | GrainTrack, Fertilizer, Breakeven |

## Tech Stack

- **Frontend**: React 18 (via CDN), Tailwind CSS, Lucide Icons
- **Backend**: Supabase (PostgreSQL + Row Level Security)
- **PDF Generation**: jsPDF + AutoTable
- **PDF Parsing**: Claude API (via PHP proxy) for POY import
- **Build**: Single-file HTML apps (no build step required)

## Project Structure

```
grain-inventory/
├── graintrack.html          # Grain marketing app
├── fertilizer.html          # Fertilizer management app
├── fertcalc.html            # Standalone blend calculator (public tool)
├── breakeven.html           # Breakeven calculator
├── login.html               # Shared login page
├── spray-suite/             # Chemical application suite
│   └── apps/
│       └── chemical_app_manager_v3_7_3.html
├── migrations/
│   └── farm_management_suite.sql
├── api/
│   └── claude-proxy.php     # PHP proxy for Claude API
├── README.md
├── CHANGELOG.md
└── PLANNING.md
```

## Features

### GrainTrack
- Contract management (cash sales, basis, HTA, futures)
- Grain inventory by storage location
- Production tracking by field
- Delivery logging with POY PDF import
- Dashboard with Barchart futures integration (RSI, Stochastics)
- Transfers and adjustments

### Spray-Suite
- Chemical application logging with weather data
- FIFO inventory tracking
- Tank mix recipes
- Container type management
- Field-by-field cost tracking

### Fertilizer App
- Application logging with farm > field cascading selection
- Prepaid inventory (bought-ahead tracking with FIFO)
- Fertilizer plans (templates)
- Blend calculator (solve for P first, finish with N)
- Reports by landlord/tenant with adjustment %
- Total needs calculator for COOP ordering

### Breakeven Calculator
- **Comprehensive Crop Plans**: Multi-tab editor for seed, fertilizer passes, chemical passes, and field operations
- **Field Plan Assignments**: Assign crop plans to fields with per-field overrides
- **Overhead Expense Allocation**: By crop/practice (IR/DL), specific field, or all acres
- **Special Categories**: Family Living (toggleable) and Debt Service tracking
- **Field-Level Expenses**: Conservation, taxes, tile drainage allocated to specific fields
- Seed cost tracking with commodity defaults and bag calculations
- Land rent management with copy year forward
- Pulls actual costs from Fertilizer App & Spray-Suite
- Per-field and per-commodity breakeven analysis
- Landlord report with PDF export for landlord statements
- GrainTrack integration (breakeven on dashboard)
- Cost breakdown visualization by category

## Setup

### 1. Supabase Database

Create a Supabase project and run the migration files in order:
```sql
-- Run in Supabase SQL Editor
migrations/farm_management_suite.sql
```

### 2. Configuration

Update the Supabase URL and anon key in each HTML file:
```javascript
const SUPABASE_URL = 'https://your-project.supabase.co';
const SUPABASE_KEY = 'your-anon-key';
```

### 3. Deployment

**Hostinger (current)**
- Upload HTML files to `/portal/` directories
- Set up `config.php` for Claude API proxy

**Alternative hosting**
- Serve the HTML files from any web server
- Or use Supabase hosting, Netlify, Vercel, etc.

## Development

```bash
# Clone the repo
git clone https://github.com/baldwinfarms/grain-inventory.git
cd grain-inventory

# Make changes
# Test locally in browser (just open the HTML file)

# Commit and push
git add .
git commit -m "Description of changes"
git push
```

## Version History

See [CHANGELOG.md](CHANGELOG.md) for detailed release notes.

### Current Versions
- **GrainTrack**: v1.9.2
- **Spray-Suite**: v3.7.3
- **Fertilizer App**: v1.0.1
- **Breakeven Calculator**: v2.0.0

## License

Private - Baldwin Farms

## Support

For issues or feature requests, contact the development team.
