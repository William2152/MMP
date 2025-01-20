import 'package:flutter/material.dart';

class WeightPage extends StatefulWidget {
  const WeightPage({Key? key}) : super(key: key);

  @override
  State<WeightPage> createState() => _WeightPageState();
}

class _WeightPageState extends State<WeightPage> {
  double currentWeight = 34.0;
  final ScrollController _scrollController = ScrollController();
  final double minWeight = 10.0;
  final double maxWeight = 250.0;
  final double scaleWidth = 3000.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToWeight(currentWeight);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToWeight(double weight) {
    final pixelsPerKg = scaleWidth / (maxWeight - minWeight);
    final targetScroll = (weight - minWeight) * pixelsPerKg;
    _scrollController.jumpTo(targetScroll);
  }

  void _onScaleUpdate() {
    final scrollPosition = _scrollController.offset;
    final pixelsPerKg = scaleWidth / (maxWeight - minWeight);

    setState(() {
      currentWeight = minWeight + (scrollPosition) / pixelsPerKg;
      currentWeight = double.parse((currentWeight).toStringAsFixed(0));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          const Text(
            'Your current weight',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: const Text(
              'kg',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF4CAF50),
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const Spacer(),
          SizedBox(
            height: 280,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Wrapper container untuk scroll area
                Container(
                  margin: const EdgeInsets.only(bottom: 100),
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (scrollNotification) {
                      if (scrollNotification is ScrollUpdateNotification) {
                        _onScaleUpdate();
                      }
                      return true;
                    },
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      scrollDirection: Axis.horizontal,
                      physics: const ClampingScrollPhysics(),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width / 2,
                        ),
                        child: CustomPaint(
                          size: Size(scaleWidth, 100),
                          painter: WeightScalePainter(
                            currentWeight: currentWeight,
                            minWeight: minWeight,
                            maxWeight: maxWeight,
                            scaleWidth: scaleWidth,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Indikator dan nilai
                Positioned(
                  bottom: 100,
                  child: CustomPaint(
                    size: const Size(20, 16),
                    painter: TrianglePainter(),
                  ),
                ),

                Positioned(
                  bottom: 0,
                  child: Container(
                    height: 90,
                    width: 2,
                    color: const Color(0xFF4CAF50),
                    margin: const EdgeInsets.only(bottom: 116),
                  ),
                ),

                Positioned(
                  bottom: 0,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        currentWeight.toStringAsFixed(0),
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'kg',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ElevatedButton(
              onPressed: () {
                // Handle continue
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                disabledBackgroundColor: Colors.grey,
              ),
              child: const Text(
                'Continue',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WeightScalePainter extends CustomPainter {
  final double currentWeight;
  final double minWeight;
  final double maxWeight;
  final double scaleWidth;

  WeightScalePainter({
    required this.currentWeight,
    required this.minWeight,
    required this.maxWeight,
    required this.scaleWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 0.5;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    final pixelsPerKg = size.width / (maxWeight - minWeight);

    for (double i = minWeight; i <= maxWeight; i += 1) {
      final x = (i - minWeight) * pixelsPerKg;
      final isMajorTick = i % 10 == 0;

      final tickHeight = isMajorTick ? 24.0 : 16.0;

      canvas.drawLine(
        Offset(x, size.height / 2 - tickHeight / 2),
        Offset(x, size.height / 2 + tickHeight / 2),
        paint..strokeWidth = isMajorTick ? 1.0 : 0.5,
      );

      if (isMajorTick) {
        textPainter.text = TextSpan(
          text: i.toStringAsFixed(0),
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        );
        textPainter.layout();

        textPainter.paint(
          canvas,
          Offset(x - textPainter.width / 2, size.height / 2 + 30),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant WeightScalePainter oldDelegate) {
    return oldDelegate.currentWeight != currentWeight;
  }
}

class TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF4CAF50)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
