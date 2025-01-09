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
import 'package:health_pro/screens/getting_started_screen.dart';
import 'package:health_pro/screens/home_screen.dart';
import 'package:health_pro/screens/landing_screen.dart';
import 'package:health_pro/screens/login_screen.dart';
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

  // Create a GlobalKey for Navigator
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

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

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Schedule navigation after the current frame is drawn
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          // Use the NavigatorState from the global key
          _navigatorKey.currentState?.pushReplacementNamed('/');
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
        navigatorKey:
            _navigatorKey, // Pass the navigator key to the MaterialApp
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
