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
import 'package:health_pro/screens/food_log_screen.dart';
import 'package:health_pro/screens/home_screen.dart';
import 'package:health_pro/screens/landing_screen.dart';
import 'package:health_pro/screens/login_screen.dart';
import 'package:health_pro/screens/onboarding_screen.dart';
import 'package:health_pro/screens/vision_screen.dart';
import 'package:health_pro/screens/water_screen.dart';
import 'package:health_pro/widgets/navigation_wrapper.dart';
import 'package:pedometer/pedometer.dart';
import 'blocs/auth/auth_bloc.dart';
import 'repositories/auth_repository.dart';
import 'screens/register_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

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
        channelKey: 'activity_tracker',
        channelName: 'Activity Tracker Notifications',
        channelDescription: 'Notifications for activity tracker updates',
        defaultColor: Colors.green,
        importance: NotificationImportance.High,
        playSound: true,
      ),
    ],
  );

  await initializeBackgroundService();
  runApp(MyApp());
}

@pragma('vm:entry-point')
Future<void> onStart(ServiceInstance service) async {
  // Set foreground notification immediately for Android
  if (service is AndroidServiceInstance) {
    // Must be called within 5 seconds on Android
    await service.setAsForegroundService();
    await service.setForegroundNotificationInfo(
      title: "HealthPro Pedometer",
      content: "Tracking steps in background...",
    );
  }

  final repository = ActivityRepository();

  try {
    Pedometer.stepCountStream.listen((StepCount event) {
      final steps = event.steps;
      final distance = steps * 0.78 / 1000;
      final calories = steps * 0.05;
      final now = DateTime.now();

      repository.saveActivity(StepActivity(
        id: 'background_${now.toIso8601String()}',
        userId: 'current_user_id',
        steps: steps,
        distance: distance,
        calories: calories,
        date: now.toIso8601String(),
        lastUpdated: now,
        isSynced: false,
      ));
    }, onError: (error) {
      print('Pedometer error: $error');
    });
  } catch (e) {
    print('Error initializing step counter: $e');
  }
}

Future<void> initializeBackgroundService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      isForegroundMode: true,
      autoStart: true,
      autoStartOnBoot: true,
      foregroundServiceNotificationId: 888, // Add a unique notification ID
    ),
    iosConfiguration: IosConfiguration(
      onForeground: onStart,
      onBackground: (service) => true,
      autoStart: true,
    ),
  );

  await service.startService();
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
