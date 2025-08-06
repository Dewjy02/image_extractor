import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_text_reader/services/store_text_in_firestore.dart';
import 'package:image_text_reader/widgets/image_preview.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //setup the image picker
  late ImagePicker imagePicker;
  late TextRecognizer textRecognizer;
  String? pickedImagePath;
  String recognizedText = "";
  bool isImagePicked = false;
  bool isProcessing = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    imagePicker = ImagePicker();
    textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  }

  // function to pick an Image
  void _pickImage({required ImageSource source}) async {
    final pickedImage = await imagePicker.pickImage(source: source);
    if (pickedImage == null) {
      return;
    }
    setState(() {
      pickedImagePath = pickedImage.path;
      isImagePicked = true;
    });
  }

  //show bottom sheet
  void _showBottomSheetWidget() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("Choose from Gallery"),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(source: ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("Take from Camera"),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(source: ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Function to process the picked image
  void _processImage() async {
    if (pickedImagePath == null) {
      return;
    }
    setState(() {
      isProcessing = true;
      recognizedText = "";
    });

    try {
      //convert my image into input image
      final inputImage = InputImage.fromFilePath(pickedImagePath!);
      final RecognizedText textReturnFromModel = await textRecognizer
          .processImage(inputImage);
      // Loop through the recognized text blocks and lines and concatenate them
      for (TextBlock block in textReturnFromModel.blocks) {
        for (TextLine line in block.lines) {
          recognizedText += "${line.text}\n";
        }
      }
      //store the converstion data in the firestore
      if (recognizedText.isNotEmpty) {
        try {
          await StoreTextInFirestore().storeConversionData(
            converstionData: recognizedText,
            converstionDate: DateTime.now(),
            imageFile: File(pickedImagePath!),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Text Recognized successfully")),
          );
        } catch (e) {
          print(e.toString());
        }
      }
    } catch (error) {
      print(error.toString());
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Error Recognizing Text")));
    } finally {
      setState(() {
        isProcessing = false;
      });
    }
  }

  //copy to clipboard
  void _copyToClipboard() async {
    if (recognizedText.isNotEmpty) {
      await Clipboard.setData(ClipboardData(text: recognizedText));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Text copied to clipboard!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "ML Text Recognition",
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: ImagePreview(imagePath: pickedImagePath),
              ),
              if (!isImagePicked)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: isProcessing ? null : _showBottomSheetWidget,
                      child: const Text(
                        "Pick an Image",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ],
                ),
              if (isImagePicked)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: isProcessing ? null : _processImage,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Process Image",
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                          if (isProcessing) ...[
                            const SizedBox(width: 20),
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Recognized text",
                      style: TextStyle(fontSize: 20),
                    ),
                    IconButton(
                      onPressed: _copyToClipboard,
                      icon: const Icon(Icons.copy),
                    ),
                  ],
                ),
              ),
              if (!isProcessing) ...[
                Expanded(
                  child: Scrollbar(
                    child: SingleChildScrollView(
                      child: Row(
                        children: [
                          Flexible(
                            child: SelectableText(
                              recognizedText.isEmpty
                                  ? "No Text Recognaized"
                                  : recognizedText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
