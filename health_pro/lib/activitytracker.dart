import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pedometer/pedometer.dart';
import 'dart:async';
import 'package:permission_handler/permission_handler.dart';

class _ActivityTracker extends StatefulWidget {
  const _ActivityTracker({Key? key}) : super(key: key);

  @override
  _ActivityTrackerState createState() => _ActivityTrackerState();
}

class _ActivityTrackerState extends State<_ActivityTracker> {
  double _distance = 0.0; // Total jarak dalam meter
  double _calories = 0.0; // Total kalori terbakar
  int _stepCount = 0; // Langkah berjalan sejak tracking dimulai
  int _initialStepCount = 0; // Langkah awal dari perangkat
  int _targetSteps = 10000; // Target langkah
  double _weight = 70.0; // Berat badan pengguna dalam kg (bisa diubah)
  List<Position> _positions = []; // Menyimpan lokasi pengguna
  StreamSubscription<Position>? _positionStream;
  StreamSubscription<StepCount>? _stepStream;

  bool _isTracking = false; // Menandai apakah tracking aktif

  @override
  void initState() {
    super.initState();
  }

  Future<void> _startTracking() async {
    // Minta izin lokasi
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      print('Permission denied for location.');
      return;
    } else {
      print('Location permission granted.');
    }

    // Minta izin activityRecognition
    final status = await Permission.activityRecognition.request();
    if (!status.isGranted) {
      print('Permission denied for activity recognition.');
      return;
    } else {
      print('Activity recognition permission granted.');
    }

    setState(() {
      _isTracking = true;
      _distance = 0.0;
      _stepCount = 0;
      _calories = 0.0;
      _positions.clear();
    });

    // Mulai pelacakan langkah
    _stepStream = Pedometer.stepCountStream.listen((StepCount event) {
      if (_initialStepCount == 0) {
        // Simpan langkah awal
        _initialStepCount = event.steps;
        print('Initial step count: $_initialStepCount');
      }

      setState(() {
        // Hitung langkah relatif terhadap langkah awal
        _stepCount = event.steps - _initialStepCount;
        print('Steps updated: $_stepCount');
        _calculateCalories();
      });
    }, onError: (error) {
      print('Step tracking error: $error');
    });

    // Mulai pelacakan posisi
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).listen((Position position) {
      setState(() {
        if (_positions.isNotEmpty) {
          // Hitung jarak berdasarkan posisi terbaru
          _distance += Geolocator.distanceBetween(
            _positions.last.latitude,
            _positions.last.longitude,
            position.latitude,
            position.longitude,
          );
          print('Distance updated: $_distance meters');
          _calculateCalories();
        }
        _positions.add(position);
      });
    });
  }

  void _stopTracking() {
    setState(() {
      _isTracking = false;
      _initialStepCount = 0; // Reset langkah awal saat berhenti tracking
    });

    _positionStream?.cancel();
    _stepStream?.cancel();

    print('Tracking stopped. Total distance: ${_distance / 1000} km');
  }

  void _calculateCalories() {
    double caloriesPerStep = _weight * 0.0005;
    double caloriesPerKm = _weight * 1.036;

    double caloriesFromSteps = _stepCount * caloriesPerStep;
    double distanceInKm = _distance / 1000; // Konversi jarak ke kilometer
    double caloriesFromDistance = distanceInKm * caloriesPerKm;

    setState(() {
      _calories =
          (caloriesFromSteps + caloriesFromDistance) / 2; // Rata-rata kalori
    });
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
                  value: '${(_distance / 1000).toStringAsFixed(2)} km',
                  icon: Icons.directions_walk,
                ),
              ],
            ),
          ),
          const Spacer(),
          // Tombol Start/Stop Tracking
          Padding(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 40),
              ),
              onPressed: _isTracking ? _stopTracking : _startTracking,
              child: Text(
                _isTracking ? 'Stop Tracking' : 'Start Tracking',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ),
          ),
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
