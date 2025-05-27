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

    // Generate quiz using fallback method (Hugging Face integration commented out for now)
    let quiz;
    try {
      // For now, we'll use the fallback method as it's more reliable
      quiz = generateFallbackQuiz(documentText, parseInt(numQuestions), difficulty);
      
      // Uncomment this if you have a valid Hugging Face token
      // quiz = await generateQuizWithHuggingFace(
      //   documentText, 
      //   parseInt(numQuestions), 
      //   difficulty, 
      //   huggingFaceToken
      // );
    } catch (error) {
      console.warn('Quiz generation failed:', error.message);
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

// Hugging Face integration (currently not used)
async function generateQuizWithHuggingFace(documentText, numQuestions, difficulty, token) {
  // Use a more suitable model for text generation
  const API_URL = 'https://api-inference.huggingface.co/models/google/flan-t5-large';

  const prompt = `Generate ${numQuestions} multiple choice questions with ${difficulty} difficulty based on this text:

${documentText.substring(0, 1000)}

Format each question as:
Q: [question]
A) [option]
B) [option] 
C) [option]
D) [option]
Correct: [A/B/C/D]`;

  const response = await fetch(API_URL, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${token || process.env.HUGGINGFACE_TOKEN}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      inputs: prompt,
      parameters: {
        max_new_tokens: 800,
        temperature: 0.7,
        do_sample: true
      }
    })
  });

  if (!response.ok) {
    const errorText = await response.text();
    throw new Error(`Hugging Face API error: ${response.status} - ${errorText}`);
  }

  const result = await response.json();
  console.log('Hugging Face response:', result);

  // This would need proper parsing of the generated text
  // For now, fall back to the simple method
  throw new Error('Using fallback generation method');
}

// Improved fallback quiz generation
function generateFallbackQuiz(documentText, numQuestions, difficulty) {
  const sentences = documentText
    .split(/[.!?]+/)
    .map(s => s.trim())
    .filter(s => s.length > 30 && s.length < 200);
  
  const words = documentText
    .toLowerCase()
    .split(/\s+/)
    .filter(w => w.length > 4 && /^[a-zA-Z]+$/.test(w));
  
  // Get unique important words
  const wordFreq = {};
  words.forEach(word => {
    wordFreq[word] = (wordFreq[word] || 0) + 1;
  });
  
  const importantWords = Object.keys(wordFreq)
    .filter(word => wordFreq[word] > 1)
    .sort((a, b) => wordFreq[b] - wordFreq[a])
    .slice(0, 20);

  const questions = [];
  const usedSentences = new Set();

  for (let i = 0; i < Math.min(numQuestions, sentences.length); i++) {
    let sentence = sentences[i];
    let attempts = 0;
    
    // Try to find a sentence we haven't used
    while (usedSentences.has(sentence) && attempts < sentences.length) {
      sentence = sentences[Math.floor(Math.random() * sentences.length)];
      attempts++;
    }
    
    if (usedSentences.has(sentence)) break;
    usedSentences.add(sentence);

    // Find a key term in this sentence
    const sentenceWords = sentence.toLowerCase().split(/\s+/);
    const keyWord = importantWords.find(word => sentenceWords.includes(word));
    
    if (keyWord) {
      const otherWords = importantWords.filter(w => w !== keyWord).slice(0, 3);
      
      // Create different question types based on difficulty
      let question;
      if (difficulty === 'easy') {
        question = {
          question: `According to the document, what is mentioned about "${keyWord}"?`,
          options: [
            sentence.substring(0, 80) + (sentence.length > 80 ? '...' : ''),
            `It relates to ${otherWords[0] || 'different concepts'}`,
            `It involves ${otherWords[1] || 'other topics'}`,
            `It concerns ${otherWords[2] || 'alternative subjects'}`
          ],
          correct_answer: 0,
          explanation: `The document states: "${sentence}"`
        };
      } else if (difficulty === 'medium') {
        question = {
          question: `What can be inferred about "${keyWord}" from the document?`,
          options: [
            `It is described as: ${sentence.substring(0, 60)}...`,
            `It primarily involves ${otherWords[0] || 'unrelated concepts'}`,
            `It is mainly about ${otherWords[1] || 'different subjects'}`,
            `It focuses on ${otherWords[2] || 'other topics'}`
          ],
          correct_answer: 0,
          explanation: `Based on the text: "${sentence}"`
        };
      } else { // hard
        question = {
          question: `Analyze the relationship between "${keyWord}" and the main concept discussed in the document.`,
          options: [
            `${keyWord} is integral to the main discussion as shown by: ${sentence.substring(0, 50)}...`,
            `${keyWord} contradicts the main theme regarding ${otherWords[0] || 'other aspects'}`,
            `${keyWord} is unrelated to the core concepts involving ${otherWords[1] || 'different elements'}`,
            `${keyWord} minimally impacts the discussion about ${otherWords[2] || 'various topics'}`
          ],
          correct_answer: 0,
          explanation: `The document demonstrates this relationship through: "${sentence}"`
        };
      }
      
      questions.push(question);
    }
  }

  // Fill remaining questions if needed
  while (questions.length < numQuestions && questions.length < 10) {
    const remainingSentences = sentences.filter(s => !usedSentences.has(s));
    if (remainingSentences.length === 0) break;
    
    const randomSentence = remainingSentences[Math.floor(Math.random() * remainingSentences.length)];
    usedSentences.add(randomSentence);
    
    questions.push({
      question: `What does the document mention about the following topic?`,
      options: [
        randomSentence.substring(0, 80) + (randomSentence.length > 80 ? '...' : ''),
        'This information is not discussed in the document',
        'The document contradicts this information',
        'This topic is mentioned differently'
      ],
      correct_answer: 0,
      explanation: `The document states: "${randomSentence}"`
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