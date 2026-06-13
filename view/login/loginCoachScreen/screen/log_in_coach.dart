import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart' as notifications;
import 'package:get/get.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import '../../../../controllers/controller_coach/log_in_coach_controller.dart';
import '../../../../core/color.dart';
import '../../../../core/next_button.dart';
import '../../../../core/password_field.dart';
import '../../../homePage/widget/text_title_add_player.dart';
import '../../loginScout/widget/text_form_login_widget.dart';


class LoginCoachScreen extends StatelessWidget {
  final LogInCoachController loginController = Get.put(LogInCoachController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: ColorApp.background,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
        backgroundColor: Colors.white10,
        automaticallyImplyLeading: false,
        title: TextTitleAddPlayer(text: 'Login as coach'),
        ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Form(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Padding(
                        //   padding: const EdgeInsets.symmetric(vertical: 60),
                        //   child: Text(
                        //     "Log in as Coach",
                        //     style: TextStyle(
                        //       color: ColorApp.richLavender,
                        //       fontSize: 36,
                        //       fontWeight: FontWeight.bold,
                        //     ),
                        //   ),
                        // ),
                        Container(
                          width: 250,
                          height: 250,
                          child: Image.asset("image/icon.png"),
                        ),
                        TextFormLoginWidget(
                          text: 'Email',
                          hint: 'Email',
                          controller: loginController.emailController,
                          colorText: Colors.white,
                          type: TextInputType.emailAddress,
                          readOnly: false,
                        ),
                        const SizedBox(height: 22),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Password",
                              style: TextStyle(fontSize: 16.0, color: Colors.white),
                            ),
                            const SizedBox(height: 12),
                            PasswordFieldWidget(
                              controller: loginController.passwordController,),
                          ],
                        ),
                        const SizedBox(height: 22),
                        TextButton(
                          onPressed: () {
                            Get.to(() => EmailSenderCoach());
                          },
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Forgot Password?",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        Obx(() => Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton.icon(
                            iconAlignment: IconAlignment.end,
                            onPressed: () {

                                loginController.login(); // استدعاء دالة تسجيل الدخول

                            },
                            icon: loginController.isLoading.value
                                ? CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                                : Icon(Icons.arrow_forward, color: Colors.white),
                            label: loginController.isLoading.value
                                ? Text("")
                                : Text("Next", style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                          ),
                        ))
                        // Obx(() => Align(
                        //   alignment: Alignment.centerRight,
                        //   child: NextButtonWidget(
                        //     onPressed: () {
                        //       loginController.login();
                        //     },
                        //     loading: loginController.isLoading.value,
                        //   ),
                        // )),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EmailSenderCoach extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  late String verificationCode; // متغير لتخزين الرمز العشوائي
  final LogInCoachController loginController = Get.put(LogInCoachController());


  // إنشاء رمز عشوائي مكون من 5 خانات
  String generateRandomCode() {
    final random = Random();
    return List.generate(5, (_) => random.nextInt(10).toString()).join();
  }

  Future<void> sendEmail(String recipientEmail) async {
    final emailExists = await loginController.isEmailRegistered(recipientEmail);

    if (!emailExists) {
      Get.snackbar(
        "Error",
        "Email not found in the database.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return; // إنهاء العملية إذا لم يكن البريد الإلكتروني موجودًا
    }

    String username = 'alalighind@gmail.com'; // بريدك الثابت
    String password = 'trny edau twbo qxux';   // كلمة مرور التطبيق

    final smtpServer = gmail(username, password);

    verificationCode = generateRandomCode(); // توليد الرمز العشوائي

    final message = Message()
      ..from = Address(username, 'Your App Name')
      ..recipients.add(recipientEmail)
      ..subject = 'Your Verification Code'
      ..text = 'Your verification code is: $verificationCode';

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());

      // الانتقال إلى صفحة إدخال الكود
      Get.to(() => VerificationScreen(verificationCode: verificationCode, recipientEmail: emailController.text,));
    } on MailerException catch (e) {
      print('Message not sent. \n$e');
      Get.snackbar(
        "Error",
        "Failed to send email. Please try again later.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorApp.background,
      appBar: AppBar(
        title: TextTitleAddPlayer(text: 'Send Email'),
        backgroundColor: Colors.white10,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 44, horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Enter Recipient Email",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: emailController,
              decoration: InputDecoration(
                hintText: "example@gmail.com",
                hintStyle: TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              style: TextStyle(color: Colors.black),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  final email = emailController.text.trim();
                  if (email.isNotEmpty) {
                    sendEmail(email);
                  } else {
                    Get.snackbar(
                      "Error",
                      "Please enter a valid email address",
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorApp.oasisGreen,
                ),
                child: Text("Send Email", style: TextStyle(color: Colors.white),),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VerificationScreen extends StatelessWidget {
  final String verificationCode; // الكود المرسل
  final String recipientEmail; // البريد الإلكتروني المرسل إليه
  final TextEditingController codeController = TextEditingController();

  VerificationScreen({required this.verificationCode, required this.recipientEmail});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorApp.background,
      appBar: AppBar(
        title: TextTitleAddPlayer(text: 'Enter Verification Code'),
        backgroundColor: Colors.white10,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 44, horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Enter the code sent to your email",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: codeController,
              decoration: InputDecoration(
                hintText: "Enter code",
                hintStyle: TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              style: TextStyle(color: Colors.black),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  final enteredCode = codeController.text.trim();
                  if (enteredCode == verificationCode) {
                    Get.snackbar(
                      "Success",
                      "Code verified successfully!",
                      backgroundColor: Colors.green,
                      colorText: Colors.white,
                    );
                    // الانتقال إلى صفحة إعادة تعيين كلمة المرور مع إرسال البريد الإلكتروني
                    Get.to(() => ResetPasswordScreen(userEmail: recipientEmail));
                  } else {
                    Get.snackbar(
                      "Error",
                      "Invalid code. Please try again.",
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorApp.richLavender,
                ),
                child: Text("Verify Code"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ResetPasswordScreen extends StatelessWidget {
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final LogInCoachController loginController = Get.put(LogInCoachController());
  final String userEmail; // البريد الإلكتروني المرسل

  ResetPasswordScreen({required this.userEmail});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorApp.background,
      appBar: AppBar(
        title: TextTitleAddPlayer(text: 'Reset password'),
        backgroundColor: Colors.white10,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 44, horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Enter New Password",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: newPasswordController,
              decoration: InputDecoration(
                hintText: "New Password",
                hintStyle: TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              style: TextStyle(color: Colors.black),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            Text(
              "Confirm New Password",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: confirmPasswordController,
              decoration: InputDecoration(
                hintText: "Confirm Password",
                hintStyle: TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              style: TextStyle(color: Colors.black),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  final newPassword = newPasswordController.text.trim();
                  final confirmPassword = confirmPasswordController.text.trim();

                  if (newPassword.isEmpty || confirmPassword.isEmpty) {
                    Get.snackbar(
                      "Error",
                      "Both fields are required",
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                    );
                  } else if (newPassword != confirmPassword) {
                    Get.snackbar(
                      "Error",
                      "Passwords do not match",
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                    );
                  } else if (newPassword.length < 8) {
                    Get.snackbar(
                      "Error",
                      "Password must be at least 8 characters long.",
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                    );
                  } else {
                    try {
                      await loginController.updatePasswordInFirestore(newPassword, userEmail);
                      Get.snackbar(
                        "Success",
                        "Password reset successfully!",
                        backgroundColor: Colors.green,
                        colorText: Colors.white,
                      );
                    } catch (e) {
                      // Get.snackbar(
                      //   "Error",
                      //   "An error occurred while resetting password.",
                      //   backgroundColor: Colors.red,
                      //   colorText: Colors.white,
                      // );
                      print("An error occurred while resetting password.");
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorApp.oasisGreen,
                ),
                child: Text("Reset Password"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



