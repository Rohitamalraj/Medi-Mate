import React from 'react';
import {
  TouchableOpacity,
  Text,
  StyleSheet,
  View,
  ActivityIndicator,
} from 'react-native';
import theme from '../theme';

/**
 * Large, accessible button component optimized for seniors
 * - Minimum 60x60 dp touch target
 * - High contrast colors (WCAG AAA)
 * - Large, readable text
 * - Clear visual feedback
 */
const LargeButton = ({
  title,
  onPress,
  variant = 'primary',
  size = 'large',
  icon,
  disabled = false,
  loading = false,
  fullWidth = true,
  style,
  textStyle,
}) => {
  const buttonStyle = [
    styles.button,
    styles[`button_${variant}`],
    styles[`button_${size}`],
    fullWidth && styles.fullWidth,
    disabled && styles.disabled,
    style,
  ];

  const textStyles = [
    styles.text,
    styles[`text_${variant}`],
    styles[`text_${size}`],
    disabled && styles.textDisabled,
    textStyle,
  ];

  return (
    <TouchableOpacity
      style={buttonStyle}
      onPress={onPress}
      disabled={disabled || loading}
      activeOpacity={0.7}
      accessibilityRole="button"
      accessibilityLabel={title}
      accessibilityState={{disabled: disabled || loading}}>
      <View style={styles.content}>
        {loading ? (
          <ActivityIndicator
            color={
              variant === 'primary' ? theme.colors.textLight : theme.colors.primary
            }
            size="large"
          />
        ) : (
          <>
            {icon && <View style={styles.iconContainer}>{icon}</View>}
            <Text style={textStyles}>{title}</Text>
          </>
        )}
      </View>
    </TouchableOpacity>
  );
};

const styles = StyleSheet.create({
  button: {
    borderRadius: theme.borderRadius.large,
    justifyContent: 'center',
    alignItems: 'center',
    ...theme.shadows.medium,
  },
  content: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
  },
  iconContainer: {
    marginRight: theme.spacing.sm,
  },
  fullWidth: {
    width: '100%',
  },

  // Variants
  button_primary: {
    backgroundColor: theme.colors.primary,
  },
  button_secondary: {
    backgroundColor: theme.colors.backgroundSecondary,
    borderWidth: 2,
    borderColor: theme.colors.primary,
  },
  button_emergency: {
    backgroundColor: theme.colors.emergency,
  },
  button_success: {
    backgroundColor: theme.colors.success,
  },
  button_outline: {
    backgroundColor: 'transparent',
    borderWidth: 3,
    borderColor: theme.colors.primary,
  },

  // Sizes
  button_small: {
    height: theme.buttonSizes.small.height,
    paddingHorizontal: theme.buttonSizes.small.paddingHorizontal,
  },
  button_medium: {
    height: theme.buttonSizes.medium.height,
    paddingHorizontal: theme.buttonSizes.medium.paddingHorizontal,
  },
  button_large: {
    height: theme.buttonSizes.large.height,
    paddingHorizontal: theme.buttonSizes.large.paddingHorizontal,
  },
  button_xlarge: {
    height: theme.buttonSizes.xlarge.height,
    paddingHorizontal: theme.buttonSizes.xlarge.paddingHorizontal,
  },

  // Text variants
  text: {
    fontWeight: theme.typography.bold,
    textAlign: 'center',
  },
  text_primary: {
    color: theme.colors.textLight,
  },
  text_secondary: {
    color: theme.colors.primary,
  },
  text_emergency: {
    color: theme.colors.textLight,
  },
  text_success: {
    color: theme.colors.textLight,
  },
  text_outline: {
    color: theme.colors.primary,
  },

  // Text sizes
  text_small: {
    fontSize: theme.buttonSizes.small.fontSize,
  },
  text_medium: {
    fontSize: theme.buttonSizes.medium.fontSize,
  },
  text_large: {
    fontSize: theme.buttonSizes.large.fontSize,
  },
  text_xlarge: {
    fontSize: theme.buttonSizes.xlarge.fontSize,
  },

  // Disabled state
  disabled: {
    backgroundColor: theme.colors.disabled,
    opacity: 0.6,
  },
  textDisabled: {
    color: theme.colors.textDisabled,
  },
});

export default LargeButton;
