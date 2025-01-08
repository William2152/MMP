// lib/main.dart

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:pedometer/pedometer.dart'; // Tambahkan pustaka pedometer
import 'package:health_pro/screens/activity_tracker_screen.dart';
import 'package:health_pro/screens/home_screen.dart';
import 'package:health_pro/screens/landing_screen.dart';
import 'package:health_pro/screens/login_screen.dart';
import 'package:health_pro/screens/nutrition_counter_screen.dart';
import 'blocs/auth/auth_bloc.dart';
import 'repositories/auth_repository.dart';
import 'screens/register_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await initializeBackgroundService(); // Inisialisasi background service
  runApp(MyApp());
}

Future<void> initializeBackgroundService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      isForegroundMode: true,
      autoStart: true,
    ),
    iosConfiguration: IosConfiguration(
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );

  await service.startService();
}

@pragma('vm:entry-point')
Future<void> onStart(ServiceInstance service) async {
  if (service is AndroidServiceInstance) {
    service.setForegroundNotificationInfo(
      title: "HealthPro Pedometer",
      content: "Tracking steps in background...",
    );
  }

  // Handle stop event
  service.on("stop").listen((event) {
    service.stopSelf();
  });

  // Track step count in the background
  Pedometer.stepCountStream.listen((StepCount event) {
    final stepData = {"steps": event.steps};
    service.invoke("update_steps", stepData);
  });
}

@pragma('vm:entry-point')
bool onIosBackground(ServiceInstance service) {
  return true;
}

class MyApp extends StatelessWidget {
  final AuthRepository _authRepository = AuthRepository();

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(_authRepository),
        ),
      ],
      child: MaterialApp(
        title: 'HealthPro App',
        theme: ThemeData(
          primaryColor: const Color(0xFF2D5A27),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2D5A27),
          ),
        ),
        initialRoute: '/activity_tracker',
        routes: {
          '/': (context) => const LandingScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/home': (context) => const HomeScreen(),
          '/nutrition': (context) => const NutritionCounterScreen(),
          '/activity_tracker': (context) => ActivityTrackerScreen(),
        },
      ),
    );
  }
}
