import 'package:flutter/material.dart';

class CustomBottomBar extends StatefulWidget {
  final Color backgroundColor;
  final Color selectedColor;
  final Color unselectedColor;

  const CustomBottomBar({
    Key? key,
    this.backgroundColor = const Color(0xFFE3F4E9),
    this.selectedColor = const Color(0xFF2D5A27),
    this.unselectedColor = Colors.black54,
  }) : super(key: key);

  @override
  State<CustomBottomBar> createState() => _CustomBottomBarState();
}

class _CustomBottomBarState extends State<CustomBottomBar> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> _navigationItems = [
    {
      'icon': Icons.home,
      'label': 'Home',
      'route': '/home',
    },
    {
      'icon': Icons.show_chart,
      'label': 'Nutrition',
      'route': '/nutrition',
    },
    {
      'icon': Icons.schedule,
      'label': 'Schedule',
      'route': '/schedule',
    },
    {
      'icon': Icons.person,
      'label': 'Profile',
      'route': '/profile',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final itemCount = _navigationItems.length + 1; // +1 for center logo
    final middleIndex = itemCount ~/ 2;

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
            children: List.generate(itemCount, (index) {
              // Center logo
              if (index == middleIndex) {
                return SizedBox(
                  width: 60,
                  height: 60,
                  child: Center(
                    child: Image.asset(
                      'assets/images/healthpro_logo.png',
                      fit: BoxFit.fitWidth,
                      width: 50,
                    ),
                  ),
                );
              }

              // Adjust index for items after logo
              final itemIndex = index > middleIndex ? index - 1 : index;
              final item = _navigationItems[itemIndex];
              final isSelected = _selectedIndex == itemIndex;

              return Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedIndex = itemIndex;
                      });
                      Navigator.pushNamed(context, item['route']);
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
            }),
          ),
        ),
      ),
    );
  }
}
