import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../models/model_scout/sign_up_model.dart';
import '../../../routes.dart';
import '../../not_controller.dart';

class UserController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var isLoading = false.obs; // حالة التحميل
  var selectedImage = Rx<File?>(null); // حالة الصورة المختارة
  var currentUserUid = ''.obs; // متغير لتخزين معرف المستخدم الحالي
  var followList = <String>[].obs;
  var followTeamList = <String>[].obs;
  RxString loadingPlayerId = ''.obs;
  RxString loadingTeamId = ''.obs;
  RxInt playerCount = 0.obs;

  Future<int> fetchPlayerCount() async {
    QuerySnapshot playerSnapshot = await _firestore.collection('players').get();
    List<QueryDocumentSnapshot> playerDocuments = playerSnapshot.docs;
    return playerDocuments.length;
  }


  @override
  void onInit() {
    super.onInit();
    loadCurrentUserUid(); // تحميل معرف المستخدم عند بدء تشغيل الكونترول
    setupFCM();
    updateFCMToken(currentUserUid.value);
    fetchUserData();
    fetchFirstName();
    getFollowingPlayers();
  }

  void loadCurrentUserUid() {
    currentUserUid.value = _auth.currentUser?.uid ?? '';
  }

  bool isFollowing(String playerId) {
    return followList.contains(playerId);
  }

  bool isFollowingTeam(String teamId) {
    return followTeamList.contains(teamId);
  }


  Future<void> fetchFollowList() async {
    DocumentSnapshot userSnapshot = await _firestore.collection('Users').doc(
        currentUserUid.value).get();

    if (userSnapshot.exists) {
      Map<String, dynamic> userData = userSnapshot.data() as Map<String,
          dynamic>;

      // تحويل القائمة إلى List<String> إذا كانت تحتوي على قيم
      List<dynamic> followData = userData['follow'] ?? [];
      followList.value = followData.map((item) => item.toString()).toList();
    }
  }
  Future<void> fetchFollowListTeam() async {
      DocumentSnapshot userSnapshot = await _firestore.collection('Users').doc(
          currentUserUid.value).get();

      if (userSnapshot.exists) {
        Map<String, dynamic> userData = userSnapshot.data() as Map<String,
            dynamic>;

        // تحويل القائمة إلى List<String> إذا كانت تحتوي على قيم
        List<dynamic> followData = userData['followTeams'] ?? [];
        followTeamList.value = followData.map((item) => item.toString()).toList();
      }
  }


  Future<void> toggleFollowTeams(String userId, String teamId) async {
    loadingTeamId.value = teamId;
    DocumentReference userRef = FirebaseFirestore.instance.collection('Users').doc(userId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot userSnapshot = await transaction.get(userRef);

      if (userSnapshot.exists) {
        Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;
        List<dynamic> followData = userData['followTeams'] ?? [];
        List<String> updatedFollowList = followData.cast<String>();

        if (updatedFollowList.contains(teamId)) {
          updatedFollowList.remove(teamId);
        } else {
          updatedFollowList.add(teamId);
        }

        // تحديث followTeamList هنا
        followTeamList.value = updatedFollowList; // <-- أضف هذا السطر

        transaction.update(userRef, {'followTeams': updatedFollowList});
      }
    });

    loadingTeamId.value = ''; // إعادة تعيين حالة التحميل
  }




  Future<void> toggleFollowPlayer(String userId, String playerId) async {
    loadingPlayerId.value = playerId; // تحديث حالة التحميل للاعب المحدد
    DocumentReference userRef = FirebaseFirestore.instance.collection('Users')
        .doc(userId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot userSnapshot = await transaction.get(userRef);

      if (userSnapshot.exists) {
        Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;
        List<dynamic> followData = userData['follow'] ?? [];
        List<String> updatedFollowList = followData.cast<String>();

        if (updatedFollowList.contains(playerId)) {
          updatedFollowList.remove(playerId);
        } else {
          updatedFollowList.add(playerId);
        }
        transaction.update(userRef, {'follow': updatedFollowList});
      }
    });

    await fetchFollowList();
    loadingPlayerId.value = ''; // إعادة تعيين حالة التحميل
  }





  Future<List<Map<String, dynamic>>> getFollowingPlayers() async {
    List<Map<String, dynamic>> followingPlayers = [];

    // تأكد من أن followList ليست فارغة
    if (followList.isEmpty) {
      return followingPlayers; // إذا كانت القائمة فارغة، قم بإرجاع قائمة فارغة
    }

    // استخدم Future.wait لإجراء جميع الاستعلامات بشكل متزامن
    try {
      final playerSnapshots = await Future.wait(
        followList.map((playerId) =>
            FirebaseFirestore.instance.collection('players')
                .doc(playerId)
                .get()),
      );

      for (DocumentSnapshot playerSnapshot in playerSnapshots) {
        if (playerSnapshot.exists) {
          followingPlayers.add(playerSnapshot.data() as Map<String, dynamic>);
        }
      }
    } catch (e) {
      print("Error fetching following players: $e");
      // يمكن هنا التعامل مع الأخطاء إذا لزم الأمر
    }

    return followingPlayers;
  }


  // دالة لاختيار الصورة من المعرض
  Future<File?> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      selectedImage.value = File(pickedFile.path); // تحديث الصورة المختارة
    }
    return null;
  }

  // تحميل بيانات المستخدم الحالية
  Future<void> loadCurrentUserData() async {
    try {
      currentUserUid.value = _auth.currentUser?.uid ?? '';
      if (currentUserUid.value.isNotEmpty) {
        DocumentSnapshot userDoc = await _firestore.collection('Users').doc(
            currentUserUid.value).get();
        // يمكنك إضافة المزيد من البيانات هنا إذا لزم الأمر
      }
    } catch (e) {
      print("Error loading user data: $e");
    }
  }

  // التحقق من وجود البريد الإلكتروني في قاعدة البيانات
  Future<bool> checkEmailExists(String email) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('Users')
          .where('email', isEqualTo: email)
          .get();
      return querySnapshot.docs
          .isNotEmpty; // إذا كان هناك مستندات، البريد الإلكتروني موجود
    } catch (e) {
      Get.snackbar("Error", "Email already exists",
          backgroundColor: Colors.red,
          colorText: Colors.white
      );
      print("Error checking email");
      print(e);
      return false;
    }
  }

  // التحقق من وجود رقم الهاتف في قاعدة البيانات
  Future<bool> checkPhoneExists(String phone) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('Users')
          .where('phoneNumber', isEqualTo: phone)
          .get();
      return querySnapshot.docs
          .isNotEmpty; // إذا كان هناك مستندات، رقم الهاتف موجود
    } catch (e) {
      Get.snackbar("Error", "Phone number already exists",
          backgroundColor: Colors.red,
          colorText: Colors.white
      );
      print("Error checking phone: $e");
      return false;
    }
  }

  var emailError = ''.obs;
  var phoneError = ''.obs;

  // دالة التسجيل في Firebase

  void saveFCMToken(String userId) async {
    String? token = await FirebaseMessaging.instance.getToken();
    final userDocRef = FirebaseFirestore.instance.collection('Users').doc(
        userId);
    await userDocRef.set({
      'fcmToken': token,
    }, SetOptions(merge: true));
    print("FCM Token saved for user $userId: $token");
    }
  Future<void> addFieldIfNotExists(String userId, String fieldName, dynamic defaultValue) async {
    DocumentReference userRef = _firestore.collection('Users').doc(userId);
    DocumentSnapshot userSnapshot = await userRef.get();

    if (userSnapshot.exists) {
      Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;
      // التحقق مما إذا كان الحقل موجودًا أم لا
      if (!userData.containsKey(fieldName)) {
        await userRef.update({fieldName: defaultValue});
        print("Field '$fieldName' added with default value.");
      }
    }
  }


  Future<void> signUp(UserModel user) async {
    isLoading.value = true; // تفعيل حالة التحميل
    try {
      print("Starting sign-up process..."); // بداية عملية التسجيل

      // التحقق من وجود البريد الإلكتروني
      emailError.value = ''; // إعادة تعيين رسالة الخطأ للبريد الإلكتروني
      phoneError.value = ''; // إعادة تعيين رسالة الخطأ لرقم الهاتف

      // التحقق من وجود البريد الإلكتروني
      if (await checkEmailExists(user.email)) {
        emailError.value = 'Email already exists';
        print("Email already exists: ${user.email}");
      } else {
        print("Email is available: ${user.email}");
      }

      // التحقق من وجود رقم الهاتف
      if (await checkPhoneExists(user.phoneNumber)) {
        phoneError.value = 'Phone number already exists';
        print("Phone number already exists: ${user.phoneNumber}");
      } else {
        print("Phone number is available: ${user.phoneNumber}");
      }

      // إنشاء حساب جديد في Firebase Authentication
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
        email: user.email,
        password: user.password,
      );

      print("User created with UID: ${userCredential.user?.uid}");

      // تعيين معرف المستخدم
      user.uid = userCredential.user?.uid; // تعيين UID هنا
      await addFieldIfNotExists(user.uid!, 'followTeams', []);
      // تحديث المتغير العالمي
      String? profileImageUrl;
      if (selectedImage.value != null) {
        String fileName = "profile_picture_${DateTime.now().millisecondsSinceEpoch}.jpg";
        Reference storageRef = FirebaseStorage.instance
            .ref()
            .child('Users')
            .child(user.uid!)
            .child(fileName); // مسار الصورة داخل مجلد المستخدم

        UploadTask uploadTask = storageRef.putFile(selectedImage.value!);
        TaskSnapshot snapshot = await uploadTask;
        profileImageUrl = await snapshot.ref.getDownloadURL();
      }
      user.profilePicture = profileImageUrl ?? '';

      currentUserUid.value = user.uid!; // حفظ UID في المتغير الخارجي
      print('User UID after signup: ${user.uid}');

      // إعداد بيانات المستخدم مع تعيين userType كـ "Scout"
      user.userType = 'scout'; // تعيين نوع المستخدم هنا

      // حفظ بيانات المستخدم في Firestore
      await _firestore.collection('Users').doc(user.uid).set(user.toJson());
      print('User added to Firestore with UID: ${user.uid}');
      saveFCMToken(currentUserUid.value);
      await PushNotificationsService.setupFirebaseMessaging(
          Get.context!, currentUserUid.value);

      Get.snackbar(
        'Success',
        'User registered successfully.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Error during sign up: $e'); // طباعة الخطأ
      Get.snackbar(
        'Error',
        'Email is already exists',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false; // إنهاء حالة التحميل
    }
  }


  // دالة لتحديث بيانات المستخدم
  Future<void> updateUserProfile({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
  }) async {
    isLoading.value = true;

    try {
      // التحقق من وجود UID للمستخدم الحالي
      if (currentUserUid.value.isEmpty) {
        throw Exception("User is not logged in.");
      }

      // بناء بيانات التحديث
      Map<String, dynamic> updatedData = {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phoneNumber': phone,
        'profilePicture': selectedImage.value != null ? selectedImage.value!
            .path : '',
      };

      // تحديث البيانات في Firestore
      await _firestore.collection('Users').doc(currentUserUid.value).update(
          updatedData);

      Get.snackbar(
        'Success',
        'Profile updated successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print("Error updating profile: $e");
      Get.snackbar(
        'Error',
        'Failed to update profile',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // دالة للتحقق من صحة المدخلات (الحقول)
  String? validateField(String value, String fieldType, {String? password}) {
    if (value.contains(' ')) {
      return 'Spaces are not allowed.'; // تحقق من عدم وجود مسافات
    }

    switch (fieldType) {
      case 'firstName':
        return value.isEmpty ? 'please enter the first name' : null;
      case 'lastName':
        return value.isEmpty ? 'please enter the last name' : null;
      case 'email':
        return !RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
            .hasMatch(value)
            ? 'please enter valid email'
            : null;
      case 'phone':
        return !RegExp(r'^(?:\+966|05)[0-9]{8}$').hasMatch(value)
            ? 'starting with +966 or 05 and must be 10 digits.'
            : null;
      case 'password':
        return value.length < 8
            ? 'please enter valid password, must be more than 8 characters'
            : null;
      case 'confirmPassword':
        if (value.isEmpty) {
          return 'please confirm your password';
        } else if (value != password) {
          return 'Passwords do not match';
        }
        return null;
      case 'gender':
        return value.isEmpty ? 'please select a gender' : null;
      default:
        return null; // إذا كان الحقل غير معروف
    }
  }

  // التحقق من جميع الحقول وبناء نموذج المستخدم
  UserModel? validateAndCreateUser({
    required TextEditingController firstNameController,
    required TextEditingController lastNameController,
    required TextEditingController emailController,
    required TextEditingController phoneController,
    required TextEditingController passwordController,
    required TextEditingController confirmPasswordController,
    required String? selectedGender,
    required String defaultProfilePicture,
    required File? image,
  }) {
    // التحقق من صحة جميع المدخلات
    if (validateField(firstNameController.text, 'firstName') != null ||
        validateField(lastNameController.text, 'lastName') != null ||
        validateField(emailController.text, 'email') != null ||
        validateField(phoneController.text, 'phone') != null ||
        validateField(passwordController.text, 'password') != null ||
        validateField(confirmPasswordController.text, 'confirmPassword',
            password: passwordController.text) != null ||
        validateField(selectedGender ?? '', 'gender') != null) {
      return null; // إذا كان هناك خطأ
    }

    // بناء نموذج المستخدم إذا كانت المدخلات صحيحة
    return UserModel(
      uid: currentUserUid.value,
      firstName: firstNameController.text.trim(),
      lastName: lastNameController.text.trim(),
      email: emailController.text.trim(),
      phoneNumber: phoneController.text.trim(),
      password: passwordController.text.trim(),
      profilePicture: image?.path ?? defaultProfilePicture,
      gender: selectedGender!,
      code: '',
      userType: 'Scout',
      follow: [],
      followTeams: [],
    );
  }

  var firstName = ''.obs;


  Future<Map<String, String>> fetchFirstName() async {
    User? user = _auth.currentUser; // المستخدم الحالي
    if (user != null) {
      // جلب بيانات المستخدم من Firestore
      DocumentSnapshot userDoc = await _firestore.collection('Users').doc(user.uid).get();
      if (userDoc.exists) {
        // جلب الاسم الأول وصورة البروفايل
        String firstName = userDoc['firstName'] ?? 'User'; // إذا لم تكن القيمة موجودة
        String lastName = userDoc['lastName'] ?? ''; // إذا لم تكن القيمة موجودة
        String profilePicture = userDoc['profilePicture'] ?? ''; // رابط صورة البروفايل
        String email = userDoc['email'] ?? ''; // رابط صورة البروفايل
        return {
          'firstName': firstName,
          'lastName' : lastName,
          'email' : email,
          'profilePicture': profilePicture,
        };
      }
    }
    // في حالة عدم وجود مستخدم أو البيانات
    return {
      'firstName': 'User',
      'profilePicture': '', // قيمة افتراضية
    };
  }

  void loadUserData() async {
    Map<String, String> userData = await fetchFirstName();
    String firstName = userData['firstName'] ?? 'User';
    String profilePicture = userData['profilePicture'] ?? '';

    print('First Name: $firstName');
    print('Profile Picture: $profilePicture');
  }

  void fetchUserData() async {
    try {
      User? user = _auth.currentUser; // الحصول على المستخدم الحالي
      if (user != null) {
        DocumentSnapshot userDoc = await _firestore.collection('Users').doc(
            user.uid).get();
        if (userDoc.exists) {
          firstName.value = userDoc['firstName'] ?? 'User'; // تعيين الاسم الأول

          // جلب حقل follow كقائمة من المعرفات
          List<String> followedPlayerIds = List<String>.from(
              userDoc['follow'] ?? []);
          // followingPlayers.clear(); // مسح القائمة الحالية
          // جلب تفاصيل اللاعبين المتابعين
          for (String playerId in followedPlayerIds) {
            DocumentSnapshot playerDoc = await _firestore.collection('players')
                .doc(playerId)
                .get();
            if (playerDoc.exists) {
              // followingPlayers.add(playerDoc.data() as Map<String, dynamic>);
            }
          }
        }
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();

      Get.snackbar('Success', 'Logged out successfully.',
          backgroundColor: Colors.green,
          colorText: Colors.white
      );
      Get.offNamed(
          AppRoutes.chooseUser); // إعادة التوجيه إلى صفحة اختيار المستخدم
    } catch (e) {
      print('Error logging out: $e');
      Get.snackbar('Error', 'Failed to log out: $e');
    }
  }

  Future<void> updateFCMToken(String userId) async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // الحصول على الرمز الحالي
    String? fcmToken = await messaging.getToken();

    // تحديث رمز FCM في قاعدة البيانات
    await FirebaseFirestore.instance.collection('Users').doc(userId).update({
      'fcmToken': fcmToken,
    });
    }
  void setupFCM() {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // استمع للتحديثات على رمز FCM
    messaging.onTokenRefresh.listen((newToken) async {
      // تحديث رمز FCM في قاعدة البيانات
      await updateFCMToken(
          currentUserUid.value); // استخدم المعرف الحالي للمستخدم
    });
  }

}