import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AILoadingAnimation extends StatelessWidget {
  final String message;
  final double size;
  final Color primaryColor;
  final Color secondaryColor;

  const AILoadingAnimation({
    super.key,
    this.message = 'Generating quiz with AI',
    this.size = 120,
    this.primaryColor = Colors.deepPurple,
    this.secondaryColor = Colors.purpleAccent,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Enhanced animated container with glassmorphism effect
          Container(
            width: size + 40,
            height: size + 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  // ignore: deprecated_member_use
                  primaryColor.withOpacity(0.1),
                  // ignore: deprecated_member_use
                  primaryColor.withOpacity(0.05),
                  Colors.transparent,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  // ignore: deprecated_member_use
                  color: primaryColor.withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Multi-layered pulsing background
                ...List.generate(3, (index) {
                  final scale = 1.0 - (index * 0.2);
                  final opacity = 0.3 - (index * 0.1);
                  
                  return Container(
                    width: size * scale,
                    height: size * scale,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          // ignore: deprecated_member_use
                          primaryColor.withOpacity(opacity),
                          // ignore: deprecated_member_use
                          primaryColor.withOpacity(opacity * 0.5),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  )
                      .animate(onPlay: (controller) => controller.repeat(reverse: true))
                      .scale(
                        begin: Offset(0.8, 0.8),
                        end: Offset(1.2, 1.2),
                        duration: Duration(milliseconds: 2000 + (index * 500)),
                        curve: Curves.easeInOut,
                      )
                      .fade(
                        begin: opacity * 0.5,
                        end: opacity,
                        duration: Duration(milliseconds: 2000 + (index * 500)),
                      );
                }),

                // Central AI brain icon with enhanced styling
                Container(
                  width: size * 0.6,
                  height: size * 0.6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        primaryColor,
                        secondaryColor,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        // ignore: deprecated_member_use
                        color: primaryColor.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.psychology,
                    size: size * 0.35,
                    color: Colors.white,
                  ),
                )
                    .animate(onPlay: (controller) => controller.repeat())
                    .rotate(duration: 8000.ms, curve: Curves.linear)
                    .shimmer(
                      duration: 2000.ms,
                      // ignore: deprecated_member_use
                      color: Colors.white.withOpacity(0.3),
                    ),

                // Enhanced orbital particles with different shapes
                ...List.generate(6, (index) {
                  final angle = index * (pi / 3); // 60 degrees apart
                  final radius = size * 0.45;
                  final offsetX = radius * cos(angle);
                  final offsetY = radius * sin(angle);
                  final particleSize = size * (0.08 + (index % 2) * 0.04);

                  return Positioned(
                    left: (size + 40) / 2 + offsetX - particleSize / 2,
                    top: (size + 40) / 2 + offsetY - particleSize / 2,
                    child: _EnhancedParticle(
                      color: index.isEven ? primaryColor : secondaryColor,
                      size: particleSize,
                      delay: (index * 300).ms,
                      shape: index % 3 == 0 ? ParticleShape.circle : 
                             index % 3 == 1 ? ParticleShape.square : ParticleShape.diamond,
                    ),
                  );
                }),

                // Floating data bits animation
                ...List.generate(8, (index) {
                  final angle = index * (pi / 4);
                  final radius = size * 0.65;
                  final offsetX = radius * cos(angle);
                  final offsetY = radius * sin(angle);

                  return Positioned(
                    left: (size + 40) / 2 + offsetX - 6,
                    top: (size + 40) / 2 + offsetY - 6,
                    child: _DataBit(
                      delay: (index * 400).ms,
                      // ignore: deprecated_member_use
                      color: primaryColor.withOpacity(0.6),
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Enhanced message with gradient text
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  // ignore: deprecated_member_use
                  primaryColor.withOpacity(0.1),
                  // ignore: deprecated_member_use
                  secondaryColor.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                // ignore: deprecated_member_use
                color: primaryColor.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Text(
              message,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                foreground: Paint()
                  ..shader = LinearGradient(
                    colors: [primaryColor, secondaryColor],
                  ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
              ),
              textAlign: TextAlign.center,
            ),
          )
              .animate()
              .fadeIn(duration: 800.ms, delay: 500.ms)
              .slideY(begin: 0.3, end: 0),

          const SizedBox(height: 24),

          // Enhanced progress indicator with modern design
          Container(
            width: 120,
            height: 6,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3),
              color: Colors.grey.shade200,
            ),
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    gradient: LinearGradient(
                      colors: [primaryColor, secondaryColor],
                    ),
                  ),
                )
                    .animate(onPlay: (controller) => controller.repeat())
                    .slideX(
                      begin: -1.0,
                      end: 1.0,
                      duration: 1500.ms,
                      curve: Curves.easeInOut,
                    ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Enhanced floating dots with wave animation
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryColor, secondaryColor],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        // ignore: deprecated_member_use
                        color: primaryColor.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                )
                    .animate(onPlay: (controller) => controller.repeat())
                    .moveY(
                      begin: 0,
                      end: -10,
                      duration: 1000.ms,
                      delay: (index * 150).ms,
                      curve: Curves.easeInOut,
                    )
                    .then()
                    .moveY(
                      begin: -10,
                      end: 0,
                      duration: 1000.ms,
                      curve: Curves.easeInOut,
                    ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

enum ParticleShape { circle, square, diamond }

class _EnhancedParticle extends StatelessWidget {
  final Color color;
  final double size;
  final Duration delay;
  final ParticleShape shape;

  const _EnhancedParticle({
    required this.color,
    required this.size,
    required this.delay,
    required this.shape,
  });

  @override
  Widget build(BuildContext context) {
    Widget particleWidget;
    
    switch (shape) {
      case ParticleShape.circle:
        particleWidget = Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              // ignore: deprecated_member_use
              colors: [color, color.withOpacity(0.5)],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                // ignore: deprecated_member_use
                color: color.withOpacity(0.4),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        );
        break;
      case ParticleShape.square:
        particleWidget = Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              // ignore: deprecated_member_use
              colors: [color, color.withOpacity(0.7)],
            ),
            borderRadius: BorderRadius.circular(2),
            boxShadow: [
              BoxShadow(
                // ignore: deprecated_member_use
                color: color.withOpacity(0.4),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        );
        break;
      case ParticleShape.diamond:
        particleWidget = Transform.rotate(
          angle: pi / 4,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                // ignore: deprecated_member_use
                colors: [color, color.withOpacity(0.7)],
              ),
              borderRadius: BorderRadius.circular(2),
              boxShadow: [
                BoxShadow(
                  // ignore: deprecated_member_use
                  color: color.withOpacity(0.4),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        );
        break;
    }

    return particleWidget
        .animate(
          delay: delay,
          onPlay: (controller) => controller.repeat(),
        )
        .scale(
          begin: const Offset(0.5, 0.5),
          end: const Offset(1.2, 1.2),
          duration: 1500.ms,
          curve: Curves.easeInOut,
        )
        .fade(
          begin: 0.4,
          end: 1.0,
          duration: 1500.ms,
        )
        .rotate(
          begin: 0,
          end: 2 * pi,
          duration: 3000.ms,
        );
  }
}

class _DataBit extends StatelessWidget {
  final Duration delay;
  final Color color;

  const _DataBit({
    required this.delay,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 4,
      height: 4,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    )
        .animate(
          delay: delay,
          onPlay: (controller) => controller.repeat(),
        )
        .fade(
          begin: 0.0,
          end: 1.0,
          duration: 800.ms,
        )
        .then()
        .fade(
          begin: 1.0,
          end: 0.0,
          duration: 800.ms,
        )
        .scale(
          begin: const Offset(0.5, 0.5),
          end: const Offset(1.5, 1.5),
          duration: 1600.ms,
        );
  }
}