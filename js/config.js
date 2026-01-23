/**
 * GrainTrack Configuration v1.0.0
 * Central configuration for Supabase and app constants
 */

// Supabase Configuration
export const SUPABASE_URL = 'https://xehapaasizntuzqzvwej.supabase.co';
export const SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhlaGFwYWFzaXpudHV6cXp2d2VqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjgzMTkwOTksImV4cCI6MjA4Mzg5NTA5OX0.JTtRaVRfZ4DNddTdT2BsKgCNabErgsCB0rBCHlK0mbA';

// Initialize Supabase client
export const supabase = window.supabase.createClient(SUPABASE_URL, SUPABASE_KEY);

// App Constants
export const APP_VERSION = '1.7.1';
export const APP_NAME = 'GrainTrack Suite';

// Options contract size
export const BUSHELS_PER_CONTRACT = 5000;

// Barchart commodity symbol mapping
export const BARCHART_COMMODITY_MAP = {
  'Corn': 'ZC',
  'Soybeans': 'ZS',
  'Wheat': 'ZW',
  'KC Wheat': 'KE',
  'Hard Red Winter Wheat': 'KE',
  'Milo': 'ZC' // Use corn as proxy
};

// Month code mapping for futures symbols
export const FUTURES_MONTH_CODES = {
  'Jan': 'F', 'Feb': 'G', 'Mar': 'H', 'Apr': 'J',
  'May': 'K', 'Jun': 'M', 'Jul': 'N', 'Aug': 'Q',
  'Sep': 'U', 'Oct': 'V', 'Nov': 'X', 'Dec': 'Z'
};

// Contract types
export const CONTRACT_TYPES = ['CASH', 'FUTURES', 'OPTIONS', 'HTA', 'BASIS'];

// Option types
export const OPTION_TYPES = ['PUT', 'CALL'];

// Position types
export const POSITION_TYPES = ['LONG', 'SHORT'];

// Strategy types
export const STRATEGY_TYPES = ['COLLAR'];

// Default crop year (current year)
export const getDefaultCropYear = () => new Date().getFullYear();

// Crop year range for dropdowns
export const getCropYearRange = () => {
  const current = new Date().getFullYear();
  return [current - 1, current, current + 1, current + 2];
};
