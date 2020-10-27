import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image/image.dart' as ImageLibrary;
import 'package:image_picker/image_picker.dart';
import 'package:pds/models/PlantImage.dart';
import 'package:pds/models/diagnosis_result.dart';
import 'package:pds/screens/plantdiagnosisscreen/plant_details_screen.dart';
import 'package:pds/services/request/upload_image.dart';
import 'package:pds/services/tflitemodelservice/check_image_with_tflite.dart';
import 'package:pds/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TakeImageScreen extends StatefulWidget {
  final VoidCallback signOut;
  final PlantImage plantImage;

  TakeImageScreen(this.signOut, this.plantImage);

  @override
  _TakeImageScreenState createState() => _TakeImageScreenState(this.plantImage);
}

class _TakeImageScreenState extends State<TakeImageScreen> {
  File imageFile;
  String plantImageUrl;
  final PlantImage plantImage;
  static int count = 0;
  String plantName;
  String imageType = '';
  int imageHeight = 0, imageWidth = 0, imageSize = 0;
  String userName;
  bool isSendImageToServer = false;

  //nativeCall
  static const platformMethodChannel =
      const MethodChannel('heartbeat.fritz.ai/native');

  _grabCutImage(var imageFilePath, var imageName) async {
    String _message;
    try {
      final String result = await platformMethodChannel
          .invokeMethod('grabCutImage', <String, dynamic>{
        'param1': imageFilePath,
        'param2': imageName,
      });
      _message = result;
    } on PlatformException catch (e) {
      // _message = "Can't do native stuff ${e.message}.";
      _message = "CANT_DO_NATIVE";
    } on MissingPluginException catch(e) {
      _message = "CANT_DO_NATIVE";

    } on Exception catch(e) {
      _message = "CANT_DO_NATIVE";

    }
    print("nativeMessageGrabCut: $_message");
    return _message;
  }

  _isBlurOrTooDarkTooBrightImage(var imageFilePath, var imageName) async {
    String _message;
    try {
      final bool result = await platformMethodChannel
          .invokeMethod('isBlurOrTooDarkTooBrightImage', <String, dynamic>{
        'param1': imageFilePath,
        'param2': imageName,
      });
      if (result)
        _message = "true";
      else
        _message = "false";

      print("isBlurOrTooDarkTooBrightImage_message: $_message");
    } on PlatformException catch (e) {
      // _message = "Can't do native stuff ${e.message}.";
      _message = "CANT_DO_NATIVE";
    } on MissingPluginException catch(e) {
      _message = "CANT_DO_NATIVE";

    } on Exception catch(e) {
      _message = "CANT_DO_NATIVE";

    }
    return _message;
  }

  final _scaffoldKey = new GlobalKey<ScaffoldState>();

  _TakeImageScreenState(this.plantImage) {
    this.plantName = this.plantImage.plantName;
    this.plantImageUrl = this.plantImage.imageUrl;
  }

  String selectedPlantName;
  String selectedPlantImageLink = 'assets/images/maze.jpg';

  UploadImage uploadImage = new UploadImage();

  @override
  void initState() {
    super.initState();
    getPref();

    //Load TFLite model
    CheckImageWithTFLite checkImageWithTFLite = new CheckImageWithTFLite();
    checkImageWithTFLite.loadTFLiteModel(this.plantName);
  }

