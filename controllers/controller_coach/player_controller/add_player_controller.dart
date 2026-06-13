import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:saoutapp/controllers/controller_scout/controller_scout_auth/user_controller.dart';
import 'package:saoutapp/routes.dart';
import 'package:saoutapp/view/homePage/screen/add_player/player_statistics.dart';
import '../team_controller.dart';
import '../sign_up_coach_controller.dart';
import 'notify_player.dart';

class PlayerController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TeamController _teamController = Get.put(TeamController());
  final CoachController _coachController = Get.find();
  final UserController userController = Get.put(UserController());
  final NotifyPlayerController notifyPlayerController = Get.put(NotifyPlayerController());


  List<Map<String, dynamic>> filterPlayersByAge(List<Map<String, dynamic>> players, int age) {
    return players.where((player) => player['age'] == age).toList();
  }

  // Controller variables
  var selectedType = ''.obs;
  var playerId = ''.obs;
  var coachId = ''.obs;
  var teamId = ''.obs;
  var isLoading = false.obs;
  void clearPlayerData() {
    playerId.value = '';
    firstNameController.clear();
    lastNameController.clear();
    playerNumberController.clear();
    heightController.clear();
    weightController.clear();
    ageController.clear();
    cityController.clear();
    goals.value = 0;
    assists.value = 0;
    shotsOnTarget.value = 0;
    tackles.value = 0;
    interceptions.value = 0;
    dribblesCompleted.value = 0;
    yellowCards.value = 0;
    redCards.value = 0;
    foulGoals.value = 0;
    penaltyGoals.value = 0;
    cleanSheets.value = 0;
    saves.value = 0;
    penaltiesSaved.value = 0;
    ownGoals.value = 0;
    goalsConceded.value = 0;
    passAccuracy.value = 0;
    // إذا كنت تستخدم متغيرات أخرى، تأكد من مسحها أيضًا
    profileImage.value = null; // مسح صورة البروفايل
    // highlightVideo.value = null; // مسح الفيديو
    selectedType.value = ''; // مسح نوع اللاعب
    achievements.clear();
    videos.clear();

  }


  // @override
  // void onInit() {
  //   super.onInit();
  //   fetchPlayers();
  // }
  // TextEditingControllers for input
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController playerNumberController = TextEditingController();
  TextEditingController heightController = TextEditingController();
  TextEditingController weightController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController cityController = TextEditingController();

  // Player statistics
  var goals = 0.obs;
  var assists = 0.obs;
  var shotsOnTarget = 0.obs;
  var tackles = 0.obs;
  var interceptions = 0.obs;
  var dribblesCompleted = 0.obs;
  var yellowCards = 0.obs;
  var redCards = 0.obs;
  var foulGoals = 0.obs;
  var penaltyGoals = 0.obs;
  Rx<double> passAccuracy = 0.0.obs;
   var achievements =  <Map<String, dynamic>>[].obs;


  // Goalkeeper statistics
  var cleanSheets = 0.obs;
  var saves = 0.obs;
  var penaltiesSaved = 0.obs;
  var ownGoals = 0.obs;
  var goalsConceded = 0.obs;

  Rx<File?> profileImage = Rx<File?>(null);
  final String defaultProfilePicture = 'image/avatar.png';
