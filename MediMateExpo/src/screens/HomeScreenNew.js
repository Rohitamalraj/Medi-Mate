import React, {useState} from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  StatusBar,
} from 'react-native';
import {SafeAreaView} from 'react-native-safe-area-context';
import {useLanguage} from '../context/LanguageContext';
import {useUser} from '../context/UserContext';
import BannerCarousel from '../components/BannerCarousel';
import QuickAccessCard from '../components/QuickAccessCard';
import BottomNavigation from '../components/BottomNavigation';
import theme from '../theme';

const HomeScreen = ({navigation}) => {
  const {t} = useLanguage();
  const {user} = useUser();
  const [activeTab, setActiveTab] = useState('home');

  // Banner data
  const banners = [
    {
      title: 'Health Checkup',
      subtitle: 'Schedule your monthly health screening',
      emoji: '🏥',
      color: '#B3D9FF',
    },
    {
      title: 'Medicine Reminder',
      subtitle: 'Never miss your daily medications',
      emoji: '💊',
      color: '#FFE5B4',
    },
    {
      title: 'Video Call',
      subtitle: 'Connect with your family instantly',
      emoji: '📱',
      color: '#D4F1D4',
    },
  ];

  // Quick Access Items (matching the image layout)
  const quickAccessItems = [
    {
      icon: '🎤',
      title: 'Voice Assistant',
      subtitle: 'Speak to get help and support',
      color: '#B3D9FF',
      onPress: () => console.log('Voice'),
    },
    {
      icon: '🎮',
      title: 'Entertainment',
      subtitle: 'Fun, Games, puzzles and more',
      color: '#E6D4FF',
      onPress: () => console.log('Entertainment'),
    },
    {
      icon: '💼',
      title: 'Assistance',
      subtitle: 'Access doctor appointments and more',
      color: '#B3D9FF',
      onPress: () => console.log('Assistance'),
    },
    {
      icon: '💬',
      title: 'Community',
      subtitle: 'Connect with like-minded people',
      color: '#B3D9FF',
      onPress: () => console.log('Community'),
    },
    {
      icon: '📍',
      title: 'Travel',
      subtitle: 'Explore senior-friendly destinations',
      color: '#B3D9FF',
      onPress: () => console.log('Travel'),
    },
    {
      icon: '🏛️',
      title: 'Sacred Locations',
      subtitle: 'Plan pilgrimages with ease',
      color: '#B3D9FF',
      onPress: () => console.log('Sacred'),
    },
    {
      icon: '💊',
      title: 'Medicines',
      subtitle: 'Manage your medications easily',
      color: '#B3D9FF',
      onPress: () => console.log('Medicines'),
    },
    {
      icon: '❤️',
      title: 'Health',
      subtitle: 'Track vitals and wellness',
      color: '#FFD4D4',
      onPress: () => console.log('Health'),
    },
  ];

  const handleTabPress = (tabId) => {
    setActiveTab(tabId);
    if (tabId === 'profile') {
      navigation.navigate('Profile');
    }
    // Handle other tabs
  };

  return (
    <SafeAreaView style={styles.container}>
      <StatusBar barStyle="dark-content" backgroundColor="#FFFFFF" />
      
      {/* Header */}
      <View style={styles.header}>
        <View style={styles.headerLeft}>
          <TouchableOpacity
            style={styles.profileAvatar}
            onPress={() => navigation.navigate('Profile')}>
            <Text style={styles.profileAvatarText}>
              {user.name.charAt(0).toUpperCase()}
            </Text>
          </TouchableOpacity>
          <View style={styles.headerTextContainer}>
            <Text style={styles.welcomeText}>Welcome</Text>
            <Text style={styles.userName}>{user.name}</Text>
          </View>
        </View>
        <TouchableOpacity style={styles.pointsBadge}>
          <Text style={styles.pointsEmoji}>🪙</Text>
          <Text style={styles.pointsText}>99+</Text>
        </TouchableOpacity>
      </View>

      {/* Main Content */}
      <ScrollView
        style={styles.scrollView}
        contentContainerStyle={styles.content}
        showsVerticalScrollIndicator={false}>
        
        {/* Banner Carousel */}
        <BannerCarousel banners={banners} />

        {/* Quick Access Section */}
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Quick Access</Text>
          
          <View style={styles.grid}>
            {quickAccessItems.map((item, index) => (
              <View key={index} style={styles.gridItem}>
                <QuickAccessCard
                  icon={item.icon}
                  title={item.title}
                  subtitle={item.subtitle}
                  color={item.color}
                  onPress={item.onPress}
                />
              </View>
            ))}
          </View>
        </View>
      </ScrollView>

      {/* Bottom Navigation */}
      <BottomNavigation activeTab={activeTab} onTabPress={handleTabPress} />
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#FFFFFF',
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: 20,
    paddingVertical: 16,
    backgroundColor: '#FFFFFF',
    borderBottomWidth: 1,
    borderBottomColor: '#F0F0F0',
  },
  headerLeft: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  profileAvatar: {
    width: 50,
    height: 50,
    borderRadius: 25,
    backgroundColor: '#E8F4FF',
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 12,
  },
  profileAvatarText: {
    fontSize: 20,
    fontWeight: theme.typography.bold,
    color: theme.colors.primary,
  },
  headerTextContainer: {
    justifyContent: 'center',
  },
  welcomeText: {
    fontSize: 14,
    color: theme.colors.textSecondary,
    marginBottom: 2,
  },
  userName: {
    fontSize: 18,
    fontWeight: theme.typography.bold,
    color: theme.colors.textPrimary,
  },
  pointsBadge: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#FFF4E6',
    paddingHorizontal: 12,
    paddingVertical: 8,
    borderRadius: 20,
  },
  pointsEmoji: {
    fontSize: 20,
    marginRight: 4,
  },
  pointsText: {
    fontSize: 16,
    fontWeight: theme.typography.bold,
    color: '#FF9500',
  },
  scrollView: {
    flex: 1,
  },
  content: {
    paddingBottom: 100,
  },
  section: {
    paddingHorizontal: 20,
    marginTop: theme.spacing.md,
  },
  sectionTitle: {
    fontSize: 20,
    fontWeight: theme.typography.bold,
    color: theme.colors.textPrimary,
    marginBottom: theme.spacing.lg,
  },
  grid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    marginHorizontal: -8,
  },
  gridItem: {
    width: '50%',
    paddingHorizontal: 8,
    marginBottom: 16,
  },
});

export default HomeScreen;
