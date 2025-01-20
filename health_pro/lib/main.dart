import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_pro/blocs/water/water_bloc.dart';
import 'package:health_pro/models/step_activity.dart';
import 'package:health_pro/repositories/activity_repository.dart';
import 'package:health_pro/repositories/water_repository.dart';
import 'package:health_pro/screens/account_screen.dart';
import 'package:health_pro/screens/activity_tracker_screen.dart';
import 'package:health_pro/screens/birth_year_selector_screen.dart';
import 'package:health_pro/screens/food_log_screen.dart';
import 'package:health_pro/screens/gender_selection_screen.dart';
import 'package:health_pro/screens/height_selector_screen.dart';
import 'package:health_pro/screens/home_screen.dart';
import 'package:health_pro/screens/landing_screen.dart';
import 'package:health_pro/screens/login_screen.dart';
import 'package:health_pro/screens/onboarding_screen.dart';
import 'package:health_pro/screens/personal_information_screen.dart';
import 'package:health_pro/screens/vision_screen.dart';
import 'package:health_pro/screens/water_screen.dart';
import 'package:health_pro/screens/weight_selector_screen.dart';
import 'package:health_pro/services/background_pedometer_service.dart';
import 'package:health_pro/widgets/navigation_wrapper.dart';
import 'package:pedometer/pedometer.dart';
import 'blocs/auth/auth_bloc.dart';
import 'repositories/auth_repository.dart';
import 'screens/register_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await BackgroundPedometerService.initializeService();
  AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        channelKey: 'water_reminder',
        channelName: 'Water Reminder Notifications',
        channelDescription: 'Notifications to remind you to drink water',
        defaultColor: Colors.blue,
        importance: NotificationImportance.High,
        playSound: true,
      ),
      NotificationChannel(
        channelKey: 'step_counter',
        channelName: 'Step Tracker Notifications',
        channelDescription: 'Notifications for activity tracker updates',
        defaultColor: Colors.green,
        importance: NotificationImportance.High,
        playSound: true,
      ),
    ],
  );

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final WaterRepository _waterRepository;
  final AuthRepository _authRepository;
  final ActivityRepository _activityRepository;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  String _currentRoute = '/';

  _MyAppState()
      : _waterRepository = WaterRepository(AwesomeNotifications()),
        _authRepository = AuthRepository(
          waterRepository: WaterRepository(AwesomeNotifications()),
        ),
        _activityRepository = ActivityRepository();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _updateCurrentRoute(String route) {
    _currentRoute = route;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final currentState = _navigatorKey.currentState;
          if (currentState != null) {
            currentState.pushReplacementNamed(_currentRoute);
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(_authRepository),
        ),
        BlocProvider<WaterBloc>(
          create: (context) => WaterBloc(repository: _waterRepository),
        )
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        navigatorKey: _navigatorKey,
        title: 'HealthPro App',
        theme: ThemeData(
          primaryColor: const Color(0xFF2D5A27),
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.white,
          ),
        ),
        initialRoute: '/',
        navigatorObservers: [
          RouteObserver<PageRoute>(),
          _CustomNavigatorObserver((route) => _updateCurrentRoute(route)),
        ],
        routes: {
          '/': (context) => const LandingScreen(),
          '/onboarding': (context) => const OnboardingScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
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
          '/vision': (context) => NavigationWrapper(
                screen: const VisionScreen(),
                showBottomBar: true,
              ),
          '/height': (context) => NavigationWrapper(
                screen: const HeightSelectorScreen(),
                showBottomBar: true,
              ),
          '/birth': (context) => NavigationWrapper(
                screen: const BirthYearSelectorScreen(),
                showBottomBar: true,
              ),
          '/weight': (context) => NavigationWrapper(
                screen: const WeightSelectorScreen(),
                showBottomBar: true,
              ),
          '/gender': (context) => NavigationWrapper(
                screen: const GenderSelectionScreen(),
                showBottomBar: true,
              ),
          '/personal': (context) => NavigationWrapper(
                screen: PersonalInformationScreen(),
                showBottomBar: true,
              ),
        },
      ),
    );
  }
}

class _CustomNavigatorObserver extends NavigatorObserver {
  final Function(String) onRouteChanged;

  _CustomNavigatorObserver(this.onRouteChanged);

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route.settings.name != null) {
      onRouteChanged(route.settings.name!);
    }
    super.didPush(route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute?.settings.name != null) {
      onRouteChanged(newRoute!.settings.name!);
    }
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }
}
