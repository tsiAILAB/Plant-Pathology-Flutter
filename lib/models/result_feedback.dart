class ResultFeedback {
  int _id;
  String _userName;
  String _plantName;
  String _feedback;

  ResultFeedback(this._userName, this._plantName, this._feedback);

  String get feedback => _feedback;
  String get plantName => _plantName;
  String get userName => _userName;

  ResultFeedback.fromMap(dynamic obj) {
    this._userName = obj['user_name'];
    this._plantName = obj['plant_name'];
    this._feedback = obj['feedback'];
  }

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map["user_name"] = _userName;
    map["plant_name"] = _plantName;
    map["feedback"] = _feedback;

    return map;
  }
}
