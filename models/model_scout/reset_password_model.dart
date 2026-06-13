// models/user_model.dart
class ResetPasswordModel {
  String email;
  String code; // كود التحقق
  String password; // كلمة المرور

  ResetPasswordModel({required this.email, this.code = '', this.password = ''});
}
