module.exports = {
  LLM_API_ENDPOINT: process.env.LLM_API_ENDPOINT || 'http://localhost:3001/generate',
  MAX_FILE_SIZE: 5 * 1024 * 1024, // 5MB
  SUPPORTED_FILE_TYPES: ['pdf', 'docx', 'txt']
};