import 'package:pds/models/result_feedback.dart';
import 'package:pds/services/request/result_feedback_request.dart';

abstract class ResultFeedbackCallBack {
  void onResultFeedbackSuccess(ResultFeedback resultFeedback);
  void onResultFeedbacksSuccess(List<ResultFeedback> resultFeedback);
  void onResultFeedbackError(String error);
}

class ResultFeedbackResponse {
  ResultFeedbackCallBack _callBack;
  ResultFeedbackRequest resultFeedbackRequest = new ResultFeedbackRequest();

  ResultFeedbackResponse(this._callBack);

  saveNewResultFeedback(ResultFeedback resultFeedback) {
    resultFeedbackRequest
        .saveNewResultFeedback(resultFeedback)
        .then((resultFeedback) =>
            _callBack.onResultFeedbacksSuccess(resultFeedback))
        .catchError(
            (onError) => _callBack.onResultFeedbackError(onError.toString()));
  }
}
