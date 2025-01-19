import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_pro/blocs/auth/auth_bloc.dart';
import 'package:health_pro/blocs/auth/auth_event.dart';

class GenderSelectionScreen extends StatefulWidget {
  const GenderSelectionScreen({super.key});

  @override
  State<GenderSelectionScreen> createState() => _GenderSelectionScreenState();
}

class _GenderSelectionScreenState extends State<GenderSelectionScreen> {
  String selectedGender = 'Male'; // Default selected gender

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
                'What is your gender?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'We use your gender to create personalized nutrition\ngoals that match your body type.',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              _GenderOption(
                icon: '👨',
                label: 'Male',
                isSelected: selectedGender == 'Male',
                onTap: () => setState(() => selectedGender = 'Male'),
              ),
              const SizedBox(height: 12),
              _GenderOption(
                icon: '👩',
                label: 'Female',
                isSelected: selectedGender == 'Female',
                onTap: () => setState(() => selectedGender = 'Female'),
              ),
              const SizedBox(height: 12),
              _GenderOption(
                icon: '😊',
                label: 'Prefer not to say',
                isSelected: selectedGender == 'Prefer not to say',
                onTap: () =>
                    setState(() => selectedGender = 'Prefer not to say'),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final authBloc = BlocProvider.of<AuthBloc>(context);
                    authBloc.add(UpdateGender(gender: selectedGender));

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Gender saved as $selectedGender')),
                    );

                    // Navigasi ke halaman berikutnya
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      Navigator.pushReplacementNamed(context, '/home');
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
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

class _GenderOption extends StatelessWidget {
  final String icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenderOption({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8F5E9) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.green.shade200 : Colors.grey.shade200,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Text(
              icon,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
