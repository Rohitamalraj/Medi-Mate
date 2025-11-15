/**
 * Direct Supabase Test
 */

const db = require('./src/config/database');

async function testSupabase() {
  console.log('\n🧪 Testing Supabase Direct Operations\n');
  
  try {
    // Test 1: Create user
    console.log('1️⃣  Creating user...');
    const user = await db.createUser('1234567890', 'Test User', 'en');
    console.log('✅ User created:', user);
    
    // Test 2: Find user by phone
    console.log('\n2️⃣  Finding user by phone...');
    const foundUser = await db.findUserByPhone('1234567890');
    console.log('✅ User found:', foundUser);
    
    // Test 3: Add medication
    console.log('\n3️⃣  Adding medication...');
    const medication = await db.createMedication(
      user.id,
      'Test Medicine',
      '1 tablet',
      '08:00',
      'daily'
    );
    console.log('✅ Medication added:', medication);
    
    // Test 4: Get medications
    console.log('\n4️⃣  Getting medications...');
    const medications = await db.getMedicationsByUserId(user.id);
    console.log('✅ Medications:', medications);
    
    // Test 5: Create conversation
    console.log('\n5️⃣  Creating conversation...');
    const conversation = await db.createConversation(
      user.id,
      'Hello',
      'Hi there!'
    );
    console.log('✅ Conversation created:', conversation);
    
    console.log('\n🎉 All Supabase operations working!\n');
    
  } catch (error) {
    console.error('\n❌ Error:', error.message);
    console.error('Full error:', error);
  }
  
  process.exit(0);
}

testSupabase();
