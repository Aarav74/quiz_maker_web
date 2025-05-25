import 'package:flutter/material.dart';

class QuizResultsScreen extends StatefulWidget {
  final List<Map<String, dynamic>> quizData;
  final String documentTitle;

  const QuizResultsScreen({
    super.key,
    required this.quizData,
    required this.documentTitle, required List<Map<String, dynamic>> questions,
  });

  @override
  State<QuizResultsScreen> createState() => _QuizResultsScreenState();
}

class _QuizResultsScreenState extends State<QuizResultsScreen> {
  Map<int, String> userAnswers = {};
  Map<int, bool> showResults = {};
  int currentQuestionIndex = 0;
  bool showFinalResults = false;

  @override
  Widget build(BuildContext context) {
    if (widget.quizData.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Quiz Results'),
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text(
                'No quiz questions generated',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Please check your document and try again',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz: ${widget.documentTitle}'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          if (!showFinalResults)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Center(
                child: Text(
                  '${currentQuestionIndex + 1}/${widget.quizData.length}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
        ],
      ),
      body: showFinalResults ? _buildFinalResults() : _buildQuizQuestion(),
    );
  }

  Widget _buildQuizQuestion() {
    final question = widget.quizData[currentQuestionIndex];
    final questionText = question['question'] ?? 'No question available';
    final options = List<String>.from(question['options'] ?? []);
    final correctAnswer = question['correct_answer'] ?? '';

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Progress indicator
          LinearProgressIndicator(
            value: (currentQuestionIndex + 1) / widget.quizData.length,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.deepPurple),
          ),
          const SizedBox(height: 24),
          
          // Question card
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Question ${currentQuestionIndex + 1}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    questionText,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Options
          ...options.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;
            final optionLetter = String.fromCharCode(65 + index); // A, B, C, D
            
            final isSelected = userAnswers[currentQuestionIndex] == option;
            final hasAnswered = userAnswers.containsKey(currentQuestionIndex);
            final showResult = showResults[currentQuestionIndex] ?? false;
            final isCorrect = option == correctAnswer;
            
            Color? backgroundColor;
            Color? borderColor;
            Color textColor = Colors.black87;
            
            if (showResult && hasAnswered) {
              if (isSelected) {
                backgroundColor = isCorrect ? Colors.green[100] : Colors.red[100];
                borderColor = isCorrect ? Colors.green : Colors.red;
                textColor = isCorrect ? Colors.green[800]! : Colors.red[800]!;
              } else if (isCorrect) {
                backgroundColor = Colors.green[50];
                borderColor = Colors.green[300];
                textColor = Colors.green[700]!;
              }
            } else if (isSelected && !showResult) {
              backgroundColor = Colors.deepPurple[50];
              borderColor = Colors.deepPurple;
              textColor = Colors.deepPurple[800]!;
            }
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: InkWell(
                onTap: hasAnswered && showResult ? null : () => _selectAnswer(option),
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: backgroundColor ?? Colors.white,
                    border: Border.all(
                      color: borderColor ?? Colors.grey[300]!,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? (showResult && isCorrect ? Colors.green : Colors.deepPurple) : Colors.transparent,
                          border: Border.all(
                            color: isSelected ? (showResult && isCorrect ? Colors.green : Colors.deepPurple) : Colors.grey,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            optionLetter,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.grey[600],
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          option,
                          style: TextStyle(
                            fontSize: 16,
                            color: textColor,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (showResult && isCorrect)
                        const Icon(Icons.check_circle, color: Colors.green, size: 20),
                      if (showResult && isSelected && !isCorrect)
                        const Icon(Icons.cancel, color: Colors.red, size: 20),
                    ],
                  ),
                ),
              ),
            );
          }),
          
          const SizedBox(height: 24),
          
          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (currentQuestionIndex > 0)
                ElevatedButton.icon(
                  onPressed: _previousQuestion,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Previous'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.black87,
                  ),
                ),
              const Spacer(),
              if (userAnswers.containsKey(currentQuestionIndex) && !(showResults[currentQuestionIndex] ?? false))
                ElevatedButton(
                  onPressed: _checkAnswer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Check Answer'),
                ),
              if (showResults[currentQuestionIndex] ?? false)
                ElevatedButton.icon(
                  onPressed: currentQuestionIndex < widget.quizData.length - 1 
                      ? _nextQuestion 
                      : _showFinalResults,
                  icon: Icon(currentQuestionIndex < widget.quizData.length - 1 
                      ? Icons.arrow_forward 
                      : Icons.assessment),
                  label: Text(currentQuestionIndex < widget.quizData.length - 1 
                      ? 'Next' 
                      : 'Results'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFinalResults() {
    final correctAnswers = _getCorrectAnswersCount();
    final totalQuestions = widget.quizData.length;
    final percentage = (correctAnswers / totalQuestions * 100).round();
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const Icon(
                    Icons.emoji_events,
                    size: 64,
                    color: Colors.amber,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Quiz Complete!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You scored $correctAnswers out of $totalQuestions',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$percentage%',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: _getScoreColor(percentage),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => setState(() {
              showFinalResults = false;
              currentQuestionIndex = 0;
            }),
            icon: const Icon(Icons.refresh),
            label: const Text('Review Answers'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Take New Quiz'),
          ),
        ],
      ),
    );
  }

  void _selectAnswer(String answer) {
    setState(() {
      userAnswers[currentQuestionIndex] = answer;
    });
  }

  void _checkAnswer() {
    setState(() {
      showResults[currentQuestionIndex] = true;
    });
  }

  void _nextQuestion() {
    if (currentQuestionIndex < widget.quizData.length - 1) {
      setState(() {
        currentQuestionIndex++;
      });
    }
  }

  void _previousQuestion() {
    if (currentQuestionIndex > 0) {
      setState(() {
        currentQuestionIndex--;
      });
    }
  }

  void _showFinalResults() {
    setState(() {
      showFinalResults = true;
    });
  }

  int _getCorrectAnswersCount() {
    int correct = 0;
    for (int i = 0; i < widget.quizData.length; i++) {
      final question = widget.quizData[i];
      final correctAnswer = question['correct_answer'];
      final userAnswer = userAnswers[i];
      if (userAnswer == correctAnswer) {
        correct++;
      }
    }
    return correct;
  }

  Color _getScoreColor(int percentage) {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 60) return Colors.orange;
    return Colors.red;
  }
}