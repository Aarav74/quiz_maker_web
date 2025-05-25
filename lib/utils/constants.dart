import 'dart:ui';

class AppColors {
  static const primary = Color(0xFF6C63FF);
  static const secondary = Color(0xFF4A44B7);
  static const accent = Color(0xFFF9A826);
  static const background = Color(0xFFF8F9FA);
}

class ApiEndpoints {
  static const baseUrl = 'http://localhost:3000/api';
  static const generateQuiz = '$baseUrl/generate-quiz';
}