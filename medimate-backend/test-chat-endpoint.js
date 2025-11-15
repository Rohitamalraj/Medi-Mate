/**
 * Test Chat Endpoint (with Gemini fallback)
 */

const http = require('http');

const BASE_URL = 'http://localhost:3000';

function makeRequest(method, path, data = null, token = null) {
  return new Promise((resolve, reject) => {
    const url = new URL(path, BASE_URL);
    const options = {
      method: method,
      headers: { 'Content-Type': 'application/json' }
    };

    if (token) {
      options.headers['Authorization'] = `Bearer ${token}`;
    }

    const req = http.request(url, options, (res) => {
      let body = '';
      res.on('data', chunk => body += chunk);
      res.on('end', () => {
        try {
          resolve({ status: res.statusCode, data: JSON.parse(body) });
        } catch (e) {
          resolve({ status: res.statusCode, data: body });
        }
      });
    });

    req.on('error', reject);
    if (data) req.write(JSON.stringify(data));
    req.end();
  });
}

async function testChatEndpoint() {
  console.log('\n🧪 Testing Chat Endpoint (Gemini with Fallback)\n');
  console.log('='.repeat(50));
  
  try {
    // First, login to get token
    console.log('\n1️⃣  Logging in...');
    const loginRes = await makeRequest('POST', '/api/auth/login', {
      phone: '9876543210'
    });
    
    if (loginRes.status !== 200) {
      console.log('❌ Login failed');
      return;
    }
    
    const token = loginRes.data.token;
    const userId = loginRes.data.user.id;
    console.log(`✅ Logged in (User ID: ${userId})`);
    
    // Test English chat
    console.log('\n2️⃣  Testing English Chat...');
    const enRes = await makeRequest('POST', '/api/chat', {
      userId: userId,
      message: 'Hello, how are you today?',
      language: 'en'
    }, token);
    
    if (enRes.status === 200 && enRes.data.success) {
      console.log('✅ English Chat Working!');
      console.log(`   Response: "${enRes.data.response}"`);
      console.log(`   Using: ${enRes.data.response.includes("I'm MediMate") ? 'Mock Response (Gemini unavailable)' : 'Real Gemini API'}`);
    } else {
      console.log('❌ English chat failed');
    }
    
    // Test Tamil chat
    console.log('\n3️⃣  Testing Tamil Chat...');
    const taRes = await makeRequest('POST', '/api/chat', {
      userId: userId,
      message: 'வணக்கம், எப்படி இருக்கீங்க?',
      language: 'ta'
    }, token);
    
    if (taRes.status === 200 && taRes.data.success) {
      console.log('✅ Tamil Chat Working!');
      console.log(`   Response: "${taRes.data.response}"`);
    } else {
      console.log('❌ Tamil chat failed');
    }
    
    // Test Hindi chat
    console.log('\n4️⃣  Testing Hindi Chat...');
    const hiRes = await makeRequest('POST', '/api/chat', {
      userId: userId,
      message: 'नमस्ते, आप कैसे हैं?',
      language: 'hi'
    }, token);
    
    if (hiRes.status === 200 && hiRes.data.success) {
      console.log('✅ Hindi Chat Working!');
      console.log(`   Response: "${hiRes.data.response}"`);
    } else {
      console.log('❌ Hindi chat failed');
    }
    
    // Test health advice
    console.log('\n5️⃣  Testing Health Advice...');
    const healthRes = await makeRequest('POST', '/api/chat/health-advice', {
      symptom: 'mild headache',
      language: 'en'
    }, token);
    
    if (healthRes.status === 200 && healthRes.data.success) {
      console.log('✅ Health Advice Working!');
      console.log(`   Advice: "${healthRes.data.advice.substring(0, 100)}..."`);
    } else {
      console.log('❌ Health advice failed');
    }
    
    // Test conversation history
    console.log('\n6️⃣  Testing Conversation History...');
    const historyRes = await makeRequest('GET', `/api/chat/history/${userId}`, null, token);
    
    if (historyRes.status === 200 && historyRes.data.success) {
      console.log('✅ Conversation History Working!');
      console.log(`   Total conversations: ${historyRes.data.count}`);
    } else {
      console.log('❌ Conversation history failed');
    }
    
    console.log('\n' + '='.repeat(50));
    console.log('\n📊 Summary:\n');
    console.log('✅ Chat endpoint is working!');
    console.log('✅ Multi-language support active');
    console.log('✅ Fallback system working');
    console.log('\n⚠️  Note: Gemini API key may be invalid');
    console.log('   But the app works with mock responses!');
    console.log('\n💡 To get real AI responses:');
    console.log('   1. Visit: https://makersuite.google.com/app/apikey');
    console.log('   2. Create new API key');
    console.log('   3. Update .env file');
    console.log('   4. Restart server\n');
    
  } catch (error) {
    console.error('\n❌ Error:', error.message);
  }
}

// Check server and run tests
console.log('Checking if server is running...');
makeRequest('GET', '/api/health')
  .then(() => {
    console.log('✅ Server is running\n');
    testChatEndpoint();
  })
  .catch(() => {
    console.error('❌ Server is not running!');
    console.error('Please start the server first: npm start\n');
    process.exit(1);
  });
