// navigation_wrapper.dart
import 'package:flutter/material.dart';
import 'custom_bottom_bar.dart';

class NavigationWrapper extends StatefulWidget {
  final Widget screen;
  final bool showBottomBar;

  static const List<String> screensWithBottomBar = [
    '/home',
    '/activity',
    '/water', // Fixed missing comma
    '/food_log',
    '/account',
  ];

  const NavigationWrapper({
    super.key,
    required this.screen,
    this.showBottomBar = true,
  });

  @override
  State<NavigationWrapper> createState() => _NavigationWrapperState();
}

class _NavigationWrapperState extends State<NavigationWrapper> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = 0;
  }

  void _onNavigate(int index, String route) {
    if (mounted) {
      setState(() {
        _currentIndex = index;
      });
    }
    Navigator.pushReplacementNamed(context, route);
  }

  int _getCurrentIndex(String route) {
    final index = NavigationWrapper.screensWithBottomBar.indexOf(route);
    return index != -1 ? index : 0; // Return 0 if route not found
  }

  @override
  Widget build(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name;
    final shouldShowBottomBar = widget.showBottomBar &&
        currentRoute != null &&
        NavigationWrapper.screensWithBottomBar.contains(currentRoute);

    if (currentRoute != null) {
      _currentIndex = _getCurrentIndex(currentRoute);
    }

    return Scaffold(
      body: widget.screen,
      bottomNavigationBar: shouldShowBottomBar
          ? CustomBottomBar(
              currentIndex: _currentIndex,
              onNavigate: _onNavigate,
            )
          : null,
    );
  }
}
