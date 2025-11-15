/**
 * Clear test data from Supabase
 */

const { createClient } = require('@supabase/supabase-js');
require('dotenv').config();

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_ANON_KEY
);

async function clearData() {
  console.log('\n🧹 Clearing test data from Supabase...\n');
  
  try {
    // Delete in correct order (child tables first)
    console.log('Deleting reminders...');
    await supabase.from('reminders').delete().neq('id', 0);
    
    console.log('Deleting conversations...');
    await supabase.from('conversations').delete().neq('id', 0);
    
    console.log('Deleting medications...');
    await supabase.from('medications').delete().neq('id', 0);
    
    console.log('Deleting users...');
    await supabase.from('users').delete().neq('id', 0);
    
    console.log('\n✅ All test data cleared!');
    console.log('🧪 You can now run: npm test\n');
    
  } catch (error) {
    console.error('\n❌ Error:', error.message);
  }
}

clearData();
