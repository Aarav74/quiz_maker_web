// ignore_for_file: deprecated_member_use, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'quiz_results_screen.dart';

// Remove dart:io import - it doesn't work on web
// import 'dart:io';

class QuizGenerationScreen extends StatefulWidget {
  final String filePath;
  final int numQuestions;
  final String difficulty;
  final String huggingFaceToken;
  final Uint8List? fileBytes;
  final String? fileName;

  const QuizGenerationScreen({
    super.key,
    required this.filePath,
    this.numQuestions = 5,
    this.difficulty = 'medium',
    required this.huggingFaceToken,
    this.fileBytes,
    this.fileName,
  });

  @override
  State<QuizGenerationScreen> createState() => _QuizGenerationScreenState();
}

class _QuizGenerationScreenState extends State<QuizGenerationScreen>
    with TickerProviderStateMixin {
  bool _isGenerating = true;
  double _progress = 0;
  String _status = 'Preparing document...';
  String? _errorMessage;
  List<Map<String, dynamic>> _questions = [];

  // Animation controllers
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late AnimationController _sparkleController;

  // Animation values
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _waveAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _generateQuiz();
  }

  void _initializeAnimations() {
    // Rotation animation for loading icon
    _rotationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _rotationAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );

    // Pulse animation for progress indicator
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Wave animation for background
    _waveController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();

    _waveAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(parent: _waveController, curve: Curves.linear));

    // Sparkle animation
    _sparkleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    _waveController.dispose();
    _sparkleController.dispose();
    super.dispose();
  }

  Future<void> _generateQuiz() async {
    try {
      // Step 1: Prepare document
      await _updateProgress(0.1, 'Analyzing document structure...');

      // Web-compatible file validation
      if (kIsWeb) {
        if (widget.fileBytes == null || widget.fileBytes!.isEmpty) {
          throw Exception('No file data provided');
        }
        if (widget.fileName == null || widget.fileName!.isEmpty) {
          throw Exception('No file name provided');
        }
        print(
          'Web: Processing file ${widget.fileName} with ${widget.fileBytes!.length} bytes',
        );
      } else {
        if (widget.filePath.isEmpty) {
          throw Exception('No file path provided');
        }
        print('Mobile: Processing file at ${widget.filePath}');
      }

      // Step 2: Send to backend using multipart request
      await _updateProgress(0.3, 'Connecting to AI brain...');

      final apiUrl = '${_getBackendUrl()}/api/generate-quiz';

      final request = http.MultipartRequest('POST', Uri.parse(apiUrl));

      // Add file - web compatible way
      if (kIsWeb && widget.fileBytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'document',
            widget.fileBytes!,
            filename: widget.fileName ?? 'document.txt',
          ),
        );
      } else {
        // For mobile platforms
        request.files.add(
          await http.MultipartFile.fromPath('document', widget.filePath),
        );
      }

      // Add form fields
      request.fields['numQuestions'] = widget.numQuestions.toString();
      request.fields['difficulty'] = widget.difficulty;
      if (widget.huggingFaceToken.isNotEmpty) {
        request.fields['huggingFaceToken'] = widget.huggingFaceToken;
      }

      // Add headers
      request.headers.addAll({'Accept': 'application/json'});

      // Step 3: Send request
      await _updateProgress(0.5, 'Processing content with AI...');

      final streamedResponse = await request.send().timeout(
        const Duration(minutes: 2),
      );
      final response = await http.Response.fromStream(streamedResponse);

      // Step 4: Parse response
      await _updateProgress(0.7, 'Crafting intelligent questions...');

      if (response.statusCode == 200) {
        // Check if response is JSON
        if (response.headers['content-type']?.contains('application/json') !=
            true) {
          throw Exception(
            'Server returned non-JSON response. Check if API endpoint exists.',
          );
        }

        final responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          _questions = List<Map<String, dynamic>>.from(
            responseData['data']['quiz'] ?? [],
          );

          if (_questions.isEmpty) {
            throw Exception('No questions were generated');
          }

          // Step 5: Complete
          await _updateProgress(0.9, 'Polishing your quiz...');
          await Future.delayed(800.ms);
          await _updateProgress(1.0, 'Quiz ready! 🎉');
          await Future.delayed(1000.ms);

          if (mounted) {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    QuizResultsScreen(
                      questions: _questions,
                      quizData: _questions,
                      documentTitle:
                          responseData['data']['document_title'] ?? 'Quiz',
                    ),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position:
                              Tween<Offset>(
                                begin: const Offset(0.0, 0.3),
                                end: Offset.zero,
                              ).animate(
                                CurvedAnimation(
                                  parent: animation,
                                  curve: Curves.easeOutBack,
                                ),
                              ),
                          child: child,
                        ),
                      );
                    },
              ),
            );
          }
        } else {
          throw Exception(responseData['error'] ?? 'Quiz generation failed');
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
              errorMessage =
                  'API endpoint not found. Check your Express server is running.';
              break;
            case 405:
              errorMessage =
                  'Method not allowed. Check API route configuration.';
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

        throw Exception(errorMessage);
      }
    } catch (e) {
      // ignore: duplicate_ignore
      // ignore: avoid_print
      print('Error in _generateQuiz: $e'); // Debug print
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

    if (errorStr.contains('Connection refused') ||
        errorStr.contains('SocketException')) {
      return '''Cannot connect to server:
• Make sure your Express server is running on http://localhost:3001
• Run: npm start (or node app.js) in your server directory
• Check if you can access http://localhost:3001/api/health in your browser''';
    } else if (errorStr.contains('_namespace') || errorStr.contains('XML')) {
      return '''Server configuration issue:
• Ensure your backend returns JSON (not XML)
• Check server error pages
• Verify CORS headers include: Content-Type: application/json''';
    } else if (errorStr.contains('Timeout')) {
      return 'Request timed out. Try a smaller document or check your internet connection.';
    } else if (errorStr.contains('404')) {
      return '''API endpoint not found:
• Check if your Express server is running
• Verify the endpoint exists at /api/generate-quiz
• Check server logs for errors''';
    } else if (errorStr.contains('Unsupported operation')) {
      return '''Platform compatibility issue:
• This appears to be a web/mobile compatibility problem
• Make sure you're using the correct file picker for your platform
• Check that file data is properly passed to this screen''';
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
    await Future.delayed(500.ms);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1A1A2E),
              const Color(0xFF16213E),
              const Color(0xFF0F3460),
              Colors.deepPurple.shade900,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Animated background waves
            _buildAnimatedBackground(),

            // Main content
            SafeArea(
              child: Column(
                children: [
                  // Custom App Bar
                  _buildCustomAppBar(),

                  // Main content area - FIXED: Using Flexible instead of Expanded
                  Flexible(
                    child: _errorMessage != null
                        ? _buildErrorContent()
                        : _isGenerating
                        ? _buildLoadingContent()
                        : _buildSuccessContent(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _waveAnimation,
      builder: (context, child) {
        return CustomPaint(
          painter: WaveBackgroundPainter(_waveAnimation.value),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildCustomAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          // Back button with style
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            ),
          ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.3, end: 0),

          const SizedBox(width: 16),

          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Quiz Generation',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ).animate().fadeIn(delay: 400.ms).slideY(begin: -0.3, end: 0),
                Text(
                  'Powered by AI',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.3, end: 0),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          // Add some spacing at the top to keep it visually centered
          SizedBox(height: MediaQuery.of(context).size.height * 0.05),

          // AI Brain Animation - FIXED: Reduced size for smaller screens
          _buildAIBrainAnimation(),

          const SizedBox(height: 30),

          // Status text with animation
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value * 0.1 + 0.95,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Text(
                    _status,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 25),

          // Progress indicator with glow effect
          _buildProgressIndicator(),

          const SizedBox(height: 15),

          // Progress percentage
          Text(
            '${(_progress * 100).toStringAsFixed(0)}%',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ).animate().fadeIn().scale(),

          const SizedBox(height: 30),

          // Progress steps
          _buildProgressSteps(),

          // Add bottom spacing
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildAIBrainAnimation() {
    return AnimatedBuilder(
      animation: _rotationController,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer ring - FIXED: Reduced size
            Transform.rotate(
              angle: _rotationAnimation.value,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.deepPurple.withOpacity(0.3),
                    width: 2,
                  ),
                ),
              ),
            ),

            // Middle ring - FIXED: Reduced size
            Transform.rotate(
              angle: -_rotationAnimation.value * 0.8,
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.blue.withOpacity(0.4),
                    width: 2,
                  ),
                ),
              ),
            ),

            // Inner core with AI icon - FIXED: Reduced size
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value * 0.1 + 0.9,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.deepPurple.withOpacity(0.8),
                          Colors.blue.withOpacity(0.6),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepPurple.withOpacity(0.5),
                          blurRadius: 20,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.psychology,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),

            // Sparkle effects
            ..._buildSparkles(),
          ],
        );
      },
    );
  }

  List<Widget> _buildSparkles() {
    return List.generate(8, (index) {
      final angle = (index / 8) * 2 * math.pi;
      final radius = 70.0; // FIXED: Reduced radius

      return AnimatedBuilder(
        animation: _sparkleController,
        builder: (context, child) {
          final sparkleValue =
              (_sparkleController.value + (index * 0.125)) % 1.0;
          final opacity = (math.sin(sparkleValue * math.pi * 2) + 1) / 2;

          return Positioned(
            left: math.cos(angle) * radius,
            top: math.sin(angle) * radius,
            child: Opacity(
              opacity: opacity * 0.8,
              child: Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildProgressIndicator() {
    return Container(
      width: 280, // FIXED: Reduced width
      height: 6, // FIXED: Reduced height
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
        color: Colors.white.withOpacity(0.2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Stack(
              children: [
                // Progress bar
                LinearProgressIndicator(
                  value: _progress,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.deepPurple.withOpacity(0.8),
                  ),
                ),

                // Glow effect
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepPurple.withOpacity(
                            _pulseAnimation.value * 0.3,
                          ),
                          blurRadius: 10,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildProgressSteps() {
    final steps = [
      {'icon': Icons.document_scanner, 'label': 'Analyzing'},
      {'icon': Icons.cloud_upload, 'label': 'Uploading'},
      {'icon': Icons.psychology, 'label': 'AI Processing'},
      {'icon': Icons.quiz, 'label': 'Creating Quiz'},
      {'icon': Icons.check_circle, 'label': 'Complete'},
    ];

    return Container(
      padding: const EdgeInsets.all(16), // FIXED: Reduced padding
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: steps.asMap().entries.map((entry) {
          final index = entry.key;
          final step = entry.value;
          final isActive = _progress > (index / (steps.length - 1));
          final isCurrent =
              _progress >= (index / (steps.length - 1)) &&
              _progress < ((index + 1) / (steps.length - 1));

          return Flexible(
            // FIXED: Wrap with Flexible
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  width: 35, // FIXED: Reduced size
                  height: 35,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive
                        ? Colors.deepPurple
                        : Colors.white.withOpacity(0.2),
                    border: Border.all(
                      color: isCurrent ? Colors.white : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    step['icon'] as IconData,
                    color: isActive ? Colors.white : Colors.white54,
                    size: 18, // FIXED: Reduced icon size
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  step['label'] as String,
                  style: TextStyle(
                    color: isActive ? Colors.white : Colors.white54,
                    fontSize: 11, // FIXED: Reduced font size
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildErrorContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.red.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Error icon with animation
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red.withOpacity(0.2),
              ),
              child: const Icon(
                Icons.error_outline,
                size: 40,
                color: Colors.red,
              ),
            ).animate().scale(delay: 200.ms),

            const SizedBox(height: 24),

            const Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 400.ms),

            const SizedBox(height: 16),

            Text(
              _errorMessage!,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white70,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 600.ms),

            const SizedBox(height: 32),

            // Retry button with style
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _errorMessage = null;
                  _isGenerating = true;
                  _progress = 0;
                });
                _generateQuiz();
              },
              icon: const Icon(Icons.refresh),
              label: const Text(
                'Try Again',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.3, end: 0),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        children: [
          // Success animation
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.green.withOpacity(0.8),
                  Colors.green.withOpacity(0.4),
                ],
              ),
            ),
            child: const Icon(
              Icons.check_circle,
              size: 60,
              color: Colors.white,
            ),
          ).animate().scale(delay: 200.ms, duration: 800.ms),

          const SizedBox(height: 32),

          const Text(
            'Quiz Generated Successfully! 🎉',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.3, end: 0),

          const SizedBox(height: 16),

          const Text(
            'Your intelligent quiz is ready to challenge minds!',
            style: TextStyle(fontSize: 16, color: Colors.white70),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 800.ms),

          const SizedBox(height: 40),

          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => QuizResultsScreen(
                    questions: _questions,
                    quizData: _questions,
                    documentTitle: 'Quiz',
                  ),
                ),
              );
            },
            icon: const Icon(Icons.quiz),
            label: const Text(
              'View Quiz',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ).animate().fadeIn(delay: 1000.ms).slideY(begin: 0.3, end: 0),
        ],
      ),
    );
  }
}

// Custom painter for animated background waves
class WaveBackgroundPainter extends CustomPainter {
  final double animationValue;

  WaveBackgroundPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    final path = Path();

    for (int i = 0; i < 3; i++) {
      path.reset();
      path.moveTo(0, size.height * 0.3 + i * 50);

      for (double x = 0; x <= size.width; x += 10) {
        final y =
            size.height * 0.3 +
            i * 50 +
            math.sin((x / 100) + animationValue + i) * 20;
        path.lineTo(x, y);
      }

      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
      path.close();

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
