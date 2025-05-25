const axios = require('axios');
const { LLM_API_ENDPOINT } = require('../utils/constants');

exports.generateQuestions = async (text) => {
  try {
    const prompt = `
    Generate 5 quiz questions based on the following text. 
    Format each question as JSON with:
    - question: string
    - options: string array (4 items)
    - correctAnswerIndex: number (0-3)
    - explanation: string (optional)
    
    Text: ${text.substring(0, 2000)}... [truncated if too long]
    `;

    const response = await axios.post(LLM_API_ENDPOINT, { prompt });
    return response.data.questions;
  } catch (error) {
    console.error('LLM API error:', error);
    throw error;
  }
};