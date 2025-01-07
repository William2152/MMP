import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pedometer/pedometer.dart';
import 'dart:async';

import 'package:permission_handler/permission_handler.dart';

class ActivityTracker extends StatefulWidget {
  const ActivityTracker({Key? key}) : super(key: key);

  @override
  _ActivityTrackerState createState() => _ActivityTrackerState();
}

class _ActivityTrackerState extends State<ActivityTracker> {
  // Variabel untuk pelacakan lokasi dan jarak
  double _distance = 0.0; // Total jarak (meter)
  List<Position> _positions = []; // Menyimpan lokasi pengguna

  // Variabel untuk waktu bergerak
  DateTime? _startTime; // Waktu mulai
  DateTime? _endTime; // Waktu berhenti

  // Variabel untuk langkah
  int _stepCount = 0; // Total langkah

  @override
  void initState() {
    super.initState();
    _startTracking(); // Memulai pelacakan lokasi
    _startStepTracking(); // Memulai pelacakan langkah
    _debugTracker(); // Debug tracker
  }

  /// Meminta izin lokasi dan mulai melacak
  Future<void> _startTracking() async {
    print('Requesting location permission...');
    LocationPermission permission = await Geolocator.requestPermission();
    print('Location permission: $permission');

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      print('Permission denied.');
      return;
    }

    final status = await Permission.activityRecognition.request();
    if (status.isGranted) {
      print('Activity Recognition permission granted.');
    } else {
      print('Activity Recognition permission denied.');
    }

    print('Starting location tracking...');
    _startTime = DateTime.now(); // Catat waktu mulai

    Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).listen((Position position) {
      print('New position: ${position.latitude}, ${position.longitude}');
      setState(() {
        if (_positions.isNotEmpty) {
          // Hitung jarak antara titik terakhir dan titik baru
          _distance += Geolocator.distanceBetween(
            _positions.last.latitude,
            _positions.last.longitude,
            position.latitude,
            position.longitude,
          );
          print('Updated distance: $_distance meters');
        }
        _positions.add(position);
      });
    }, onError: (error) {
      print('Location tracking error: $error');
    });
  }

  /// Memulai pelacakan langkah menggunakan pedometer
  void _startStepTracking() {
    print('Starting step tracking...');
    Pedometer.stepCountStream.listen((StepCount event) {
      print('New step count: ${event.steps}');
      setState(() {
        _stepCount = event.steps; // Perbarui jumlah langkah
      });
    }, onError: (error) {
      print('Step tracking error: $error');
    });
  }

  /// Debug tracker untuk memantau status
  void _debugTracker() {
    Timer.periodic(const Duration(seconds: 5), (timer) {
      print(
          'Debug -> Distance: $_distance meters, Steps: $_stepCount, Time: ${_getMovingTime()}');
      if (_endTime != null) {
        timer.cancel(); // Hentikan timer jika pelacakan dihentikan
      }
    });
  }

  /// Menghentikan pelacakan
  void _stopTracking() {
    print('Stopping tracking...');
    _endTime = DateTime.now(); // Catat waktu berhenti
    print('End time: $_endTime');
    print('Total moving time: ${_getMovingTime()}');
    setState(() {});
  }

  /// Menghitung waktu bergerak dalam format jam, menit, detik
  String _getMovingTime() {
    if (_startTime == null || _endTime == null) return "N/A";
    final duration = _endTime!.difference(_startTime!);
    return "${duration.inHours}h ${duration.inMinutes % 60}m ${duration.inSeconds % 60}s";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Activity Tracker')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Steps Taken: $_stepCount',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              'Distance Traveled: ${_distance.toStringAsFixed(2)} meters',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              'Moving Time: ${_endTime == null ? "Tracking..." : _getMovingTime()}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _stopTracking,
              child: const Text('Stop Tracking'),
            ),
          ],
        ),
      ),
    );
  }
}
