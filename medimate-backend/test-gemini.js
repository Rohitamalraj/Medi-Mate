/**
 * Test Google Gemini API Integration
 * Run with: node test-gemini.js
 */

const { GoogleGenerativeAI } = require('@google/generative-ai');

// Your Gemini API Key
const GEMINI_API_KEY = 'AIzaSyCN5nSMutwEDYlP_LNgLShn89k9yt2R1yc';

const genAI = new GoogleGenerativeAI(GEMINI_API_KEY);

async function testGemini() {
  console.log('\n🧪 Testing Google Gemini API\n');
  console.log('='.repeat(50));

  try {
    const model = genAI.getGenerativeModel({ model: 'gemini-pro' });

    // Test 1: English
    console.log('\n1️⃣  Testing English...');
    const englishResult = await model.generateContent(
      'You are MediMate, a caring AI companion for seniors. Say hello in a warm, friendly way.'
    );
    const englishResponse = englishResult.response.text();
    console.log('✅ English Response:');
    console.log(`   "${englishResponse.substring(0, 100)}..."\n`);

    // Test 2: Tamil
    console.log('2️⃣  Testing Tamil...');
    const tamilPrompt = `நீங்கள் MediMate, மூத்த குடிமக்களுக்கான AI துணை. தமிழில் வணக்கம் சொல்லுங்கள்.`;
    const tamilResult = await model.generateContent(tamilPrompt);
    const tamilResponse = tamilResult.response.text();
    console.log('✅ Tamil Response:');
    console.log(`   "${tamilResponse.substring(0, 100)}..."\n`);

    // Test 3: Hindi
    console.log('3️⃣  Testing Hindi...');
    const hindiPrompt = `आप MediMate हैं, वरिष्ठ नागरिकों के लिए AI साथी। हिंदी में नमस्ते कहें।`;
    const hindiResult = await model.generateContent(hindiPrompt);
    const hindiResponse = hindiResult.response.text();
    console.log('✅ Hindi Response:');
    console.log(`   "${hindiResponse.substring(0, 100)}..."\n`);

    // Test 4: Health Advice
    console.log('4️⃣  Testing Health Advice...');
    const healthPrompt = `A senior citizen has a mild headache. Provide simple advice in English. Be caring and suggest when to see a doctor.`;
    const healthResult = await model.generateContent(healthPrompt);
    const healthResponse = healthResult.response.text();
    console.log('✅ Health Advice:');
    console.log(`   "${healthResponse.substring(0, 150)}..."\n`);

    console.log('='.repeat(50));
    console.log('\n✅ All Gemini API tests passed!');
    console.log('🎉 Your API key is working perfectly!\n');

  } catch (error) {
    console.error('\n❌ Error testing Gemini API:');
    console.error(`   ${error.message}\n`);
    
    if (error.message.includes('API key')) {
      console.log('💡 Tip: Check if your API key is correct');
      console.log('   Get a new key at: https://makersuite.google.com/app/apikey\n');
    }
    
    process.exit(1);
  }
}

// Run tests
testGemini();
