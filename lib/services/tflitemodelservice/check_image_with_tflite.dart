import 'dart:io';

import 'package:tflite/tflite.dart';

class CheckImageWithTFLite {
  File pickedImage;
  bool isImageLoaded = false;

  List _result;
  String _confidence = "";
  String _name = "";
  String numbers = "";

  loadTFLiteModel() async {
    Tflite.close();
    try {
      List<TFLiteModel> tfModels = [];

      TFLiteModel tfLiteModel = TFLiteModel(
          "assets/tflitemodels/etomato.tflite",
          "assets/tflitemodels/etomato.txt");

      tfModels.add(tfLiteModel);

      tfLiteModel = TFLiteModel("assets/tflitemodels/otomato.tflite",
          "assets/tflitemodels/otomato.txt");

      tfModels.add(tfLiteModel);

      tfLiteModel = TFLiteModel("assets/tflitemodels/vtomato.tflite",
          "assets/tflitemodels/vtomato.txt");

      tfModels.add(tfLiteModel);

      var i = 0;
      for (final tfModel in tfModels) {
        var result =
            await Tflite.loadModel(model: tfModel.model, labels: tfModel.label);

        print("$i RESULT AFTER LOADING MODEL: $result");
        i++;
      }
      //<<<<<<<<------------Potato Models----------->>>>>>>
      // model: "assets/potato_model_64.tflite",
      // labels: "assets/potato_model_64.txt"
      // model: "assets/potato_model_128.tflite",
      // labels: "assets/potato_model_128.txt"
      // model: "assets/tflitepotato_model_224.tflite",
      // labels: "assets/tflitepotato_model_224.txt"

      //<<<<<<<<------------Maize Models----------->>>>>>>
      // model: "assets/maize_model_64.tflite",
      // labels: "assets/maize_model_64.txt"
      // model: "assets/maize_model_128.tflite",
      // labels: "assets/maize_model_128.txt"
      // model: "assets/tflitemaize_model_224.tflite",
      // labels: "assets/tflitemaize_model_224.txt"

      //<<<<<<<<------------Tomato Models----------->>>>>>>
      // model: "assets/tomato_model_64.tflite",
      // labels: "assets/tomato_model_64.txt"
      // model: "assets/tomato_model_128.tflite",
      // labels: "assets/tomato_model_128.txt"

      //<<<<<<<<------------New Models----------->>>>>>>
      // model: "assets/tflitemodels/etomato.tflite",
      // labels: "assets/tflitemodels/etomato.txt"
      // model: "assets/tflitemodels/otomato.tflite",
      // labels: "assets/tflitemodels/otomato.txt"
      // model: "assets/tflitemodels/vtomato.tflite",
      // labels: "assets/tflitemodels/vtomato.txt"
      // model: "assets/tflitemodels/tomato.tflite",
      // labels: "assets/tflitemodels/tomato.txt"
      // model: "assets/yolov4-tiny-416.tflite",
      // labels: "assets/yolov4-tiny-416.txt"

    } catch (e) {
      print("Loading Model failed! $e");
    }
  }

  applyModelOnImage(File file) async {
    var res = await Tflite.runModelOnImage(path: file.path);
    return res;
  }
}

class TFLiteModel {
  String model;
  String label;

  TFLiteModel(this.model, this.label);
}
