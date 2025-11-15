/**
 * Complete Gemini API Test Suite
 * Tests all available models and features
 */

const { GoogleGenerativeAI } = require('@google/generative-ai');
require('dotenv').config();

const GEMINI_API_KEY = process.env.GEMINI_API_KEY;

console.log('\n🧪 Complete Gemini API Test Suite\n');
console.log('='.repeat(50));
console.log(`API Key: ${GEMINI_API_KEY ? GEMINI_API_KEY.substring(0, 20) + '...' : 'Not found'}\n`);

if (!GEMINI_API_KEY) {
  console.error('❌ GEMINI_API_KEY not found in .env file');
  process.exit(1);
}

const genAI = new GoogleGenerativeAI(GEMINI_API_KEY);

// Test different model names
const modelsToTest = [
  'gemini-pro',
  'gemini-1.5-pro',
  'gemini-1.5-flash',
  'gemini-1.5-flash-latest',
  'gemini-1.5-pro-latest'
];

async function testModel(modelName) {
  try {
    console.log(`\n📝 Testing model: ${modelName}`);
    const model = genAI.getGenerativeModel({ model: modelName });
    
    const result = await model.generateContent(
      'Say "Hello from MediMate!" in one short sentence.'
    );
    
    const response = result.response.text();
    console.log(`✅ SUCCESS!`);
    console.log(`   Response: "${response}"`);
    return { model: modelName, success: true, response };
    
  } catch (error) {
    console.log(`❌ FAILED: ${error.message.substring(0, 100)}`);
    return { model: modelName, success: false, error: error.message };
  }
}

async function testMultiLanguage(workingModel) {
  console.log('\n' + '='.repeat(50));
  console.log('🌍 Testing Multi-Language Support\n');
  
  const tests = [
    {
      lang: 'English',
      prompt: 'You are MediMate, an AI companion for seniors. Say hello warmly in English in one sentence.'
    },
    {
      lang: 'Tamil',
      prompt: 'நீங்கள் MediMate, மூத்த குடிமக்களுக்கான AI துணை. தமிழில் ஒரு வாக்கியத்தில் வணக்கம் சொல்லுங்கள்.'
    },
    {
      lang: 'Hindi',
      prompt: 'आप MediMate हैं, वरिष्ठ नागरिकों के लिए AI साथी। हिंदी में एक वाक्य में नमस्ते कहें।'
    }
  ];
  
  const model = genAI.getGenerativeModel({ model: workingModel });
  
  for (const test of tests) {
    try {
      console.log(`\n${test.lang}:`);
      const result = await model.generateContent(test.prompt);
      const response = result.response.text();
      console.log(`✅ "${response.substring(0, 80)}..."`);
    } catch (error) {
      console.log(`❌ Failed: ${error.message}`);
    }
  }
}

async function testHealthAdvice(workingModel) {
  console.log('\n' + '='.repeat(50));
  console.log('🏥 Testing Health Advice Feature\n');
  
  try {
    const model = genAI.getGenerativeModel({ model: workingModel });
    
    const prompt = `You are a health assistant for seniors in India.
A senior citizen has a mild headache.

Provide in English:
1. General advice (not medical diagnosis)
2. When to see a doctor
3. Simple home remedies
4. Reassurance

Keep it simple and caring. Maximum 3 sentences.`;
    
    const result = await model.generateContent(prompt);
    const response = result.response.text();
    
    console.log('✅ Health Advice Response:');
    console.log(`   ${response.substring(0, 150)}...`);
    
  } catch (error) {
    console.log(`❌ Failed: ${error.message}`);
  }
}

async function testConversationContext(workingModel) {
  console.log('\n' + '='.repeat(50));
  console.log('💬 Testing Conversation Context\n');
  
  try {
    const model = genAI.getGenerativeModel({ model: workingModel });
    
    // First message
    console.log('User: "My name is Lakshmi"');
    let result = await model.generateContent(
      'You are MediMate. A user says: "My name is Lakshmi". Respond warmly and remember their name. One sentence.'
    );
    console.log(`✅ AI: "${result.response.text()}"`);
    
    // Follow-up (testing context - note: this won't actually remember without chat history)
    console.log('\nUser: "What is my name?"');
    result = await model.generateContent(
      'Previous: User said "My name is Lakshmi". Now user asks "What is my name?". Respond with their name.'
    );
    console.log(`✅ AI: "${result.response.text()}"`);
    
  } catch (error) {
    console.log(`❌ Failed: ${error.message}`);
  }
}

async function runAllTests() {
  console.log('='.repeat(50));
  console.log('🔍 Step 1: Finding Working Model\n');
  
  let workingModel = null;
  const results = [];
  
  for (const modelName of modelsToTest) {
    const result = await testModel(modelName);
    results.push(result);
    
    if (result.success && !workingModel) {
      workingModel = modelName;
    }
  }
  
  console.log('\n' + '='.repeat(50));
  console.log('📊 Model Test Results:\n');
  
  results.forEach(r => {
    if (r.success) {
      console.log(`✅ ${r.model} - WORKING`);
    } else {
      console.log(`❌ ${r.model} - Failed`);
    }
  });
  
  if (!workingModel) {
    console.log('\n❌ No working model found!');
    console.log('\n💡 Possible issues:');
    console.log('   1. API key might be invalid or expired');
    console.log('   2. API key might not have access to these models');
    console.log('   3. Check your API key at: https://makersuite.google.com/app/apikey');
    process.exit(1);
  }
  
  console.log(`\n✅ Working Model Found: ${workingModel}`);
  console.log('\n💡 Update your code to use this model!');
  
  // Run additional tests with working model
  await testMultiLanguage(workingModel);
  await testHealthAdvice(workingModel);
  await testConversationContext(workingModel);
  
  console.log('\n' + '='.repeat(50));
  console.log('\n🎉 All Gemini API Tests Complete!\n');
  console.log(`✅ Working Model: ${workingModel}`);
  console.log('✅ Multi-language: Tested');
  console.log('✅ Health Advice: Tested');
  console.log('✅ Conversation: Tested\n');
  
  console.log('📝 Next Steps:');
  console.log(`   1. Update src/services/gemini.js to use: ${workingModel}`);
  console.log('   2. Restart your server');
  console.log('   3. Test the chat endpoint\n');
}

runAllTests().catch(error => {
  console.error('\n❌ Fatal Error:', error.message);
  process.exit(1);
});
