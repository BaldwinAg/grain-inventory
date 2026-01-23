# GrainTrack Mobile Changelog

## [1.0.0] - 2026-01-22

### Initial Release
Standalone PWA for quick contract entry on iPhone.

### Features
- **All contract types**: CASH, FUTURES, OPTIONS, HTA, BASIS
- **OPTIONS support**:
  - PUT/CALL selection
  - LONG/SHORT positions
  - Number of contracts input (auto-calculates bushels)
  - Strategy linking for collars
- **Crop year selector** with memory (persists between sessions)
- **Recent contracts history** (last 10 entries, stored locally)
- **Offline detection** with retry option
- **Success animation** on contract creation

### Design
- **Baldwin Ag color scheme**:
  - Primary: Baldwin Green (#2d5016)
  - Accent: Baldwin Gold (#f4e157)
  - Background: Wheat gradient (#f5f1e8 to #e8e2d5)
- **Typography**:
  - Headers: Bebas Neue
  - Body: IBM Plex Sans
- **Touch-optimized UI**:
  - Large tap targets
  - Press feedback animations
  - iOS safe area support
  - No zoom on input focus

### PWA Features
- Add to Home Screen support
- Standalone app mode (no browser bars)
- Custom app icon (wheat graphic)
- Theme color integration

### Technical
- Connects to same Supabase backend as main app
- No separate authentication required
- Real-time sync with main GrainTrack app

### Files
- `graintrack-mobile.html` - Main app
- `graintrack-manifest.json` - PWA config
- `graintrack-icon.svg` - App icon