// قائمة تحتوي على فيديوهات اللاعب
  var videos = <Map<String, String>>[].obs; // كل خريطة تحتوي على title, description, videoUrl.

  var playersList = [].obs;


  Future<void> addPlayerToTeam(String playerId) async {
    try {
      await _firestore.collection('team').doc(teamId.value).update({
        'playersId': FieldValue.arrayUnion([playerId]) // إضافة اللاعب
      });
      print("Player added to team's playersId successfully.");
    } catch (e) {
      print("Error adding player to team's playersList: $e");
    }
  }




  // Function to calculate the average age of players

  double getAverageAge() {
    if (playersList.isEmpty) return 0.0; // Return 0 if the list is empty

    double totalAge = 0;
    for (var player in playersList) {
      if (player.containsKey('age') && player['age'] != null) {
        // تحقق من أن القيمة ليست فارغة
        try {
          totalAge += double.parse(player['age'].toString()); // تحويل القيمة إلى num
          // _updateAverageAgeOfPlayers();
        } catch (e) {
          print('Error parsing age for player: $player. Error: $e');
        }
      }
    }
    _teamController.updateTeamDataAv(totalAge / playersList.length);
    return totalAge / playersList.length; // حساب المتوسط
  }



  List<Map<String, dynamic>> filterAndSortPlayers(List<Map<String, dynamic>> players, {int? ageFilter, bool sortByGoals = false, bool sortByAssists = false}) {
    List<Map<String, dynamic>> filteredPlayers = players.where((player) {
      if (ageFilter != null) {
        return player['age'] == ageFilter;
      }
      return true;
    }).toList();

    if (sortByGoals) {
      filteredPlayers.sort((a, b) => b['goals'].compareTo(a['goals']));
    } else if (sortByAssists) {
      filteredPlayers.sort((a, b) => b['assists'].compareTo(a['assists']));
    }

    return filteredPlayers;
  }



  // Fetch players function
  Future<void> fetchPlayers(String coachId, String teamId) async {
    if (coachId.isEmpty || teamId.isEmpty) {
      print("Error: Coach ID or Team ID is missing.");
      return;
    }

    try {
      // استعلام لجلب اللاعبين الذين ينتمون للمدرب والفريق المحددين
      QuerySnapshot snapshot = await _firestore
          .collection('players')
          .where('coachId', isEqualTo: coachId)
          .where('teamId', isEqualTo: teamId)
          .get();

      playersList.clear();

      // حلقة عبر الوثائق المسترجعة
      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>?;

        // التحقق من وجود بيانات اللاعب
        if (data != null) {
          // التحقق من وجود playerId وتحديثه إذا كان مفقودًا
          if (!data.containsKey('playerId')) {
            await doc.reference.update({
              'playerId': doc.id, // إضافة playerId
            });
            print('Updated player with ID: ${doc.id}'); // طباعة معرف اللاعب المحدث
          }


          playersList.add(data); // إضافة بيانات اللاعب إلى القائمة
        } else {
          print("No data found for player ID: ${doc.id}"); // طباعة إذا كانت البيانات غير موجودة
        }
      }

      print("Total players fetched: ${playersList.length}"); // طباعة إجمالي عدد اللاعبين المسترجعين
      update(); // تحديث الحالة بعد جلب البيانات
    } catch (e) {
      print('Error fetching players: $e'); // طباعة الأخطاء في حالة الفشل
      // Get.snackbar('Error', 'Failed to fetch players');
    }
  }



  Future<void> requestStoragePermission() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
  }

  // Function to pick an image
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      profileImage.value = File(pickedFile.path);
      update();
    }
  }


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

  // Function to validate inputs and proceed
  Future<void> validateAndProceed() async {

    try {
      // التحقق من عدم وجود حقول فارغة
      if (firstNameController.text.isEmpty ||
          lastNameController.text.isEmpty ||
          playerNumberController.text.isEmpty ||
          ageController.text.isEmpty ||
          heightController.text.isEmpty ||
          weightController.text.isEmpty ||
          cityController.text.isEmpty||
          selectedType.value.isEmpty
      ) {
        return;
      }

      // التحقق من صحة رقم اللاعب
      int playerNumber = int.tryParse(playerNumberController.text) ?? -1;
      if (playersList.any((player) => player['playerNumber'] == playerNumber)) {
        Get.snackbar('Error', 'Player number already exists.',
        backgroundColor: Colors.red,
          colorText: Colors.white
        );
        return;
      }

      // التحقق من عمر اللاعب
      int age = int.tryParse(ageController.text) ?? 0;
      if (age < 6 || age > 18) {
          print("Age must be between 6 and 18 years");
        return;
      }

      // الانتقال إلى الصفحة التالية بناءً على نوع اللاعب
      if (selectedType.value == 'Goalkeeper') {
        print("$coachId goalllllllllllllllllllllllllllllllllllllllllllllllllll");
        print("$teamId goalllllllllllllllllllllllllllllllllllllllllllllllllll");
        Get.toNamed(AppRoutes.goalKeeperStatistics, arguments: {
          'coachId': coachId.value,
          'teamId': teamId.value,
        });
      } else {
        // Get.toNamed(AppRoutes.playerStatistics);
        Future.delayed(Duration(milliseconds: 20), () {
          Get.to(() => PlayerStatistics(),
              transition: Transition.rightToLeft,
              duration: const Duration(milliseconds: 770));
        });
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to validate inputs.',
          backgroundColor: Colors.red,
          colorText: Colors.white
      );
      print(e);
    }
  }

  void addAchievement(String title, String type, DateTime date) {
    achievements.add({
      'title': title,
      'type': type,
      'date': date.toIso8601String(),
    });
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

  // Function to add player
  Future<void> addPlayer(BuildContext context) async {
    try {
      if (_coachController.coachId.value.isEmpty || _teamController.teamId.value.isEmpty) {

        print('Coach ID or Team ID cannot be empty.');
        return;
      }

      print("Coach ID: ${_coachController.coachId.value}");
      print("Team ID: ${_teamController.teamId.value}");

      QuerySnapshot existingPlayers = await _firestore.collection('players')
          .where('playerNumber', isEqualTo: int.parse(playerNumberController.text))
          .where('teamId', isEqualTo: _teamController.teamId.value)
          .get();

      if (existingPlayers.docs.isNotEmpty) {
        Get.snackbar('Error', 'Player with this number already exists in the team.');
        return;
      }

      String? imageUrl;

      // Upload image and video
      if (profileImage.value != null) {
        imageUrl = await uploadFile(profileImage.value!, 'players/${profileImage.value!.path.split('/').last}');
      }



      // if (highlightVideo.value != null) {
      //   videoUrl = await uploadFile(highlightVideo.value!, 'players/videos/${highlightVideo.value!.path.split('/').last}');
      // }
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

      // Ensure non-negative statistics
      goals.value = goals.value < 0 ? 0 : goals.value;
      assists.value = assists.value < 0 ? 0 : assists.value;
      shotsOnTarget.value = shotsOnTarget.value < 0 ? 0 : shotsOnTarget.value;
      tackles.value = tackles.value < 0 ? 0 : tackles.value;
      interceptions.value = interceptions.value < 0 ? 0 : interceptions.value;
      dribblesCompleted.value = dribblesCompleted.value < 0 ? 0 : dribblesCompleted.value;
      yellowCards.value = yellowCards.value < 0 ? 0 : yellowCards.value;
      redCards.value = redCards.value < 0 ? 0 : redCards.value;
      foulGoals.value = foulGoals.value < 0 ? 0 : foulGoals.value;
      penaltyGoals.value = penaltyGoals.value < 0 ? 0 : penaltyGoals.value;

      Map<String, dynamic> playerData = {
        'playerId': playerId.value,
        'coachId': _coachController.coachId.value,
        'teamId': _teamController.teamId.value,
        'firstName': firstNameController.text,
        'lastName': lastNameController.text,
        'playerNumber': int.parse(playerNumberController.text),
        'height': double.parse(heightController.text),
        'weight': double.parse(weightController.text),
        'position': selectedType.value,
        'city': cityController.text,
        'goals': goals.value,
        'assists': assists.value,
        'shotsOnTarget': shotsOnTarget.value,
        'tackles': tackles.value,
        'interceptions': interceptions.value,
        'passAccuracy': passAccuracy.value,
        'dribblesCompleted': dribblesCompleted.value,
        'yellowCards': yellowCards.value,
        'redCards': redCards.value,
        'foulGoals': foulGoals.value,
        'penaltyGoals': penaltyGoals.value,
        'age': int.parse(ageController.text),
        'image': imageUrl,
        'videoUrl' : videoData,
        'cleanSheets': cleanSheets.value,
        'saves': saves.value,
        'penaltiesSaved': penaltiesSaved.value,
        'ownGoals': ownGoals.value,
        'goalsConceded': goalsConceded.value,
        'achievements':  achievements.toList(),
      };

      DocumentReference docRef = await _firestore.collection('players').add(playerData);
      playerId.value = docRef.id; // هنا يتم تخزين المعرف التلقائي في المتغير playerId
      await docRef.update({'playerId': docRef.id});

      coachId.value = _coachController.coachId.value;
      teamId.value = _teamController.teamId.value;
      await addPlayerToTeam(playerId.value);
      print("Player ID after adding:=================================================================================== ${playerId.value}");
      await notifyPlayerController.notifyFollowersOnPlayerAdded(
        teamId.value,
        playerId.value,
        context,
      );
      clearPlayerData();
      Get.snackbar('Success', 'Player added successfully.',
      backgroundColor: Colors.green,
        colorText: Colors.white
      );
      print("${playerId} =========================================================playerid");
      print("${firstNameController} =========================================playerid");
      Get.toNamed(AppRoutes.homePage, arguments: {
        'playerId' : playerId.value,
        'coachId': coachId.value,
        'teamId': teamId.value,
      });
    } catch (e) {
      Get.snackbar('Error', 'Failed to add player',
          backgroundColor: Colors.red,
          colorText: Colors.white
      );
      print(e);
    }
  }

// Function to get the number of players
  int getNumberOfPlayers() {
    return playersList.length;
  }


  var playersListMatch = <Map<String, dynamic>>[].obs; // تأكد من أن نوع البيانات صحيح

  // دالة لجلب اللاعبين
  void fetchPlayersMatch(String teamId) async {
  try {
  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection('players')
      .where('teamId', isEqualTo: teamId)
      .get();

  // تحديث قائمة اللاعبين
  playersList.assignAll(snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList());
  print("Players fetched: ${playersList.length}");
  } catch (e) {
  print("Error fetching players: $e");
  }
  }

}
