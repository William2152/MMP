import 'dart:convert';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_pro/blocs/food/bloc/food_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class VisionScreen extends StatefulWidget {
  const VisionScreen({super.key});

  @override
  State<VisionScreen> createState() => _VisionScreenState();
}

class _VisionScreenState extends State<VisionScreen>
    with SingleTickerProviderStateMixin {
  List<CameraDescription> camera1 = [];
  CameraController? cameraController;
  late AnimationController _scanAnimationController;
  bool isScanning = false;
  final PanelController _panelController = PanelController();
  Map<String, dynamic>? scanResults;
  List<String> selectedFoods = [];
  Map<String, String> foodCategories = {};
  String? selectedCategory;

  @override
  void initState() {
    super.initState();
    _requestCameraPermission();
    _scanAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _scanAnimationController.dispose();
    cameraController?.dispose();
    super.dispose();
  }

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
      // Inisialisasi kamera
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    List<CameraDescription> camera2 = await availableCameras();
    if (camera2.isNotEmpty) {
      setState(() {
        camera1 = camera2;
        cameraController = CameraController(
          camera2.first,
          ResolutionPreset.high,
          enableAudio: false,
        );
      });

      await cameraController!.initialize().then((_) {
        if (!mounted) return;
        setState(() {});
      });
    }
  }

  Widget _buildCameraPreview() {
    if (cameraController == null || !cameraController!.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF4CAF50),
        ),
      );
    }

    return Stack(
      children: [
        // Camera Preview with correct aspect ratio
        Center(
          child: Container(
            width: double.infinity,
            height: double.infinity,
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: cameraController!.value.previewSize!.height,
                height: cameraController!.value.previewSize!.width,
                child: Stack(
                  children: [
                    Center(
                      child: CameraPreview(cameraController!),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Grid Overlay
        Positioned.fill(
          child: CustomPaint(
            painter: GridPainter(),
          ),
        ),
        // Scanning Animation
        if (isScanning)
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _scanAnimationController,
              builder: (context, child) {
                return CustomPaint(
                  painter: ScanningLinePainter(
                    progress: _scanAnimationController.value,
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SlidingUpPanel(
        controller: _panelController,
        minHeight: 100,
        maxHeight: MediaQuery.of(context).size.height * 0.7,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        panel: _buildResultsPanel(),
        body: _buildCameraPreview(),
      ),
      floatingActionButton: (scanResults == null)
          ? FloatingActionButton(
              onPressed: !isScanning ? _scanImage : null,
              backgroundColor: const Color(0xFF4CAF50),
              child: Icon(
                isScanning ? Icons.hourglass_bottom : Icons.camera,
                color: Colors.white,
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildResultsPanel() {
    return BlocProvider(
      create: (context) => FoodBloc(FirebaseFirestore.instance),
      child: BlocConsumer<FoodBloc, FoodState>(
        listener: (context, state) {
          if (state is FoodSavedState) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Foods saved successfully!')),
            );
            Navigator.pop(context);
          } else if (state is FoodSaveErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${state.message}')),
            );
          }
        },
        builder: (context, state) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Pilihan kategori global hanya muncul jika hasil scan ada
                if (scanResults != null) ...[
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Select a category for all selected foods:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // Dropdown untuk kategori
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: DropdownButtonFormField<String>(
                      value: selectedCategory,
                      items: ['Breakfast', 'Lunch', 'Dinner', 'Snack']
                          .map((category) => DropdownMenuItem<String>(
                                value: category,
                                child: Text(category),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCategory = value;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],

                Expanded(
                  child: scanResults == null
                      ? const Center(
                          child: Text(
                            'Take a photo to scan food',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : Column(
                          children: [
                            Expanded(child: _buildScanResults()),

                            // Tombol Save hanya aktif jika kategori telah dipilih
                            if (selectedFoods.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: ElevatedButton(
                                  onPressed: selectedCategory == null
                                      ? null
                                      : () {
                                          final user =
                                              FirebaseAuth.instance.currentUser;
                                          if (user != null) {
                                            final List<Map<String, dynamic>>
                                                foodsToSave =
                                                selectedFoods.map((foodName) {
                                              final foodDetails =
                                                  scanResults?['detected_foods']
                                                      .firstWhere((food) =>
                                                          food['name'] ==
                                                          foodName);
                                              return {
                                                'name': foodDetails['name'],
                                                'calories':
                                                    foodDetails['calories'],
                                              };
                                            }).toList();

                                            // Tambahkan kategori global dan timestamp
                                            context.read<FoodBloc>().add(
                                                  SaveSelectedFoodsEvent(
                                                    foodsToSave,
                                                    selectedCategory!, // Kategori global
                                                  ),
                                                );
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                  content: Text(
                                                      'Please login to save your selection.')),
                                            );
                                          }
                                        },
                                  child: state is FoodSavingState
                                      ? const CircularProgressIndicator(
                                          color: Colors.white,
                                        )
                                      : const Text('Save Selected Foods'),
                                ),
                              ),
                          ],
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildScanResults() {
    if (scanResults?['status'] != 'success') {
      return const Center(
        child: Text(
          'No food detected',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: scanResults?['detected_foods'].length ?? 0,
      itemBuilder: (context, index) {
        final food = scanResults!['detected_foods'][index];
        final foodName = food['name'];

        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Checkbox(
              value: selectedFoods.contains(foodName),
              onChanged: (isSelected) {
                setState(() {
                  if (isSelected == true) {
                    selectedFoods.add(foodName);
                  } else {
                    selectedFoods.remove(foodName);
                  }
                });
              },
            ),
            title: Text(
              foodName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Text(
              '${food['calories']} kcal',
              style: TextStyle(color: Colors.grey[600]),
            ),
            trailing: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: food['confidence'] / 100,
                  backgroundColor: Colors.grey[200],
                  color: const Color(0xFF4CAF50),
                ),
                Text(
                  '${food['confidence']}%',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _scanImage() async {
    setState(() {
      isScanning = true;
      scanResults = null;
    });

    try {
      XFile image = await cameraController!.takePicture();
      Uint8List imageData = await image.readAsBytes();

      final generationConfig = GenerationConfig(
        responseMimeType: 'application/json',
        temperature: 0,
      );

      final model = FirebaseVertexAI.instance.generativeModel(
        model: 'gemini-1.5-flash',
        generationConfig: generationConfig,
      );

      final prompt = [
        Content.multi([
          InlineDataPart('image/jpeg', imageData),
          TextPart(
            'You are an AI food recognition model. Analyze the provided image of food and return a JSON response that includes the following information: 1) status (string): Indicate the status of the operation as "success" if food is detected or "error" if no food is detected. 2) detected_foods (array): A list of detected foods. For each detected food, include: 2.1) name (string): The name of the detected food, e.g., "Nasi Goreng" 2.2) confidence (integer): AI confidence score in percentage (0–100). 2.3)calories (decimal 2): The estimated calories of the food in kcal, rounded to two decimal places. Instructions: Use high-quality food recognition algorithms to identify the food in the image. Ensure the confidence score and calorie estimates are accurate and precise. If the image contains no recognizable food, return a status of "error" and an empty detected_foods array.',
          ),
        ]),
      ];

      final response = await model.generateContent(prompt);
      setState(() {
        scanResults = jsonDecode(response.text!);
        isScanning = false;
      });

      _panelController.open();
    } catch (e) {
      setState(() {
        isScanning = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 1;

    // Draw vertical lines
    for (int i = 1; i < 3; i++) {
      final x = size.width * (i / 3);
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Draw horizontal lines
    for (int i = 1; i < 3; i++) {
      final y = size.height * (i / 3);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ScanningLinePainter extends CustomPainter {
  final double progress;

  ScanningLinePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF4CAF50).withOpacity(0),
          const Color(0xFF4CAF50).withOpacity(0.5),
          const Color(0xFF4CAF50).withOpacity(0),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, 20));

    final y = size.height * progress;
    canvas.drawRect(
      Rect.fromLTWH(0, y - 10, size.width, 20),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
