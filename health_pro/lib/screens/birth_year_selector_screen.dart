import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';

class BirthYearSelectorScreen extends StatefulWidget {
  const BirthYearSelectorScreen({Key? key}) : super(key: key);

  @override
  _BirthYearSelectorScreenState createState() =>
      _BirthYearSelectorScreenState();
}

class _BirthYearSelectorScreenState extends State<BirthYearSelectorScreen> {
  int? selectedYear;
  final List<int> years = List.generate(
    DateTime.now().year - 1950 + 1,
    (index) => 1950 + index,
  ).reversed.toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select your birth year',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Share your birth year to better tailor\nyour nutrition goals.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.builder(
                  itemCount: years.length,
                  itemBuilder: (context, index) {
                    final year = years[index];
                    final isSelected = selectedYear == year;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedYear = year;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 20,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(
                                  0xFFE8F5E9) // Light green background
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          year.toString(),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: isSelected ? Colors.black : Colors.grey,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: selectedYear == null
                      ? null
                      : () {
                          final currentYear = DateTime.now().year;
                          final age = currentYear - selectedYear!;
                          final authBloc = BlocProvider.of<AuthBloc>(context);

                          // Kirim event untuk menyimpan usia
                          authBloc.add(UpdateAge(age: age));

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Age ($age years) has been saved successfully!'),
                            ),
                          );

                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            Navigator.pushReplacementNamed(context, '/gender');
                          });
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    disabledBackgroundColor: Colors.grey,
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
