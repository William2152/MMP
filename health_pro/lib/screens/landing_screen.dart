import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';
import '../blocs/auth/auth_state.dart';
import 'dart:io' show Platform;

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_animationController);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAndNavigate();
      _requestPermissions(); // Tambahkan pemeriksaan izin di sini
    });
  }

  /// Memeriksa izin notifikasi dan aktivitas
  Future<void> _requestPermissions() async {
    // Periksa izin notifikasi
    final notificationPermission = await Permission.notification.status;
    if (notificationPermission.isDenied) {
      await Permission.notification.request();
    }

    // Periksa izin aktivitas (activity recognition)
    if (Platform.isAndroid) {
      final activityPermission = await Permission.activityRecognition.request();
      if (!activityPermission.isGranted) {
        debugPrint("Activity Recognition permission not granted.");
        await openAppSettings();
      }
    }
  }

  /// Navigasi dengan animasi
  Future<void> _initializeAndNavigate() async {
    try {
      await _animationController.forward();

      if (!mounted) return;

      context.read<AuthBloc>().add(CheckAuthStatus());
    } catch (e) {
      debugPrint('Navigation error: $e');
      if (mounted && !_isNavigating) {
        await _performNavigationWithAnimation('/onboarding');
      }
    }
  }

  Future<void> _performNavigationWithAnimation(String route) async {
    if (_isNavigating) return;
    _isNavigating = true;

    await _animationController.reverse();

    if (!mounted) return;

    Navigator.of(context).pushReplacementNamed(route);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authBloc = BlocProvider.of<AuthBloc>(context);
      authBloc.add(CheckUserData());
    });
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is UserDataIncomplete && !_isNavigating) {
          await _performNavigationWithAnimation('/weight');
        } else if (state is AuthSuccess && !_isNavigating) {
          await _performNavigationWithAnimation('/home');
        } else if ((state is AuthUnauthenticated || state is AuthError) &&
            !_isNavigating) {
          await _performNavigationWithAnimation('/onboarding');
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF98D8AA),
        body: FadeTransition(
          opacity: _animation,
          child: SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/healthpro_logo.png',
                    width: 250,
                    fit: BoxFit.fitWidth,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Track your health, transform your life!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
