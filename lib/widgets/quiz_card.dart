import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/quiz_question.dart';

class QuizCard extends StatefulWidget {
  final QuizQuestion question;
  final int questionNumber;
  final bool showAnswers;
  final Function(int)? onAnswerSelected;
  final int? selectedAnswer;
  final bool isInteractive;

  const QuizCard({
    super.key,
    required this.question,
    required this.questionNumber,
    this.showAnswers = false,
    this.onAnswerSelected,
    this.selectedAnswer,
    this.isInteractive = true,
  });

  @override
  State<QuizCard> createState() => _QuizCardState();
}

class _QuizCardState extends State<QuizCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.grey.shade50,
          ],
        ),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
            spreadRadius: 2,
          ),
        ],
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question header with gradient background
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.deepPurple.shade600,
                    Colors.deepPurple.shade400,
                  ],
                ),
              ),
              child: Row(
                children: [
                  // Question number badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      // ignore: deprecated_member_use
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        // ignore: deprecated_member_use
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'Q${widget.questionNumber}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Question difficulty indicator
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      // ignore: deprecated_member_use
                      color: _getDifficultyColor().withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        // ignore: deprecated_member_use
                        color: _getDifficultyColor().withOpacity(0.4),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getDifficultyIcon(),
                          size: 12,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getDifficultyText(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Expand/collapse button
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                    icon: Icon(
                      _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Question content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Question text with enhanced typography
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.blue.shade100,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.help_outline,
                          color: Colors.blue.shade600,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            widget.question.question,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade800,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Answer options with enhanced design
                  ...widget.question.options.asMap().entries.map((entry) {
                    final index = entry.key;
                    final option = entry.value;
                    final isCorrect = index == widget.question.correctAnswerIndex;
                    final isSelected = widget.selectedAnswer == index;
                    final showResult = widget.showAnswers;
                    
                    Color backgroundColor = Colors.white;
                    Color borderColor = Colors.grey.shade300;
                    Color textColor = Colors.grey.shade800;
                    IconData? iconData;
                    Color? iconColor;
                    
                    if (showResult) {
                      if (isCorrect) {
                        backgroundColor = Colors.green.shade50;
                        borderColor = Colors.green.shade400;
                        textColor = Colors.green.shade800;
                        iconData = Icons.check_circle;
                        iconColor = Colors.green.shade600;
                      } else if (isSelected && !isCorrect) {
                        backgroundColor = Colors.red.shade50;
                        borderColor = Colors.red.shade400;
                        textColor = Colors.red.shade800;
                        iconData = Icons.cancel;
                        iconColor = Colors.red.shade600;
                      }
                    } else if (isSelected) {
                      backgroundColor = Colors.deepPurple.shade50;
                      borderColor = Colors.deepPurple.shade400;
                      textColor = Colors.deepPurple.shade800;
                      iconData = Icons.radio_button_checked;
                      iconColor = Colors.deepPurple.shade600;
                    } else {
                      iconData = Icons.radio_button_unchecked;
                      iconColor = Colors.grey.shade400;
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: widget.isInteractive && !showResult 
                              ? () => widget.onAnswerSelected?.call(index)
                              : null,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: backgroundColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: borderColor,
                                width: 2,
                              ),
                              boxShadow: isSelected && !showResult
                                  ? [
                                      BoxShadow(
                                        // ignore: deprecated_member_use
                                        color: Colors.deepPurple.withOpacity(0.1),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              children: [
                                // Option letter badge
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    // ignore: deprecated_member_use
                                    color: iconColor?.withOpacity(0.1) ?? Colors.grey.shade100,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: iconColor ?? Colors.grey.shade300,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      String.fromCharCode(65 + index), // A, B, C, D
                                      style: TextStyle(
                                        color: iconColor ?? Colors.grey.shade600,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Option text
                                Expanded(
                                  child: Text(
                                    option,
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: textColor,
                                      fontWeight: isSelected || (showResult && isCorrect) 
                                          ? FontWeight.w600 
                                          : FontWeight.w500,
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Status icon
                                if (iconData != null)
                                  Icon(
                                    iconData,
                                    color: iconColor,
                                    size: 20,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ).animate()
                          .fadeIn(duration: 300.ms, delay: Duration(milliseconds: index * 100))
                          .slideX(begin: 0.3, end: 0),
                    );
                  }),

                  // Explanation section (expandable)
                  if (widget.question.explanation != null && _isExpanded) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.amber.shade50,
                            Colors.orange.shade50,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.amber.shade200,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.amber.shade600,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.lightbulb,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Explanation',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber.shade800,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            widget.question.explanation!,
                            style: TextStyle(
                              color: Colors.amber.shade900,
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ).animate()
                        .fadeIn(duration: 500.ms)
                        .slideY(begin: -0.2, end: 0),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate()
        .fadeIn(duration: 600.ms)
        .slideY(begin: 0.3, end: 0);
  }

  Color _getDifficultyColor() {
    // This would typically come from the question model
    // For now, using a default color scheme
    return Colors.orange;
  }

  IconData _getDifficultyIcon() {
    // This would typically come from the question model
    return Icons.speed;
  }

  String _getDifficultyText() {
    // This would typically come from the question model
    return 'Medium';
  }
}

// Enhanced quiz question model (you may need to update your existing model)
class EnhancedQuizQuestion {
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final String? explanation;
  final String difficulty;
  final String category;
  final int points;

  const EnhancedQuizQuestion({
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    this.explanation,
    this.difficulty = 'medium',
    this.category = 'general',
    this.points = 1,
  });
}