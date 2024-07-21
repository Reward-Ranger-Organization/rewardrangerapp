class UpdateScore {
  bool status;
  Data data;

  UpdateScore({
    required this.status,
    required this.data,
  });

  factory UpdateScore.fromJson(Map<String, dynamic> json) {
    return UpdateScore(
      status: json['status'],
      data: Data.fromJson(json['data']),
    );
  }
}

class Data {
  String lastName;
  String gender;
  int score;
  String city;
  String firstName;
  DateTime dob;

  Data({
    required this.lastName,
    required this.gender,
    required this.score,
    required this.city,
    required this.firstName,
    required this.dob,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      lastName: json['lastName'],
      gender: json['gender'],
      score: json['score'],
      city: json['city'],
      firstName: json['firstName'],
      dob: DateTime.parse(json['dob']),
    );
  }
}
