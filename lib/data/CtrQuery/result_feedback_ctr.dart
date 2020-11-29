import 'package:pds/data/database_helper.dart';
import 'package:pds/models/result_feedback.dart';

class ResultFeedbackCtr {
  DatabaseHelper con = new DatabaseHelper();

  //insertion
  Future<List<ResultFeedback>> saveResultFeedback(
      ResultFeedback resultFeedback) async {
    var userName = resultFeedback.userName;
    var plantName = resultFeedback.plantName;
    var feedback = resultFeedback.feedback;

    var dbClient = await con.db;
    var result = await dbClient.rawInsert(
        "INSERT INTO result_feedback (user_name, plant_name, feedback) VALUES ('$userName', '$plantName', '$feedback')");

    var res2 = await dbClient.rawQuery(
        "SELECT * FROM result_feedback WHERE user_name = '$userName'");

    List<ResultFeedback> results = res2.isNotEmpty
        ? res2.map((c) => ResultFeedback.fromMap(c)).toList()
        : null;

    return results;
  }

  Future<List<ResultFeedback>> getAllResultFeedback() async {
    var dbClient = await con.db;
    var res = await dbClient.rawQuery("SELECT * FROM result_feedback");

    List<ResultFeedback> list = res.isNotEmpty
        ? res.map((c) => ResultFeedback.fromMap(c)).toList()
        : null;

    return list;
  }
}
