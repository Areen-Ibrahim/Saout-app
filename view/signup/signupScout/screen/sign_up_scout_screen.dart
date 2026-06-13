import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/controller_coach/sign_up_coach_controller.dart';
import '../../../../controllers/controller_scout/controller_scout_auth/user_controller.dart';
import '../../../../core/color.dart';
import '../../../../core/next_button.dart';
import '../../../../core/password_field.dart';
import '../../../../core/stack_background.dart';
import '../../../../models/model_scout/sign_up_model.dart';
import '../../../../routes.dart';
import '../../../homePage/widget/text_title_add_player.dart';
import '../widget/drop_down_gender.dart';
import '../widget/profile_picture.dart';
import '../widget/text_form_field_widget.dart';

class SignupView extends StatelessWidget {
  final UserController _userController = Get.put(UserController());
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  String? selectedGender;
  final _formKey = GlobalKey<FormState>();
  final String defaultProfilePicture = 'image/avatarDefault.png';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorApp.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white10,
        title: TextTitleAddPlayer(text: 'SignUp as scout'),
      ),
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
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
                      //   child: Text("Sign up as scout",
                      //       style: TextStyle(
                      //           color: ColorApp.richLavender,
                      //           fontSize: 38,
                      //           fontWeight: FontWeight.bold)),
                      // ),
                      SizedBox(height: 19),
                      Center(
                        child: ProfilePictureWidget(
                          pickImage: _userController.pickImage,
                          image: _userController.selectedImage,
                          defaultProfilePicture: _userController.selectedImage.value?.path ?? defaultProfilePicture,
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextFormFieldWidget(
                        text: 'First Name',
                        hint: 'First Name',
                        controller: firstNameController,
                        inputType: TextInputType.text,
                        validator: (value) => _userController.validateField(value!, 'firstName'),
                      ),
                      TextFormFieldWidget(
                        text: 'Last Name',
                        hint: 'Last Name',
                        controller: lastNameController,
                        inputType: TextInputType.text,
                        validator: (value) => _userController.validateField(value!, 'lastName'),
                      ),
                      TextFormFieldWidget(
                        text: 'Email',
                        hint: 'Email',
                        controller: emailController,
                        inputType: TextInputType.emailAddress,
                        validator: (value) => _userController.validateField(value!, 'email'),
                      ),
                      TextFormFieldWidget(
                        text: 'Number Phone',
                        hint: 'Number Phone',
                        controller: phoneController,
                        inputType: TextInputType.phone,
                        validator: (value) => _userController.validateField(value!, 'phone'),
                      ),
                      // استبدال حقل كلمة المرور الحالي بـ PasswordFieldWidget
                      Text(
                        "Password",
                        style: TextStyle(fontSize: 16.0, color: Colors.white),
                      ),
                      SizedBox(height: 12),
                      PasswordFieldWidget(
                        controller: passwordController,
                        validator: (value) => _userController.validateField(value!, 'password'),

                      ),
                      SizedBox(height: 20),
                      // حقل تأكيد كلمة المرور مع زر الإخفاء/الإظهار
                      Text(
                        "Confirm Password",
                        style: TextStyle(fontSize: 16.0, color: Colors.white),
                      ),
                      SizedBox(height: 12),
                      PasswordFieldWidget(
                        controller: confirmPasswordController,
                        validator: (value) => _userController.validateField(value!,
                          'confirmPassword',
                          password: passwordController.text,),
                      ),
                      SizedBox(height: 20),
                      DropDownGender(
                        selectedGender: selectedGender,
                        onChange: (String? newValue) {
                          selectedGender = newValue;
                        },
                        text: 'Select gender',
                        item: const ['Male', 'Female'],
                      ),
                      const SizedBox(height: 20),
                      Obx(() {
                        return Align(
                          alignment: Alignment.centerRight,
                          child: NextButtonWidget(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                if (selectedGender == null) {
                                  // رسالة خطأ إذا لم يتم اختيار الجنس
                                  Get.snackbar('Error', 'Please select a gender.', backgroundColor: Colors.red, colorText: Colors.white);
                                  return; // عدم المتابعة إذا لم يتم اختيار الجنس
                                }

                                UserModel? userModel = _userController.validateAndCreateUser(
                                  firstNameController: firstNameController,
                                  lastNameController: lastNameController,
                                  emailController: emailController,
                                  phoneController: phoneController,
                                  passwordController: passwordController,
                                  selectedGender: selectedGender,
                                  defaultProfilePicture: defaultProfilePicture,
                                  image: _userController.selectedImage.value,
                                  confirmPasswordController: confirmPasswordController,
                                );

                                if (userModel != null) {
                                  await _userController.signUp(userModel).then((_) {
                                    Get.snackbar('Success', 'Create account successfully',
                                    backgroundColor: Colors.green,
                                      colorText: Colors.white
                                    );
                                    Get.toNamed(AppRoutes.homePageScout, arguments: {
                                      'userId' : _userController.currentUserUid.value
                                    });
                                  }).catchError((e) {
                                    print(e);
                                  });
                                }
                              }
                            },
                            loading: _userController.isLoading.value,
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