  @override
  Widget build(BuildContext context) {
    //Load TFLite model
    // CheckImageWithTFLite checkImageWithTFLite = new CheckImageWithTFLite();
    // checkImageWithTFLite.loadTFLiteModel();

    selectedPlantName = this.plantName;
    switch (selectedPlantName) {
      case "Potato":
        selectedPlantImageLink = 'assets/images/potato.jpg';
        break;
      case "Tomato":
        selectedPlantImageLink = 'assets/images/tomato.jpg';
        break;
      case "Maize":
        selectedPlantImageLink = 'assets/images/maze.jpg';
        break;
      default:
        selectedPlantImageLink = null;
    }
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Plant Diagnosis System',
            style: TextStyle(color: Colors.blueGrey)),
        iconTheme: IconThemeData(color: Colors.blueGrey),
        backgroundColor: Colors.white,
        actions: <Widget>[
          IconButton(
            onPressed: () {
              signOut();
            },
            icon: Icon(Icons.power_settings_new),
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            SizedBox(height: 20),
            Container(
              child: Column(
                children: <Widget>[
                  FlatButton(
                    onPressed: () {
                      print("I'm Maize");
                    },
                    child: CircleAvatar(
                      backgroundImage: (selectedPlantImageLink != null)
                          ? AssetImage('$selectedPlantImageLink')
                          : FileImage(File("$plantImageUrl")),
                      radius: 40,
                    ),
                  ),
                  Text(
                    "$selectedPlantName",
                    style: TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Card(
              child: Column(
                children: <Widget>[
                  decideImageView(),
//                  uploadIcon(),
                ],
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RaisedButton.icon(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0)),
                  icon: Icon(
                    Icons.camera,
                    color: Colors.white,
                  ),
                  color: Colors.blueGrey,
                  textColor: Colors.white,
                  label: Text("Camera"),
                  onPressed: () {
                    openCamera();
                  },
                ),
                SizedBox(width: 30),
                RaisedButton.icon(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0)),
                  icon: Icon(
                    Icons.image,
                    color: Colors.white,
                  ),
                  color: Colors.blueGrey,
                  textColor: Colors.white,
                  label: Text("Gallery"),
                  onPressed: () {
                    openGallery();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  signOut() {
    setState(() {
      widget.signOut();
    });
    Utils.gotoHomeUi(context);
  }

  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      userName = preferences.getString("user");
      isSendImageToServer = preferences.getBool("imageToServer") ?? false;
    });
  }

//  EmailServerSMTP.sendEmailViaSMTP("firozsujan@gmail.com", 33446);
  openGallery() async {
    var picture;
    var picker = new ImagePicker();
    try {
      picture = await picker.getImage(
          source: ImageSource.gallery, maxHeight: 200, maxWidth: 600);
    } catch (e) {
      Utils.showLongToast("Please try again!");
    }
    this.setState(() {
      imageFile = File(picture.path);
    });
  }

  openCamera() async {
    var picture;
    var picker = new ImagePicker();
    try {
      picture = await picker.getImage(
          source: ImageSource.camera, maxHeight: 200, maxWidth: 600);
    } catch (e) {
      Utils.showLongToast("Please try again!");
    }
    Utils utils = new Utils();
    this.setState(() {
      imageFile = File(picture.path);
      var fileName;
      try {
        utils.saveImage(imageFile, fileName, plantName);
      } catch (e) {}
    });
  }

  Widget decideImageView() {
    try {
      if (imageFile != null) {
        getImageDetails(imageFile);
        Utils.showLongToast("Thanks for uploading the photo");
//      _showImageUploadSuccessfullyDialog(context);
        return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.file(imageFile),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Text("Type - $imageType",
                        style: TextStyle(color: Colors.blueGrey)),
                    Text("Size - $imageSize",
                        style: TextStyle(color: Colors.blueGrey)),
                    Text('Height : $imageHeight',
                        style: TextStyle(color: Colors.blueGrey)),
                    Text('Width : $imageWidth',
                        style: TextStyle(color: Colors.blueGrey)),
                  ],
                ),
              ),
              FlatButton(
                color: Colors.blueGrey,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0)),
                child: Text(
                  "Analyze",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0),
                ),
                onPressed: () {
                  _onLoading(context, imageFile, plantName);
                  // _showDecisionDialog(context, imageFile, plantName);
                },
              ),
              SizedBox(height: 10),
            ]);
      } else {
        return Text(
          "Pick an image",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
        );
      }
    } catch (e) {
      return Text(
        "Pick an image",
        style: TextStyle(
            fontWeight: FontWeight.bold, fontSize: 25, color: Colors.blueGrey),
      );
    }
  }

  uploadIcon() {
    if (imageFile != null) {
      return IconButton(
        icon: Icon(Icons.file_upload),
        tooltip: 'Upload Image to the Server',
        onPressed: () {
          // _showDecisionDialog(context, imageFile, plantName);
          _onLoading(context, imageFile, plantName);
        },
      );
    } else {
      return IconButton(
        icon: Icon(Icons.file_upload),
        onPressed: () {},
      );
    }
  }

  void showLongToast(String text) {
    Fluttertoast.showToast(
      msg: text,
      toastLength: Toast.LENGTH_LONG,
    );
  }

  void _showSnackBar(String text) {
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Text(text),
    ));
  }

  void getImageDetails(imageFile) {
    try {
      String fileName = imageFile.path.split("/").last;
      String imageType = fileName.split(".").last;
      var imageHeight, imageWidth, imageSize;
      ImageLibrary.Image image =
          ImageLibrary.decodeImage(imageFile.readAsBytesSync());
      imageHeight = image.height;
      imageWidth = image.width;
      imageSize = image.length / 1024;

      log('Height: $imageHeight');
      log('width: $imageWidth');

      setState(() {
        this.imageType = imageType;
        this.imageHeight = imageHeight;
        this.imageWidth = imageWidth;
        this.imageSize = imageSize.toInt();
      });
    } on Exception catch (e) {
      // TODO
    }
  }

