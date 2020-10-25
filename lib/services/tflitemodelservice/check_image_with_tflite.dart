import 'dart:io';

import 'package:tflite/tflite.dart';

class CheckImageWithTFLite {
  File pickedImage;
  bool isImageLoaded = false;

  List _result;
  String _confidence = "";
  String _name = "";
  String numbers = "";

  loadTFLiteModel(String selectedPlantName) async {
    Tflite.close();
    try {
      List<TFLiteModel> tfModels = [];
      TFLiteModel tfLiteModel;
      switch (selectedPlantName) {
        case "Potato":
          tfLiteModel = TFLiteModel("assets/tflitemodels/potato.tflite",
              "assets/tflitemodels/potato.txt");
          tfModels.add(tfLiteModel);
          break;
        case "Tomato":
          tfLiteModel = TFLiteModel("assets/tflitemodels/tomato.tflite",
              "assets/tflitemodels/tomato.txt");
          tfModels.add(tfLiteModel);
          break;
        case "Maize":
          tfLiteModel = TFLiteModel("assets/tflitemodels/maize.tflite",
              "assets/tflitemodels/maize.txt");
          tfModels.add(tfLiteModel);
          break;

        default:
          tfLiteModel = TFLiteModel("assets/tflitemodels/tomato.tflite",
              "assets/tflitemodels/tomato.txt");
          tfModels.add(tfLiteModel);
      }

      var i = 0;
      //load TFLite models
      for (final tfModel in tfModels) {
        var result =
            await Tflite.loadModel(model: tfModel.model, labels: tfModel.label);

        print("$i RESULT AFTER LOADING MODEL: $result");
        i++;
      }
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
