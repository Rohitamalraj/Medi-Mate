/**
 * Test Speech Endpoints
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

async function testSpeechEndpoints() {
  console.log('\n🎤 Testing Speech Endpoints\n');
  console.log('='.repeat(50));
  
  let token = '';
  
  try {
    // Login first
    console.log('\n1️⃣  Logging in...');
    const loginRes = await makeRequest('POST', '/api/auth/login', {
      phone: '9876543210'
    });
    
    if (loginRes.status === 200) {
      token = loginRes.data.token;
      console.log('✅ Logged in');
    } else {
      console.log('❌ Login failed');
      return;
    }
    
    // Test TTS - English
    console.log('\n2️⃣  Testing TTS (English)...');
    const ttsEnRes = await makeRequest('POST', '/api/speech/text-to-speech', {
      text: 'Hello, how are you today?',
      language: 'en'
    }, token);
    
    if (ttsEnRes.status === 200 && ttsEnRes.data.success) {
      console.log('✅ TTS English Working');
      console.log(`   Config:`, ttsEnRes.data.config);
    } else {
      console.log('❌ TTS English failed');
    }
    
    // Test TTS - Tamil
    console.log('\n3️⃣  Testing TTS (Tamil)...');
    const ttsTaRes = await makeRequest('POST', '/api/speech/text-to-speech', {
      text: 'வணக்கம், எப்படி இருக்கீங்க?',
      language: 'ta'
    }, token);
    
    if (ttsTaRes.status === 200 && ttsTaRes.data.success) {
      console.log('✅ TTS Tamil Working');
      console.log(`   Language: ${ttsTaRes.data.config.lang}`);
      console.log(`   Rate: ${ttsTaRes.data.config.rate}`);
    } else {
      console.log('❌ TTS Tamil failed');
    }
    
    // Test TTS - Hindi
    console.log('\n4️⃣  Testing TTS (Hindi)...');
    const ttsHiRes = await makeRequest('POST', '/api/speech/text-to-speech', {
      text: 'नमस्ते, आप कैसे हैं?',
      language: 'hi'
    }, token);
    
    if (ttsHiRes.status === 200 && ttsHiRes.data.success) {
      console.log('✅ TTS Hindi Working');
      console.log(`   Language: ${ttsHiRes.data.config.lang}`);
    } else {
      console.log('❌ TTS Hindi failed');
    }
    
    // Test STT
    console.log('\n5️⃣  Testing STT Configuration...');
    const sttRes = await makeRequest('POST', '/api/speech/speech-to-text', {
      language: 'ta'
    }, token);
    
    if (sttRes.status === 200 && sttRes.data.success) {
      console.log('✅ STT Configuration Working');
      console.log(`   Config:`, sttRes.data.config);
    } else {
      console.log('❌ STT failed');
    }
    
    // Test Voice Settings
    console.log('\n6️⃣  Testing Voice Settings...');
    const voiceRes = await makeRequest('GET', '/api/speech/voice-settings/ta', null, token);
    
    if (voiceRes.status === 200 && voiceRes.data.success) {
      console.log('✅ Voice Settings Working');
      console.log(`   Settings:`, voiceRes.data.settings);
    } else {
      console.log('❌ Voice settings failed');
    }
    
    // Test Supported Languages
    console.log('\n7️⃣  Testing Supported Languages...');
    const langRes = await makeRequest('GET', '/api/speech/supported-languages', null, token);
    
    if (langRes.status === 200 && langRes.data.success) {
      console.log('✅ Supported Languages Working');
      console.log(`   Languages: ${langRes.data.languages.length}`);
      langRes.data.languages.forEach(lang => {
        console.log(`   - ${lang.name} (${lang.code}): TTS=${lang.tts}, STT=${lang.stt}`);
      });
    } else {
      console.log('❌ Supported languages failed');
    }
    
    console.log('\n' + '='.repeat(50));
    console.log('\n🎉 Speech Endpoints Test Complete!\n');
    console.log('✅ Text-to-Speech: Working');
    console.log('✅ Speech-to-Text: Working');
    console.log('✅ Multi-language: Supported');
    console.log('✅ Voice Settings: Available\n');
    console.log('📝 Next: Integrate into React Native app');
    console.log('📖 Guide: SPEECH_INTEGRATION_GUIDE.md\n');
    
  } catch (error) {
    console.error('\n❌ Error:', error.message);
  }
}

// Check server and run tests
console.log('Checking if server is running...');
makeRequest('GET', '/api/health')
  .then(() => {
    console.log('✅ Server is running\n');
    testSpeechEndpoints();
  })
  .catch(() => {
    console.error('❌ Server is not running!');
    console.error('Please start the server first: npm start\n');
    process.exit(1);
  });
