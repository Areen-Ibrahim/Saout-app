class CoachModel {
  // String? coachId; // إضافة معرف المدرب
  String email;
  String userName;
  String phoneNumber;
  String password;
  String userType;
  String confirmPassword;
  String? fcmToken;

  CoachModel({
    // this.coachId,
    required this.email,
    required this.userName,
    required this.phoneNumber,
    required this.password,
    required this.userType,
    required this.confirmPassword,
     this.fcmToken,
  });

  // دالة لتحويل النموذج إلى خريطة
  Map<String, dynamic> toMap() {
    return {
      // 'coachId': coachId,
      'userName': userName,
      'email': email,
      'phoneNumber': phoneNumber,
      'password': password,
      'userType': userType,
      'confirmPassword': confirmPassword,
    };
  }

  // دالة لإنشاء النموذج من خريطة
  factory CoachModel.fromMap(Map<String, dynamic> map) {
    return CoachModel(
      // coachId: map['coachId'] as String?, // استرجاع معرف المدرب
      userName: map['userName'] as String,
      email: map['email'] as String,
      fcmToken: map['fcmToken'] as String,
      phoneNumber: map['phoneNumber'] as String,
      password: map['password'] as String,
      userType: map['userType'] as String,
      confirmPassword: map['confirmPassword'] as String,
    );
  }
}
