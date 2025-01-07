// lib/main.dart

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_pro/activitytracker.dart';
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
  runApp(MyApp());
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
        initialRoute: '/activity',
        routes: {
          '/': (context) => const LandingScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/home': (context) => const HomeScreen(),
          '/nutrition': (context) => const NutritionCounterScreen(),
          '/activity': (context) => const ActivityTracker(),
        },
      ),
    );
  }
}
