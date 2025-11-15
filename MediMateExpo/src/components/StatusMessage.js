import React from 'react';
import {View, Text, StyleSheet} from 'react-native';
import theme from '../theme';

/**
 * Status message component with icon and text
 */
const StatusMessage = ({icon, message, variant = 'info', style}) => {
  return (
    <View style={[styles.container, styles[`container_${variant}`], style]}>
      {icon && <Text style={styles.icon}>{icon}</Text>}
      <Text style={[styles.message, styles[`message_${variant}`]]}>
        {message}
      </Text>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: theme.spacing.lg,
    borderRadius: theme.borderRadius.medium,
    marginVertical: theme.spacing.sm,
  },
  container_info: {
    backgroundColor: theme.colors.backgroundSecondary,
  },
  container_success: {
    backgroundColor: '#D1FAE5',
  },
  container_warning: {
    backgroundColor: '#FEF3C7',
  },
  container_error: {
    backgroundColor: '#FEE2E2',
  },
  icon: {
    fontSize: 32,
    marginRight: theme.spacing.md,
  },
  message: {
    flex: 1,
    fontSize: theme.typography.bodyLarge,
    lineHeight: theme.typography.bodyLarge * theme.typography.lineHeightRelaxed,
  },
  message_info: {
    color: theme.colors.textPrimary,
  },
  message_success: {
    color: '#065F46',
  },
  message_warning: {
    color: '#92400E',
  },
  message_error: {
    color: '#991B1B',
  },
});

export default StatusMessage;
