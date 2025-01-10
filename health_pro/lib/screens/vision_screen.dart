import 'dart:convert';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:flutter/material.dart';

class VisionScreen extends StatefulWidget {
  const VisionScreen({super.key});

  @override
  State<VisionScreen> createState() => _VisionScreenState();
}

class _VisionScreenState extends State<VisionScreen> {
  List<CameraDescription> camera1 = [];
  CameraController? cameraController;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    List<CameraDescription> camera2 = await availableCameras();
    if (camera2.isNotEmpty) {
      setState(() {
        camera1 = camera2;
        cameraController =
            CameraController(camera2.first, ResolutionPreset.high);
      });

      await cameraController!.initialize().then((_) {
        setState(() {});
      });
    }
  }

  _cameraPreview() {
    if (cameraController == null ||
        cameraController?.value.isInitialized == false) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return Center(child: CameraPreview(cameraController!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Today',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _cameraPreview(),
              ElevatedButton(
                  onPressed: () {
                    _scanImage();
                  },
                  child: Text("foto"))
            ],
          ),
        ),
      ),
    );
    ;
  }

  void _scanImage() async {
    XFile image = await cameraController!.takePicture();
    Uint8List image_data = await image.readAsBytes();
    final generatinConfig =
        GenerationConfig(responseMimeType: 'application/json', temperature: 0);
    final model = FirebaseVertexAI.instance.generativeModel(
        model: 'gemini-1.5-flash', generationConfig: generatinConfig);
    final prompt = [
      Content.multi([
        InlineDataPart('image/jpeg', image_data),
        // TextPart(
        //     'hitung kalori dari gambar makanan yang difoto, kembalikan dalam json dengan properti (totalCalories) dan (foodWeight) dalam gram. jika tidak dapat mendeteksi makanan, maka isi kedua properti tersebut dengan teks (tidak terdeteksi). jenis makanan dapat beramacam macam real food (soto, bakso, rawon, pizza, dll), processed food (nugget, sosis, dll), makanan kemasan (mie instant, coklat kemasan, dll), makanan mentah (daging sapi, daging ayam, ikan, dll), bahan makanan (seperti tepung, gula, garam, dll). estimasikan berat dari makanan berdasarkan ukuran pada gambar dan sudut pengambilan kamera')
        TextPart(
            'gambar yang diberikan akan selalu berupa makanan, kembalikan dalam json dengan properti (foodName, calories), jika tidak terdeteksi sebagai makanan apapun maka semua properti diisi dengan "tidak terdeteksi". Makanan dapat berupa apapun (makanan siap saji, makanan ringan, makanan berat, makanan penutup, dan semua jenis makanan yang dapat ditemukan di internet). Cari informasi jumlah kcal per 100g berdasarkan nama makanan yang terdeteksi')
      ])
    ];
    final response = await model.generateContent(prompt);
    final result = jsonDecode(response.text!);
    // print('result:$result');
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: Text('Hasil'),
              content: Column(children: [
                Text("name:" + result['foodName']),
                Text("calories:" + result['calories'] + "kcal/100g")
              ]));
        });
  }
}
