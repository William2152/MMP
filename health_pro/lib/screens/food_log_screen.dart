import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
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
          Expanded(
            child: _buildTimelineView(),
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
          // Reset dates list untuk kalendar harian
          dates = List.generate(
            7,
            (index) => date.subtract(Duration(days: 3 - index)),
          );
        });
      },
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

  Widget _buildCaloriesRemaining(int totalFoodCalories) {
    const int goalCalories = 2000; // Ganti sesuai kebutuhan
    const int exerciseCalories = 0; // Tambahkan jika ada data olahraga
    final int remainingCalories =
        goalCalories - totalFoodCalories + exerciseCalories;

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
              const Text('+', style: TextStyle(fontSize: 20)),
              _buildCalorieBox('$exerciseCalories', 'Exercise'),
              const Text('=', style: TextStyle(fontSize: 20)),
              _buildCalorieBox('$remainingCalories', 'Remaining'),
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
    final userId =
        (BlocProvider.of<AuthBloc>(context).state as AuthSuccess).user.id;

    // Hitung awal dan akhir hari dari tanggal yang dipilih
    final startOfDay =
        DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    final endOfDay = DateTime(
        selectedDate.year, selectedDate.month, selectedDate.day, 23, 59, 59);

    const int goalCalories = 2000; // Target kalori statis (bisa disesuaikan)
    int foodCalories = 0; // Total kalori makanan
    int exerciseCalories = 0; // Kalori yang dibakar dari latihan

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

        // Siapkan daftar per jam (kosong jika tidak ada data)
        final Map<int, List<_MealEntry>> hourlyMeals = Map.fromIterable(
          List.generate(24, (index) => index), // Jam 0 - 23
          key: (hour) => hour,
          value: (hour) => [],
        );

        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          final documents = snapshot.data!.docs;

          for (var doc in documents) {
            final data = doc.data() as Map<String, dynamic>;
            final foods = data['foods'] as List<dynamic>;
            final timestamp = (data['timestamp'] as Timestamp).toDate();

            // Ambil jam dari timestamp
            final hour = timestamp.hour;

            for (var food in foods) {
              final calories = (food['calories'] as num).toDouble();
              hourlyMeals[hour]?.add(_MealEntry(
                time: DateFormat('h:mm a').format(timestamp),
                title: data['category'], // Menggunakan kategori
                food: food['name'],
                calories: calories,
                color: _getCategoryColor(
                    data['category']), // Warna berdasarkan kategori
              ));
              foodCalories += calories.toInt(); // Tambahkan kalori makanan
            }
          }
        }

        // Hitung Calories Remaining
        final int caloriesRemaining =
            goalCalories - foodCalories + exerciseCalories;

        return Column(
          children: [
            // Bagian Perhitungan Kalori
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey[200],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildCalorieBox('$goalCalories', 'Goal'),
                  const Text('-', style: TextStyle(fontSize: 20)),
                  _buildCalorieBox('$foodCalories', 'Food'),
                  const Text('+', style: TextStyle(fontSize: 20)),
                  _buildCalorieBox('$exerciseCalories', 'Exercise'),
                  const Text('=', style: TextStyle(fontSize: 20)),
                  _buildCalorieBox('$caloriesRemaining', 'Remaining'),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: 24, // 24 jam
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
                                ? Column(
                                    children: meals.map((meal) {
                                      return Container(
                                        padding: const EdgeInsets.all(16),
                                        margin:
                                            const EdgeInsets.only(bottom: 8),
                                        decoration: BoxDecoration(
                                          color: meal
                                              .color, // Gunakan warna dari kategori
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
                                              '${meal.calories} cal',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  )
                                : const SizedBox(
                                    height:
                                        40), // Slot kosong jika tidak ada data
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            bottom: 8), // Menambahkan padding bottom 8
                        child: const Divider(
                          height: 1,
                        ),
                      ),
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
