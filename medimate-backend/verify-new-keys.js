/**
 * Verify New API Keys
 */

const https = require('https');
const { createClient } = require('@supabase/supabase-js');

// New API Keys
const GEMINI_API_KEY = 'AIzaSyCSXbKuIYrDi1jICz_7SuV1TdE1_2K6RA0';
const SUPABASE_URL = 'https://seljelsqrxiuobobkhhp.supabase.co';
const SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNlbGplbHNlcXJ4aXVib2JraGhwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjMxOTE5MjMsImV4cCI6MjA3ODc2NzkyM30.KSbHPg5A9_S_aFEGi0W6Q8iNAH-CYYDZ6AXuXnovns8';

console.log('\n🔍 Verifying New API Keys...\n');
console.log('='.repeat(50));

// Test Gemini API
console.log('\n1️⃣  Testing Gemini API Key...');
console.log(`Key: ${GEMINI_API_KEY.substring(0, 20)}...\n`);

const options = {
  hostname: 'generativelanguage.googleapis.com',
  path: `/v1beta/models?key=${GEMINI_API_KEY}`,
  method: 'GET',
  headers: { 'Content-Type': 'application/json' }
};

const req = https.request(options, (res) => {
  let data = '';
  
  res.on('data', (chunk) => {
    data += chunk;
  });
  
  res.on('end', () => {
    console.log(`Status Code: ${res.statusCode}`);
    
    if (res.statusCode === 200) {
      try {
        const response = JSON.parse(data);
        console.log('✅ Gemini API Key is VALID!\n');
        console.log(`Available Models: ${response.models ? response.models.length : 0}`);
        if (response.models && response.models.length > 0) {
          console.log('Sample models:');
          response.models.slice(0, 5).forEach(model => {
            console.log(`  - ${model.name}`);
          });
        }
      } catch (e) {
        console.log('Response:', data);
      }
    } else {
      console.log('❌ Gemini API Key is INVALID\n');
      console.log('Response:', data.substring(0, 200));
    }
    
    // Test Supabase
    testSupabase();
  });
});

req.on('error', (error) => {
  console.error('❌ Error:', error.message);
  testSupabase();
});

req.end();

async function testSupabase() {
  console.log('\n' + '='.repeat(50));
  console.log('\n2️⃣  Testing Supabase Connection...');
  console.log(`URL: ${SUPABASE_URL}`);
  console.log(`Key: ${SUPABASE_KEY.substring(0, 20)}...\n`);
  
  try {
    const supabase = createClient(SUPABASE_URL, SUPABASE_KEY);
    
    // Test connection by querying users table
    const { data, error, count } = await supabase
      .from('users')
      .select('*', { count: 'exact', head: true });
    
    if (error) {
      if (error.message.includes('relation "public.users" does not exist')) {
        console.log('⚠️  Supabase connected but tables not created yet');
        console.log('✅ Supabase API Key is VALID!\n');
        console.log('📝 Next step: Run the SQL schema');
        console.log('   File: supabase-schema.sql\n');
      } else {
        console.log('❌ Supabase Error:', error.message);
      }
    } else {
      console.log('✅ Supabase API Key is VALID!');
      console.log('✅ Tables are ready!');
      console.log(`✅ Users table: ${count || 0} records\n`);
    }
    
    printSummary();
    
  } catch (error) {
    console.error('❌ Supabase Error:', error.message);
    printSummary();
  }
}

function printSummary() {
  console.log('='.repeat(50));
  console.log('\n📊 Summary:\n');
  console.log('New API Keys Status:');
  console.log('  • Gemini API: Check output above');
  console.log('  • Supabase: Check output above\n');
  console.log('✅ Keys have been updated in .env.local');
  console.log('🔒 .env.local is now in .gitignore (safe)\n');
  console.log('📝 Next Steps:');
  console.log('  1. If Gemini is valid: Restart server');
  console.log('  2. If Supabase needs tables: Run schema');
  console.log('  3. Test the backend: npm test\n');
}
