const express = require('express');
const cors = require('cors');
const path = require('path');

const app = express();

// CORS configuration for Flutter
const corsOptions = {
  origin: function (origin, callback) {
    // Allow requests with no origin (mobile apps, Postman, etc.)
    if (!origin || origin.startsWith('http://localhost') || origin.startsWith('https://localhost')) {
      return callback(null, true);
    }
    return callback(new Error('Not allowed by CORS: ' + origin));
  },
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'Accept'],
};

// Apply CORS middleware first - REMOVE DUPLICATE
app.use(cors(corsOptions));
app.options('*', cors(corsOptions));

// Other middleware
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Add request logging
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.path}`);
  if (req.method !== 'GET') {
    console.log('Headers:', req.headers);
    console.log('Body:', req.body);
  }
  next();
});

// Import routes
const apiRoutes = require('./routes/api');

// Root route
app.get('/', (req, res) => {
  res.json({ 
    status: 'ok', 
    message: 'Quiz Generator API is working',
    timestamp: new Date().toISOString(),
    endpoints: [
      'GET / - This message',
      'GET /api/health - Health check',
      'POST /api/generate-quiz - Generate quiz from document'
    ]
  });
});

// API routes
app.use('/api', apiRoutes);

// 404 handler for API routes
app.use('/api/*', (req, res) => {
  res.status(404).json({ 
    success: false,
    error: `API endpoint ${req.path} not found`,
    available_endpoints: [
      'GET /api/health',
      'POST /api/generate-quiz'
    ]
  });
});

// Global error handling
app.use((err, req, res, next) => {
  console.error('Error occurred:', err.stack);
  
  // Handle CORS errors
  if (err.message && err.message.includes('Not allowed by CORS')) {
    return res.status(403).json({
      success: false,
      error: 'CORS error: Origin not allowed'
    });
  }
  
  // Handle specific error types
  if (err.code === 'LIMIT_FILE_SIZE') {
    return res.status(413).json({
      success: false,
      error: 'File too large. Maximum size is 10MB.'
    });
  }
  
  if (err.code === 'LIMIT_UNEXPECTED_FILE') {
    return res.status(400).json({
      success: false,
      error: 'Unexpected file upload.'
    });
  }
  
  res.status(500).json({ 
    success: false,
    error: 'Internal server error',
    message: process.env.NODE_ENV === 'development' ? err.message : 'Something went wrong!'
  });
});

// Handle unhandled promise rejections
process.on('unhandledRejection', (reason, promise) => {
  console.error('Unhandled Rejection at:', promise, 'reason:', reason);
});

// Handle uncaught exceptions
process.on('uncaughtException', (error) => {
  console.error('Uncaught Exception:', error);
  process.exit(1);
});

const PORT = process.env.PORT || 3001;
app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Server running on port ${PORT}`);
  console.log(`📍 Access at: http://localhost:${PORT}`);
  console.log(`🏥 Health check: http://localhost:${PORT}/api/health`);
  console.log(`📝 Quiz generation: http://localhost:${PORT}/api/generate-quiz`);
});

module.exports = app;