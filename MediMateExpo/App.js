/**
 * MediMate - AI Companion for Seniors
 * Expo App Entry Point
 */

import React from 'react';
import {NavigationContainer} from '@react-navigation/native';
import {createStackNavigator} from '@react-navigation/stack';
import {SafeAreaProvider} from 'react-native-safe-area-context';
import {LanguageProvider, useLanguage} from './src/context/LanguageContext';
import {UserProvider} from './src/context/UserContext';
import HomeScreen from './src/screens/HomeScreenNew';
import LanguageSelectionScreen from './src/screens/LanguageSelectionScreen';
import ProfileScreen from './src/screens/ProfileScreen';
import theme from './src/theme';

const Stack = createStackNavigator();

function AppNavigator() {
  const {isFirstTime} = useLanguage();

  return (
    <Stack.Navigator
      screenOptions={{
        headerShown: false,
        gestureEnabled: true,
        cardStyle: {backgroundColor: theme.colors.background},
      }}>
      {isFirstTime ? (
        <>
          <Stack.Screen 
            name="LanguageSelection" 
            component={LanguageSelectionScreen}
            options={{gestureEnabled: false}}
          />
          <Stack.Screen name="Home" component={HomeScreen} />
          <Stack.Screen name="Profile" component={ProfileScreen} />
        </>
      ) : (
        <>
          <Stack.Screen name="Home" component={HomeScreen} />
          <Stack.Screen name="Profile" component={ProfileScreen} />
          <Stack.Screen 
            name="LanguageSelection" 
            component={LanguageSelectionScreen}
          />
        </>
      )}
    </Stack.Navigator>
  );
}

export default function App() {
  return (
    <SafeAreaProvider>
      <LanguageProvider>
        <UserProvider>
          <NavigationContainer>
            <AppNavigator />
          </NavigationContainer>
        </UserProvider>
      </LanguageProvider>
    </SafeAreaProvider>
  );
}
