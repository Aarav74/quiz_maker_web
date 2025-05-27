import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class QuizApiService {
  // Update this URL to your Express.js app URL
  // For web development (running flutter on web)
  static const String _baseUrl = 'http://localhost:3001';
  
  // For Android emulator
  // static const String _baseUrl = 'http://10.0.2.2:3001';
  
  // For iOS simulator
  // static const String _baseUrl = 'http://127.0.0.1:3001';
  
  // For production
  // static const String _baseUrl = 'https://your-app.herokuapp.com';
  static const Duration _timeout = Duration(minutes: 2);

  static Future<QuizGenerationResponse> generateQuiz({
    required String filePath,
    int numQuestions = 5,
    String difficulty = 'medium',
    String? huggingFaceToken,
    Function(double, String)? onProgress,
  }) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw QuizGenerationException('Document file not found');
      }

      onProgress?.call(0.1, 'Preparing document...');

      final fileSize = await file.length();
      if (fileSize > 10 * 1024 * 1024) {
        throw QuizGenerationException('File too large. Max size is 10MB.');
      }

      // ✅ CORRECT API ENDPOINT
      final apiUrl = '$_baseUrl/api/generate-quiz';
      
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(apiUrl),
      );

      // Add file
      request.files.add(await http.MultipartFile.fromPath('document', filePath));
      
      // Add form fields
      request.fields['numQuestions'] = numQuestions.toString();
      request.fields['difficulty'] = difficulty;
      if (huggingFaceToken != null && huggingFaceToken.isNotEmpty) {
        request.fields['huggingFaceToken'] = huggingFaceToken;
      }

      // Add headers
      request.headers.addAll({
        'Accept': 'application/json',
        // 'Content-Type': 'multipart/form-data', // Let http package handle this
      });

      onProgress?.call(0.5, 'Uploading and processing...');

      final streamedResponse = await request.send().timeout(_timeout);
      final response = await http.Response.fromStream(streamedResponse);

      // Debug logging

      if (response.statusCode == 200) {
        // Check if response is JSON
        if (response.headers['content-type']?.contains('application/json') != true) {
          throw QuizGenerationException('Server returned non-JSON response. Check if API endpoint exists.');
        }

        final data = json.decode(response.body);
        
        if (data['success'] == true) {
          final quizData = List<Map<String, dynamic>>.from(data['data']['quiz'] ?? []);
          onProgress?.call(1.0, 'Quiz ready!');

          return QuizGenerationResponse(
            success: true,
            quiz: quizData,
            documentTitle: data['data']['document_title'] ?? file.path.split('/').last,
            metadata: QuizMetadata(
              questionsGenerated: quizData.length,
              difficulty: difficulty,
              documentSize: fileSize,
              processingTime: DateTime.now(),
            ),
          );
        } else {
          throw QuizGenerationException(data['error'] ?? 'Quiz generation failed');
        }
      } else {
        String errorMessage = 'Server error (${response.statusCode})';
        
        try {
          final errorData = json.decode(response.body);
          errorMessage = errorData['error'] ?? errorMessage;
        } catch (_) {
          // If response is not JSON, use status-based error message
          switch (response.statusCode) {
            case 404:
              errorMessage = 'API endpoint not found. Check your Express server.';
              break;
            case 405:
              errorMessage = 'Method not allowed. Check API route configuration.';
              break;
            case 413:
              errorMessage = 'File too large.';
              break;
            case 500:
              errorMessage = 'Internal server error. Check server logs.';
              break;
            default:
              errorMessage = 'Server error: ${response.statusCode}';
          }
        }
        
        throw QuizGenerationException(errorMessage);
      }
    } catch (e) {
      if (e is QuizGenerationException) rethrow;
      throw QuizGenerationException(_parseError(e));
    }
  }

  static Future<bool> isServiceAvailable() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/health'), // ✅ Fixed: Added /api prefix
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<Map<String, dynamic>> getServiceHealth() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/health'), // ✅ Fixed: Added /api prefix
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'status': 'error', 
          'message': 'Service unavailable (${response.statusCode})'
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  static String _parseError(dynamic error) {
    final msg = error.toString().toLowerCase();

    if (msg.contains('socketexception') || msg.contains('connection refused')) {
      return 'Cannot connect to server. Make sure your Express server is running on $_baseUrl';
    } else if (msg.contains('timeout')) {
      return 'Request timed out. The server might be overloaded.';
    } else if (msg.contains('formatexception') || msg.contains('unexpected token')) {
      return 'Server returned invalid response. Check if the API endpoint exists.';
    } else if (msg.contains('file not found')) {
      return 'Document not found. Please reselect the file.';
    } else {
      return error.toString().replaceAll('Exception: ', '');
    }
  }
}

class QuizGenerationResponse {
  final bool success;
  final List<Map<String, dynamic>> quiz;
  final String documentTitle;
  final QuizMetadata? metadata;
  final String? error;

  QuizGenerationResponse({
    required this.success,
    this.quiz = const [],
    this.documentTitle = '',
    this.metadata,
    this.error,
  });

  factory QuizGenerationResponse.error(String error) {
    return QuizGenerationResponse(
      success: false,
      error: error,
    );
  }
}

class QuizMetadata {
  final int questionsGenerated;
  final String difficulty;
  final int documentSize;
  final DateTime processingTime;

  QuizMetadata({
    required this.questionsGenerated,
    required this.difficulty,
    required this.documentSize,
    required this.processingTime,
  });
}

class QuizGenerationException implements Exception {
  final String message;
  QuizGenerationException(this.message);
  
  @override
  String toString() => message;
}