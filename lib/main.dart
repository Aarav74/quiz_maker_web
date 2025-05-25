import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/quiz_generation_screen.dart';
import 'screens/quiz_results_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Quiz Maker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          elevation: 2,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/home': (context) => const HomeScreen(),
        '/quiz-generation': (context) => const QuizGenerationScreen(filePath: '', huggingFaceToken: '',), // Default, will be overridden
        '/quiz-results': (context) => const QuizResultsScreen(quizData: [], documentTitle: '', questions: [],), // Default, will be overridden
      },
      onGenerateRoute: (settings) {
        // Handle routes with parameters
        switch (settings.name) {
          case '/quiz-generation':
            final args = settings.arguments as Map<String, dynamic>?;
            return MaterialPageRoute(
              builder: (context) => QuizGenerationScreen(
                filePath: args?['filePath'] ?? '',
                huggingFaceToken: args?['huggingFaceToken'],
                numQuestions: args?['numQuestions'] ?? 5,
                difficulty: args?['difficulty'] ?? 'medium',
              ),
            );
          case '/quiz-results':
            final args = settings.arguments as Map<String, dynamic>?;
            return MaterialPageRoute(
              builder: (context) => QuizResultsScreen(
                quizData: args?['quizData'] ?? [],
                documentTitle: args?['documentTitle'] ?? '', questions: [],
              ),
            );
          default:
            return MaterialPageRoute(
              builder: (context) => const HomeScreen(),
            );
        }
      },
    );
  }
}