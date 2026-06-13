import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:image_picker/image_picker.dart';
import 'package:saoutapp/controllers/controller_coach/player_controller/add_player_controller.dart';

import '../../../routes.dart';

class UpdatePlayerController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final PlayerController _playerController = Get.find<PlayerController>();
  var isLoading = false.obs;
  List<Map<String, dynamic>> achievements = <Map<String, dynamic>>[].obs;
  RxList<Map<String, String>> videos = <Map<String, String>>[].obs;

  // TextEditingControllers for player fields
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController playerNumberController = TextEditingController();
  TextEditingController heightController = TextEditingController();
  TextEditingController weightController = TextEditingController();
  TextEditingController positionController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController imageController = TextEditingController();

  // Player statistics
  var goalsController = 0.obs; // استخدام RxInt بدلاً من int
  var assistsController = 0.obs;
  var shotsOnTargetController = 0.obs;
  var tacklesController = 0.obs;
  var interceptionsController = 0.obs;
  var dribblesCompletedController = 0.obs;
  var yellowCardsController = 0.obs;
  var redCardsController = 0.obs;
  var foulGoalsController = 0.obs;
  var penaltyGoalsController = 0.obs;
  var cleanSheetsController = 0.obs;
  var savesController = 0.obs;
  var penaltiesSavedController = 0.obs;
  var ownGoalsController = 0.obs;
  var goalsConcededController = 0.obs;

  var passAccuracyController = 0.0.obs; // استخدام RxDouble للتمرير الدقيق

  String? coachId;
  String? teamId;
  var selectedType = ''.obs;

  Rx<File?> profileImage = Rx<File?>(null);
  Rx<File?> highlightVideo = Rx<File?>(null);
  final String defaultProfilePicture = 'image/avatarDefault.png';



  Future<void> fetchVideos(String playerId) async {
    try {
      DocumentSnapshot playerDoc = await _firestore.collection('players').doc(playerId).get();

      if (playerDoc.exists) {
        var data = playerDoc.data() as Map<String, dynamic>;
        var rawVideos = data['videos'];

        if (rawVideos is List) {
          for (var video in rawVideos) {
            if (video is Map<String, dynamic>) {
              videos.add({
                'title': video['title'] ?? '',
                'description': video['description'] ?? '',
                'videoUrl': video['videoUrl'] ?? '',
              });
            }
          }
        }
      }
    } catch (e) {
      print('Error fetching videos: $e');
    }
  }

  void updateVideo(int index, String title, String description) {
    if (index >= 0 && index < videos.length) {
      final updatedVideo = Map<String, String>.from(videos[index]);
      updatedVideo['title'] = title;
      updatedVideo['description'] = description;
      videos[index] = updatedVideo; // تحديث القائمة محليًا
      updatePlayerVideosToFirebase(); // مزامنة Firebase
    } else {
      print("Invalid index: $index");
    }
  }


  void removeVideo(int index) {
    if (index >= 0 && index < videos.length) {
      videos.removeAt(index); // إزالة العنصر محليًا
      updatePlayerVideosToFirebase(); // مزامنة Firebase
    } else {
      print("Invalid index: $index");
    }
  }

  Future<void> updatePlayerVideosToFirebase() async {
    try {
      List<Map<String, String>> videoData = videos.map((video) {
        return {
          'title': video['title'] ?? '',
          'description': video['description'] ?? '',
          'videoUrl': video['videoUrl'] ?? '',
        };
      }).toList();

      await _firestore.collection('players').doc(_playerController.playerId.value).update({
        'videos': videoData,
      });
    } catch (e) {
      print('Error updating player videos: $e');
    }
  }



  // دالة لتحديث فيديوهات اللاعب في Firebase
  Future<void> updatePlayerVideos(String playerId) async {
    try {
      await _firestore.collection('players').doc(playerId).update({
        'videos': videos,
      });
    } catch (e) {
      print('Error updating player videos: $e');
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      profileImage.value = File(pickedFile.path);
      update();
    }
  }

  // Function to pick a video
  // Future<void> pickVideo() async {
  //   final picker = ImagePicker();
  //   final pickedFile = await picker.pickVideo(source: ImageSource.gallery);
  //   if (pickedFile != null) {
  //     highlightVideo.value = File(pickedFile.path);
  //     update();
  //   }
  // }

  // Function to upload file to Firebase Storage
  Future<String?> uploadFile(File file, String path) async {
    try {
      Reference storageReference = FirebaseStorage.instance.ref().child(path);
      UploadTask uploadTask = storageReference.putFile(file);
      TaskSnapshot taskSnapshot = await uploadTask;
      return await taskSnapshot.ref.getDownloadURL();

    } catch (e) {
      // Get.snackbar('Error', 'Failed to upload file');
      print(e);
      return null;
    }
  }
  void addAchievement(String? title, String? type, DateTime? date) {
    achievements.add({
      'title': title ?? '',  // إذا كانت القيمة null، استخدم قيمة فارغة.
      'type': type ?? '',    // إذا كانت القيمة null، استخدم قيمة فارغة.
      'date': date ?? DateTime.now(), // إذا كانت القيمة null، استخدم التاريخ الحالي.
    });
    update();
  }


  void removeAchievement(int index) {
    achievements.removeAt(index);
    update();
  }

  void updateAchievement(int index, String title, String type, DateTime date) {
    achievements[index] = {
      'title': title,
      'type': type,
      'date': date,
    };
    update(); // قم بتحديث الحالة بعد تعديل الإنجاز
  }
  // دالة لاسترجاع بيانات اللاعب
  Future<void> fetchPlayerData(String playerId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('players').doc(playerId).get();
      if (doc.exists) {
        var data = doc.data() as Map<String, dynamic>;

        firstNameController.text = data['firstName'] ?? '';
        lastNameController.text = data['lastName'] ?? '';
        playerNumberController.text = data['playerNumber']?.toString() ?? '';
        ageController.text = data['age']?.toString() ?? '';
        cityController.text = data['city'] ?? '';
        heightController.text = data['height']?.toString() ?? '';
        weightController.text = data['weight']?.toString() ?? '';
        profileImage.value = data['image'] ?? '';
        selectedType.value = data['position'] ?? '';

        // إضافة البيانات الجديدة
        goalsController.value = data['goals'] ?? 0;
        assistsController.value = data['assists'] ?? 0;
        shotsOnTargetController.value = data['shotsOnTarget'] ?? 0;
        tacklesController.value = data['tackles'] ?? 0;
        interceptionsController.value = data['interceptions'] ?? 0;
        dribblesCompletedController.value = data['dribblesCompleted'] ?? 0;
        yellowCardsController.value = data['yellowCards'] ?? 0;
        redCardsController.value = data['redCards'] ?? 0;
        foulGoalsController.value = data['foulGoals'] ?? 0;
        penaltyGoalsController.value = data['penaltyGoals'] ?? 0;
        passAccuracyController.value = data['passAccuracy']?.toDouble() ?? 0.0;


        cleanSheetsController.value = data['cleanSheets'] ?? 0;
        savesController.value = data['saves'] ?? 0;
        penaltiesSavedController.value = data['penaltiesSaved'] ?? 0;
        ownGoalsController.value = data['ownGoals'] ?? 0;
        goalsConcededController.value = data['goalsConceded'] ?? 0;
        if (data['image'] != null) {
          profileImage.value = File(data['image']); // أو يمكنك استخدام Image.network إذا كانت URL
        }

        // if (data['videoUrl'] != null) {
        //   highlightVideo.value = File(data['videoUrl']); // أو يمكنك استخدام VideoPlayer إذا كانت URL
        // }


        coachId = data['coachId'];
        teamId = data['teamId'];

        if (data['achievements'] != null) {
          achievements = List<Map<String, dynamic>>.from(data['achievements']);
        }
        update();
      } else {
        print('Player does not exist.');
      }
    } catch (e) {
      print('Error fetching player data: $e');
    }
  }

  // دالة لتحميل صورة اللاعب
  String? getPlayerImageUrl() {
    if (profileImage.value != null) {
      return profileImage.value!.path; // إرجاع مسار الصورة المحلية
    } else {
      return imageController.text; // إرجاع رابط الصورة المخزنة في Firebase إذا كانت موجودة
    }
  }

  Future<String?> uploadFileAsync(List<File> files, String storagePath) async {
    try {
      // تنفيذ التحميل في وقت واحد لكل الملفات باستخدام Future.wait
      final uploadResults = await Future.wait(files.map((file) async {
        final fileName = file.path.split('/').last;
        final ref = FirebaseStorage.instance.ref().child('$storagePath/$fileName');
        final uploadTask = ref.putFile(file);
        final snapshot = await uploadTask.whenComplete(() {});
        return await snapshot.ref.getDownloadURL();
      }));
      return uploadResults.join(',');  // إرجاع قائمة الروابط
    } catch (e) {
      print('Failed to upload files: $e');
      return null;
    }
  }
  Future<String?> uploadVideoToFirebase(File videoFile) async {
    try {
      final fileName = videoFile.path.split('/').last;
      final ref = FirebaseStorage.instance.ref().child('players/videos/$fileName');
      final uploadTask = ref.putFile(videoFile);
      final snapshot = await uploadTask.whenComplete(() {});
      final videoUrl = await snapshot.ref.getDownloadURL();
      return videoUrl;
    } catch (e) {
      print('Failed to upload video: $e');
      return null;
    }
  }

  // دالة لتحديث بيانات اللاعب
  Future<void> updatePlayer() async {
    isLoading.value = true;
    try {
      String? imageUrl = imageController.text; // استخدم الصورة القديمة افتراضيًا

      // رفع الصورة الجديدة إذا تم اختيارها
      if (profileImage.value != null) {
        imageUrl = await uploadFile(
          profileImage.value!,
          'players/${profileImage.value!.path.split('/').last}',
        );
      }

      List<Map<String, String>> videoData = [];
      if (videos.isNotEmpty) {
        List<Future<String?>> uploadTasks = [];
        for (var video in videos) {
          if (video['videoUrl'] != null && video['videoUrl']!.isNotEmpty) {
            uploadTasks.add(uploadVideoToFirebase(File(video['videoUrl']!)));
          }
        }

        final uploadedVideos = await Future.wait(uploadTasks);
        for (int i = 0; i < uploadedVideos.length; i++) {
          if (uploadedVideos[i] != null) {
            videoData.add({
              'title': videos[i]['title']!,
              'description': videos[i]['description']!,
              'videoUrl': uploadedVideos[i]!,
            });
          }
        }
      }

      await _firestore.collection('players').doc(_playerController.playerId.value).update({
        'firstName': firstNameController.text,
        'lastName': lastNameController.text,
        'playerNumber': playerNumberController.text,
        'height': heightController.text,
        'weight': weightController.text,
        'city': cityController.text,
        'age': ageController.text,
        'goals': goalsController.value,
        'assists': assistsController.value,
        'shotsOnTarget': shotsOnTargetController.value,
        'tackles': tacklesController.value,
        'interceptions': interceptionsController.value,
        'dribblesCompleted': dribblesCompletedController.value,
        'yellowCards': yellowCardsController.value,
        'redCards': redCardsController.value,
        'foulGoals': foulGoalsController.value,
        'penaltyGoals': penaltyGoalsController.value,
        'cleanSheets': cleanSheetsController.value,
        'saves': savesController.value,
        'penaltiesSaved': penaltiesSavedController.value,
        'ownGoals': ownGoalsController.value,
        'goalsConceded': goalsConcededController.value,
        'passAccuracy': passAccuracyController.value,
        'position': selectedType.value,
        'image': imageUrl, // استخدام الرابط الجديد أو القديم
        'videos': videoData,
        'achievements': achievements,
      });
      update();
      Get.toNamed(AppRoutes.homePage, arguments: {
        'coachId': _playerController.coachId.value,
        'teamId': _playerController.teamId.value,
      });
    } catch (e) {
      print('Error updating player: $e');
      throw 'Failed to update player profile';
    } finally {
      isLoading.value = false; // إيقاف حالة التحميل
    }
  }

  // دالة لتحديث بيانات اللاعب وإظهار رسالة واحدة فقط
  Future<void> updatePlayerProfile() async {
    try {
      await updatePlayer();

      Get.snackbar('Success', 'Player profile updated successfully.',
          backgroundColor: Colors.green,
          colorText: Colors.white);

    } catch (e) {
      Get.snackbar('Error', 'Player profile not updated successfully.',
          backgroundColor: Colors.red,
          colorText: Colors.white);
      print(e);
    }finally {
      isLoading.value = false; // تعيين حالة التحميل إلى false في النهاية
    }
  }
}
