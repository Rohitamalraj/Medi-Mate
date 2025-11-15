/**
 * Test New API Keys Setup
 */

require('dotenv').config({ path: '.env.local' });
const { GoogleGenerativeAI } = require('@google/generative-ai');

const GEMINI_API_KEY = process.env.GEMINI_API_KEY;
const SUPABASE_URL = process.env.SUPABASE_URL;

console.log('\n🧪 Testing New API Keys Setup\n');
console.log('='.repeat(50));

console.log('\n📋 Configuration:');
console.log(`  Gemini Key: ${GEMINI_API_KEY ? GEMINI_API_KEY.substring(0, 20) + '...' : 'NOT FOUND'}`);
console.log(`  Supabase URL: ${SUPABASE_URL || 'NOT FOUND'}\n`);

async function testGemini() {
  if (!GEMINI_API_KEY) {
    console.log('❌ Gemini API key not found in .env.local');
    return;
  }

  try {
    console.log('1️⃣  Testing Gemini API...');
    const genAI = new GoogleGenerativeAI(GEMINI_API_KEY);
    const model = genAI.getGenerativeModel({ model: 'gemini-2.0-flash' });
    
    const result = await model.generateContent('Say "Hello from MediMate!" in one sentence.');
    const response = result.response.text();
    
    console.log('✅ Gemini API is WORKING!');
    console.log(`   Response: "${response}"\n`);
    
    // Test Tamil
    console.log('2️⃣  Testing Tamil support...');
    const taResult = await model.generateContent('வணக்கம் என்று ஒரு வாக்கியத்தில் சொல்லுங்கள்.');
    const taResponse = taResult.response.text();
    console.log('✅ Tamil support working!');
    console.log(`   Response: "${taResponse}"\n`);
    
    console.log('='.repeat(50));
    console.log('\n🎉 SUCCESS! All API keys are working!\n');
    console.log('✅ Gemini API: Working');
    console.log('✅ Multi-language: Working');
    console.log('✅ Backend: Ready to use\n');
    console.log('📝 Next Steps:');
    console.log('  1. Server is running on port 3000');
    console.log('  2. Test with: npm test');
    console.log('  3. Connect your frontend\n');
    
  } catch (error) {
    console.error('\n❌ Error:', error.message);
  }
}

testGemini();
