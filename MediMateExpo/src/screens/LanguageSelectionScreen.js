import React from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  ScrollView,
} from 'react-native';
import {SafeAreaView} from 'react-native-safe-area-context';
import {useLanguage} from '../context/LanguageContext';
import theme from '../theme';

const LanguageSelectionScreen = ({navigation}) => {
  const {languages, changeLanguage, currentLanguage, isFirstTime} = useLanguage();

  const handleLanguageSelect = async (languageCode) => {
    await changeLanguage(languageCode);
    if (isFirstTime) {
      navigation.replace('Home');
    } else {
      if (navigation.canGoBack()) {
        navigation.goBack();
      } else {
        navigation.navigate('Home');
      }
    }
  };

  return (
    <SafeAreaView style={styles.container}>
      <ScrollView contentContainerStyle={styles.content}>
        <View style={styles.header}>
          <Text style={styles.headerEmoji}>🌍</Text>
          <Text style={styles.headerTitle}>Choose Your Language</Text>
          <Text style={styles.headerSubtitle}>
            {isFirstTime
              ? 'Select your preferred language to continue'
              : 'Change your preferred language'}
          </Text>
        </View>

        <View style={styles.languagesContainer}>
          {languages.map((language) => (
            <TouchableOpacity
              key={language.code}
              style={[
                styles.languageCard,
                currentLanguage === language.code && styles.languageCardSelected,
              ]}
              onPress={() => handleLanguageSelect(language.code)}
              activeOpacity={0.7}>
              <View style={styles.languageContent}>
                <Text style={styles.languageFlag}>{language.flag}</Text>
                <View style={styles.languageTextContainer}>
                  <Text style={styles.languageName}>{language.nativeName}</Text>
                  <Text style={styles.languageEnglishName}>{language.name}</Text>
                </View>
                {currentLanguage === language.code && (
                  <View style={styles.checkmark}>
                    <Text style={styles.checkmarkText}>✓</Text>
                  </View>
                )}
              </View>
            </TouchableOpacity>
          ))}
        </View>

        {!isFirstTime && (
          <TouchableOpacity
            style={styles.cancelButton}
            onPress={() => {
              if (navigation.canGoBack()) {
                navigation.goBack();
              }
            }}>
            <Text style={styles.cancelButtonText}>Cancel</Text>
          </TouchableOpacity>
        )}
      </ScrollView>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: theme.colors.background,
  },
  content: {
    padding: theme.spacing.xl,
  },
  header: {
    alignItems: 'center',
    marginBottom: theme.spacing.xxxl,
    marginTop: theme.spacing.xl,
  },
  headerEmoji: {
    fontSize: 80,
    marginBottom: theme.spacing.lg,
  },
  headerTitle: {
    fontSize: theme.typography.h1,
    fontWeight: theme.typography.bold,
    color: theme.colors.primary,
    marginBottom: theme.spacing.sm,
    textAlign: 'center',
  },
  headerSubtitle: {
    fontSize: theme.typography.body,
    color: theme.colors.textSecondary,
    textAlign: 'center',
    paddingHorizontal: theme.spacing.lg,
  },
  languagesContainer: {
    gap: theme.spacing.md,
  },
  languageCard: {
    backgroundColor: theme.colors.backgroundSecondary,
    borderRadius: theme.borderRadius.large,
    padding: theme.spacing.xl,
    borderWidth: 3,
    borderColor: theme.colors.border,
    ...theme.shadows.medium,
  },
  languageCardSelected: {
    borderColor: theme.colors.primary,
    backgroundColor: theme.colors.primary + '10',
  },
  languageContent: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  languageFlag: {
    fontSize: 48,
    marginRight: theme.spacing.lg,
  },
  languageTextContainer: {
    flex: 1,
  },
  languageName: {
    fontSize: theme.typography.h3,
    fontWeight: theme.typography.bold,
    color: theme.colors.textPrimary,
    marginBottom: theme.spacing.xs,
  },
  languageEnglishName: {
    fontSize: theme.typography.body,
    color: theme.colors.textSecondary,
  },
  checkmark: {
    width: 40,
    height: 40,
    borderRadius: 20,
    backgroundColor: theme.colors.primary,
    justifyContent: 'center',
    alignItems: 'center',
  },
  checkmarkText: {
    color: theme.colors.textLight,
    fontSize: 24,
    fontWeight: theme.typography.bold,
  },
  cancelButton: {
    marginTop: theme.spacing.xl,
    padding: theme.spacing.lg,
    borderRadius: theme.borderRadius.large,
    borderWidth: 2,
    borderColor: theme.colors.borderDark,
    alignItems: 'center',
  },
  cancelButtonText: {
    fontSize: theme.typography.h4,
    fontWeight: theme.typography.semibold,
    color: theme.colors.textSecondary,
  },
});

export default LanguageSelectionScreen;
