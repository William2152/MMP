// lib/main.dart

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_pro/screens/account_screen.dart';
import 'package:health_pro/screens/food_log_screen.dart';
import 'package:health_pro/screens/getting_started_screen.dart';
import 'package:health_pro/screens/home_screen.dart';
import 'package:health_pro/screens/landing_screen.dart';
import 'package:health_pro/screens/login_screen.dart';
import 'package:health_pro/screens/nutrition_counter_screen.dart';
import 'package:health_pro/screens/water_reminder_screen.dart';
import 'package:health_pro/screens/water_screen.dart';
import 'package:health_pro/widgets/navigation_wrapper.dart';
import 'blocs/auth/auth_bloc.dart';
import 'repositories/auth_repository.dart';
import 'blocs/water_old/water_bloc_old.dart';
import 'repositories/water_repository_old.dart';
import 'screens/register_screen.dart';
// import 'screens/export.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
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
        initialRoute: '/',
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
                screen: const NutritionCounterScreen(),
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
          '/hydration': (context) => NavigationWrapper(
                screen: const WaterReminderScreen(),
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