//  getImageSizeByte(fileLength){
//
//      String sizes = { "B", "KB", "MB", "GB" };
//      int order = 0;
//      while (fileLength >= 1024 && order + 1 < sizes.Length) {
//        order++;
//        fileLength = fileLength/1024;
//      }
//      string result = String.Format("{0:0.##} {1}", fileLength, sizes[order]);
//      return result;
//
//  }

  _showDecisionDialog(
      BuildContext dialogContext, File imageFile, String plantName) {
    UploadImage uploadImage = new UploadImage();

    return showDialog(
        context: dialogContext,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            title: Text('Do you want diagnosis of this Image?',
                style: TextStyle(color: Colors.blueGrey)),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      GestureDetector(
                        child: OutlineButton(
                          onPressed: () async {
                            if (imageFile != null) {
//                              uploadDummyImage(imageFile, plantName);
                              //check blur
                              var fileName = imageFile.path.split("/").last;
                              //check tooDark or tooBright
                              String isBlurOrTooDarkTooBrightImage =
                                  await _isBlurOrTooDarkTooBrightImage(
                                      imageFile.path, fileName) as String;
                              // Utils.showLongToast(
                              //     "Image! " + isBlurOrTooDarkTooBrightImage);

                              print(
                                  "isBlurOrTooDarkTooBrightImage: $isBlurOrTooDarkTooBrightImage");
                              if (isBlurOrTooDarkTooBrightImage == "false") {
                                String grabCutImageFile = await _grabCutImage(
                                    imageFile.path, fileName) as String;

                                print("grabCutImageFile: " + grabCutImageFile);
                                print(
                                    "isSendImageToServer: $isSendImageToServer");

                                if (isSendImageToServer) {
                                  // var grabCutFileName =
                                  //     grabCutImageFile.split("/").last;
                                  uploadImage.uploadImage(
                                      context,
                                      new File(grabCutImageFile),
                                      plantName,
                                      userName,
                                      "",
                                      "");
                                } else {
                                  //check image by TFLite model
                                  List res;
                                  CheckImageWithTFLite checkImageWithTFLite =
                                      new CheckImageWithTFLite();
                                  if (grabCutImageFile != null) {
                                    res = await checkImageWithTFLite
                                        .applyModelOnImage(
                                            new File(grabCutImageFile)) as List;
                                  } else {
                                    res = await checkImageWithTFLite
                                        .applyModelOnImage(imageFile) as List;
                                  }
                                  String str = res[0]["label"];
                                  String _name = str.substring(0);
                                  String prediction =
                                      (res[0]['confidence'] * 100)
                                          .toString()
                                          .substring(0, 5);

                                  print("name: $_name");
                                  print("prediction: " + prediction + "%");

                                  DiagnosisResult diagnosisResult =
                                      new DiagnosisResult();
                                  diagnosisResult.diseaseName = _name;
                                  diagnosisResult.diagnosisResponse =
                                      prediction;

                                  List<DiagnosisResult> diagnosisResults =
                                      new List<DiagnosisResult>();
                                  diagnosisResults.add(diagnosisResult);

                                  //print result
                                  // var diagnosisResultText = "";
                                  // for (var i = 0;
                                  //     i < diagnosisResults.length;
                                  //     i++) {
                                  //   diagnosisResultText = diagnosisResultText +
                                  //       "Disease Name: " +
                                  //       diagnosisResults[i].diseaseName +
                                  //       "\nProbability: " +
                                  //       diagnosisResults[i].diagnosisResponse +
                                  //       "%\n";
                                  //
                                  //   if (i != diagnosisResults.length - 1) {
                                  //     diagnosisResultText =
                                  //         diagnosisResultText + "\n";
                                  //   }
                                  // }
                                  // print(
                                  //     "DiagnosisResult: $diagnosisResultText");

                                  // Navigator.of(context).pop();
                                  Navigator.push(
                                    dialogContext,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            PlantDetailsScreen(
                                                userName,
                                                plantName,
                                                diagnosisResults,
                                                imageFile.path,
                                                "0")),
                                  );

                                  // Navigator.of(context).pop();
                                  Utils.showLongToast("Name: " +
                                      str +
                                      " probability: " +
                                      prediction +
                                      "%");
                                }
                              } else {
                                Utils.showLongToast(
                                    "Please take another Image!");
                                // Utils.showLongToast("Image diagnosis failed!");
                              }
                            } else {
                              Utils.showLongToast("Image upload failed!");
                              // Utils.showLongToast("Image diagnosis failed!");
                            }
                            Navigator.pop(context);
                          },
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0)),
                          child: Text(
                            'Yes',
                            style: TextStyle(color: Colors.teal[800]),
                          ),
                        ),
                        onTap: () {},
                      ),
                      GestureDetector(
                        child: OutlineButton(
                          onPressed: () {
                            _scaffoldKey.currentState.showSnackBar(new SnackBar(
                              duration: new Duration(seconds: 4),
                              content: new Row(
                                children: <Widget>[
                                  new CircularProgressIndicator(),
                                  new Text("  running diagnosis...")
                                ],
                              ),
                            ));

                            Utils utils = new Utils();
                            var fileName = imageFile.path.split("/").last;
                            utils
                                .saveImage(imageFile, fileName, imageFile.path)
                                .whenComplete(() => Navigator.pop(context));
                            Utils.showLongToast("Image saved in local storage");
                            Navigator.pop(context);
                          },
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0)),
                          child: Text(
                            'No',
                            style: TextStyle(color: Colors.teal[800]),
                          ),
                        ),
                        onTap: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
  }

  void _onLoading(BuildContext context, File imageFile, String plantName) {
    BuildContext dialogContext;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        dialogContext = context;
        return Dialog(
          backgroundColor: Colors.white,
          child: new Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 10.0,
                height: 60.0,
              ),
              new CircularProgressIndicator(),
              new Text(
                "   Analyzing...",
                style: TextStyle(
                    color: Colors.blueGrey,
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0),
              ),
            ],
          ),
        );
      },
    );
    new Future.delayed(new Duration(seconds: 3), () {
      Navigator.pop(dialogContext);
      _diagnoseTheImage(context, imageFile, plantName);
    });
  }

  _diagnoseTheImage(
      BuildContext context, File imageFile, String plantName) async {
    if (imageFile != null) {
//     uploadDummyImage(imageFile, plantName);
      //check blur
      var fileName = imageFile.path.split("/").last;
      //check tooDark or tooBright
      String isBlurOrTooDarkTooBrightImage =
          await _isBlurOrTooDarkTooBrightImage(imageFile.path, fileName)
              as String;
      // Utils.showLongToast(
      //     "Image! " + isBlurOrTooDarkTooBrightImage);

      print("isBlurOrTooDarkTooBrightImage: $isBlurOrTooDarkTooBrightImage");
      if (isBlurOrTooDarkTooBrightImage == "false") {
        String grabCutImageFile =
            await _grabCutImage(imageFile.path, fileName) as String;

        print("grabCutImageFile: " + grabCutImageFile);
        print("isSendImageToServer: $isSendImageToServer");

        if (isSendImageToServer) {
          // var grabCutFileName =
          //     grabCutImageFile.split("/").last;
          uploadImage.uploadImage(
              context, new File(grabCutImageFile), plantName, userName, "", "");
        } else {
          //check image by TFLite model
          List res;
          CheckImageWithTFLite checkImageWithTFLite =
              new CheckImageWithTFLite();
          if (grabCutImageFile != null) {
            res = await checkImageWithTFLite
                .applyModelOnImage(new File(grabCutImageFile)) as List;
          } else {
            res =
                await checkImageWithTFLite.applyModelOnImage(imageFile) as List;
          }
          String str = res[0]["label"];
          String _name = str.substring(0);
          String prediction =
              (res[0]['confidence'] * 100).toString().substring(0, 5);

          print("name: $_name");
          print("prediction: " + prediction + "%");

          DiagnosisResult diagnosisResult = new DiagnosisResult();
          diagnosisResult.diseaseName = _name;
          diagnosisResult.diagnosisResponse = prediction;

          List<DiagnosisResult> diagnosisResults = new List<DiagnosisResult>();
          diagnosisResults.add(diagnosisResult);

          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => PlantDetailsScreen(userName, plantName,
                    diagnosisResults, imageFile.path, "0")),
          );

          // Navigator.of(context).pop();
          // Utils.showLongToast(
          //     "Name: " + str + " probability: " + prediction + "%");
        }
      } else if (isBlurOrTooDarkTooBrightImage == "CANT_DO_NATIVE") {
        CheckImageWithTFLite checkImageWithTFLite = new CheckImageWithTFLite();
        List res =
            await checkImageWithTFLite.applyModelOnImage(imageFile) as List;

        String str = res[0]["label"];
        String _name = str.substring(0);
        String prediction =
            (res[0]['confidence'] * 100).toString().substring(0, 5);

        print("name: $_name");
        print("prediction: " + prediction + "%");

        DiagnosisResult diagnosisResult = new DiagnosisResult();
        diagnosisResult.diseaseName = _name;
        diagnosisResult.diagnosisResponse = prediction;

        List<DiagnosisResult> diagnosisResults = new List<DiagnosisResult>();
        diagnosisResults.add(diagnosisResult);

        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => PlantDetailsScreen(
                  userName, plantName, diagnosisResults, imageFile.path, "0")),
        );
      } else {
        // Utils.showLongToast("Please take another Image!");
        // Utils.showLongToast("Image diagnosis failed!");
      }
    } else {
      Utils.showLongToast("Image upload failed!");
      // Utils.showLongToast("Image diagnosis failed!");
    }
  }

  void uploadDummyImage(File imageFile, String plantName) {
    DiagnosisResult diagnosisResponse;
    String fileName = imageFile.path.split("/").last;
    String imageType = fileName.split(".").last;
    String _diseaseName, _diagnosisResponse;

//    if (plantName.toUpperCase() == "POTATO" &&
//        fileName.toUpperCase() == "EARLY_BLIGHT") {
//    if (count == 0) {
//      _diseaseName = "Early Blight";
//      _diagnosisResponse = "Disease Found, Probability-92.75%";
//
//      plantDiagnosisResponse = new DiagnosisResult(
//          plantName, imageFile.path, _diseaseName, _diagnosisResponse);
////    } else if (plantName.toUpperCase() == "POTATO" &&
////        fileName.toUpperCase() == "LATE_BLIGHT") {
//    } else if (count == 1) {
//      _diseaseName = "Late Blight";
//      _diagnosisResponse = "Disease Found, Probability-98.12%";
//
//      plantDiagnosisResponse = new DiagnosisResult(
//          plantName, imageFile.path, _diseaseName, _diagnosisResponse);
////    } else if (plantName.toUpperCase() == "POTATO" &&
////        fileName.toUpperCase() == "HEALTHY_LEAF") {
//    } else if (count == 2) {
//      _diseaseName = "Diseas not found";
//      _diagnosisResponse = "Disease Not Found, Probability-92.75%";
//
//      plantDiagnosisResponse = new DiagnosisResult(
//          plantName, imageFile.path, _diseaseName, _diagnosisResponse);
//    } else {
//      _diseaseName = "Not a Plant";
//      _diagnosisResponse = "This is not a Plant!";
//
//      plantDiagnosisResponse = new DiagnosisResult(
//          plantName, imageFile.path, _diseaseName, _diagnosisResponse);
//      count = -1;
//    }

    count = count + 1;

//    Navigator.of(context).pop();
//    Navigator.push(
//      context,
//      MaterialPageRoute(
//          builder: (context) =>
//              PlantDetailsScreen(userName, plantName, diagnosisResponse, )),
//    );
  }
}

Future<void> _showImageUploadSuccessfullyDialog(BuildContext context) {
  return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          title: Text(
            'Image Uploaded Successfully',
            style: TextStyle(color: Colors.green),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Icon(
                      Icons.check_circle,
                      size: 50.0,
                      color: Colors.green,
                    )
                  ],
                ),
              ],
            ),
          ),
        );
      });
}
