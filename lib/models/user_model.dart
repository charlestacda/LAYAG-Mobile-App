class UserModel {
  String userCollege, userEmail, userFirstName, userLastName, userNo, userType, userProfile;

  UserModel({
    required this.userCollege,
    required this.userEmail,
    required this.userFirstName,
    required this.userLastName,
    required this.userNo,
    required this.userType,
    required this.userProfile,
  });

  static UserModel fromMap(Map<dynamic, dynamic> map) {
    return UserModel(
      userCollege: map['userCollege'],
      userEmail: map['userEmail'],
      userFirstName: map['userFirstName'],
      userLastName: map['userLastName'],
      userNo: map['userNo'],
      userType: map['userType'],
      userProfile: map['userProfile'],
    );
  }
}
