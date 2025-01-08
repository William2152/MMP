import 'package:flutter/material.dart';

class WaterVolumeSelection extends StatelessWidget {
  final int selectedVolumeIndex;
  final int customVolume;
  final Function(int) onVolumeSelected;

  const WaterVolumeSelection({
    Key? key,
    required this.selectedVolumeIndex,
    required this.customVolume,
    required this.onVolumeSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> volumeOptions = [
      {'volume': 250, 'icon': Icons.water_drop, 'label': 'Water'},
      {'volume': 500, 'icon': Icons.local_drink, 'label': 'Bottle'},
      {'volume': 180, 'icon': Icons.coffee, 'label': 'Cup'},
      {'volume': customVolume, 'icon': Icons.blender, 'label': 'Custom'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Water Volume',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: volumeOptions.length,
            itemBuilder: (context, index) =>
                _buildVolumeCard(context, index, volumeOptions[index]),
          ),
        ],
      ),
    );
  }

  Widget _buildVolumeCard(
      BuildContext context, int index, Map<String, dynamic> option) {
    final isSelected = selectedVolumeIndex == index;

    return GestureDetector(
      onTap: () => onVolumeSelected(index),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.green : Colors.grey.shade200,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    option['icon'],
                    color: Colors.blue,
                    size: 24,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${option['volume']} ml',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    option['label'],
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
