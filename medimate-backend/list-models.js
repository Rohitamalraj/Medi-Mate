const { GoogleGenerativeAI } = require('@google/generative-ai');

const GEMINI_API_KEY = 'AIzaSyCN5nSMutwEDYlP_LNgLShn89k9yt2R1yc';
const genAI = new GoogleGenerativeAI(GEMINI_API_KEY);

async function listModels() {
  try {
    console.log('\n📋 Listing available Gemini models...\n');
    
    const models = await genAI.listModels();
    
    console.log('Available models:');
    for await (const model of models) {
      console.log(`  - ${model.name}`);
      console.log(`    Display Name: ${model.displayName}`);
      console.log(`    Supported: ${model.supportedGenerationMethods.join(', ')}\n`);
    }
  } catch (error) {
    console.error('Error:', error.message);
  }
}

listModels();
