import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _onboardingData = [
    {
      'title': 'Track Your Daily Steps',
      'description':
          'Stay active and healthy by monitoring your daily steps and activities',
      'image': 'assets/step_tracker.png'
    },
    {
      'title': 'Water Intake Reminder',
      'description':
          'Stay hydrated with timely water drinking reminders throughout your day',
      'image': 'assets/water_reminder.png'
    },
    {
      'title': 'Count Your Calories',
      'description':
          'Monitor your daily calorie intake and maintain a balanced diet',
      'image': 'assets/nutrition_tracker.png'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _onboardingData.length,
                itemBuilder: (context, index) => OnboardingPage(
                  title: _onboardingData[index]['title']!,
                  description: _onboardingData[index]['description']!,
                  image: _onboardingData[index]['image']!,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              height: 180,
              child: Column(
                children: [
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: _onboardingData.length,
                    effect: ExpandingDotsEffect(
                      activeDotColor: const Color(0xFF4CAF50),
                      dotColor: const Color(0xFFE0E0E0),
                      dotHeight: 8,
                      dotWidth: 8,
                      expansionFactor: 3,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 130,
                        height: 48,
                        child: OutlinedButton(
                          onPressed: () {
                            // Navigate to login screen
                            Navigator.pushReplacementNamed(context, '/login');
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF4CAF50)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              color: Color(0xFF4CAF50),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 35),
                      SizedBox(
                        width: 130,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            // Navigate to register screen
                            Navigator.pushReplacementNamed(
                                context, '/register');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Register',
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
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final String title;
  final String description;
  final String image;

  const OnboardingPage({
    Key? key,
    required this.title,
    required this.description,
    required this.image,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 300,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Image.asset(
              image,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 40),
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            description,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF757575),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
