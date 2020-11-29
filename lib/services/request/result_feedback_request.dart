import 'package:pds/data/CtrQuery/result_feedback_ctr.dart';
import 'package:pds/models/result_feedback.dart';

class ResultFeedbackRequest {
  ResultFeedbackCtr con = new ResultFeedbackCtr();

  Future<List<ResultFeedback>> saveNewResultFeedback(
      ResultFeedback resultFeedback) async {
    var results = await con.saveResultFeedback(resultFeedback);
    return results;
  }
}
