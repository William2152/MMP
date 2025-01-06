import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GettingStartedScreen extends StatefulWidget {
  @override
  _GettingStartedScreenState createState() => _GettingStartedScreenState();
}

class _GettingStartedScreenState extends State<GettingStartedScreen> {
  int _currentStep = 0;
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _ageController = TextEditingController();

  final List<String> _questions = [
    'What is your weight?',
    'What is your height?',
    'What is your age?',
  ];

  final List<String> _units = ['kg', 'cm', 'years'];

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
    } else {
      // TODO: Handle submission of data
      print('Weight: ${_weightController.text}');
      print('Height: ${_heightController.text}');
      print('Age: ${_ageController.text}');
      // Navigate to the next screen or process the data
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text('Getting Started'),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _questions[_currentStep],
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40),
              TextField(
                controller: _currentStep == 0
                    ? _weightController
                    : _currentStep == 1
                        ? _heightController
                        : _ageController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  hintText:
                      'Enter your ${_questions[_currentStep].split(' ').last.toLowerCase()}',
                  suffixText: _units[_currentStep],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.green),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.green, width: 2),
                  ),
                ),
              ),
              Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentStep > 0)
                    ElevatedButton(
                      onPressed: _previousStep,
                      child: Text('Previous'),
                      style: ElevatedButton.styleFrom(
                        // primary: Colors.white,
                        // onPrimary: Colors.green,
                        side: BorderSide(color: Colors.green),
                        padding:
                            EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      ),
                    ),
                  ElevatedButton(
                    onPressed: _nextStep,
                    child: Text(_currentStep < 2 ? 'Next' : 'Finish'),
                    style: ElevatedButton.styleFrom(
                      // primary: Colors.green,
                      // onPrimary: Colors.white,
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _ageController.dispose();
    super.dispose();
  }
}
