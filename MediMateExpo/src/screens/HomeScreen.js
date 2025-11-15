import React, {useState} from 'react';
import {
  View,
  Text,
  StyleSheet,
  SafeAreaView,
  ScrollView,
  StatusBar,
  TouchableOpacity,
} from 'react-native';
import VoiceButton from '../components/VoiceButton';
import IconButton from '../components/IconButton';
import Card from '../components/Card';
import StatusMessage from '../components/StatusMessage';
import {useLanguage} from '../context/LanguageContext';
import {useUser} from '../context/UserContext';
import theme from '../theme';

/**
 * Home Screen - Main interface for MediMate
 * Features:
 * - Large, easy-to-tap buttons
 * - High contrast design
 * - Voice-first interaction
 * - Maximum 2 levels of navigation
 */
const HomeScreen = ({navigation}) => {
  const [isListening, setIsListening] = useState(false);
  const {t} = useLanguage();
  const {user} = useUser();

  const handleVoicePress = () => {
    setIsListening(!isListening);
    // TODO: Implement voice recognition
    console.log('Voice button pressed');
  };

  const handleCallFamily = () => {
    console.log('Call family pressed');
    // TODO: Navigate to contacts screen
  };

  const handleMedicines = () => {
    console.log('Medicines pressed');
    // TODO: Navigate to medicines screen
  };

  const handleNews = () => {
    console.log('News pressed');
    // TODO: Navigate to news screen
  };

  const handleEmergency = () => {
    console.log('Emergency pressed');
    // TODO: Handle emergency call
  };

  return (
    <SafeAreaView style={styles.container}>
      <StatusBar
        barStyle="dark-content"
        backgroundColor={theme.colors.background}
      />
      
      {/* Header */}
      <View style={styles.header}>
        <View style={styles.headerLeft}>
          <Text style={styles.headerTitle}>{t('appName')}</Text>
          <Text style={styles.headerSubtitle}>{t('tagline')}</Text>
        </View>
        <TouchableOpacity
          style={styles.profileButton}
          onPress={() => navigation.navigate('Profile')}
          activeOpacity={0.7}>
          <View style={styles.profileAvatar}>
            <Text style={styles.profileAvatarText}>
              {user.name.charAt(0).toUpperCase()}
            </Text>
          </View>
        </TouchableOpacity>
      </View>

      <ScrollView
        style={styles.scrollView}
        contentContainerStyle={styles.content}
        showsVerticalScrollIndicator={false}>
        
        {/* Welcome Card */}
        <Card>
          <View style={styles.welcomeSection}>
            <Text style={styles.greeting}>{t('greeting')}</Text>
            <Text style={styles.greetingSubtext}>{t('greetingSubtext')}</Text>
          </View>
        </Card>

        {/* Main Voice Button */}
        <VoiceButton 
          onPress={handleVoicePress} 
          isListening={isListening}
        />

        {/* Status Message */}
        <StatusMessage
          icon={isListening ? '🎤' : '💬'}
          message={
            isListening
              ? t('speakNow')
              : t('howCanHelp')
          }
          variant={isListening ? 'success' : 'info'}
        />

        {/* Quick Actions Section */}
        <View style={styles.sectionHeader}>
          <Text style={styles.sectionTitle}>{t('quickActions')}</Text>
        </View>

        <View style={styles.actionsGrid}>
          <View style={styles.actionRow}>
            <IconButton
              icon={<Text style={styles.emoji}>☎️</Text>}
              label={t('callFamily')}
              onPress={handleCallFamily}
              variant="primary"
              style={styles.actionButton}
            />
            <IconButton
              icon={<Text style={styles.emoji}>💊</Text>}
              label={t('medicines')}
              onPress={handleMedicines}
              variant="secondary"
              style={styles.actionButton}
            />
          </View>

          <View style={styles.actionRow}>
            <IconButton
              icon={<Text style={styles.emoji}>📰</Text>}
              label={t('news')}
              onPress={handleNews}
              variant="secondary"
              style={styles.actionButton}
            />
            <IconButton
              icon={<Text style={styles.emoji}>🆘</Text>}
              label={t('emergency')}
              onPress={handleEmergency}
              variant="emergency"
              style={styles.actionButton}
            />
          </View>
        </View>

        {/* Today's Reminders Card */}
        <Card style={styles.remindersCard}>
          <Text style={styles.cardTitle}>{t('todayReminders')}</Text>
          <View style={styles.reminderItem}>
            <Text style={styles.reminderTime}>08:00 AM</Text>
            <Text style={styles.reminderText}>💊 {t('bloodPressureMedicine')}</Text>
          </View>
          <View style={styles.reminderItem}>
            <Text style={styles.reminderTime}>02:00 PM</Text>
            <Text style={styles.reminderText}>💊 {t('diabetesMedicine')}</Text>
          </View>
          <View style={styles.reminderItem}>
            <Text style={styles.reminderTime}>08:00 PM</Text>
            <Text style={styles.reminderText}>💊 {t('vitaminD')}</Text>
          </View>
        </Card>

        {/* Footer spacing */}
        <View style={styles.footer} />
      </ScrollView>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: theme.colors.backgroundSecondary,
  },
  header: {
    backgroundColor: theme.colors.primary,
    paddingHorizontal: theme.spacing.lg,
    paddingVertical: theme.spacing.xl,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    ...theme.shadows.medium,
  },
  headerLeft: {
    flex: 1,
  },
  headerTitle: {
    fontSize: 36,
    fontWeight: theme.typography.bold,
    color: theme.colors.textLight,
    marginBottom: theme.spacing.xs,
  },
  headerSubtitle: {
    fontSize: 18,
    color: theme.colors.textLight,
    opacity: 0.9,
  },
  profileButton: {
    marginLeft: theme.spacing.md,
  },
  profileAvatar: {
    width: 60,
    height: 60,
    borderRadius: 30,
    backgroundColor: theme.colors.textLight,
    justifyContent: 'center',
    alignItems: 'center',
    borderWidth: 3,
    borderColor: theme.colors.primaryLight,
  },
  profileAvatarText: {
    fontSize: 24,
    fontWeight: theme.typography.bold,
    color: theme.colors.primary,
  },
  scrollView: {
    flex: 1,
  },
  content: {
    padding: theme.spacing.lg,
  },
  welcomeSection: {
    alignItems: 'center',
    paddingVertical: theme.spacing.md,
  },
  greeting: {
    fontSize: 32,
    marginBottom: theme.spacing.sm,
  },
  greetingSubtext: {
    fontSize: theme.typography.body,
    color: theme.colors.textSecondary,
    textAlign: 'center',
  },
  sectionHeader: {
    marginTop: theme.spacing.xl,
    marginBottom: theme.spacing.md,
  },
  sectionTitle: {
    fontSize: theme.typography.h3,
    fontWeight: theme.typography.bold,
    color: theme.colors.textPrimary,
  },
  actionsGrid: {
    marginBottom: theme.spacing.lg,
  },
  actionRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: theme.spacing.md,
  },
  actionButton: {
    flex: 1,
    marginHorizontal: theme.spacing.xs,
  },
  emoji: {
    fontSize: 56,
  },
  remindersCard: {
    marginTop: theme.spacing.lg,
    backgroundColor: '#FEF3C7',
  },
  cardTitle: {
    fontSize: theme.typography.h4,
    fontWeight: theme.typography.bold,
    color: theme.colors.textPrimary,
    marginBottom: theme.spacing.md,
  },
  reminderItem: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: theme.spacing.md,
    borderBottomWidth: 1,
    borderBottomColor: theme.colors.border,
  },
  reminderTime: {
    fontSize: theme.typography.body,
    fontWeight: theme.typography.bold,
    color: theme.colors.primary,
    width: 100,
  },
  reminderText: {
    flex: 1,
    fontSize: theme.typography.body,
    color: theme.colors.textPrimary,
  },
  footer: {
    height: theme.spacing.xxxl,
  },
});

export default HomeScreen;
