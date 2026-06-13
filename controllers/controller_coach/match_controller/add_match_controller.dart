import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:saoutapp/controllers/controller_coach/sign_up_coach_controller.dart';
import 'package:saoutapp/controllers/controller_coach/team_controller.dart';
import 'package:saoutapp/routes.dart';
import 'package:http/http.dart' as http;

class AddMatchController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TeamController _teamController = Get.put(TeamController());
  final CoachController _coachController = Get.put(CoachController());

  var selectedFormations = '4-4-1-1'.obs;
  var coachId = ''.obs;
  var teamId = ''.obs;
  var matchId = ''.obs;
  var isLoading = false.obs;
  var teamName = ''.obs;
  Rx<File?> opponentTeamImage = Rx<File?>(null);



  TextEditingController opposingTeamController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController myResultController = TextEditingController(); // نتيجة فريقك
  TextEditingController opponentResultController = TextEditingController(); // نتيجة الفريق المنافس
  Rx<double> latitude = 0.0.obs;
  Rx<double> longitude = 0.0.obs;
  var goals = 0.obs;

  // var selectedGoalScorers = <String>[].obs;
  var selectedAssistProviders = <String>[].obs;

  var selectedPlayerIDs = <String>[].obs;
  Rx<int> winningMatchesCount = 0.obs;


  // قائمة لتخزين المباريات
  var matches = <Map<String, dynamic>>[].obs;

  var goalsList = <Map<String, dynamic>>[].obs; // تأكد من هذه السطر
  var isOffline = false.obs;  // المتغير لحالة الاتصال

  // دالة للتحقق من الاتصال بالإنترنت
  Future<bool> checkInternetConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;  // إذا كان هناك اتصال
  }

  // متغيرات لتخزين رسائل الخطأ
  var dateError = ''.obs;
  var resultError = ''.obs;
  var totalMatchesCount = 0.obs; // عدد المباريات
  int getTotalMatchesCount() {
    return totalMatchesCount.value;
  }


  void updateFormation(String newFormation) {
    selectedFormations.value = newFormation;
    selectedPlayerIDs.clear();
    print("تم تحديث التشكيلة: $newFormation. قائمة اللاعبين تم تفريغها.");
  }

  bool addPlayer(String playerId) {
    if (!selectedPlayerIDs.contains(playerId)) {
      selectedPlayerIDs.add(playerId);
      print("تم اختيار اللاعب: $playerId");
      return true;  // عملية الإضافة ناجحة
    } else {
      Get.snackbar('Error', 'Player already selected.',
          backgroundColor: Colors.red,
          colorText: Colors.white
      );
      return false;  // عملية الإضافة فشلت لأن اللاعب موجود بالفعل
    }
  }

  var selectedDate = ''.obs;
  var selectedTime = ''.obs;

  // دالة لاختيار التاريخ
  Future<void> selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      selectedDate.value = "${pickedDate.year}-${pickedDate.month}-${pickedDate.day}";
      updateMatchDateTime();
    }
  }

  // دالة لاختيار الوقت
  Future<void> selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      selectedTime.value = "${pickedTime.hour}:${pickedTime.minute}";
      updateMatchDateTime();
    }
  }
  DateTime? matchDateTime;

  void updateMatchDateTime() {
    if (selectedDate.isNotEmpty && selectedTime.isNotEmpty) {
      matchDateTime = DateTime(
        int.parse(selectedDate.value.split('-')[0]), // year
        int.parse(selectedDate.value.split('-')[1]), // month
        int.parse(selectedDate.value.split('-')[2]), // day
        int.parse(selectedTime.value.split(':')[0]), // hour
        int.parse(selectedTime.value.split(':')[1]), // minute
      );
      print("Match DateTime: $matchDateTime");
    } else {
      print("Date or Time is not selected yet");
    }
  }


  // Future<void> compareResults() async {
  //   // محاولة تحويل المدخلات إلى أعداد صحيحة
  //   int? myResult = int.tryParse(myResultController.text);
  //   int? opponentResult = int.tryParse(opponentResultController.text);
  //
  //   // إذا كانت القيم المدخلة غير صالحة (لا يمكن تحويلها إلى أعداد صحيحة)
  //   if (myResult == null || opponentResult == null) {
  //     // إظهار رسالة تنبيه في حال كانت المدخلات غير صحيحة
  //     Get.snackbar('Error', 'Please enter valid numeric results');
  //     print('Invalid input: myResult = $myResult, opponentResult = $opponentResult');
  //     return;
  //   }
  //
  //   print('My Result: $myResult');
  //   print('Opponent Result: $opponentResult');
  //
  //   // إذا كانت النتيجة الخاصة بك أكبر من نتيجة الفريق المنافس
  //   if (myResult > opponentResult) {
  //     winningMatchesCount.value++; // زيادة العداد
  //     print('New Winning Matches Count: ${winningMatchesCount.value}');
  //     await _teamController.updateTeamData(winningMatchesCount.value);
  //   }
  //   // إذا كانت نتيجة الفريق المنافس أكبر
  //   else if (myResult < opponentResult) {
  //     print('${opposingTeamController.text} is the winner!');
  //   }
  //   // إذا كانت النتيجتين متساويتين
  //   else {
  //     print('The result is a draw!');
  //   }
  // }




  void addGoal(int index, int minute, String playerId) {
    // تحديث الهدف في القائمة إذا كان موجوداً، أو إضافته إذا لم يكن كذلك
    if (index < goalsList.length) {
      goalsList[index] = {
        'minute': minute,
        'playerId': playerId,
      };
    } else {
      goalsList.add({
        'minute': minute,
        'playerId': playerId,
      });
    }
    print("Goal added/updated: minute $minute, playerId $playerId");
  }

  Future<String?> uploadFile(File file, String path) async {
    try {
      Reference storageReference = FirebaseStorage.instance.ref().child(path);
      UploadTask uploadTask = storageReference.putFile(file);
      TaskSnapshot taskSnapshot = await uploadTask;
      return await taskSnapshot.ref.getDownloadURL();
    } catch (e) {
      Get.snackbar('Error', 'Failed to upload file');
      print(e);
      return null;
    }
  }
  void loadOpponentImage(String imageUrl) async {
    try {
      // تحميل الصورة من الرابط وحفظها في المتغير كـ File
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/opponent_image.png');
        await file.writeAsBytes(bytes);
        opponentTeamImage.value = file;
      }
    } catch (e) {
      print("Error loading image: $e");
    }
  }

  Future<void> addMatch(BuildContext context) async {
    try {
      print("خطوة 1: التحقق من معرف المدرب والفريق.");
      if (_coachController.coachId.value.isEmpty || _teamController.teamId.value.isEmpty) {
        String? passedCoachId = Get.arguments['coachId'];
        String? passedTeamId = Get.arguments['teamId'];

        if (passedTeamId != null) {
          _coachController.coachId.value = passedCoachId;
          _teamController.teamId.value = passedTeamId;
        } else {
          print('خطأ: معرف المدرب أو الفريق فارغ.');
          return;
        }
      }
      String? imageUrl;

      // Upload image and video
      if (opponentTeamImage.value != null) {
        imageUrl = await uploadFile(opponentTeamImage.value!, 'matches/${opponentTeamImage.value!.path.split('/').last}');
      }

      resultError.value = '';

      // print("خطوة 2: إعداد نتائج المباراة.");
      int myResult = int.tryParse(myResultController.text) ?? 0;
      int opponentResult = int.tryParse(opponentResultController.text) ?? 0;
      print("${winningMatchesCount.value} theerrrreee");

      if (myResult > opponentResult) {
        winningMatchesCount.value++; // زيادة العداد
        print('New Winning Matches Count: ${winningMatchesCount.value}');
        await _teamController.updateTeamData(winningMatchesCount.value);
      } else if (myResult < opponentResult) {
        print('${opposingTeamController.text} is the winner!');
      } else {
        print('The result is a draw!');
      }

      if (matchDateTime != null) {
        Timestamp matchTimestamp = Timestamp.fromDate(matchDateTime!);
        print('تاريخ ووقت المباراة: $matchTimestamp');

        Map<String, dynamic> matchData = {
          'matchID': matchId.value,
          'matchLocation': locationController.text,
          'matchDate': matchTimestamp,
          'matchFormation': selectedFormations.value,
          'myResult': myResult,
          'opponentResult': opponentResult,
          'teamID': _teamController.teamId.value,
          'coachID': _coachController.coachId.value,
          'playerIDs': selectedPlayerIDs,
          'opponentTeamName': opposingTeamController.text,
          'winningMatchesCount': winningMatchesCount.value,
          'latitude': latitude.value,
          'longitude': longitude.value,
          'assisters': selectedAssistProviders,
          'goalsList': goalsList.toList(),
          'opponentTeamImage': imageUrl,
        };
        DocumentReference docRef = await FirebaseFirestore.instance.collection('matches').add(matchData);

        matchId.value = docRef.id;
        print("تم توليد معرف المباراة الفريد: $matchId");

         await _firestore.collection('matches').doc(matchId.value).update({
                'matchID': matchId.value,
              });

        // خطوة إضافة المباراة إلى قاعدة البيانات
        print("خطوة 3: إضافة المباراة إلى قاعدة البيانات.");
        await FirebaseFirestore.instance.collection('matches').add(matchData);
        print("تمت إضافة المباراة إلى قاعدة البيانات بنجاح.");

        // إرسال إشعارات للمتابعين
        // await sendNotificationsToFollowers(selectedPlayerIDs, context);

        Get.snackbar('Success', 'Match added successfully', backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        Get.snackbar('Field', 'Match not add successfully', backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      print("خطأ أثناء إضافة المباراة: $e");
      // Get.snackbar('خطأ', 'فشل في إضافة المباراة: $e', backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> fetchMatches(String coachId, String teamId) async {
    try {
      // التحقق من الاتصال قبل البدء في جلب البيانات
      bool isOnline = await checkInternetConnection();
      if (!isOnline) {
        isOffline.value = true;  // تغيير حالة الاتصال إلى غير متصل
        Get.snackbar(
          'No Internet',
          'Please check your internet connection and try again.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;  // إيقاف عملية جلب البيانات إذا لم يكن هناك اتصال
      } else {
        isOffline.value = false;  // حالة متصل
      }

      isLoading.value = true;  // بدء تحميل البيانات
      print("Fetching matches for coachID: $coachId and teamID: $teamId");

      if (coachId.isEmpty || teamId.isEmpty) {
        print("Error: Coach ID or Team ID is missing.");
        return;
      }

      var querySnapshot = await _firestore
          .collection('matches')
          .where('coachID', isEqualTo: coachId)
          .where('teamID', isEqualTo: teamId)
          .get();

      // معالجة البيانات المسترجعة
      matches.clear();
      totalMatchesCount.value = querySnapshot.docs.length;

      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> matchData = doc.data() as Map<String, dynamic>;
        matchData['matchID'] = doc.id;

        // احصل على بيانات الفريق من TeamController
        matchData['teamName'] = _teamController.teamName.value;
        matchData['teamImage'] = _teamController.teamImage.value;

        if (matchData['teamName'] == '') {
          matchData['teamName'] = 'Unknown Team';
        }

        matches.add(matchData);
        print("Match ID: ${doc.id}, Match Data: $matchData");
      }

      isLoading.value = false;  // انتهى تحميل البيانات
      print("Total Matches Count: ${totalMatchesCount.value}");
    } catch (e) {
      isLoading.value = false;  // إنهاء عملية التحميل في حال حدوث خطأ
      print('Error fetching matches: $e');
      Get.snackbar('Error', 'Failed to fetch matches');
    }
  }


  // هنا تأتي الدالة الأخرى
  Future<void> deleteMatch(String matchId) async {
    if (matchId.isEmpty) {
     print('Match ID cannot be empty.');
      return;
    }

    try {
      DocumentSnapshot matchDoc = await _firestore.collection('matches').doc(matchId).get();

      if (matchDoc.exists) {
        await _firestore.collection('matches').doc(matchId).delete();
        matches.removeWhere((match) => match['matchID'] == matchId);
        await fetchMatches(_coachController.coachId.value, _teamController.teamId.value); // تحديث المباريات بعد الحذف
        Get.snackbar('Success', 'Match deleted successfully.',
        backgroundColor: Colors.green,
          colorText: Colors.white
        );
        Get.toNamed(AppRoutes.matchHome, arguments: {
          'coachId': _coachController.coachId.value,
          'teamId': _teamController.teamId.value,
        });
      } else {
        Get.snackbar('Error', 'Match not found.',
        backgroundColor: Colors.red,
          colorText: Colors.white
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete match',
      backgroundColor: Colors.red,
        colorText: Colors.white

      );
      print(e);
    }
  }
  Future<List<Map<String, String>>> fetchTeams() async {
    try {
      // جلب جميع الفرق من قاعدة البيانات
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('team').get();

      // قائمة تحتوي على أسماء الفرق وصورهم
      List<Map<String, String>> teams = snapshot.docs.map((doc) {
        return {
          'teamName': doc['teamName'] as String,  // اسم الفريق
          'image': doc['image'] as String,  // رابط الصورة
        };
      }).toList();

      // استبعاد اسم فريق المدرب من القائمة
      String myTeamName = _teamController.teamName.value;  // استخدام اسم الفريق الحالي من Controller
      teams.removeWhere((team) => team['teamName'] == myTeamName);

      return teams;  // إرجاع القائمة المعدلة
    } catch (e) {
      print('Error fetching teams: $e');
      return [];
    }
  }

}
