class LoginCoachModel {
  String email;
  String password;

  LoginCoachModel({required this.email, required this.password});
  // دالة لتحويل النموذج إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}
