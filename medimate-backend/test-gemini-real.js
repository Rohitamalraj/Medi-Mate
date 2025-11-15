/**
 * Test Real Gemini API with correct model
 */

const { GoogleGenerativeAI } = require('@google/generative-ai');
require('dotenv').config();

const GEMINI_API_KEY = process.env.GEMINI_API_KEY;
const genAI = new GoogleGenerativeAI(GEMINI_API_KEY);

async function testRealGemini() {
  console.log('\n🧪 Testing REAL Gemini API\n');
  console.log('='.repeat(50));
  console.log(`API Key: ${GEMINI_API_KEY.substring(0, 20)}...\n`);
  
  try {
    // Use the correct model name
    const model = genAI.getGenerativeModel({ model: 'gemini-2.0-flash' });
    
    // Test 1: English
    console.log('1️⃣  Testing English...');
    const enResult = await model.generateContent(
      'You are MediMate, a caring AI companion for seniors in India. Say hello warmly in English in one short sentence.'
    );
    const enResponse = enResult.response.text();
    console.log(`✅ English: "${enResponse}"\n`);
    
    // Test 2: Tamil
    console.log('2️⃣  Testing Tamil...');
    const taResult = await model.generateContent(
      'நீங்கள் MediMate, மூத்த குடிமக்களுக்கான AI துணை. தமிழில் ஒரு வாக்கியத்தில் அன்பாக வணக்கம் சொல்லுங்கள்.'
    );
    const taResponse = taResult.response.text();
    console.log(`✅ Tamil: "${taResponse}"\n`);
    
    // Test 3: Hindi
    console.log('3️⃣  Testing Hindi...');
    const hiResult = await model.generateContent(
      'आप MediMate हैं, वरिष्ठ नागरिकों के लिए AI साथी। हिंदी में एक वाक्य में गर्मजोशी से नमस्ते कहें।'
    );
    const hiResponse = hiResult.response.text();
    console.log(`✅ Hindi: "${hiResponse}"\n`);
    
    // Test 4: Health Advice
    console.log('4️⃣  Testing Health Advice...');
    const healthResult = await model.generateContent(
      'A senior citizen has a mild headache. Provide simple advice in English (max 2 sentences). Be caring and suggest when to see a doctor.'
    );
    const healthResponse = healthResult.response.text();
    console.log(`✅ Health Advice: "${healthResponse}"\n`);
    
    console.log('='.repeat(50));
    console.log('\n🎉 SUCCESS! Gemini API is working perfectly!\n');
    console.log('✅ Model: gemini-2.0-flash');
    console.log('✅ Multi-language: Working');
    console.log('✅ Health advice: Working');
    console.log('\n📝 Your backend will now use REAL AI responses!\n');
    
  } catch (error) {
    console.error('\n❌ Error:', error.message);
    console.error('\nFull error:', error);
  }
}

testRealGemini();
