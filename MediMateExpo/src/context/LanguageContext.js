import React, {createContext, useState, useContext, useEffect} from 'react';
import AsyncStorage from '@react-native-async-storage/async-storage';

// Language translations
const translations = {
  en: {
    appName: 'MediMate',
    tagline: 'Your Friend',
    greeting: '👋 Hello!',
    greetingSubtext: 'How can I help you today?',
    tapToSpeak: 'TAP TO SPEAK',
    listening: 'Listening...',
    speakNow: 'Speak now... I am listening',
    howCanHelp: 'How can I help you?',
    quickActions: 'Quick Actions',
    callFamily: 'CALL FAMILY',
    medicines: 'MEDICINES',
    news: 'READ NEWS',
    emergency: 'EMERGENCY',
    todayReminders: "Today's Reminders",
    profile: 'Profile',
    settings: 'Settings',
    chooseLanguage: 'Choose Language',
    notifications: 'Notifications',
    help: 'Help & Support',
    about: 'About MediMate',
    logout: 'Logout',
    bloodPressureMedicine: 'Blood Pressure Medicine',
    diabetesMedicine: 'Diabetes Medicine',
    vitaminD: 'Vitamin D',
  },
  ta: {
    appName: 'மெடிமேட்',
    tagline: 'உங்கள் நண்பர்',
    greeting: '🙏 வணக்கம்!',
    greetingSubtext: 'இன்று நான் எப்படி உதவ முடியும்?',
    tapToSpeak: 'தொடவும் பேசவும்',
    listening: 'கேட்கிறேன்...',
    speakNow: 'பேசுங்கள்... நான் கேட்கிறேன்',
    howCanHelp: 'எனக்கு எப்படி உதவ முடியும்?',
    quickActions: 'விரைவு செயல்கள்',
    callFamily: 'குடும்பம் அழைக்க',
    medicines: 'மருந்துகள்',
    news: 'செய்திகள் படிக்க',
    emergency: 'அவசரம்',
    todayReminders: 'இன்றைய நினைவூட்டல்கள்',
    profile: 'சுயவிவரம்',
    settings: 'அமைப்புகள்',
    chooseLanguage: 'மொழியைத் தேர்ந்தெடுக்கவும்',
    notifications: 'அறிவிப்புகள்',
    help: 'உதவி & ஆதரவு',
    about: 'மெடிமேட் பற்றி',
    logout: 'வெளியேறு',
    bloodPressureMedicine: 'இரத்த அழுத்த மருந்து',
    diabetesMedicine: 'நீரிழிவு மருந்து',
    vitaminD: 'வைட்டமின் டி',
  },
  hi: {
    appName: 'मेडिमेट',
    tagline: 'आपका दोस्त',
    greeting: '🙏 नमस्ते!',
    greetingSubtext: 'आज मैं आपकी कैसे मदद कर सकता हूं?',
    tapToSpeak: 'बोलने के लिए टैप करें',
    listening: 'सुन रहा हूं...',
    speakNow: 'अब बोलें... मैं सुन रहा हूं',
    howCanHelp: 'मैं आपकी कैसे मदद कर सकता हूं?',
    quickActions: 'त्वरित क्रियाएं',
    callFamily: 'परिवार को कॉल करें',
    medicines: 'दवाइयाँ',
    news: 'समाचार पढ़ें',
    emergency: 'आपातकाल',
    todayReminders: 'आज के रिमाइंडर',
    profile: 'प्रोफ़ाइल',
    settings: 'सेटिंग्स',
    chooseLanguage: 'भाषा चुनें',
    notifications: 'सूचनाएं',
    help: 'सहायता एवं समर्थन',
    about: 'मेडिमेट के बारे में',
    logout: 'लॉग आउट',
    bloodPressureMedicine: 'रक्तचाप की दवा',
    diabetesMedicine: 'मधुमेह की दवा',
    vitaminD: 'विटामिन डी',
  },
  te: {
    appName: 'మెడిమేట్',
    tagline: 'మీ స్నేహితుడు',
    greeting: '🙏 నమస్కారం!',
    greetingSubtext: 'ఈరోజు నేను మీకు ఎలా సహాయం చేయగలను?',
    tapToSpeak: 'మాట్లాడటానికి నొక్కండి',
    listening: 'వింటున్నాను...',
    speakNow: 'ఇప్పుడు మాట్లాడండి... నేను వింటున్నాను',
    howCanHelp: 'నేను మీకు ఎలా సహాయం చేయగలను?',
    quickActions: 'శీఘ్ర చర్యలు',
    callFamily: 'కుటుంబానికి కాల్ చేయండి',
    medicines: 'మందులు',
    news: 'వార్తలు చదవండి',
    emergency: 'అత్యవసరం',
    todayReminders: 'నేటి రిమైండర్‌లు',
    profile: 'ప్రొఫైల్',
    settings: 'సెట్టింగ్‌లు',
    chooseLanguage: 'భాషను ఎంచుకోండి',
    notifications: 'నోటిఫికేషన్‌లు',
    help: 'సహాయం & మద్దతు',
    about: 'మెడిమేట్ గురించి',
    logout: 'లాగ్ అవుట్',
    bloodPressureMedicine: 'రక్తపోటు ఔషధం',
    diabetesMedicine: 'మధుమేహం ఔషధం',
    vitaminD: 'విటమిన్ డి',
  },
};

const languages = [
  {code: 'en', name: 'English', nativeName: 'English', flag: '🇬🇧'},
  {code: 'ta', name: 'Tamil', nativeName: 'தமிழ்', flag: '🇮🇳'},
  {code: 'hi', name: 'Hindi', nativeName: 'हिंदी', flag: '🇮🇳'},
  {code: 'te', name: 'Telugu', nativeName: 'తెలుగు', flag: '🇮🇳'},
];

const LanguageContext = createContext();

export const LanguageProvider = ({children}) => {
  const [currentLanguage, setCurrentLanguage] = useState('en');
  const [isFirstTime, setIsFirstTime] = useState(true);

  useEffect(() => {
    loadLanguage();
  }, []);

  const loadLanguage = async () => {
    try {
      const savedLanguage = await AsyncStorage.getItem('selectedLanguage');
      const firstTime = await AsyncStorage.getItem('isFirstTime');
      
      if (savedLanguage) {
        setCurrentLanguage(savedLanguage);
        setIsFirstTime(false);
      } else if (firstTime === null) {
        setIsFirstTime(true);
      }
    } catch (error) {
      console.error('Error loading language:', error);
    }
  };

  const changeLanguage = async (languageCode) => {
    try {
      await AsyncStorage.setItem('selectedLanguage', languageCode);
      await AsyncStorage.setItem('isFirstTime', 'false');
      setCurrentLanguage(languageCode);
      setIsFirstTime(false);
    } catch (error) {
      console.error('Error saving language:', error);
    }
  };

  const t = (key) => {
    return translations[currentLanguage][key] || translations.en[key] || key;
  };

  return (
    <LanguageContext.Provider
      value={{
        currentLanguage,
        changeLanguage,
        t,
        languages,
        isFirstTime,
        setIsFirstTime,
      }}>
      {children}
    </LanguageContext.Provider>
  );
};

export const useLanguage = () => {
  const context = useContext(LanguageContext);
  if (!context) {
    throw new Error('useLanguage must be used within LanguageProvider');
  }
  return context;
};
