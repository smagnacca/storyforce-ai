/**
 * Fable LLM Integration Test
 * Tests real API calls without mocking
 */

const axios = require('axios');
require('dotenv').config();

const FABLE_API_KEY = process.env.FABLE_API_KEY;
const FABLE_MODEL = process.env.FABLE_MODEL || 'claude-fable-5';
const BASE_URL = 'https://api.anthropic.com/v1';

console.log('🔍 Testing Fable LLM Integration...\n');

// Test profile: Insurance Agent
const testProfile = {
  client_name: 'Sarah Chen',
  client_role: 'Insurance Agent',
  company: 'Liberty Mutual',
  industry: 'Insurance',
  winter: {
    fear: 'Losing clients to online competitors',
    pain: 'Price competition from digital platforms',
    frustration: 'Difficulty building relationships online'
  },
  spring: {
    vision: 'Referral-based growth through relationships',
    outcome: 'Positioned as trusted advisor',
    feeling: 'Confident and connected'
  }
};

// Three-Act Story Prompt
const prompt = `Generate a compelling three-act sales story for ${testProfile.client_name}, ${testProfile.client_role} at ${testProfile.company}.

CONTEXT:
- Industry: ${testProfile.industry}
- Pain Point: ${testProfile.winter.pain}
- Vision: ${testProfile.spring.vision}

INSTRUCTIONS:
Create a story with three acts:

**Act 1 (Inciting Incident):**
- Open with Sarah's frustration: ${testProfile.winter.frustration}
- Show her struggling to connect with prospects online
- Make it personal and specific to insurance sales

**Act 2 (Turning Point):**
- Introduce a shift in her approach
- Show her leveraging existing relationships
- Demonstrate the power of personal trust and referrals

**Act 3 (Resolution):**
- Show Sarah as the ${testProfile.spring.outcome}
- Paint a vivid picture of her success
- Leave the audience inspired

Keep the story to 300-400 words. Use vivid details and metaphors.`;

async function testFableAPI() {
  try {
    console.log('📤 Sending request to Fable API...\n');
    console.log('Profile:', testProfile.client_name);
    console.log('Role:', testProfile.client_role);
    console.log('Industry:', testProfile.industry);
    console.log('\n');

    const startTime = Date.now();

    const response = await axios.post(
      `${BASE_URL}/messages`,
      {
        model: FABLE_MODEL,
        max_tokens: 1024,
        messages: [{
          role: 'user',
          content: prompt
        }]
      },
      {
        headers: {
          'anthropic-version': '2023-06-01',
          'x-api-key': FABLE_API_KEY,
          'content-type': 'application/json'
        },
        timeout: 30000
      }
    );

    const elapsed = Date.now() - startTime;

    console.log('✅ API Response Received\n');
    console.log('-------------------------------------------');
    console.log('Response:', response.data.content[0].text);
    console.log('-------------------------------------------\n');

    // Usage tracking
    const usage = response.data.usage;
    console.log('📊 Token Usage:');
    console.log(`  - Input tokens: ${usage.input_tokens}`);
    console.log(`  - Output tokens: ${usage.output_tokens}`);
    console.log(`  - Total: ${usage.input_tokens + usage.output_tokens}`);

    // Cost calculation (Opus 4.1 pricing)
    const inputCost = (usage.input_tokens / 1_000_000) * 15;
    const outputCost = (usage.output_tokens / 1_000_000) * 45;
    const totalCost = inputCost + outputCost;

    console.log('\n💰 Cost Estimate (Anthropic Opus 4.1):');
    console.log(`  - Input: $${inputCost.toFixed(6)}`);
    console.log(`  - Output: $${outputCost.toFixed(6)}`);
    console.log(`  - Total: $${totalCost.toFixed(6)}`);

    console.log('\n⏱️ Performance:');
    console.log(`  - Latency: ${elapsed}ms`);
    console.log(`  - Tokens/sec: ${((usage.input_tokens + usage.output_tokens) / (elapsed / 1000)).toFixed(2)}`);

    console.log('\n✅ Fable Integration Test PASSED\n');
    process.exit(0);

  } catch (err) {
    console.error('❌ Fable Integration Test FAILED\n');
    console.error('Error:', err.response?.data || err.message);
    
    if (err.response?.status === 401) {
      console.error('\nℹ️ Authentication failed. Check FABLE_API_KEY in .env');
    }
    if (err.code === 'ECONNABORTED') {
      console.error('\nℹ️ Request timeout. API may be unreachable.');
    }

    process.exit(1);
  }
}

testFableAPI();
