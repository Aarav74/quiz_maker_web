import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_3d_choice_chip/flutter_3d_choice_chip.dart';
import 'package:lottie/lottie.dart';
import 'quiz_generation_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PlatformFile? _selectedFile;
  bool _isLoading = false;
  String _difficulty = 'medium';

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'docx', 'txt'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        setState(() => _selectedFile = result.files.first);
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _generateQuiz() {
    if (_selectedFile == null) return;
    
    setState(() => _isLoading = true);
    Future.delayed(500.ms, () {
      Navigator.push(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(
          builder: (context) => QuizGenerationScreen(
            filePath: _selectedFile!.path!,
            difficulty: _difficulty, huggingFaceToken: '',
          ),
        ),
      );
      setState(() => _isLoading = false);
    });
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
              Colors.deepPurple.shade900,
              Colors.deepPurple.shade700,
              Colors.deepPurple.shade500,
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo and Title
                    Column(
                      children: [
                        Lottie.asset(
                          'assets/animations/document_scan.json',
                          width: 150,
                          height: 150,
                        ),
                        const Text(
                          'Doc2Quiz',
                          style: TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'Poppins',
                          ),
                        ).animate().fadeIn(delay: 200.ms),
                        const Text(
                          'Transform documents into interactive quiz',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),

                    // 3D Document Upload Card
                    Animate(
                      effects: const [
                        FadeEffect(),
                        ScaleEffect(begin: Offset(0.9, 0.9))
                      ],
                      child: Card(
                        elevation: 12,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white,
                                Colors.grey.shade100,
                              ],
                            ),
                          ),
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              // 3D File Icon
                              ChoiceChip3D(
                                width: 100,
                                height: 100,
                                style: ChoiceChip3DStyle(
                                  topColor: Colors.deepPurple.shade300,
                                  backColor: Colors.deepPurple.shade700,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                onSelected: () => _pickFile(),
                                onUnSelected: () {},
                                selected: false,
                                child: const Icon(
                                  Icons.insert_drive_file,
                                  size: 40,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Upload Button
                              ElevatedButton(
                                onPressed: _pickFile,
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
                                  elevation: 5,
                                  // ignore: deprecated_member_use
                                  shadowColor: Colors.deepPurple.withOpacity(0.5),
                                ),
                                child: const Text(
                                  'Upload Document',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Difficulty Selector
                              const Text(
                                'Select Difficulty:',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildDifficultyChip('Easy', Colors.green),
                                  const SizedBox(width: 10),
                                  _buildDifficultyChip('Medium', Colors.orange),
                                  const SizedBox(width: 10),
                                  _buildDifficultyChip('Hard', Colors.red),
                                ],
                              ),
                              const SizedBox(height: 20),

                              // File Info
                              if (_selectedFile != null) ...[
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    // ignore: deprecated_member_use
                                    color: Colors.deepPurple.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.description,
                                              color: Colors.deepPurple),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              _selectedFile!.name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          const Icon(Icons.storage,
                                              color: Colors.deepPurple),
                                          const SizedBox(width: 8),
                                          Text(
                                            '${(_selectedFile!.size / 1024).toStringAsFixed(2)} KB',
                                            style: const TextStyle(
                                                color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Generate Button
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _generateQuiz,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 18),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: _isLoading
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Text(
                                            'Generate Quiz',
                                            style: TextStyle(fontSize: 16),
                                          ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Footer
                    const SizedBox(height: 40),
                    const Text(
                      'made by Aarav • Doc2Quiz v1.0',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyChip(String label, Color color) {
    return ChoiceChip(
      label: Text(label),
      selected: _difficulty == label.toLowerCase(),
      onSelected: (selected) {
        setState(() {
          _difficulty = label.toLowerCase();
        });
      },
      // ignore: deprecated_member_use
      selectedColor: color.withOpacity(0.2),
      labelStyle: TextStyle(
        color: _difficulty == label.toLowerCase() ? color : Colors.grey,
        fontWeight: FontWeight.bold,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: _difficulty == label.toLowerCase() ? color : Colors.grey,
        ),
      ),
    );
  }
}