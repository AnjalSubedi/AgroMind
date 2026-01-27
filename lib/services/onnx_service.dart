import 'dart:io';
import 'package:flutter/services.dart'; // for rootBundle
import 'package:onnxruntime/onnxruntime.dart';
import 'package:image/image.dart' as img; // Rename to avoid conflict
import 'dart:typed_data';

class OnnxInferenceService {
  OrtSession? _session;

  /// Load the ONNX model from assets
  Future<void> loadModel() async {
    if (_session != null) return; // Already loaded

    try {
      // Initialize the OrtEnv (needs to be done once)
      OrtEnv.instance.init();

      // Load model data
      final rawAsset = await rootBundle.load(
        'assets/models/kisanai_rice_model.onnx',
      );
      final bytes = rawAsset.buffer.asUint8List();

      final sessionOptions = OrtSessionOptions();
      // sessionOptions.setInterOpNumThreads(1);
      // sessionOptions.setIntraOpNumThreads(1);
      // You can configure threads or execution providers here if needed

      _session = OrtSession.fromBuffer(bytes, sessionOptions);
    } catch (e) {
      print("Error loading ONNX model: $e");
      // Rethrow or handle gracefully
    }
  }

  /// Run inference on a file image
  /// Returns the index of the predicted class
  Future<int> runInference(File imageFile) async {
    if (_session == null) {
      await loadModel();
      if (_session == null) throw Exception("Model failed to load");
    }

    // 1. Load and Resize Image
    final bytes = await imageFile.readAsBytes();
    final decodedImage = img.decodeImage(bytes);
    if (decodedImage == null) throw Exception("Failed to decode image");

    // Resize to 224x224 (as per model metadata)
    final resizedImage = img.copyResize(decodedImage, width: 224, height: 224);

    // 2. Preprocess to Float32 Tensor [1, 3, 224, 224]
    // Normalization parameters from metadata/standard ImageNet
    // mean = [0.485, 0.456, 0.406]
    // std = [0.229, 0.224, 0.225]
    final mean = [0.485, 0.456, 0.406];
    final std = [0.229, 0.224, 0.225];

    final Float32List inputFloats = Float32List(1 * 3 * 224 * 224);

    // Pixel verification loop - convert to CHW format (Channel, Height, Width)
    for (var y = 0; y < 224; y++) {
      for (var x = 0; x < 224; x++) {
        final pixel = resizedImage.getPixel(x, y);
        // img package usually returns generic Pixel object or int (ARGB) depending on version
        // Assuming image ^4.x, pixel is a Pixel object.

        final r = pixel.r / 255.0;
        final g = pixel.g / 255.0;
        final b = pixel.b / 255.0;

        // Apply normalization
        final normR = (r - mean[0]) / std[0];
        final normG = (g - mean[1]) / std[1];
        final normB = (b - mean[2]) / std[2];

        // Assign to flat array for tensor
        // Layout: [Batch, Channel, Height, Width]
        // R channel
        inputFloats[0 * (3 * 224 * 224) + 0 * (224 * 224) + y * 224 + x] =
            normR;
        // G channel
        inputFloats[0 * (3 * 224 * 224) + 1 * (224 * 224) + y * 224 + x] =
            normG;
        // B channel
        inputFloats[0 * (3 * 224 * 224) + 2 * (224 * 224) + y * 224 + x] =
            normB;
      }
    }

    // 3. Create Input Tensor
    final inputOrt = OrtValueTensor.createTensorWithDataList(
      inputFloats,
      [1, 3, 224, 224], // Shape
    );

    // 4. Run Inference
    final runOptions = OrtRunOptions();
    final inputs = {
      'input': inputOrt,
    }; // Name 'input' is standard, check model if fails
    final outputs = _session!.run(runOptions, inputs);

    // 5. Cleanup inputs
    inputOrt.release();
    runOptions.release();

    // 6. Process Output
    // Output is usually [1, 10] logits (for 10 classes)
    final outputTensor = outputs[0]; // Assuming single output
    if (outputTensor == null) throw Exception("No output from model");

    // Get float list from output
    // The exact api to get data depends on tensor type, usually Float32List for logits
    final outputData = outputTensor.value as List<List<double>>;
    // Wait, onnxruntime dart usually returns List<dynamic> or specialized depending on shape.
    // For [1, 10] it might be List<List<double>>.
    // Let's assume it returns a list of list for batch output.

    final logits = outputData[0]; // The first (and only) batch item

    // Find Softmax / ArgMax
    int maxIndex = 0;
    double maxVal = logits[0];

    for (int i = 1; i < logits.length; i++) {
      if (logits[i] > maxVal) {
        maxVal = logits[i];
        maxIndex = i;
      }
    }

    // Release outputs
    for (var element in outputs) {
      element?.release();
    }

    return maxIndex;
  }

  void dispose() {
    _session?.release();
    OrtEnv.instance.release();
  }
}
