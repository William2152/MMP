import 'package:flutter/material.dart';

class NutritionCounterScreen extends StatefulWidget {
  const NutritionCounterScreen({Key? key}) : super(key: key);

  @override
  _NutritionCounterScreenState createState() => _NutritionCounterScreenState();
}

class _NutritionCounterScreenState extends State<NutritionCounterScreen> {
  String _pizzaServingSize = '100';
  String _mashedPotatoServingSize = '100';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                'Daily Nutrition',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF98D8AA)),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'I eat pizza',
                    border: InputBorder.none,
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 15),
                  ),
                ),
              ),
            ),

            // Scrollable Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Search Result Card
                  if (true) // Replace with actual search state
                    NutritionCard(
                      title: 'Pizza',
                      servingSize: _pizzaServingSize,
                      nutritionFacts: const {
                        'Calories': '262.9',
                        'Total Fat': '9.8g',
                        'Sugar': '3.6g',
                        'Protein': '11.4g',
                        'Cholesterol': '16mg',
                        'Sodium': '587mg',
                        'Carbs': '32.9g',
                        'Fiber': '2.3g',
                      },
                      showAddButton: true,
                      onServingSizeChanged: (value) {
                        setState(() {
                          _pizzaServingSize = value;
                        });
                      },
                    ),

                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 20),

                  // Summary Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F4E9),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Summary',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildSummaryRow('Calories', '802.3', '2500'),
                        _buildSummaryRow('Total Fat', '18g', '67g'),
                        _buildSummaryRow('Sugar', '52.2g', '50g',
                            isOverLimit: true),
                        _buildSummaryRow('Protein', '102.1g', '72g'),
                        _buildSummaryRow('Cholesterol', '206mg', '300mg'),
                        _buildSummaryRow('Sodium', '3000mg', '2300mg',
                            isOverLimit: true),
                        _buildSummaryRow('Carbs', '400g', '325g'),
                        _buildSummaryRow('Fiber', '2.3g', '30g'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Added Foods List
                  NutritionCard(
                    title: 'Mashed potato',
                    servingSize: _mashedPotatoServingSize,
                    nutritionFacts: const {
                      'Calories': '113',
                      'Total Fat': '4.2g',
                      'Sugar': '1.4g',
                      'Protein': '2g',
                      'Cholesterol': '1mg',
                      'Sodium': '337mg',
                      'Carbs': '17g',
                      'Fiber': '1.5g',
                    },
                    showRemoveButton: true,
                    onServingSizeChanged: (value) {
                      setState(() {
                        _mashedPotatoServingSize = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, String limit,
      {bool isOverLimit = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: isOverLimit ? Colors.red : Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            ' / $limit',
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class NutritionCard extends StatelessWidget {
  final String title;
  final String servingSize;
  final Map<String, String> nutritionFacts;
  final bool showAddButton;
  final bool showRemoveButton;
  final Function(String)? onServingSizeChanged;

  const NutritionCard({
    Key? key,
    required this.title,
    required this.servingSize,
    required this.nutritionFacts,
    this.showAddButton = false,
    this.showRemoveButton = false,
    this.onServingSizeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF98D8AA),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 40,
                      child: TextField(
                        controller: TextEditingController(text: servingSize),
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onChanged: onServingSizeChanged,
                      ),
                    ),
                    const Text(' g'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: nutritionFacts.entries.take(4).map((entry) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          '${entry.key}: ${entry.value}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: nutritionFacts.entries.skip(4).map((entry) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          '${entry.key}: ${entry.value}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          if (showAddButton || showRemoveButton)
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        showAddButton ? const Color(0xFF2D5A27) : Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                      showAddButton ? 'Add to daily consumption' : 'Remove'),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
