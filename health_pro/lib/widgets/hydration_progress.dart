import 'package:flutter/material.dart';
import 'package:liquid_progress_indicator_v2/liquid_progress_indicator.dart';
import 'water_drop_shape.dart';

class HydrationProgress extends StatelessWidget {
  final double progress;
  final double currentConsumption;
  final double dailyGoal;

  const HydrationProgress({
    super.key,
    required this.progress,
    required this.currentConsumption,
    required this.dailyGoal,
  });

  @override
  Widget build(BuildContext context) {
    final displayProgress = progress.clamp(0.0, 1.0);
    final isOverGoal = progress > 1.0;

    return Column(
      children: [
        Center(
          child: SizedBox(
            height: 240,
            width: 200,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: displayProgress),
              duration: const Duration(milliseconds: 500),
              builder: (context, animatedProgress, child) {
                return LiquidCustomProgressIndicator(
                  direction: Axis.vertical,
                  value: animatedProgress,
                  center: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 25,
                      ),
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0, end: progress),
                        duration: const Duration(milliseconds: 500),
                        builder: (context, value, child) {
                          return Text(
                            '${(value * 100).toInt()}%',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  offset: Offset(1.0, 1.0), // Offset shadow
                                  blurRadius: 10.0, // Blur intensity
                                  color: Colors.grey, // Shadow color
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0, end: currentConsumption),
                        duration: const Duration(milliseconds: 500),
                        builder: (context, value, child) {
                          return Text(
                            '${value.toInt()} ml',
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  offset: Offset(1.0, 1.0), // Offset shadow
                                  blurRadius: 10.0, // Blur intensity
                                  color: Colors.grey, // Shadow color
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(
                            begin: dailyGoal,
                            end: dailyGoal - currentConsumption),
                        duration: const Duration(milliseconds: 500),
                        builder: (context, value, child) {
                          return Text(
                            value > 0
                                ? '-${value.toInt()} ml'
                                : '+${(-value).toInt()} ml',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                              shadows: [
                                Shadow(
                                  offset: Offset(1.0, 1.0), // Offset shadow
                                  blurRadius: 10.0, // Blur intensity
                                  color: Colors.grey, // Shadow color
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  shapePath: WaterDropShape().getClip(const Size(200, 240)),
                  backgroundColor: Colors.blue.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation(Colors.blue.shade400),
                );
              },
            ),
          ),
        ),
        if (isOverGoal)
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: 1),
            duration: const Duration(milliseconds: 500),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    'Great job! You\'ve exceeded your daily goal!',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 16 * value,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
