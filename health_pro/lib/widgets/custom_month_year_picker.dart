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
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
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
  late DateTime _selectedDate;
  late int _selectedYearIndex;
  late int _selectedMonthIndex;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _selectedDate = widget.initialDate;

    // Calculate initial indices
    _selectedYearIndex = _selectedDate.year - widget.createdAt.year;
    _selectedMonthIndex =
        _getMonthIndex(_selectedDate.year, _selectedDate.month);

    // Initialize controllers with calculated indices
    _monthController =
        FixedExtentScrollController(initialItem: _selectedMonthIndex);
    _yearController =
        FixedExtentScrollController(initialItem: _selectedYearIndex);
  }

  int _getMonthIndex(int year, int month) {
    final startMonth = _getStartMonth(year);
    return month - startMonth;
  }

  @override
  void dispose() {
    _monthController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  int _getStartMonth(int year) {
    if (year == widget.createdAt.year) {
      return widget.createdAt.month;
    }
    return 1;
  }

  int _getEndMonth(int year) {
    final now = DateTime.now();
    if (year == now.year) {
      return now.month;
    }
    return 12;
  }

  List<int> _getAvailableYears() {
    final now = DateTime.now();
    final years = <int>[];
    for (int year = widget.createdAt.year; year <= now.year; year++) {
      years.add(year);
    }
    return years;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
          Text(
            DateFormat('MMMM yyyy').format(_selectedDate),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextButton(
            onPressed: () {
              widget.onDateSelected(_selectedDate);
              Navigator.pop(context);
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  Widget _buildYearPicker() {
    final years = _getAvailableYears();
    return CupertinoPicker(
      itemExtent: 40,
      scrollController: _yearController,
      onSelectedItemChanged: (index) {
        final selectedYear = years[index];
        final startMonth = _getStartMonth(selectedYear);
        final endMonth = _getEndMonth(selectedYear);

        setState(() {
          // Adjust month if needed
          if (_selectedDate.month < startMonth) {
            _selectedDate = DateTime(selectedYear, startMonth);
            _monthController.jumpToItem(0);
          } else if (_selectedDate.month > endMonth) {
            _selectedDate = DateTime(selectedYear, endMonth);
            _monthController.jumpToItem(endMonth - startMonth);
          } else {
            _selectedDate = DateTime(selectedYear, _selectedDate.month);
          }
        });
      },
      children: years.map((year) {
        return Center(
          child: Text(
            year.toString(),
            style: const TextStyle(fontSize: 16),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMonthPicker() {
    final startMonth = _getStartMonth(_selectedDate.year);
    final endMonth = _getEndMonth(_selectedDate.year);

    return CupertinoPicker(
      itemExtent: 40,
      scrollController: _monthController,
      onSelectedItemChanged: (index) {
        setState(() {
          _selectedDate = DateTime(
            _selectedDate.year,
            startMonth + index,
          );
        });
      },
      children: List.generate(
        endMonth - startMonth + 1,
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
