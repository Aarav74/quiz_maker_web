import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'quiz_results_screen.dart';
import '../widgets/loading_animation.dart';

class QuizGenerationScreen extends StatefulWidget {
  final String filePath;
  final int numQuestions;
  final String difficulty;

  const QuizGenerationScreen({
    super.key,
    required this.filePath,
    this.numQuestions = 5,
    this.difficulty = 'medium', required String huggingFaceToken,
  });

  @override
  State<QuizGenerationScreen> createState() => _QuizGenerationScreenState();
}

class _QuizGenerationScreenState extends State<QuizGenerationScreen> {
  bool _isGenerating = true;
  double _progress = 0;
  String _status = 'Preparing document...';
  String? _errorMessage;
  List<Map<String, dynamic>> _questions = [];

  @override
  void initState() {
    super.initState();
    _generateQuiz();
  }

  Future<void> _generateQuiz() async {
    try {
      // Step 1: Prepare document
      await _updateProgress(0.1, 'Processing document...');
      
      // Step 2: Send to backend
      await _updateProgress(0.3, 'Sending to AI...');
      final response = await http.post(
        Uri.parse('${_getBackendUrl()}/generate-quiz'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'filePath': widget.filePath,
          'numQuestions': widget.numQuestions,
          'difficulty': widget.difficulty,
        }),
      ).timeout(const Duration(seconds: 60));

      // Handle potential XML responses
      if (response.headers['content-type']?.contains('xml') ?? false) {
        throw Exception('Server returned XML instead of JSON');
      }

      // Step 3: Parse response
      await _updateProgress(0.7, 'Generating quiz...');
      final responseData = json.decode(response.body);
      
      if (response.statusCode == 200) {
        _questions = List<Map<String, dynamic>>.from(responseData['questions'] ?? []);
        if (_questions.isEmpty) {
          throw Exception('No questions were generated');
        }
        
        // Step 4: Complete
        await _updateProgress(1.0, 'Quiz ready!');
        await Future.delayed(500.ms);
        
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => QuizResultsScreen(questions: _questions, quizData: [], documentTitle: '',),
            ),
          );
        }
      } else {
        throw Exception(responseData['error'] ?? 'Failed to generate quiz');
      }
    } catch (e) {
      setState(() {
        _errorMessage = _getErrorMessage(e);
        _isGenerating = false;
      });
    }
  }

  String _getBackendUrl() {
    // Replace with your actual backend URL
    return 'http://localhost:3001'; // Development
    // return 'https://your-api.example.com'; // Production
  }

  String _getErrorMessage(dynamic error) {
    final errorStr = error.toString();
    
    if (errorStr.contains('_namespace') || errorStr.contains('XML')) {
      return '''
Server configuration issue:
1. Ensure your backend returns JSON (not XML)
2. Check server error pages
3. Verify CORS headers include:
   Content-Type: application/json
''';
    } else if (errorStr.contains('Timeout')) {
      return 'Request timed out. Try a smaller document.';
    } else if (errorStr.contains('SocketException')) {
      return 'Connection failed. Check your network/server.';
    }
    return errorStr.replaceAll('Exception: ', '');
  }

  Future<void> _updateProgress(double value, String status) async {
    if (mounted) {
      setState(() {
        _progress = value;
        _status = status;
      });
    }
    await Future.delayed(300.ms);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generating Quiz'),
        centerTitle: true,
      ),
      body: _errorMessage != null
          ? _buildErrorContent()
          : _isGenerating
              ? _buildLoadingContent()
              : _buildSuccessContent(),
    );
  }

  Widget _buildLoadingContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const AILoadingAnimation(size: 150),
          const SizedBox(height: 24),
          Text(
            _status,
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: _progress,
            minHeight: 8,
          ),
          const SizedBox(height: 8),
          Text('${(_progress * 100).toStringAsFixed(0)}%'),
        ],
      ),
    );
  }

  Widget _buildErrorContent() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _errorMessage = null;
                  _isGenerating = true;
                  _progress = 0;
                });
                _generateQuiz();
              },
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, size: 64, color: Colors.green),
          const SizedBox(height: 16),
          const Text(
            'Quiz Generated!',
            style: TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => QuizResultsScreen(questions: _questions, quizData: [], documentTitle: '',),
                ),
              );
            },
            child: const Text('View Quiz'),
          ),
        ],
      ),
    );
  }
}