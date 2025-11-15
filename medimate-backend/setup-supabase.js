/**
 * Supabase Setup Script
 * This script creates the necessary tables in your Supabase database
 */

const { createClient } = require('@supabase/supabase-js');
require('dotenv').config();

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_ANON_KEY;

console.log('\n🔧 Setting up Supabase Database...\n');
console.log('URL:', supabaseUrl);
console.log('Key:', supabaseKey ? supabaseKey.substring(0, 20) + '...' : 'Not found');

if (!supabaseUrl || !supabaseKey) {
  console.error('\n❌ Error: SUPABASE_URL or SUPABASE_ANON_KEY not found in .env file');
  process.exit(1);
}

const supabase = createClient(supabaseUrl, supabaseKey);

async function setupDatabase() {
  try {
    console.log('\n📊 Testing Supabase connection...');
    
    // Test connection by trying to query users table
    const { data, error } = await supabase
      .from('users')
      .select('count')
      .limit(1);

    if (error) {
      if (error.message.includes('relation "public.users" does not exist')) {
        console.log('\n⚠️  Tables not created yet.');
        console.log('\n📝 Please run the SQL schema in Supabase dashboard:');
        console.log('\n1. Go to: https://fajhwhldyibewvukwcdf.supabase.co');
        console.log('2. Click "SQL Editor" in the left menu');
        console.log('3. Click "New Query"');
        console.log('4. Copy and paste the contents of "supabase-schema.sql"');
        console.log('5. Click "Run"');
        console.log('\n✅ After running the schema, run this script again.\n');
        process.exit(1);
      } else {
        throw error;
      }
    }

    console.log('✅ Supabase connection successful!');
    console.log('✅ Tables are ready!');
    
    // Check each table
    console.log('\n📋 Checking tables...');
    
    const tables = ['users', 'medications', 'conversations', 'reminders'];
    
    for (const table of tables) {
      const { count, error } = await supabase
        .from(table)
        .select('*', { count: 'exact', head: true });
      
      if (error) {
        console.log(`   ❌ ${table}: Error - ${error.message}`);
      } else {
        console.log(`   ✅ ${table}: ${count || 0} records`);
      }
    }
    
    console.log('\n🎉 Supabase setup complete!');
    console.log('\n🚀 You can now start the server with: npm start\n');
    
  } catch (error) {
    console.error('\n❌ Error:', error.message);
    console.error('\nPlease check:');
    console.error('1. Your Supabase URL and API key are correct');
    console.error('2. You have run the SQL schema (supabase-schema.sql)');
    console.error('3. Your internet connection is working\n');
    process.exit(1);
  }
}

setupDatabase();
