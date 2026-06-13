import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:saoutapp/controllers/controller_coach/sign_up_coach_controller.dart';


class TeamController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // قاعدة البيانات
  final FirebaseStorage _storage = FirebaseStorage.instance; // إضافة FirebaseStorage
  final CoachController _coachController = Get.put(CoachController());
   // final AddMatchController addMatchController = Get.find();


  var teamId = ''.obs;
  var coachId = ''.obs;
  var selectedTeamType = ''.obs;
  var teamName = ''.obs;
  // var averageAge = 0.0.obs; // متغير لحفظ العمر المتوسط
  var winningMatchesCount = 0.obs;
  RxInt win = 0.obs;




  Rx<double> latitude = 0.0.obs;
  Rx<double> longitude = 0.0.obs;
  Rx<double> agePlayer = 0.0.obs;
  Rx<double> averageAge = 0.0.obs; // متغير لتخزين العمر المتوسط
  // var winningMatchesCountTeam = 0.obs;

  TextEditingController nameTeamController = TextEditingController();
  TextEditingController locationTeamController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  var isLoading = false.obs; // حالة التحميل
  var selectedImage = Rx<File?>(null); // الصورة المختارة

  var team = <Map<String, dynamic>>[].obs;


  // دالة لاختيار الصورة من المعرض
  Future<File?> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      selectedImage.value = File(pickedFile.path); // تحديث الصورة المختارة
      print('Selected image path: ${selectedImage.value!.path}'); // طباعة مسار الصورة المحددة
    } else {
      print('No image selected.');
    }
    return selectedImage.value; // يجب إرجاع الصورة المحددة
  }

  // دالة للتحقق من وجود الصورة
  bool isImageSelected() {
    return selectedImage.value != null;
  }
  Future<bool> isTeamNameAlreadyExist(String teamName) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('team')
          .where('teamName', isEqualTo: teamName)
          .get();
      return querySnapshot.docs.isNotEmpty; // إذا كان هناك مستندات، الاسم موجود بالفعل
    } catch (e) {
      print("Error checking team name: $e");
      return false;
    }
  }
  // دالة لحفظ الصورة في Firebase Storage
  Future<String?> uploadImage(File image) async {
    try {
      // تعيين اسم فريد للصورة
      String filePath = 'teams/${DateTime.now().millisecondsSinceEpoch}.png'; // يمكنك تغيير المسار وفقًا لاحتياجاتك
      UploadTask uploadTask = _storage.ref(filePath).putFile(image);
      TaskSnapshot snapshot = await uploadTask;

      // استرجاع رابط الصورة بعد التحميل
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl; // إعادة الرابط
    } catch (e) {
      print('Error uploading image: $e');
      return null; // في حالة حدوث خطأ
    }
  }

  Future<void> initializePlayersField(String teamId) async {
    try {
      DocumentReference teamDoc = _firestore.collection('team').doc(teamId);
      DocumentSnapshot snapshot = await teamDoc.get();

      if (snapshot.exists) {
        // تحقق من وجود الحقل
        if (!(snapshot.data() as Map<String, dynamic>).containsKey('playersId')) {
          // قم بإضافة الحقل إذا لم يكن موجودًا
          await teamDoc.update({
            'playersId': <String>[], // قائمة فارغة لمعرفات اللاعبين
          });
          print("Field 'playersId' created successfully.");
        } else {
          print("Field 'playersId' already exists.");
        }
      } else {
        print("Team document does not exist.");
      }
    } catch (e) {
      print('Error initializing playersId field: $e');
    }
  }


  // دالة لإنشاء فريق جديد مع الصورة
  Future<void> createTeam() async {
    isLoading.value = true;
    try {
      if (_coachController.coachId.value.isEmpty) {
        String? passedCoachId = Get.arguments['coachId'];
        _coachController.coachId.value = passedCoachId;
            }

      bool isTeamNameExist = await isTeamNameAlreadyExist(nameTeamController.text);
      if (isTeamNameExist) {
        Get.snackbar('Error', 'Team name already exists.',
            backgroundColor: Colors.red, colorText: Colors.white);
        return; // إذا كان الاسم موجودًا بالفعل، لا تستمر في إنشاء الفريق
      }

      String? imageUrl;
      if (isImageSelected()) {
        imageUrl = await uploadImage(selectedImage.value!);
      }

      Map<String, dynamic> teamData = {
        'teamId': teamId.value,
        'coachId': _coachController.coachId.value,
        'teamName': nameTeamController.text,
        'location': locationTeamController.text,
        'description': descriptionController.text,
        'teamType': selectedTeamType.value,
        'image': imageUrl,
        'latitude': latitude.value,
        'longitude': longitude.value,
        'averageAgeOfPlayers': averageAge.value, // استخدم القيمة المحسوبة
        'numberOfWins': winningMatchesCount.value,
      };

      win.value = winningMatchesCount.value;
      DocumentReference docRef = await _firestore.collection('team').add(teamData);
      teamId.value = docRef.id;
      await _firestore.collection('team').doc(teamId.value).update({
        'teamId': teamId.value,
      });
      print('Team ID: ${teamId.value}===============================================');
      await initializePlayersField(teamId.value);
      Get.snackbar('Success', 'Team created successfully.',
          backgroundColor: Colors.green,
          colorText: Colors.white
      );
    } catch (e) {
      print('Error creating team: $e');
      Get.snackbar('Error', 'Failed to create team',
          backgroundColor: Colors.red,
          colorText: Colors.white
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateTeamData(int win) async {
    isLoading.value = true;  // تحديث حالة التحميل

    try {
      // تحقق من القيم التي يتم إرسالها إلى Firestore
      print('Updating team data for team ID: ${teamId.value} with wins: $win');

      // التأكد من أنك تقوم بتحديث البيانات بشكل صحيح
      await _firestore.collection('team').doc(teamId.value).update({
        'numberOfWins': win,  // تأكد من أن هذه القيمة صحيحة
        // أضف أي بيانات أخرى تحتاج إلى تحديثها هنا
      });
      print('Team data updated successfully with numberOfWins: $win');
    } catch (e) {
      print('Error updating team data: $e');
      print('Failed to update team data: numberOfWins $e');
    } finally {
      isLoading.value = false;  // إيقاف حالة التحميل
    }
  }


  Future<void> updateTeamDataAv(double av) async {
    isLoading.value = true; // قم بتحديث حالة التحميل
    try {
      if (teamId.value.isEmpty) {
        print('Team ID is empty, cannot update data.');
        return;
      }

      print('Updating average age for team ID: ${teamId.value} with value: ${av}');
      await _firestore.collection('team').doc(teamId.value).update({
        'averageAgeOfPlayers': av,

      });
      averageAge.value = av;
      print('Team data updated successfully.averageAgeOfPlayers');
      print( 'Team data updated successfully.averageAgeOfPlayers');
      print('Updating average age for team ID: ${teamId.value}');
      print('Average Age before updating: ${averageAge.value}');

    } catch (e) {
      print('Error updating team data:averageAgeOfPlayers $e');
      print('Failed to update team data:averageAgeOfPlayers $e');
    } finally {
      isLoading.value = false; // قم بإيقاف حالة التحميل
    }
  }


  var teamImage = ''.obs;

  Future<void> fetchTeamData() async {
    try {
      var teamData = await _firestore.collection('team').doc(teamId.value).get();
      if (teamData.exists) {
        String? imageUrl = teamData['image'];
        String? name = teamData['teamName'];

        // تحقق من وجود رابط الصورة
        if (imageUrl.isNotEmpty) {
          teamImage.value = imageUrl; // رابط من الإنترنت
        } else {
          teamImage.value = 'image/avatar.png'; // صورة افتراضية إذا لم يوجد رابط
        }
        teamName.value = name ?? 'Unknown Team';
      } else {
        teamImage.value = 'image/avatar.png'; // صورة افتراضية في حال عدم وجود بيانات
        teamName.value = 'Unknown Team';
      }
    } catch (e) {
      print('Error fetching team data: $e');
      teamImage.value = 'image/avatar.png'; // صورة افتراضية في حال حدوث خطأ
    }
  }

  // دالة للتحقق من صحة الحقول
  String? validateField(String value, String fieldType) {
    if (value.isEmpty) {
      return 'This field cannot be empty.';
    }
    if (value.length < 3) { // مثال للتحقق من الطول
      return 'Value must be at least 3 characters.';
    }
    switch (fieldType) {
      case 'teamName':
      case 'location':
      case 'description':
      case 'teamType':
        return null;
      default:
        return null;
    }
  }
}
