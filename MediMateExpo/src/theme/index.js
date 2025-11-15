// Theme colors optimized for seniors - high contrast, WCAG AAA compliant
export const colors = {
  // Primary colors
  primary: '#1E40AF', // Deep blue - trust and calm
  primaryDark: '#1E3A8A',
  primaryLight: '#3B82F6',
  
  // Accent colors
  accent: '#F59E0B', // Warm orange - friendly and approachable
  accentDark: '#D97706',
  accentLight: '#FBBF24',
  
  // Emergency - highly visible
  emergency: '#DC2626', // Bright red
  emergencyDark: '#B91C1C',
  emergencyLight: '#EF4444',
  
  // Success & Health
  success: '#059669', // Green
  successLight: '#10B981',
  health: '#10B981',
  
  // Background - high contrast
  background: '#FFFFFF',
  backgroundSecondary: '#F9FAFB',
  backgroundTertiary: '#F3F4F6',
  backgroundDark: '#1F2937',
  
  // Text - WCAG AAA contrast ratios
  textPrimary: '#111827', // Very dark gray (almost black)
  textSecondary: '#4B5563',
  textLight: '#FFFFFF',
  textDisabled: '#9CA3AF',
  
  // Borders & Dividers
  border: '#E5E7EB',
  borderDark: '#6B7280',
  divider: '#D1D5DB',
  
  // Status colors
  warning: '#F59E0B',
  info: '#3B82F6',
  disabled: '#E5E7EB',
  
  // Overlay
  overlay: 'rgba(0, 0, 0, 0.5)',
  overlayLight: 'rgba(0, 0, 0, 0.3)',
};

// Spacing - larger for easier touch
export const spacing = {
  xs: 4,
  sm: 8,
  md: 16,
  lg: 24,
  xl: 32,
  xxl: 48,
  xxxl: 64,
};

// Typography - larger, readable fonts
export const typography = {
  // Font sizes
  h1: 32,
  h2: 28,
  h3: 24,
  h4: 22,
  body: 20,
  bodyLarge: 22,
  button: 20,
  caption: 16,
  
  // Font weights
  light: '300',
  regular: '400',
  medium: '500',
  semibold: '600',
  bold: '700',
  
  // Line heights - generous for readability
  lineHeightTight: 1.2,
  lineHeightNormal: 1.5,
  lineHeightRelaxed: 1.8,
};

// Button sizes - minimum 60x60 dp for easy tapping
export const buttonSizes = {
  small: {
    height: 60,
    paddingHorizontal: 20,
    fontSize: 18,
  },
  medium: {
    height: 70,
    paddingHorizontal: 24,
    fontSize: 20,
  },
  large: {
    height: 80,
    paddingHorizontal: 32,
    fontSize: 22,
  },
  xlarge: {
    height: 100,
    paddingHorizontal: 40,
    fontSize: 24,
  },
};

// Border radius
export const borderRadius = {
  small: 8,
  medium: 12,
  large: 16,
  xlarge: 24,
  round: 999,
};

// Shadows - for depth and visual hierarchy
export const shadows = {
  small: {
    shadowColor: '#000',
    shadowOffset: {width: 0, height: 2},
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 2,
  },
  medium: {
    shadowColor: '#000',
    shadowOffset: {width: 0, height: 4},
    shadowOpacity: 0.15,
    shadowRadius: 8,
    elevation: 4,
  },
  large: {
    shadowColor: '#000',
    shadowOffset: {width: 0, height: 8},
    shadowOpacity: 0.2,
    shadowRadius: 16,
    elevation: 8,
  },
};

// Icon sizes
export const iconSizes = {
  small: 32,
  medium: 48,
  large: 64,
  xlarge: 80,
};

// Animation durations
export const animations = {
  fast: 150,
  normal: 300,
  slow: 500,
};

export default {
  colors,
  spacing,
  typography,
  buttonSizes,
  borderRadius,
  shadows,
  iconSizes,
  animations,
};
