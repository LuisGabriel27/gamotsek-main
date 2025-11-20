import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'login_page.dart';
import 'database_helper.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'create_schedule.dart';
import 'display_schedule.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  String _recognizedText = '';
  File? _image;
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  List<CameraDescription>? _cameras;

  Map<String, dynamic>? _scannedMedicine;
  String _selectedLanguage = 'English';
  final FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    if (_cameras!.isNotEmpty) {
      _cameraController =
          CameraController(_cameras!.first, ResolutionPreset.medium);
      await _cameraController!.initialize();
      setState(() => _isCameraInitialized = true);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _recognizedText = 'Processing... please wait';
      });

      await _runTextRecognition(pickedFile.path);
    }
  }

  Future<void> _scanCurrentFrame() async {
    if (!_isCameraInitialized || _cameraController == null) return;

    try {
      final XFile picture = await _cameraController!.takePicture();
      setState(() {
        _image = File(picture.path);
        _recognizedText = 'Scanning current frame...';
      });

      await _runTextRecognition(picture.path);
    } catch (e) {
      setState(() {
        _recognizedText = 'Error scanning frame: $e';
      });
    }
  }

  Future<void> _runTextRecognition(String path) async {
    final inputImage = InputImage.fromFilePath(path);
    final textRecognizer = TextRecognizer();
    final recognizedTextResult = await textRecognizer.processImage(inputImage);

    String scannedText = recognizedTextResult.text.trim();

    textRecognizer.close();

    if (scannedText.isEmpty) {
      setState(() {
        _recognizedText = 'No text found';
        _scannedMedicine = null;
      });
      return;
    }

    List<String> words = scannedText
        .split(RegExp(r'[\s\n,.:;]+'))
        .map((word) => word.trim())
        .where((w) => w.isNotEmpty)
        .toList();

    List<String> nameCandidates =
        words.where((w) => RegExp(r'^[A-Za-z]+$').hasMatch(w)).toList();

    if (nameCandidates.isEmpty) {
      setState(() {
        _recognizedText = 'No valid medicine name detected.';
        _scannedMedicine = null;
      });
      return;
    }

    Map<String, dynamic>? foundMedicine;
    for (String name in nameCandidates) {
      final medicine =
          await DatabaseHelper.instance.getMedicineByName(name.toLowerCase());
      if (medicine != null) {
        foundMedicine = medicine;
        break;
      }
    }

    setState(() {
      if (foundMedicine != null) {
        _scannedMedicine = foundMedicine;
        _recognizedText = '';
      } else {
        _scannedMedicine = null;
        _recognizedText =
            'No medicine found for detected text: ${nameCandidates.join(", ")}';
      }
    });
  }

  Future<void> _speakDetails() async {
    if (_scannedMedicine == null) return;

    String details = '';

    if (_selectedLanguage == 'English') {
      details = """
        Name: ${_scannedMedicine!['name']}.
        Dosage: ${_scannedMedicine!['dosage']}.
        Usage: ${_scannedMedicine!['usage']}.
        Side effects: ${_scannedMedicine!['sideEffects']}.
        Precautions: ${_scannedMedicine!['precautions']}.
      """;
    } else {
      details = """
        Pangalan: ${_scannedMedicine!['name_tagalog']}.
        Dosis: ${_scannedMedicine!['dosage_tagalog']}.
        Paggamit: ${_scannedMedicine!['usage_tagalog']}.
        Side effects: ${_scannedMedicine!['sideEffects_tagalog']}.
        Pag-iingat: ${_scannedMedicine!['precautions_tagalog']}.
      """;
    }

    await flutterTts.setLanguage(
      _selectedLanguage == 'English' ? "en-US" : "tl-PH",
    );

    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setPitch(1.0);

    await flutterTts.speak(details);
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    flutterTts.stop();
    super.dispose();
  }

  Widget _circleButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 70,
        width: 70,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFFE53935),
        ),
        child: Icon(icon, color: Colors.white, size: 32),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gamotsek'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.schedule),
            tooltip: 'View Schedule',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DisplaySchedulePage()),
              );
            },
          ),
        ],
        backgroundColor: const Color(0xFFE53935),
        foregroundColor: Colors.white,
      ),

      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    if (_isCameraInitialized)
                      SizedBox(
                        height: 300,
                        width: double.infinity,
                        child: CameraPreview(_cameraController!),
                      ),

                    const SizedBox(height: 16),

                    if (_image != null)
                      Image.file(_image!, height: 200, fit: BoxFit.cover),

                    const SizedBox(height: 16),

                    if (_scannedMedicine != null) ...[
                      DropdownButton<String>(
                        value: _selectedLanguage,
                        items: ['English', 'Tagalog']
                            .map((lang) => DropdownMenuItem(
                                  value: lang,
                                  child: Text(lang),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedLanguage = value!;
                          });
                        },
                      ),

                      const SizedBox(height: 16),

                      /// ✅ RESTORED MEDICINE DISPLAY
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: RichText(
                          textAlign: TextAlign.justify,
                          text: TextSpan(
                            style: const TextStyle(
                                fontSize: 16, color: Colors.black, height: 1.5),
                            children: [
                              const TextSpan(
                                  text: 'Name: ',
                                  style: TextStyle(fontWeight: FontWeight.bold)),
                              TextSpan(
                                text: _selectedLanguage == 'English'
                                    ? _scannedMedicine!['name']
                                    : _scannedMedicine!['name_tagalog'],
                              ),
                              const TextSpan(text: '\n\n'),

                              const TextSpan(
                                  text: 'Dosage: ',
                                  style: TextStyle(fontWeight: FontWeight.bold)),
                              TextSpan(
                                text: _selectedLanguage == 'English'
                                    ? _scannedMedicine!['dosage']
                                    : _scannedMedicine!['dosage_tagalog'],
                              ),
                              const TextSpan(text: '\n\n'),

                              const TextSpan(
                                  text: 'Usage: ',
                                  style: TextStyle(fontWeight: FontWeight.bold)),
                              TextSpan(
                                text: _selectedLanguage == 'English'
                                    ? _scannedMedicine!['usage']
                                    : _scannedMedicine!['usage_tagalog'],
                              ),
                              const TextSpan(text: '\n\n'),

                              const TextSpan(
                                  text: 'Side Effects: ',
                                  style: TextStyle(fontWeight: FontWeight.bold)),
                              TextSpan(
                                text: _selectedLanguage == 'English'
                                    ? _scannedMedicine!['sideEffects']
                                    : _scannedMedicine!['sideEffects_tagalog'],
                              ),
                              const TextSpan(text: '\n\n'),

                              const TextSpan(
                                  text: 'Precautions: ',
                                  style: TextStyle(fontWeight: FontWeight.bold)),
                              TextSpan(
                                text: _selectedLanguage == 'English'
                                    ? _scannedMedicine!['precautions']
                                    : _scannedMedicine!['precautions_tagalog'],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      ElevatedButton.icon(
                        onPressed: _speakDetails,
                        icon: const Icon(Icons.volume_up),
                        label: const Text("Speak Details"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E88E5),
                        ),
                      ),
                    ] else ...[
                      Text(_recognizedText),
                    ],
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _circleButton(
                    icon: Icons.photo,
                    onTap: _pickImage,
                  ),

                  _circleButton(
                    icon: Icons.camera_alt,
                    onTap: _scanCurrentFrame,
                  ),

                  _circleButton(
                    icon: Icons.schedule,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreateSchedulePage(),
                        ),
                      );
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
}
