import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/controller_coach/sign_up_coach_controller.dart';
import '../../../../core/color.dart';
import '../../../../core/next_button.dart';
import '../../../../core/password_field.dart';
import '../../signupScout/widget/text_form_field_widget.dart';

class SignUpCoach extends StatefulWidget {
  @override
  _SignUpCoachState createState() => _SignUpCoachState();
}

class _SignUpCoachState extends State<SignUpCoach> {
  final CoachController _coachController = Get.put(CoachController());
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _coachController.userNameController.clear();
    _coachController.emailController.clear();
    _coachController.phoneController.clear();
    _coachController.passwordController.clear();
    _coachController.confirmPasswordController.clear();
    _coachController.phoneError.value = '';
    _coachController.emailError.value = '';

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorApp.blue,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
                        child: Text(
                          "Sign up as coach",
                          style: TextStyle(
                            color: ColorApp.richLavender,
                            fontSize: 38,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // حقل اسم المستخدم
                      TextFormFieldWidget(
                        text: 'User Name',
                        hint: 'User Name',
                        controller: _coachController.userNameController,
                        inputType: TextInputType.text,
                        validator: (value) => _coachController.validateField(value!, 'userName'),
                      ),

                      // حقل البريد الإلكتروني
                      TextFormFieldWidget(
                        text: 'Email',
                        hint: 'Email',
                        controller: _coachController.emailController,
                        inputType: TextInputType.emailAddress,
                        validator: (value) => _coachController.validateField(value!, 'email'),
                      ),

                      // حقل رقم الهاتف
                      TextFormFieldWidget(
                        text: 'Number Phone',
                        hint: 'Number Phone',
                        controller: _coachController.phoneController,
                        inputType: TextInputType.phone,
                        validator: (value) => _coachController.validateField(value!, 'phoneNumber'),
                      ),


                      // حقل كلمة المرور
                      Text(
                        "Password",
                        style: TextStyle(fontSize: 16.0, color: Colors.white),
                      ),
                      SizedBox(height: 12),
                      PasswordFieldWidget(
                        controller: _coachController.passwordController,
                        validator: (value) => _coachController.validateField(value!, 'password'),
                      ),
                      SizedBox(height: 20),

                      // حقل تأكيد كلمة المرور
                      Text(
                        "Confirm Password",
                        style: TextStyle(fontSize: 16.0, color: Colors.white),
                      ),
                      SizedBox(height: 12),
                      PasswordFieldWidget(
                        controller: _coachController.confirmPasswordController,
                        validator: (value) => _coachController.validateField(
                          value!,
                          'confirmPassword',
                          password: _coachController.passwordController.text,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // زر التسجيل
                      Obx(() {
                        return Align(
                          alignment: Alignment.centerRight,
                          child: NextButtonWidget(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                await _coachController.signUp();
                              }
                            },
                            loading: _coachController.isLoading.value,
                          ),
                        );
                      }),
                    ],
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
