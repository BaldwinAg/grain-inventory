# GrainTrack Suite

Grain inventory management system for farm operations. Track deliveries, storage locations, contracts, and inventory movements with full audit trails.

## Features

- **Dashboard** - Overview with Barchart futures integration (RSI, Stochastics, price data)
- **Inventory Management** - Track grain by location, commodity, and crop year
- **POY Import** - Import grain delivery data from elevator Proof of Yield PDFs via Claude API
- **Transfers** - Track grain moving between parties (family swaps, etc.)
- **Adjustments** - Record shrink, reconciliation, and other inventory adjustments
- **Contracts** - Manage grain sales contracts
- **Basis Management** - Track basis by location and commodity
- **Storage Locations** - Manage on-farm and commercial storage
- **Buyers** - Maintain buyer/elevator directory

## Tech Stack

- **Frontend**: React 18 (via CDN), Tailwind CSS, Lucide Icons
- **Backend**: Supabase (PostgreSQL)
- **Hosting**: Hostinger (static HTML)
- **PDF Parsing**: Claude API (via PHP proxy)

## Project Structure

```
grain-inventory/
├── graintrack_1_7_0.html          # Main application
├── claude-proxy.php               # PHP proxy for Claude API
├── config.example.php             # Template for API config
├── CHANGELOG_1_7_0.md             # Release notes
├── GrainTrackSuite_PlanningDoc_1_7_0.md
├── GrainTrackSuite_ContinuationPrompt_1_7_0.md
└── .gitignore
```

## Setup

### 1. Supabase Database

Create a Supabase project and run the database migrations. Required tables:
- `commodities`
- `grain_locations`
- `grain_inventory`
- `inventory_transactions`
- `contracts`
- `location_basis`
- `elevator_location_mappings`
- `poy_imports`
- `imported_tickets`

See `CHANGELOG_1_7_0.md` for schema details.

### 2. Hostinger Deployment

1. Upload `graintrack_1_7_0.html` as `index.html` to `/portal/grain/`

2. Create `/portal/grain/api/` folder

3. Upload `claude-proxy.php` to `/portal/grain/api/`

4. Create `config.php` in `/portal/grain/api/` (never commit this):
   ```php
   <?php
   define('ANTHROPIC_KEY', 'sk-ant-api03-YOUR-KEY-HERE');
   ```

5. Test the proxy:
   ```bash
   curl -X POST https://yourdomain.com/portal/grain/api/claude-proxy.php
   # Should return: {"error":"Empty request body"}
   ```

## Configuration

The application connects to Supabase using the anon (public) key embedded in the HTML. This is safe for client-side use with Row Level Security enabled.

The Claude API key is kept server-side in `config.php` on Hostinger and is never exposed to the client.

## Development

1. Clone the repo
2. Make changes to the HTML file
3. Test locally or push to Hostinger
4. Commit and push to GitHub

```bash
git add .
git commit -m "Description of changes"
git push
```

## Version History

- **v1.7.0** - POY Import, Inventory Adjustments, Transfers
- **v1.6.0** - Barchart Integration, Basis Management

See `CHANGELOG_1_7_0.md` for detailed release notes.

## License

Private - Baldwin Ag
