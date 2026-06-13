
class UserModel {
  String firstName;
  String lastName;
  String email;
  String phoneNumber;
  String password;
  String profilePicture;
  String gender;
  String code;
  String userType;
  String? uid;
  List<String> follow;
  List<String> followTeams;


  UserModel({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.password,
    required this.profilePicture,
    required this.gender,
    required this.code,
    required this.userType,
    this.uid,
    required this.follow,
    required this.followTeams
  });

  // دالة لتحويل النموذج إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'userId': uid,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
      'password': password,
      'profilePicture': profilePicture,
      'gender': gender,
      'code': code,
      'user_type': userType,
      'follow' : follow,
      'followTeams' : followTeams,
    };
  }

  // دالة لتحويل JSON إلى نموذج UserModel
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['userId'],
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      password: json['password'] ?? '',
      profilePicture: json['profilePicture'] ?? '',
      gender: json['gender'] ?? '',
      code: json['code'] ?? '',
      userType: json['user_type'] ?? 'scout', // القيم الافتراضية إذا لم تكن موجودة
        follow: json['follow'] ?? [],
        followTeams: json['followTeams'] ?? []
    );
  }
}
