const { GoogleGenerativeAI } = require('@google/generative-ai');
require('dotenv').config();

// Initialize Gemini
let genAI = null;
let isConfigured = false;

try {
  if (process.env.GEMINI_API_KEY) {
    genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
    isConfigured = true;
  }
} catch (error) {
  console.warn('Gemini API not configured. Using mock responses.');
}

// System prompts for different languages
const SYSTEM_PROMPTS = {
  ta: 'நீங்கள் MediMate, இந்தியாவில் உள்ள மூத்த குடிமக்களுக்கான அக்கறையுள்ள AI துணை. தமிழில் பேசுங்கள். அன்பாகவும், பொறுமையாகவும், எளிய மொழியைப் பயன்படுத்துங்கள். மருந்து நினைவூட்டல்கள், சுகாதார கேள்விகள் மற்றும் தோழமையுடன் உதவுங்கள்.',
  hi: 'आप MediMate हैं, भारत में वरिष्ठ नागरिकों के लिए एक देखभाल करने वाला AI साथी। हिंदी में बोलें। गर्मजोशी से, धैर्यपूर्वक और सरल भाषा का उपयोग करें। दवा अनुस्मारक, स्वास्थ्य प्रश्न और साहचर्य में मदद करें।',
  en: 'You are MediMate, a caring AI companion for seniors in India. Speak in English. Be warm, patient, and use simple language. Help with medication reminders, health questions, and companionship.'
};

// Mock responses when API is not configured
const MOCK_RESPONSES = {
  en: "Hello! I'm MediMate, your friendly AI companion. I'm here to help you with your medications and health. How can I assist you today?",
  ta: "வணக்கம்! நான் MediMate, உங்கள் நட்பு AI துணை. உங்கள் மருந்துகள் மற்றும் ஆரோக்கியத்தில் உங்களுக்கு உதவ நான் இங்கே இருக்கிறேன். இன்று நான் உங்களுக்கு எவ்வாறு உதவ முடியும்?",
  hi: "नमस्ते! मैं MediMate हूं, आपका मित्रवत AI साथी। मैं आपकी दवाओं और स्वास्थ्य में आपकी मदद करने के लिए यहां हूं। आज मैं आपकी कैसे सहायता कर सकता हूं?"
};

/**
 * Chat with Gemini AI
 */
async function chatWithGemini(userMessage, language = 'en', conversationHistory = []) {
  try {
    // If API not configured, return mock response
    if (!isConfigured) {
      console.log('Using mock Gemini response');
      return MOCK_RESPONSES[language] || MOCK_RESPONSES.en;
    }

    const model = genAI.getGenerativeModel({ model: 'gemini-2.0-flash' });
    
    // Build prompt with context
    const systemPrompt = SYSTEM_PROMPTS[language] || SYSTEM_PROMPTS.en;
    let fullPrompt = `${systemPrompt}\n\n`;
    
    // Add conversation history (last 5 messages)
    if (conversationHistory && conversationHistory.length > 0) {
      const recentHistory = conversationHistory.slice(-5);
      fullPrompt += 'Previous conversation:\n';
      recentHistory.forEach(msg => {
        fullPrompt += `User: ${msg.message}\nAssistant: ${msg.response}\n`;
      });
      fullPrompt += '\n';
    }
    
    fullPrompt += `User: ${userMessage}\nAssistant:`;

    // Generate response
    const result = await model.generateContent(fullPrompt);
    const response = await result.response;
    const text = response.text();

    return text;

  } catch (error) {
    console.error('Gemini API Error:', error.message);
    
    // Return friendly error message
    const errorMessages = {
      en: "I'm having trouble thinking right now. Please try again in a moment.",
      ta: "எனக்கு இப்போது சிந்திக்க சிரமம் ஏற்படுகிறது. தயவுசெய்து சிறிது நேரம் கழித்து மீண்டும் முயற்சிக்கவும்.",
      hi: "मुझे अभी सोचने में परेशानी हो रही है। कृपया एक क्षण में फिर से प्रयास करें।"
    };
    
    return errorMessages[language] || errorMessages.en;
  }
}

/**
 * Get health advice
 */
async function getHealthAdvice(symptom, language = 'en') {
  try {
    if (!isConfigured) {
      return "Please consult with your doctor about your symptoms. I'm here to support you, but a medical professional can give you the best advice.";
    }

    const model = genAI.getGenerativeModel({ model: 'gemini-2.0-flash' });
    
    const langName = {
      ta: 'Tamil',
      hi: 'Hindi',
      en: 'English'
    }[language] || 'English';
    
    const prompt = `You are a health assistant for seniors in India.
A senior citizen is experiencing: ${symptom}

Provide:
1. General advice (not medical diagnosis)
2. When to see a doctor
3. Simple home remedies if applicable
4. Reassurance

Respond in ${langName}.
Keep it simple and caring.`;
    
    const result = await model.generateContent(prompt);
    const response = await result.response;
    return response.text();
    
  } catch (error) {
    console.error('Health advice error:', error);
    return "Please consult with your doctor about your symptoms.";
  }
}

module.exports = {
  chatWithGemini,
  getHealthAdvice,
  isConfigured
};
