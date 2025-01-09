import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class CustomMonthYearPicker extends StatefulWidget {
  final DateTime initialDate;
  final DateTime createdAt;
  final Function(DateTime) onDateSelected;

  const CustomMonthYearPicker({
    Key? key,
    required this.initialDate,
    required this.createdAt,
    required this.onDateSelected,
  }) : super(key: key);

  static Future<void> show(
    BuildContext context, {
    required DateTime initialDate,
    required DateTime createdAt,
    required Function(DateTime) onDateSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return CustomMonthYearPicker(
          initialDate: initialDate,
          createdAt: createdAt,
          onDateSelected: onDateSelected,
        );
      },
    );
  }

  @override
  State<CustomMonthYearPicker> createState() => _CustomMonthYearPickerState();
}

class _CustomMonthYearPickerState extends State<CustomMonthYearPicker> {
  late FixedExtentScrollController _monthController;
  late FixedExtentScrollController _yearController;
  late int _currentSelectedYear;
  late int _currentSelectedMonth;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    // Set initial values
    _currentSelectedYear = widget.initialDate.year;
    _currentSelectedMonth = widget.initialDate.month;

    // Calculate initial indices for controllers
    int initialMonthIndex = widget.initialDate.month - 1;
    int initialYearIndex = widget.initialDate.year - widget.createdAt.year;

    // Initialize controllers
    _monthController =
        FixedExtentScrollController(initialItem: initialMonthIndex);
    _yearController =
        FixedExtentScrollController(initialItem: initialYearIndex);
  }

  @override
  void dispose() {
    _monthController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  int _getStartMonth(int selectedYear) {
    // For the account creation year, start from creation month
    if (selectedYear == widget.createdAt.year) {
      return widget.createdAt.month;
    }
    // For other years, start from January
    return 1;
  }

  int _getAvailableMonths(int selectedYear) {
    final now = DateTime.now();
    // For the current year, only show up to current month
    if (selectedYear == now.year) {
      return now.month;
    }
    // For other years, show all months
    return 12;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      color: Colors.white,
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Row(
              children: [
                Expanded(child: _buildYearPicker()),
                Expanded(child: _buildMonthPicker()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
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
              widget.onDateSelected(
                DateTime(_currentSelectedYear, _currentSelectedMonth, 1),
              );
              Navigator.pop(context);
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  Widget _buildYearPicker() {
    final now = DateTime.now();
    return CupertinoPicker(
      itemExtent: 40,
      scrollController: _yearController,
      onSelectedItemChanged: (index) {
        setState(() {
          _currentSelectedYear = widget.createdAt.year + index;

          // Adjust month if needed
          final startMonth = _getStartMonth(_currentSelectedYear);
          final availableMonths = _getAvailableMonths(_currentSelectedYear);

          if (_currentSelectedMonth < startMonth) {
            _currentSelectedMonth = startMonth;
            _monthController.jumpToItem(startMonth - 1);
          } else if (_currentSelectedMonth > availableMonths) {
            _currentSelectedMonth = availableMonths;
            _monthController.jumpToItem(availableMonths - 1);
          }
        });
      },
      children: List.generate(
        now.year - widget.createdAt.year + 1,
        (index) {
          return Center(
            child: Text(
              '${widget.createdAt.year + index}',
              style: const TextStyle(fontSize: 16),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMonthPicker() {
    final startMonth = _getStartMonth(_currentSelectedYear);
    final availableMonths = _getAvailableMonths(_currentSelectedYear);

    return CupertinoPicker(
      itemExtent: 40,
      scrollController: _monthController,
      onSelectedItemChanged: (index) {
        setState(() {
          _currentSelectedMonth = startMonth + index;
        });
      },
      children: List.generate(
        availableMonths - startMonth + 1,
        (index) {
          final month = startMonth + index;
          return Center(
            child: Text(
              DateFormat('MMMM').format(DateTime(2024, month)),
              style: const TextStyle(fontSize: 16),
            ),
          );
        },
      ),
    );
  }
}
