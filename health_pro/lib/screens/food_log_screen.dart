import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_state.dart';
import '../models/user_model.dart';

class FoodLogScreen extends StatefulWidget {
  const FoodLogScreen({super.key});

  @override
  _FoodLogScreenState createState() => _FoodLogScreenState();
}

class _FoodLogScreenState extends State<FoodLogScreen> {
  final ScrollController _dateScrollController = ScrollController();
  DateTime selectedDate = DateTime.now();
  List<DateTime> dates = [];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthSuccess) {
          // Initialize dates list if not already done
          if (dates.isEmpty) {
            selectedDate = DateTime.now();
            dates = List.generate(
              7,
              (index) => DateTime.now().subtract(Duration(days: 3 - index)),
            );
          }
          return _buildMainUI(state.user);
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildMainUI(UserModel user) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Food Log',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () => _showDatePicker(user),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormat('MMMM yyyy').format(selectedDate),
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Icon(Icons.arrow_drop_down, color: Colors.black),
              ],
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          _buildDateSelector(),
          _buildCaloriesRemaining(),
          Expanded(
            child: _buildTimelineView(),
          ),
        ],
      ),
    );
  }

  void _showDatePicker(UserModel user) {
    final now = DateTime.now();
    final createdAt = user.createdAt;

    // Calculate initial indices
    int initialMonthIndex = selectedDate.month - 1;
    int initialYearIndex = selectedDate.year - createdAt.year;
    int currentSelectedYear = selectedDate.year;
    int currentSelectedMonth = selectedDate.month;

    // Calculate the total number of months between createdAt and now
    int startMonth = createdAt.month;
    int startYear = createdAt.year;

    // Controllers for the pickers
    late FixedExtentScrollController monthController;
    late FixedExtentScrollController yearController;

    // Initialize controllers
    monthController =
        FixedExtentScrollController(initialItem: initialMonthIndex);
    yearController = FixedExtentScrollController(initialItem: initialYearIndex);

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            // Calculate available months based on selected year
            int availableMonths = 12;

            // For the account creation year
            if (currentSelectedYear == startYear) {
              // Start from the creation month
              startMonth = createdAt.month;
            } else {
              // For other years, start from January
              startMonth = 1;
            }

            // For the current year
            if (currentSelectedYear == now.year) {
              availableMonths = now.month;
            }

            return Container(
              height: 300,
              color: Colors.white,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey[300]!,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        const Text(
                          'Select Date',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              selectedDate = DateTime(
                                currentSelectedYear,
                                currentSelectedMonth,
                                1,
                              );
                            });
                            Navigator.pop(context);
                          },
                          child: const Text('Done'),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        // Year picker
                        Expanded(
                          child: CupertinoPicker(
                            itemExtent: 40,
                            scrollController: yearController,
                            onSelectedItemChanged: (index) {
                              setModalState(() {
                                currentSelectedYear = createdAt.year + index;

                                // Adjust month if needed
                                if (currentSelectedYear == startYear &&
                                    currentSelectedMonth < startMonth) {
                                  currentSelectedMonth = startMonth;
                                  monthController.jumpToItem(startMonth - 1);
                                } else if (currentSelectedYear == now.year &&
                                    currentSelectedMonth > now.month) {
                                  currentSelectedMonth = now.month;
                                  monthController.jumpToItem(now.month - 1);
                                }
                              });
                            },
                            children: List.generate(
                              now.year - createdAt.year + 1,
                              (index) {
                                return Center(
                                  child: Text(
                                    '${createdAt.year + index}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        // Month picker
                        Expanded(
                          child: CupertinoPicker(
                            itemExtent: 40,
                            scrollController: monthController,
                            onSelectedItemChanged: (index) {
                              setModalState(() {
                                // Adjust the month based on the actual available range
                                currentSelectedMonth = startMonth + index;
                              });
                            },
                            children: List.generate(
                              availableMonths - startMonth + 1,
                              (index) {
                                final month = startMonth + index;
                                return Center(
                                  child: Text(
                                    DateFormat('MMMM')
                                        .format(DateTime(2024, month)),
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      // Dispose controllers when the bottom sheet is closed
      monthController.dispose();
      yearController.dispose();
    });
  }

  Widget _buildDateSelector() {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: ListView.builder(
        controller: _dateScrollController,
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        itemBuilder: (context, index) {
          final date = dates[index];
          final isSelected = date.day == selectedDate.day;
          return GestureDetector(
            onTap: () => setState(() => selectedDate = date),
            child: Container(
              width: 60,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                border: Border.all(
                  color:
                      isSelected ? const Color(0xFF8BC34A) : Colors.transparent,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('d').format(date),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  Text(
                    DateFormat('E').format(date),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCaloriesRemaining() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Calories Remaining',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCalorieBox('1,064', 'Goal'),
              const Text('-', style: TextStyle(fontSize: 20)),
              _buildCalorieBox('0', 'Food'),
              const Text('+', style: TextStyle(fontSize: 20)),
              _buildCalorieBox('0', 'Exercise'),
              const Text('=', style: TextStyle(fontSize: 20)),
              _buildCalorieBox('1,064', 'Remaining'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalorieBox(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color:
                label == 'Remaining' ? const Color(0xFF8BC34A) : Colors.black,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineView() {
    final meals = [
      _MealEntry(
        time: '7:00 AM',
        title: 'Breakfast',
        food: 'Overnight oat',
        calories: 280,
        color: const Color(0xFFE8F5E9),
      ),
      _MealEntry(
        time: '9:00 AM',
        title: 'Snacks',
        food: 'Banana',
        calories: 88.7,
        color: const Color(0xFFE8F5E9),
      ),
      _MealEntry(
        time: '1:00 PM',
        title: 'Lunch',
        food: 'Banana',
        calories: 88.7,
        color: const Color(0xFFFFF3E0),
      ),
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 24, // Show all hours
      itemBuilder: (context, index) {
        final hour = index + 1;
        final time =
            '${hour > 12 ? hour - 12 : hour}:00 ${hour >= 12 ? 'PM' : 'AM'}';
        final meal = meals.firstWhere(
          (m) => m.time == time,
          orElse: () => _MealEntry(
              time: time,
              title: '',
              food: '',
              calories: 0,
              color: Colors.transparent),
        );

        return Column(
          children: [
            Row(
              children: [
                SizedBox(
                  width: 80,
                  child: Text(
                    time,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                Expanded(
                  child: meal.title.isNotEmpty
                      ? Container(
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: meal.color,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    meal.title,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    meal.food,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                '${meal.calories} kcal',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox(height: 40),
                ),
              ],
            ),
            const Divider(height: 1),
          ],
        );
      },
    );
  }

  void _showMonthPicker() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 300,
          color: Colors.white,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey[300]!,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const Text(
                      'Select Month',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Done'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 40,
                  onSelectedItemChanged: (index) {
                    setState(() {
                      selectedDate = DateTime(
                          selectedDate.year, index + 1, selectedDate.day);
                    });
                  },
                  children: List.generate(12, (index) {
                    return Center(
                      child: Text(
                        DateFormat('MMMM').format(DateTime(2024, index + 1)),
                        style: const TextStyle(fontSize: 16),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MealEntry {
  final String time;
  final String title;
  final String food;
  final double calories;
  final Color color;

  _MealEntry({
    required this.time,
    required this.title,
    required this.food,
    required this.calories,
    required this.color,
  });
}
