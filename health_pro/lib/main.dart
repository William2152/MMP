import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_pro/blocs/water/water_bloc.dart';
import 'package:health_pro/repositories/water_repository.dart';
import 'package:health_pro/screens/account_screen.dart';
import 'package:health_pro/screens/activity_tracker_screen.dart';
import 'package:health_pro/screens/food_log_screen.dart';
import 'package:health_pro/screens/home_screen.dart';
import 'package:health_pro/screens/landing_screen.dart';
import 'package:health_pro/screens/login_screen.dart';
import 'package:health_pro/screens/onboarding_screen.dart';
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
    null, // Ganti dengan ikon Anda
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
      autoStartOnBoot: true,
    ),
    iosConfiguration: IosConfiguration(
      onForeground: onStart,
      onBackground: (service) => true, // Log or handle as needed
      autoStart: true,
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

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final WaterRepository _waterRepository;
  final AuthRepository _authRepository;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  String _currentRoute = '/'; // Add this to track current route

  _MyAppState()
      : _waterRepository = WaterRepository(AwesomeNotifications()),
        _authRepository = AuthRepository(
          waterRepository: WaterRepository(AwesomeNotifications()),
        );

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

  // Add this method to track route changes
  void _updateCurrentRoute(String route) {
    _currentRoute = route;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          // Refresh the current screen instead of navigating to landing
          final currentState = _navigatorKey.currentState;
          if (currentState != null) {
            // Push the same route again to refresh
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
            seedColor: const Color(0xFFE3F4E9),
          ),
        ),
        initialRoute: '/',
        // Add navigator observers to track route changes
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
        },
      ),
    );
  }
}

// Add this custom navigator observer
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
