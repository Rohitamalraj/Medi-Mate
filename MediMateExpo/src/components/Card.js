import React from 'react';
import {View, StyleSheet} from 'react-native';
import theme from '../theme';

/**
 * Card container for content sections
 */
const Card = ({children, style, elevated = true}) => {
  return (
    <View style={[styles.card, elevated && styles.elevated, style]}>
      {children}
    </View>
  );
};

const styles = StyleSheet.create({
  card: {
    backgroundColor: theme.colors.background,
    borderRadius: theme.borderRadius.large,
    padding: theme.spacing.lg,
    marginVertical: theme.spacing.sm,
  },
  elevated: {
    ...theme.shadows.medium,
  },
});

export default Card;
