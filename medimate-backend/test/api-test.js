/**
 * Simple API Test for Supabase Backend
 */

const http = require('http');

const BASE_URL = 'http://localhost:3000';
let authToken = '';
let userId = '';
let medicationId = '';

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

async function runTests() {
  console.log('\n🧪 MediMate Backend API Tests (Supabase)\n');
  console.log('='.repeat(50));
  
  let passed = 0;
  let failed = 0;

  // Test 1: Health Check
  try {
    console.log('\n1. Health Check');
    const res = await makeRequest('GET', '/api/health');
    if (res.status === 200 && res.data.success) {
      console.log('   ✅ Health check passed');
      passed++;
    } else throw new Error('Failed');
  } catch (error) {
    console.log('   ❌ Health check failed');
    failed++;
  }

  // Test 2: Login (user should exist from previous tests)
  try {
    console.log('\n2. Login User');
    const res = await makeRequest('POST', '/api/auth/login', {
      phone: '9876543210'
    });
    if (res.status === 200 && res.data.success) {
      authToken = res.data.token;
      userId = res.data.user.id;
      console.log(`   ✅ Login successful (ID: ${userId})`);
      passed++;
    } else {
      // Try to register if login fails
      const regRes = await makeRequest('POST', '/api/auth/register', {
        phone: '9876543210',
        name: 'Test User',
        language: 'en'
      });
      if (regRes.status === 201 && regRes.data.success) {
        authToken = regRes.data.token;
        userId = regRes.data.user.id;
        console.log(`   ✅ User registered (ID: ${userId})`);
        passed++;
      } else throw new Error('Failed');
    }
  } catch (error) {
    console.log('   ❌ Login/Register failed');
    failed++;
  }

  // Test 3: Add Medication
  try {
    console.log('\n3. Add Medication');
    const res = await makeRequest('POST', '/api/medications', {
      user_id: userId,
      medicine_name: 'Blood Pressure Medicine',
      dosage: '1 tablet',
      time: '08:00',
      frequency: 'daily'
    }, authToken);
    if (res.status === 201 && res.data.success) {
      medicationId = res.data.medication.id;
      console.log(`   ✅ Medication added (ID: ${medicationId})`);
      passed++;
    } else throw new Error('Failed');
  } catch (error) {
    console.log('   ❌ Add medication failed');
    failed++;
  }

  // Test 4: Get Medications
  try {
    console.log('\n4. Get Medications');
    const res = await makeRequest('GET', `/api/medications/${userId}`, null, authToken);
    if (res.status === 200 && res.data.success) {
      console.log(`   ✅ Retrieved ${res.data.count} medication(s)`);
      passed++;
    } else throw new Error('Failed');
  } catch (error) {
    console.log('   ❌ Get medications failed');
    failed++;
  }

  // Test 5: Chat with AI
  try {
    console.log('\n5. Chat with AI (English)');
    const res = await makeRequest('POST', '/api/chat', {
      userId: userId,
      message: 'Hello, how are you?',
      language: 'en'
    }, authToken);
    if (res.status === 200 && res.data.success) {
      console.log(`   ✅ AI responded: "${res.data.response.substring(0, 50)}..."`);
      passed++;
    } else throw new Error('Failed');
  } catch (error) {
    console.log('   ❌ Chat failed');
    failed++;
  }

  // Test 6: Get User Stats
  try {
    console.log('\n6. Get User Stats');
    const res = await makeRequest('GET', `/api/users/${userId}/stats`, null, authToken);
    if (res.status === 200 && res.data.success) {
      console.log(`   ✅ Stats: ${res.data.stats.total_medications} meds, ${res.data.stats.total_conversations} chats`);
      passed++;
    } else throw new Error('Failed');
  } catch (error) {
    console.log('   ❌ Get stats failed');
    failed++;
  }

  // Test 7: Get Pending Reminders
  try {
    console.log('\n7. Get Pending Reminders');
    const res = await makeRequest('GET', `/api/reminders/pending/${userId}`, null, authToken);
    if (res.status === 200 && res.data.success) {
      console.log(`   ✅ Pending reminders: ${res.data.count}`);
      passed++;
    } else throw new Error('Failed');
  } catch (error) {
    console.log('   ❌ Get reminders failed');
    failed++;
  }

  console.log('\n' + '='.repeat(50));
  console.log(`\n📊 Results: ${passed} passed, ${failed} failed\n`);

  if (failed === 0) {
    console.log('✅ All tests passed! Supabase backend is working!\n');
    console.log('🗄️  Check your Supabase dashboard to see the data!\n');
  } else {
    console.log('❌ Some tests failed. Check the errors above.\n');
  }

  process.exit(failed > 0 ? 1 : 0);
}

// Check server and run tests
console.log('Checking if server is running...');
makeRequest('GET', '/api/health')
  .then(() => {
    console.log('✅ Server is running\n');
    runTests();
  })
  .catch(() => {
    console.error('❌ Server is not running!');
    console.error('Please start the server first: npm start\n');
    process.exit(1);
  });
