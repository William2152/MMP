import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'dart:async';

class ActivityTrackerScreen extends StatefulWidget {
  const ActivityTrackerScreen({Key? key}) : super(key: key);

  @override
  _ActivityTrackerScreenState createState() => _ActivityTrackerScreenState();
}

class _ActivityTrackerScreenState extends State<ActivityTrackerScreen> {
  int _stepCount = 0; // Langkah berjalan sejak tracking dimulai
  int _initialStepCount = 0; // Langkah awal dari perangkat
  double _distance = 0.0; // Total jarak dalam kilometer
  double _calories = 0.0; // Total kalori terbakar
  double _stepLength = 0.78; // Panjang langkah rata-rata dalam meter
  double _weight = 70.0; // Berat badan pengguna dalam kg (bisa diubah)
  int _targetSteps = 10000; // Target langkah
  DateTime _lastUpdatedDate = DateTime.now(); // Tanggal terakhir diperbarui

  StreamSubscription<StepCount>? _stepStream;

  @override
  void initState() {
    super.initState();
    _startTracking();
  }

  void _startTracking() {
    _stepStream = Pedometer.stepCountStream.listen((StepCount event) {
      final currentDate = DateTime.now();

      if (_lastUpdatedDate.day != currentDate.day ||
          _lastUpdatedDate.month != currentDate.month ||
          _lastUpdatedDate.year != currentDate.year) {
        // Reset data jika pergantian hari terdeteksi
        _resetData();
      }

      if (_initialStepCount == 0) {
        // Simpan langkah awal
        _initialStepCount = event.steps;
      }

      setState(() {
        // Hitung langkah relatif terhadap langkah awal
        _stepCount = event.steps - _initialStepCount;

        // Hitung jarak berdasarkan langkah
        _distance = (_stepCount * _stepLength) / 1000; // Konversi ke kilometer

        // Hitung kalori berdasarkan langkah
        _calculateCalories();

        // Perbarui tanggal terakhir
        _lastUpdatedDate = currentDate;
      });
    }, onError: (error) {
      print('Step tracking error: $error');
    });
  }

  void _resetData() {
    setState(() {
      _stepCount = 0;
      _initialStepCount = 0;
      _distance = 0.0;
      _calories = 0.0;
    });
    print("Data reset at midnight.");
  }

  void _calculateCalories() {
    // Hitung kalori dengan pendekatan langkah
    double caloriesPerStep = _weight * 0.0005;
    double caloriesFromSteps = _stepCount * caloriesPerStep;

    setState(() {
      _calories = caloriesFromSteps;
    });
  }

  @override
  void dispose() {
    _stepStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double progress = (_stepCount / _targetSteps) * 100;

    return Scaffold(
      backgroundColor: const Color(0xFF98D8AA), // Latar belakang hijau pastel
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.only(top: 60, bottom: 30),
            child: Column(
              children: const [
                Text(
                  'Pedometer',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Track Your Steps Daily',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          // Lingkaran Progress
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(260, 260),
                  painter: CircleProgressPainter(progress: progress), // Progres
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$_stepCount / $_targetSteps',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Steps',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          // Informasi Tambahan (Kalori & Jarak)
          Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 2,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InfoCard(
                  title: 'Calories Burned',
                  value: '${_calories.toStringAsFixed(2)} Kcal',
                  icon: Icons.local_fire_department,
                ),
                InfoCard(
                  title: 'Distance',
                  value: '${_distance.toStringAsFixed(2)} km',
                  icon: Icons.directions_walk,
                ),
              ],
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

class CircleProgressPainter extends CustomPainter {
  final double progress;

  CircleProgressPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;

    // Lingkaran Latar Belakang (Track)
    final trackPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12;

    canvas.drawCircle(center, radius, trackPaint);

    // Lingkaran Progress
    final progressPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Colors.teal, Colors.tealAccent],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 12;

    final startAngle = -90.0 * 3.14159 / 180; // Mulai dari atas
    final sweepAngle = 2 * 3.14159 * (progress / 100);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const InfoCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.teal, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
}
