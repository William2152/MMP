import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'dart:io' show Platform;

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
  double _stepLength = 0.78; // Panjang langkah rata-rata (meter)
  double _weight = 70.0; // Berat badan user (kg, bisa diubah)
  int _targetSteps = 10000; // Target langkah harian
  DateTime _lastUpdatedDate = DateTime.now(); // Tanggal terakhir diperbarui

  StreamSubscription<StepCount>? _stepStream;

  @override
  void initState() {
    super.initState();
    _requestActivityRecognitionPermission();
  }

  /// Minta izin ACTIVITY_RECOGNITION di Android (API 29 ke atas)
  Future<void> _requestActivityRecognitionPermission() async {
    if (Platform.isAndroid) {
      // Minta izin ACTIVITY_RECOGNITION
      final status = await Permission.activityRecognition.request();

      if (status.isGranted) {
        // Jika diizinkan, mulai pedometer
        _startTracking();
      } else if (status.isDenied) {
        // Izin ditolak sementara
        // Beri penjelasan ke user atau minta lagi di event tertentu
        print("ACTIVITY_RECOGNITION permission denied.");
      } else if (status.isPermanentlyDenied) {
        // User menolak izin secara permanen, arahkan ke settings
        print("ACTIVITY_RECOGNITION permission permanently denied.");
        await openAppSettings();
      }
    } else {
      // iOS tidak membutuhkan ACTIVITY_RECOGNITION
      _startTracking();
    }
  }

  /// Memulai streaming langkah dari Pedometer
  void _startTracking() {
    _stepStream = Pedometer.stepCountStream.listen((StepCount event) {
      final currentDate = DateTime.now();

      // Cek pergantian hari
      if (_lastUpdatedDate.day != currentDate.day ||
          _lastUpdatedDate.month != currentDate.month ||
          _lastUpdatedDate.year != currentDate.year) {
        // Reset data jika hari berganti
        _resetData();
      }

      // Simpan langkah awal (device steps) saat pertama kali didapat
      if (_initialStepCount == 0) {
        _initialStepCount = event.steps;
      }

      setState(() {
        // Hitung langkah relatif (dikurangi langkah awal)
        _stepCount = event.steps - _initialStepCount;

        // Konversi langkah menjadi jarak (km)
        _distance = (_stepCount * _stepLength) / 1000;

        // Hitung kalori terbakar
        _calculateCalories();

        // Update tanggal terakhir
        _lastUpdatedDate = currentDate;
      });
    }, onError: (error) {
      print('Step tracking error: $error');
    });
  }

  /// Reset data (misal saat pergantian hari)
  void _resetData() {
    setState(() {
      _stepCount = 0;
      _initialStepCount = 0;
      _distance = 0.0;
      _calories = 0.0;
    });
    print("Data reset at midnight.");
  }

  /// Hitung kalori berdasarkan langkah
  void _calculateCalories() {
    // Contoh kalkulasi sederhana
    double caloriesPerStep = _weight * 0.0005;
    double caloriesFromSteps = _stepCount * caloriesPerStep;

    setState(() {
      _calories = caloriesFromSteps;
    });
  }

  @override
  void dispose() {
    // Pastikan stream pedometer di-cancel saat widget dibuang
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

          // Lingkaran Progress (Custom Paint)
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(260, 260),
                  painter: CircleProgressPainter(progress: progress),
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

          // Info tambahan (kalori, jarak)
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

// Painter untuk membuat lingkaran progress
class CircleProgressPainter extends CustomPainter {
  final double progress;

  CircleProgressPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;

    // Lingkaran latar belakang (track)
    final trackPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12;

    canvas.drawCircle(center, radius, trackPaint);

    // Lingkaran progress
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

// Widget sederhana untuk menampilkan info kalori / jarak
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
