import 'package:flutter/material.dart';
import 'custom_bottom_bar.dart';

class NavigationWrapper extends StatefulWidget {
  final Widget screen;
  final bool showBottomBar;

  static const List<String> screensWithBottomBar = [
    '/home',
    '/activity',
    '/food_log',
    '/account',
    '/water'
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
  int _currentIndex = 0;

  void _onNavigate(int index, String route) {
    setState(() {
      _currentIndex = index;
    });
    Navigator.pushReplacementNamed(context, route);
  }

  int _getCurrentIndex(String route) {
    return NavigationWrapper.screensWithBottomBar.indexOf(route);
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
