import React from 'react';
import {View, Text, StyleSheet, TouchableOpacity} from 'react-native';
import theme from '../theme';

/**
 * Icon Button Component
 * Large, accessible button with icon and label
 */
const IconButton = ({
  icon,
  label,
  onPress,
  variant = 'primary',
  disabled = false,
  style,
}) => {
  return (
    <TouchableOpacity
      style={[
        styles.container,
        styles[`container_${variant}`],
        disabled && styles.disabled,
        style,
      ]}
      onPress={onPress}
      disabled={disabled}
      activeOpacity={0.7}
      accessibilityRole="button"
      accessibilityLabel={label}>
      <View style={styles.iconWrapper}>{icon}</View>
      <Text style={[styles.label, styles[`label_${variant}`]]}>{label}</Text>
    </TouchableOpacity>
  );
};

const styles = StyleSheet.create({
  container: {
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: theme.spacing.lg,
    paddingHorizontal: theme.spacing.md,
    borderRadius: theme.borderRadius.large,
    minWidth: 120,
    minHeight: 120,
    ...theme.shadows.medium,
  },
  container_primary: {
    backgroundColor: theme.colors.primary,
  },
  container_secondary: {
    backgroundColor: theme.colors.backgroundSecondary,
  },
  container_emergency: {
    backgroundColor: theme.colors.emergency,
  },
  container_success: {
    backgroundColor: theme.colors.success,
  },
  iconWrapper: {
    marginBottom: theme.spacing.sm,
  },
  label: {
    fontSize: theme.typography.body,
    fontWeight: theme.typography.semibold,
    textAlign: 'center',
  },
  label_primary: {
    color: theme.colors.textLight,
  },
  label_secondary: {
    color: theme.colors.textPrimary,
  },
  label_emergency: {
    color: theme.colors.textLight,
  },
  label_success: {
    color: theme.colors.textLight,
  },
  disabled: {
    backgroundColor: theme.colors.disabled,
    opacity: 0.6,
  },
});

export default IconButton;
