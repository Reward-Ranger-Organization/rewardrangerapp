class UserInfo {
  final String firstName;
  final String lastName;
  final String gender;
  final int score;
  final String city;
  final String dob;
  final bool isVerified; // New field

  UserInfo({
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.score,
    required this.city,
    required this.dob,
    required this.isVerified, // New field
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return UserInfo(
      firstName: data['first_name'],
      lastName: data['last_name'],
      gender: data['gender'],
      score: data['score'],
      city: data['city'],
      dob: data['dob'],
      isVerified: data['is_verified'], // New field
    );
  }

  // Map<String, dynamic> toJson() {
  //   return {
  //     'first_name': firstName,
  //     'last_name': lastName,
  //     'gender': gender,
  //     'score': score,
  //     'city': city,
  //     'dob': dob,
  //     'is_verified': isVerified, // New field
  //   };
  // }
}
