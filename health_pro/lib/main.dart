// lib/main.dart

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_pro/screens/account_screen.dart';
import 'package:health_pro/screens/activity_tracker_screen.dart';
import 'package:health_pro/screens/food_log_screen.dart';
import 'package:health_pro/screens/getting_started_screen.dart';
import 'package:health_pro/screens/home_screen.dart';
import 'package:health_pro/screens/landing_screen.dart';
import 'package:health_pro/screens/login_screen.dart';
import 'package:health_pro/screens/nutrition_counter_screen.dart';
import 'package:health_pro/screens/water_screen.dart';
import 'package:health_pro/widgets/navigation_wrapper.dart';
import 'package:pedometer/pedometer.dart';
import 'blocs/auth/auth_bloc.dart';
import 'repositories/auth_repository.dart';
import 'blocs/water_old/water_bloc_old.dart';
import 'repositories/water_repository_old.dart';
import 'screens/register_screen.dart';
// import 'screens/export.dart';

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
  final WaterRepository _waterRepository = WaterRepository();
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(_authRepository),
        ),
        BlocProvider<WaterBloc>(
          create: (context) => WaterBloc(_waterRepository),
        )
      ],
      child: MaterialApp(
        title: 'HealthPro App',
        theme: ThemeData(
          primaryColor: const Color(0xFF2D5A27),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFE3F4E9),
          ),
        ),
        initialRoute: '/activity_tracker',
        routes: {
          '/': (context) => const LandingScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/get_start': (context) => GettingStartedScreen(),
          '/home': (context) => NavigationWrapper(
                screen: const HomeScreen(),
                showBottomBar: true,
              ),
          '/activity': (context) => NavigationWrapper(
                screen: const ActivityTrackerScreen(),
                showBottomBar: true,
              ),
          '/account': (context) => NavigationWrapper(
                screen: AccountScreen(),
                showBottomBar: true,
              ),
          '/food_log': (context) => NavigationWrapper(
                screen: const FoodLogScreen(),
                showBottomBar: true,
              ),
          '/water': (context) => NavigationWrapper(
                screen: const WaterScreen(),
                showBottomBar: true,
              ),
        },
      ),
    );
  }
}
