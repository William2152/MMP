import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_pro/blocs/auth/auth_bloc.dart';
import 'package:health_pro/blocs/auth/auth_event.dart';
import 'package:health_pro/blocs/auth/auth_state.dart';

class HeightSelectorScreen extends StatefulWidget {
  const HeightSelectorScreen({super.key});

  @override
  State<HeightSelectorScreen> createState() => _HeightSelectorScreenState();
}

class _HeightSelectorScreenState extends State<HeightSelectorScreen>
    with SingleTickerProviderStateMixin {
  double currentHeight = 170; // Default height in cm

  double startDragY = 0;

  double startHeight = 170;

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Initialize controller to show 170cm

    _controller.value =
        1 - (currentHeight / 500); // Reverse the initial position
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  void _onVerticalDragStart(DragStartDetails details) {
    startDragY = details.globalPosition.dy;

    startHeight = currentHeight;
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    final dragDifference = details.globalPosition.dy - startDragY;

    final heightDifference =
        dragDifference * 0.5; // Increased sensitivity for more precise control

    setState(() {
      currentHeight = (startHeight - heightDifference).clamp(0.0, 500.0);

      _controller.value = 1 - (currentHeight / 500); // Reverse the movement
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              const Text(
                'Your height',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: const Text(
                        'cm',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Expanded(
                child: GestureDetector(
                  onVerticalDragStart: _onVerticalDragStart,
                  onVerticalDragUpdate: _onVerticalDragUpdate,
                  child: Stack(
                    children: [
                      AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          return CustomPaint(
                            size: Size.infinite,
                            painter: RulerPainter(
                              position: _controller.value,
                              currentHeight: currentHeight,
                            ),
                          );
                        },
                      ),
                      Align(
                        alignment: const Alignment(0, 0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${currentHeight.toInt()} cm',
                              style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Container(
                              height: 2,
                              color: Colors.green,
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 20),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  final authBloc = BlocProvider.of<AuthBloc>(context);

                  // Kirim event UpdateHeight ke Bloc
                  authBloc.add(UpdateHeight(height: currentHeight.toInt()));

                  // Tampilkan pesan sukses atau error
                  authBloc.stream.listen((state) {
                    if (state is HeightUpdateSuccess) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Height updated successfully!')),
                      );
                      // Navigasi ke halaman berikutnya
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        Navigator.pushReplacementNamed(context, '/birth');
                      });
                    } else if (state is HeightUpdateError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: ${state.message}')),
                      );
                    }
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class RulerPainter extends CustomPainter {
  final double position;
  final double currentHeight;

  RulerPainter({
    required this.position,
    required this.currentHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 1;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.right,
    );

    // Calculate the spacing between lines
    final double lineSpacing =
        size.height / 100; // Increased for finer resolution

    // Center point is where the green line is
    final double centerY = size.height / 2;

    // Draw ruler lines from -50 to 550 (extended range)
    for (int i = -50; i <= 550; i++) {
      // Calculate the Y position for this height value
      final y = centerY - ((i - currentHeight) * lineSpacing);

      if (y >= 0 && y <= size.height) {
        if (i % 10 == 0 && i >= 0 && i <= 500) {
          // Draw longer line and text for every 10cm
          canvas.drawLine(Offset(0, y), Offset(60, y), paint);

          textPainter.text = TextSpan(
            text: i.toString(),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          );
          textPainter.layout();
          textPainter.paint(
            canvas,
            Offset(5, y - textPainter.height / 2),
          );
        } else if (i % 5 == 0) {
          // Draw medium line for every 5cm
          canvas.drawLine(Offset(30, y), Offset(60, y), paint);
        } else {
          // Draw short line for every 1cm
          canvas.drawLine(Offset(45, y), Offset(60, y), paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant RulerPainter oldDelegate) {
    return oldDelegate.position != position ||
        oldDelegate.currentHeight != currentHeight;
  }
}
