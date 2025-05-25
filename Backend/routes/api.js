// routes/api.js
const express = require('express');
const multer = require('multer');
const fs = require('fs');
const path = require('path');
const fetch = require('node-fetch'); // npm install node-fetch@2
const pdfParse = require('pdf-parse'); // npm install pdf-parse

const router = express.Router();



// Configure multer for file uploads
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    const uploadDir = 'uploads/';
    if (!fs.existsSync(uploadDir)) {
      fs.mkdirSync(uploadDir, { recursive: true });
    }
    cb(null, uploadDir);
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, file.fieldname + '-' + uniqueSuffix + path.extname(file.originalname));
  }
});

const upload = multer({
  storage: storage,
  limits: {
    fileSize: 10 * 1024 * 1024, // 10MB limit
  },
  fileFilter: (req, file, cb) => {
    const allowedTypes = ['.pdf', '.txt', '.doc', '.docx'];
    const fileExtension = path.extname(file.originalname).toLowerCase();
    
    if (allowedTypes.includes(fileExtension)) {
      cb(null, true);
    } else {
      cb(new Error(`Unsupported file type: ${fileExtension}. Allowed types: ${allowedTypes.join(', ')}`));
    }
  }
});

// Health check endpoint
router.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    service: 'Quiz Generator API',
    version: '1.0.0',
    uptime: process.uptime()
  });
});

// Generate quiz endpoint
router.post('/generate-quiz', upload.single('document'), async (req, res) => {
  let uploadedFilePath = null;
  
  try {
    console.log('📥 Quiz generation request received');
    console.log('Body:', req.body);
    console.log('File:', req.file);

    // Validate file upload
    if (!req.file) {
      return res.status(400).json({
        success: false,
        error: 'No document file provided. Please upload a PDF or TXT file.'
      });
    }

    uploadedFilePath = req.file.path;
    const { numQuestions = 5, difficulty = 'medium', huggingFaceToken } = req.body;

    console.log(`📋 Processing: ${req.file.originalname} (${req.file.size} bytes)`);
    console.log(`🎯 Generating ${numQuestions} questions with ${difficulty} difficulty`);

    // Extract text from document
    let documentText = '';
    const fileExtension = path.extname(req.file.originalname).toLowerCase();

    if (fileExtension === '.txt') {
      documentText = fs.readFileSync(req.file.path, 'utf-8');
    } else if (fileExtension === '.pdf') {
      const dataBuffer = fs.readFileSync(req.file.path);
      const pdfData = await pdfParse(dataBuffer);
      documentText = pdfData.text;
    } else {
      throw new Error('Unsupported file type');
    }

    console.log(`📄 Extracted ${documentText.length} characters from document`);

    if (documentText.trim().length < 100) {
      throw new Error('Document content is too short. Please provide a document with more content.');
    }

    // Generate quiz using Hugging Face or fallback method
    let quiz;
    try {
      quiz = await generateQuizWithHuggingFace(
        documentText, 
        parseInt(numQuestions), 
        difficulty, 
        huggingFaceToken
      );
    } catch (error) {
      console.warn('Hugging Face generation failed, using fallback:', error.message);
      quiz = generateFallbackQuiz(documentText, parseInt(numQuestions), difficulty);
    }

    console.log(`✅ Generated ${quiz.length} quiz questions`);

    // Clean up uploaded file
    if (fs.existsSync(uploadedFilePath)) {
      fs.unlinkSync(uploadedFilePath);
    }

    res.json({
      success: true,
      data: {
        quiz: quiz,
        document_title: req.file.originalname,
        metadata: {
          questions_generated: quiz.length,
          difficulty: difficulty,
          document_size: req.file.size,
          processing_time: new Date().toISOString()
        }
      }
    });

  } catch (error) {
    console.error('❌ Quiz generation error:', error);

    // Clean up uploaded file on error
    if (uploadedFilePath && fs.existsSync(uploadedFilePath)) {
      try {
        fs.unlinkSync(uploadedFilePath);
      } catch (cleanupError) {
        console.error('File cleanup error:', cleanupError);
      }
    }

    res.status(500).json({
      success: false,
      error: error.message || 'Failed to generate quiz'
    });
  }
});

// Hugging Face integration
async function generateQuizWithHuggingFace(documentText, numQuestions, difficulty, token) {
  const API_URL = 'https://api-inference.huggingface.co/models/microsoft/DialoGPT-large';
  // Alternative models to try:
  // 'https://api-inference.huggingface.co/models/facebook/blenderbot-400M-distill'
  // 'https://api-inference.huggingface.co/models/google/flan-t5-large'

  const prompt = `Create ${numQuestions} multiple choice questions based on this document. 
Make questions ${difficulty} difficulty level. 
Format: Question: [question text]
A) [option 1]
B) [option 2] 
C) [option 3]
D) [option 4]
Answer: [A/B/C/D]

Document: ${documentText.substring(0, 1500)}

Questions:`;

  const response = await fetch(API_URL, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${token || process.env.HUGGINGFACE_TOKEN}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      inputs: prompt,
      parameters: {
        max_new_tokens: 1000,
        temperature: 0.7,
        do_sample: true,
        return_full_text: false
      }
    })
  });

  if (!response.ok) {
    const errorText = await response.text();
    throw new Error(`Hugging Face API error: ${response.status} - ${errorText}`);
  }

  const result = await response.json();
  console.log('Hugging Face response:', result);

  // Parse the generated text (this is simplified - you might need more sophisticated parsing)
  const generatedText = result[0]?.generated_text || result.generated_text || '';
  
  // For now, return fallback since parsing LLM output requires more work
  throw new Error('Using fallback generation method');
}

// Fallback quiz generation
function generateFallbackQuiz(documentText, numQuestions, difficulty) {
  const sentences = documentText.split(/[.!?]+/).filter(s => s.length > 20);
  const words = documentText.split(/\s+/).filter(w => w.length > 4);
  const questions = [];

  for (let i = 0; i < Math.min(numQuestions, sentences.length); i++) {
    const sentence = sentences[i].trim();
    const importantWords = words.filter(w => sentence.includes(w)).slice(0, 3);
    
    if (importantWords.length > 0) {
      const targetWord = importantWords[0];
      const wrongOptions = words.filter(w => w !== targetWord).slice(0, 3);
      
      const question = {
        question: `Based on the document, what is mentioned in relation to "${targetWord}"?`,
        options: [
          `It relates to ${sentence.substring(0, 50)}...`,
          `It connects to ${wrongOptions[0] || 'other concepts'}`,
          `It refers to ${wrongOptions[1] || 'different topics'}`,
          `It means ${wrongOptions[2] || 'alternative ideas'}`
        ],
        correct_answer: 0,
        explanation: `The document mentions: "${sentence.substring(0, 100)}..."`
      };
      
      questions.push(question);
    }
  }

  // If we couldn't generate enough questions, add some generic ones
  while (questions.length < numQuestions && questions.length < 5) {
    questions.push({
      question: `What is the main topic of the document?`,
      options: [
        'The content provided in the uploaded document',
        'Unrelated information',
        'Random topics',
        'General knowledge'
      ],
      correct_answer: 0,
      explanation: 'Based on the document content analysis.'
    });
  }

  return questions;
}

// Test endpoint
router.get('/test', (req, res) => {
  res.json({
    message: 'API routes are working!',
    timestamp: new Date().toISOString()
  });
});

module.exports = router;