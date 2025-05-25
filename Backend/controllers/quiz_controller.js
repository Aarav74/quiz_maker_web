// controllers/quizController.js
const generateQuestions = async (text) => {
  // Implement your AI integration here
  // This is a mock response
  return [
    {
      question: "What is the capital of France?",
      options: ["London", "Berlin", "Paris", "Madrid"],
      correctAnswerIndex: 2,
      explanation: "Paris has been the capital of France since 508 AD"
    }
  ];
};

exports.generateQuiz = async (req, res) => {
  try {
    const { text, hide_answers } = req.body;
    let questions = await generateQuestions(text);
    
    if (hide_answers) {
      questions = questions.map(q => ({
        question: q.question,
        options: q.options,
      }));
    }
    
    res.json(questions);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};