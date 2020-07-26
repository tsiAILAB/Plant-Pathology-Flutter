import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pds/models/diagnosis_result.dart';
import 'package:pds/screens/plantdiagnosisscreen//plant_details_screen.dart';
import 'package:pds/services/apis/all_apis.dart';
import 'package:pds/utils/utils.dart';

class UploadImage extends StatefulWidget {
  @override
  _UploadImageState createState() => _UploadImageState();

  void uploadImage(BuildContext context, File imageFile, String plantName,
      String userName, String feedbackValue, String responseId) {
    _UploadImageState _uploadImageState = new _UploadImageState();
    _uploadImageState._upload(
        context, imageFile, plantName, userName, feedbackValue, responseId);
  }

  void uploadDummyImage(File imageFile, String plantName) {
    _UploadImageState _uploadImageState = new _UploadImageState();
  }
}

class _UploadImageState extends State<UploadImage> {
  String uploadImageAPI = AllApis.uploadImageUrl;
  final _scaffoldKey = new GlobalKey<ScaffoldState>();

  /*Array of Diseases. Crops: Potato, Maize, Tomato*/
  var potatoDiseases = ["Early Blight", "Late Blight", "Healthy"];
  var maizeDiseases = [
    "Common Rust",
    "Gray Leaf Spot",
    "Northern Leaf Blight",
    "Healthy"
  ];
  var tomatoDiseases = [
    "Early Blight",
    "Late Blight",
    "Leaf Curl",
    "Leaf Mold",
    "Healthy"
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      key: _scaffoldKey,
    );
  }

//  User user, File file, String imageFileName, String imageSize,
//  String imageSizeUnit, String imageTypeString, String cropName

  void _upload(BuildContext context, File imageFileForUpload, String plantName,
      String userName, String feedbackValue, String responseId) async {
    var diseaseNames;
    switch (plantName.toUpperCase()) {
      case "POTATO":
        diseaseNames = potatoDiseases;
        break;
      case "TOMATO":
        diseaseNames = tomatoDiseases;
        break;
      case "MAIZE":
        diseaseNames = maizeDiseases;
        break;
      default:
        diseaseNames = [];
        break;
    }
    if (imageFileForUpload == null) {
      //FEEDBACK API
      http.post(uploadImageAPI, body: {
        "USER_NAME": userName,
        "CROP_NAME": "FEEDBACK",
        "SIZE": feedbackValue,
        "SIZE_UNIT": responseId,
        "FORMAT": "NA",
        "IMAGE": "NA",
      }).then((res) {
        print(res.statusCode);
        if (res != null) {
//          List<String> diagnosisRes = res.body.split("_");
          Utils.gotoHomeUi(context);
        }
        Utils.showLongToast("Send feedback successful!");
      }).catchError((err) {
        print(err);
        Utils.showLongToast("Send feedback failed!");
      });
    } else {
      String base64Image = base64Encode(imageFileForUpload.readAsBytesSync());
      String fileName = imageFileForUpload.path.split("/").last;
      String imageType = fileName.split(".").last;
      Utils utils = new Utils();
      if (imageType.toUpperCase() == 'BMP') {
        Utils.showLongToast("BMP image is not supported!");
      } else if (imageType.toUpperCase() == 'PNG' ||
          imageType.toUpperCase() == 'JPG' ||
          imageType.toUpperCase() == 'JPEG' ||
          imageType.toUpperCase() == 'JPG') {
//      utils.saveImage(imageFileForUpload, fileName, plantName);
        var decodedImage =
            await decodeImageFromList(imageFileForUpload.readAsBytesSync());

        String imageSize = decodedImage.width.toString() +
            "*" +
            decodedImage.height.toString();
        String platformName = Platform.operatingSystem;

//      _scaffoldKey.currentState.showSnackBar(new SnackBar(
//        duration: new Duration(seconds: 4),
//        content: new Row(
//          children: <Widget>[
//            new CircularProgressIndicator(),
//            new Text("  Uploading...")
//          ],
//        ),
//      ));

        http.post(uploadImageAPI, body: {
          "IMAGE": base64Image,
          "USER_NAME": userName,
          "CROP_NAME": plantName.toUpperCase(),
          "FORMAT": imageType,
          "SIZE": imageSize,
          "SIZE_UNIT": "KB",
        }).then((res) {
          //            String testRes = "92.07_98.07_94.07_94.07_2";//Maize
//          String testRes = "92.07_98.07_00.07_94.07_.8_2"; //Tomato
//            String testRes = "92.07_98.07_94.07_3";//potato
          print(res.statusCode);
          String savedImageString;
          var savedImagePath =
              utils.saveImage(imageFileForUpload, fileName, plantName);

          savedImagePath.then((String result) {
            setState(() {
              savedImageString = result;
            });
          });

          if (res != null) {
            parseResponse(context, res.body, diseaseNames, plantName, userName,
                imageFileForUpload.path);
          }
          Utils.showLongToast("Image upload successful!");
        }).catchError((err) {
          print(err);
//            String testRes = "92.07_98.07_94.07_94.07_2";//Maize
//          String testRes = "92.07_98.07_00.07_94.07_.8_2"; //Tomato
//            String testRes = "92.07_98.07_94.07_3";//potato
//          parseResponse(context, testRes, diseaseNames, plantName, userName,
//              imageFileForUpload.path);
//        parseResponse(testRes, diseaseNames, plantName, userName,
//            imageFileForUpload.path);
          Utils.showLongToast("Image upload failed!");
        });
      } else {
        Utils.showLongToast("$imageType type image is not supported!");
      }
    }
  }

  void parseResponse(BuildContext context, String testRes, diseaseNames,
      String plantName, String userName, String savedImagePath) {
    List<String> diagnosisRes = testRes.split("_");

    List<DiagnosisResult> diagnosisResults = new List<DiagnosisResult>();
    for (int i = 0; i < diagnosisRes.length - 1; i++) {
      String diseaseName = diseaseNames[i];
      String diagnosis = diagnosisRes[i];
      DiagnosisResult diagnosisResult = new DiagnosisResult();
      diagnosisResult.diseaseName = diseaseName;
      diagnosisResult.diagnosisResponse = diagnosis;
      diagnosisResults.add(diagnosisResult);
    }

    String responseId = diagnosisRes[diagnosisRes.length - 1];

    Navigator.of(context).pop();
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => PlantDetailsScreen(userName, plantName,
              diagnosisResults, savedImagePath.toString(), responseId)),
    );
  }
}
