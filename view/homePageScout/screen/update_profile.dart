import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:saoutapp/controllers/controller_scout/controller_scout_auth/user_controller.dart';
import 'package:saoutapp/core/loading.dart';
import '../../../controllers/controller_scout/controller_scout_auth/update_user.dart';
import '../../../core/color.dart';
import '../../../routes.dart';
import '../../homePage/widget/text_title_add_player.dart';
import '../../signup/signupScout/widget/text_form_field_widget.dart';
import '../widget/bottom_navigation.dart';

class UpdateProfile extends StatefulWidget {
  const UpdateProfile({super.key});

  @override
  State<UpdateProfile> createState() => _UpdateProfileState();
}

class _UpdateProfileState extends State<UpdateProfile> {
  final UpdateUserController updateUserController = Get.put(UpdateUserController());
  String _selectedTab = 'Profile'; // حالة الزر المختار
  final UserController userController = Get.find<UserController>();

  @override
  void initState() {
    super.initState();
    String? userId = Get.arguments['userId']; // جلب المعرف
    print("prrooo $userId");
    userController.currentUserUid.value = userId;
    updateUserController.loadUserData();  // استخدم دالة جلب البيانات
    }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>(); // مفتاح النموذج

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorApp.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white10,
        title: TextTitleAddPlayer(text: 'My Profile'),

      ),
      body: Obx(() {
        if (updateUserController.isLoading.value) {
          return Loading();
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 22),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: GestureDetector(
                    onTap: () async {
                      await updateUserController.pickImage(); // استدعاء دالة اختيار الصورة
                    },
                    child: Obx(() {
                      return CircleAvatar(
                        radius: 50,
                        backgroundImage: _getImageProvider(updateUserController.profilePictureUrl.value),
                        child: updateUserController.profilePictureUrl.value.isEmpty
                            ? Icon(Icons.add_a_photo, size: 30, color: Colors.white)
                            : null,
                      );
                    }),
                  ),
                ),

                SizedBox(height: 20),
                TextFormFieldWidget(
                  text: 'First Name',
                  hint: 'First Name',
                  controller: updateUserController.firstNameController,
                  validator: (value) => userController.validateField(value!, "firstName"),
                ),
                TextFormFieldWidget(
                  text: 'Last Name',
                  hint: 'Last Name',
                  controller: updateUserController.lastNameController,
                  validator: (value) => userController.validateField(value!, "lastName"),
                ),
                TextFormFieldWidget(
                  text: 'Phone number',
                  hint: 'Phone number',
                  controller: updateUserController.phoneNumberController,
                  inputType: TextInputType.phone,
                  validator: (value) => userController.validateField(value!, "phone"),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          updateUserController.updateUser(userController.currentUserUid.value);
                        }
                      },
                      style: ButtonStyle(backgroundColor: WidgetStateProperty.all(ColorApp.oasisGreen)),
                      child: Text('Update Profile', style: TextStyle(color: Colors.white),),
                    ),
                    // ElevatedButton(
                    //   onPressed: () {
                    //     _showLogoutConfirmationDialog(context);
                    //   },
                    //   child: Text(
                    //     'Log out',
                    //     style: TextStyle(color: Colors.red),
                    //   ),
                    // ),
                  ],
                ),
              ],
            ),
          ),
        );
      }),
      bottomNavigationBar: BottomNavigationBarWidgetScout(
        selectedTab: _selectedTab,
        onTabSelected: (tab) => setState(() => _selectedTab = tab),
      ),
    );
  }
  
  ImageProvider _getImageProvider(String imageUrl) {
    if (imageUrl.isNotEmpty) {
      if (imageUrl.startsWith('http')) {
        return NetworkImage(imageUrl);
      } else {
        return FileImage(File(imageUrl));
      }
    } else {
      return AssetImage('image/avatarDefault.png');
    }
  }

}
