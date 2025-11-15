import React from 'react';
import {View, Text, StyleSheet, TouchableOpacity} from 'react-native';
import theme from '../theme';

const BottomNavigation = ({activeTab, onTabPress}) => {
  const tabs = [
    {id: 'home', icon: '🏠', label: 'Home'},
    {id: 'events', icon: '📅', label: 'Events'},
    {id: 'wallet', icon: '💳', label: 'Wallet'},
    {id: 'profile', icon: '👤', label: 'Profile'},
  ];

  return (
    <View style={styles.container}>
      {tabs.map((tab) => (
        <TouchableOpacity
          key={tab.id}
          style={styles.tab}
          onPress={() => onTabPress(tab.id)}
          activeOpacity={0.7}>
          <View
            style={[
              styles.iconContainer,
              activeTab === tab.id && styles.iconContainerActive,
            ]}>
            <Text
              style={[
                styles.icon,
                activeTab === tab.id && styles.iconActive,
              ]}>
              {tab.icon}
            </Text>
          </View>
          <Text
            style={[
              styles.label,
              activeTab === tab.id && styles.labelActive,
            ]}>
            {tab.label}
          </Text>
        </TouchableOpacity>
      ))}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    backgroundColor: theme.colors.background,
    borderTopWidth: 1,
    borderTopColor: theme.colors.border,
    paddingVertical: theme.spacing.sm,
    paddingHorizontal: theme.spacing.md,
    ...theme.shadows.medium,
  },
  tab: {
    flex: 1,
    alignItems: 'center',
    paddingVertical: theme.spacing.sm,
  },
  iconContainer: {
    width: 50,
    height: 50,
    borderRadius: 25,
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: theme.spacing.xs,
  },
  iconContainerActive: {
    backgroundColor: theme.colors.primary + '15',
  },
  icon: {
    fontSize: 24,
  },
  iconActive: {
    fontSize: 28,
  },
  label: {
    fontSize: 13,
    color: theme.colors.textSecondary,
    fontWeight: theme.typography.medium,
  },
  labelActive: {
    color: theme.colors.primary,
    fontWeight: theme.typography.bold,
    fontSize: 14,
  },
});

export default BottomNavigation;
