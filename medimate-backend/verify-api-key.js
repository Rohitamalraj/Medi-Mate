/**
 * Verify Gemini API Key
 */

const https = require('https');

const API_KEY = 'AIzaSyCN5nSMutwEDYlP_LNgLShn89k9yt2R1yc';

console.log('\n🔍 Verifying Gemini API Key...\n');
console.log(`API Key: ${API_KEY}\n`);

// Try to list models using REST API
const options = {
  hostname: 'generativelanguage.googleapis.com',
  path: `/v1beta/models?key=${API_KEY}`,
  method: 'GET',
  headers: {
    'Content-Type': 'application/json'
  }
};

const req = https.request(options, (res) => {
  let data = '';
  
  res.on('data', (chunk) => {
    data += chunk;
  });
  
  res.on('end', () => {
    console.log(`Status Code: ${res.statusCode}\n`);
    
    if (res.statusCode === 200) {
      try {
        const response = JSON.parse(data);
        console.log('✅ API Key is VALID!\n');
        console.log('Available Models:');
        if (response.models) {
          response.models.forEach(model => {
            console.log(`  - ${model.name}`);
          });
        }
        console.log('\n✅ You can use Gemini API!');
      } catch (e) {
        console.log('Response:', data);
      }
    } else {
      console.log('❌ API Key is INVALID or EXPIRED\n');
      console.log('Response:', data);
      console.log('\n💡 To fix:');
      console.log('   1. Go to: https://makersuite.google.com/app/apikey');
      console.log('   2. Sign in with your Google account');
      console.log('   3. Create a new API key');
      console.log('   4. Copy the new key');
      console.log('   5. Update your .env file\n');
      console.log('⚠️  Note: Your app still works with mock responses!');
    }
  });
});

req.on('error', (error) => {
  console.error('❌ Error:', error.message);
});

req.end();
