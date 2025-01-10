import 'package:flutter/material.dart';

class CustomBottomBar extends StatefulWidget {
  final Color backgroundColor;
  final Color selectedColor;
  final Color unselectedColor;
  final int currentIndex;
  final void Function(int index, String route) onNavigate;

  const CustomBottomBar({
    super.key,
    required this.currentIndex,
    required this.onNavigate,
    this.backgroundColor = const Color(0xFFE3F4E9),
    this.selectedColor = const Color(0xFF2D5A27),
    this.unselectedColor = Colors.grey,
  });

  @override
  State<CustomBottomBar> createState() => _CustomBottomBarState();
}

class _CustomBottomBarState extends State<CustomBottomBar> {
  final List<Map<String, dynamic>> _navigationItems = [
    {
      'icon': Icons.home,
      'label': 'Home',
      'route': '/home',
    },
    {
      'icon': Icons.show_chart,
      'label': 'Activity',
      'route': '/activity',
    },
    {
      'icon': Icons.water_drop,
      'label': 'Water',
      'route': '/water',
    },
    {
      'icon': Icons.schedule,
      'label': 'Food Log',
      'route': '/food_log',
    },
    {
      'icon': Icons.person,
      'label': 'Account',
      'route': '/account',
    },
    {
      'icon': Icons.person,
      'label': 'Vision',
      'route': '/vision',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _navigationItems.asMap().entries.map((entry) {
              final int itemIndex = entry.key;
              final Map<String, dynamic> item = entry.value;
              final bool isSelected = widget.currentIndex == itemIndex;

              return Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      widget.onNavigate(itemIndex, item['route']);
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          item['icon'],
                          color: isSelected
                              ? widget.selectedColor
                              : widget.unselectedColor,
                          size: 24,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item['label'],
                          style: TextStyle(
                            fontSize: 12,
                            color: isSelected
                                ? widget.selectedColor
                                : widget.unselectedColor,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
