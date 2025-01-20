import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:health_pro/widgets/custom_month_year_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
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

  Future<void> _requestCameraPermission() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      status = await Permission.camera.request();
    }

    if (!status.isGranted) {
      // Tampilkan pesan kepada user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Camera permission is required to use this feature.'),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      await Future.delayed(const Duration(milliseconds: 500));
      Navigator.pushNamed(context, '/vision');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthSuccess) {
          // Initialize dates list if not already done
          if (dates.isEmpty) {
            selectedDate = DateTime.now();
            dates =
                _getDaysInMonth(selectedDate); // Ambil semua hari dalam bulan
            // Scroll ke tanggal hari ini
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _scrollToSelectedDate();
            });
          }
          return _buildMainUI(state.user);
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  // Fungsi untuk scroll ke tanggal yang dipilih
  void _scrollToSelectedDate() {
    final index = dates.indexWhere((date) => date.day == selectedDate.day);
    if (index != -1) {
      _dateScrollController.animateTo(
        index * 68.0, // Sesuaikan dengan lebar item tanggal
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
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
          Expanded(
            child: _buildTimelineView(user),
          ),
        ],
      ),
      floatingActionButton: _isToday(selectedDate)
          ? FloatingActionButton(
              onPressed: () {
                _requestCameraPermission();
              },
              backgroundColor: const Color(0xFF4CAF50),
              child: const Icon(Icons.camera_alt),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  void _showDatePicker(UserModel user) {
    CustomMonthYearPicker.show(
      context,
      initialDate: selectedDate,
      createdAt: user.createdAt,
      onDateSelected: (DateTime date) {
        setState(() {
          selectedDate = date;
          // Reset dates list untuk semua hari dalam bulan yang dipilih
          dates = _getDaysInMonth(date);
          // Scroll ke tanggal yang dipilih
          _scrollToSelectedDate();
        });
      },
    );
  }

  // Fungsi untuk mendapatkan semua hari dalam bulan tertentu
  List<DateTime> _getDaysInMonth(DateTime date) {
    final lastDayOfMonth = DateTime(date.year, date.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;

    return List.generate(
      daysInMonth,
      (index) => DateTime(date.year, date.month, index + 1),
    );
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

  Widget _buildCaloriesRemaining(int goalCalories, int totalFoodCalories) {
    final int remainingCalories = goalCalories - totalFoodCalories;
    final bool isOvershoot = remainingCalories < 0;

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
              _buildCalorieBox('$goalCalories', 'Goal'),
              const Text('-', style: TextStyle(fontSize: 20)),
              _buildCalorieBox('$totalFoodCalories', 'Food'),
              const Text('=', style: TextStyle(fontSize: 20)),
              _buildCalorieBox(
                isOvershoot ? '${-remainingCalories}' : '$remainingCalories',
                isOvershoot ? 'Overshoot' : 'Remaining',
                color: isOvershoot ? Colors.red : const Color(0xFF8BC34A),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalorieBox(String value, String label, {Color? color}) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color ?? Colors.black,
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

  Widget _buildTimelineView(UserModel user) {
    final userId = user.id;
    final int goalCalories = user.caloriesGoal; // Ambil goal dari user

    final startOfDay =
        DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    final endOfDay = DateTime(
        selectedDate.year, selectedDate.month, selectedDate.day, 23, 59, 59);

    int totalFoodCalories = 0; // Total kalori makanan untuk hari yang dipilih

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('calorie_food_tracking')
          .where('userId', isEqualTo: userId)
          .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
          .where('timestamp', isLessThanOrEqualTo: endOfDay)
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final Map<int, List<_MealEntry>> hourlyMeals = Map.fromIterable(
          List.generate(24, (index) => index),
          key: (hour) => hour,
          value: (hour) => [],
        );

        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          final documents = snapshot.data!.docs;

          for (var doc in documents) {
            final data = doc.data() as Map<String, dynamic>;
            final foods = data['foods'] as List<dynamic>;
            final timestamp = (data['timestamp'] as Timestamp).toDate();
            final hour = timestamp.hour;
            final category = data['category'] as String;

            for (var food in foods) {
              final calories = (food['calories'] as num).toInt();
              hourlyMeals[hour]?.add(_MealEntry(
                time: DateFormat('h:mm a').format(timestamp),
                title: category,
                food: food['name'],
                calories: calories.toDouble(),
                color: _getCategoryColor(category),
              ));

              // Tambahkan kalori ke total
              totalFoodCalories += calories;
            }
          }
        }

        return Column(
          children: [
            // Tampilkan kalori remaining
            _buildCaloriesRemaining(goalCalories, totalFoodCalories),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: 24,
                itemBuilder: (context, index) {
                  final hour = index;
                  final timeLabel =
                      '${hour == 0 ? 12 : hour > 12 ? hour - 12 : hour}:00 ${hour >= 12 ? 'PM' : 'AM'}';
                  final meals = hourlyMeals[hour] ?? [];

                  return Column(
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 80,
                            child: Text(
                              timeLabel,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                          Expanded(
                            child: meals.isNotEmpty
                                ? Container(
                                    margin: const EdgeInsets.only(top: 8),
                                    child: Column(
                                      children: meals.map((meal) {
                                        return Container(
                                          padding: const EdgeInsets.all(16),
                                          margin:
                                              const EdgeInsets.only(bottom: 8),
                                          decoration: BoxDecoration(
                                            color: meal.color,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    meal.title,
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
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
                                        );
                                      }).toList(),
                                    ))
                                : const SizedBox(height: 40),
                          ),
                        ],
                      ),
                      const Divider(height: 1),
                    ],
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'breakfast':
        return const Color(0xFFFFF9C4); // Warna kuning untuk breakfast
      case 'lunch':
        return const Color(0xFFFFE0B2); // Warna oranye untuk lunch
      case 'dinner':
        return const Color(0xFFE1BEE7); // Warna ungu untuk dinner
      case 'snack':
        return const Color(0xFFBBDEFB); // Warna biru untuk snack
      default:
        return const Color(0xFFE8F5E9); // Warna hijau untuk lainnya
    }
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
