import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:group_radio_button/group_radio_button.dart';
import 'package:pds/models/diagnosis_result.dart';
import 'package:pds/models/result_feedback.dart';
import 'package:pds/services/request/upload_image.dart';
import 'package:pds/services/response/result_feedback_response.dart';
import 'package:pds/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlantDetailsScreen extends StatefulWidget {
  final List<DiagnosisResult> diagnosisResults;
  final String userName;
  final String plantName;
  final String imageUrl;
  final String responseId;

//  String plantName, diagnosisResult, diagnosisImage, diseaseName;

  PlantDetailsScreen(this.userName, this.plantName, this.diagnosisResults,
      this.imageUrl, this.responseId);

  @override
  _PlantDetailsScreen createState() => _PlantDetailsScreen(this.userName,
      this.plantName, this.diagnosisResults, this.imageUrl, this.responseId);
}

class _PlantDetailsScreen extends State<PlantDetailsScreen>
    implements ResultFeedbackCallBack {
  final List<DiagnosisResult> diagnosisResults;
  final String userName;
  final String plantName;
  final String imageUrl;
  final String responseId;
  bool isSendImageToServer;
  ResultFeedbackResponse _resultFeedbackResponse;

  _PlantDetailsScreen(this.userName, this.plantName, this.diagnosisResults,
      this.imageUrl, this.responseId) {
    _resultFeedbackResponse = new ResultFeedbackResponse(this);
  }

  @override
  Widget build(BuildContext context) {
//    File imageFile = new File(this.imagePath);

    print("DiagnosisResultStart");
    var diagnosisResultText = "";
    for (var i = 0; i < diagnosisResults.length; i++) {
      diagnosisResultText = diagnosisResultText +
          "Disease Name: " +
          diagnosisResults[i].diseaseName +
          "\nProbability: " +
          diagnosisResults[i].diagnosisResponse +
          "%\n";

      if (i != diagnosisResults.length - 1) {
        diagnosisResultText = diagnosisResultText + "\n";
      }
    }
    print("DiagnosisResult: $diagnosisResultText");

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('$plantName', style: TextStyle(color: Colors.blueGrey)),
        iconTheme: IconThemeData(color: Colors.blueGrey),
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            child: Column(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Image.file(File('$imageUrl'), height: 200),
                  ],
                ),
                SizedBox(
                  height: 10.0,
                ),
                Card(
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Row(
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Diagnosis Result ',
                              style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueGrey),
                            ),
                            SizedBox(
                              height: 15.0,
                            ),
                            Text(
                              '$diagnosisResultText',
                              style:
                                  TextStyle(fontSize: 14, color: Colors.blue),
                            ),
                            SizedBox(height: 15.0),
                            Text(
                              'Test Result: ',
                              style:
                                  TextStyle(fontSize: 14, color: Colors.blue),
                            ),
                            RadioButton(
                              description: "Yes",
                              value: "YES",
                              groupValue: _radioValue,
                              onChanged: (value) => setState(
                                () => _radioValue = value,
                              ),
                            ),
                            RadioButton(
                              description: "No",
                              value: "NO",
                              groupValue: _radioValue,
                              onChanged: (value) => setState(
                                () => _radioValue = value,
                              ),
                            ),
                            OutlineButton(
                              onPressed: () async {
                                if (_radioValue != null) {
                                  //isSendImageTOServer=true for send feedback to the server
                                  await _saveFeedback(new ResultFeedback(
                                      userName, plantName, _radioValue));

                                  if (isSendImageToServer) {
                                    _sendFeedback(context);
                                  } else {
                                    Utils.showLongToast(
                                        "Thank you for your feedback!");
                                    Navigator.of(context).pop();
                                  }
                                } else {
                                  Utils.showLongToast(
                                      "Please select one feedback!");
                                }
                              },
                              child: Text(
                                'Ok',
                                style: TextStyle(
                                    color: Colors.blue, fontSize: 16.0),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  var _radioValue;
  String choice;

  // ------ [add the next block] ------
  @override
  void initState() {
    setState(() {
      _radioValue = "YES";
    });
    super.initState();
    getPref();
  }

  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      isSendImageToServer = preferences.getBool("imageToServer") ?? false;
    });
  }

  // ------ end: [add the next block] ------

  void radioButtonChanges(String value) {
    setState(() {
      _radioValue = value;
      switch (value) {
        case 'YES':
          choice = value;
          break;
        case 'NO':
          choice = value;
          break;
        default:
          choice = null;
      }
      debugPrint(choice); //Debug the choice in console
    });
  }

  void _sendFeedback(BuildContext context) {
    UploadImage uploadImage = new UploadImage();
    uploadImage.uploadImage(
        context, null, plantName, userName, _radioValue, responseId);
  }

  Future _saveFeedback(ResultFeedback resultFeedback) async {
    List<ResultFeedback> result =
        await _resultFeedbackResponse.saveNewResultFeedback(resultFeedback);
  }

  @override
  void onResultFeedbackError(String error) {
    // TODO: implement onResultFeedbackError
  }

  @override
  void onResultFeedbackSuccess(ResultFeedback resultFeedback) {
    // TODO: implement onResultFeedbackSuccess
  }

  @override
  void onResultFeedbacksSuccess(List<ResultFeedback> resultFeedback) {
    // TODO: implement onResultFeedbacksSuccess

    print("PlantName: " +
        resultFeedback.first.plantName +
        " user: " +
        resultFeedback.first.userName +
        "FeedBack: " +
        resultFeedback.first.feedback);
  }
}
