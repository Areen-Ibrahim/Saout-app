import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:saoutapp/controllers/controller_coach/match_controller/add_match_controller.dart';
import 'package:saoutapp/controllers/controller_coach/sign_up_coach_controller.dart';
import 'package:saoutapp/controllers/controller_coach/team_controller.dart';
import 'package:saoutapp/routes.dart';

class UpdateMatchController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // TextEditingControllers
  TextEditingController opposingTeamController = TextEditingController();
  TextEditingController myResultController = TextEditingController(); // نتيجة فريقك
  TextEditingController opponentResultController = TextEditingController(); // نتيجة الفريق المنافس

  var matchId = ''.obs; // معرف المباراة
  var selectedFormation = '4-4-1-1'.obs;
  var assistProviders = <String>[].obs;
  var playerIDs = <String>[].obs; // قائمة معرفات اللاعبين المختارين
  TextEditingController dateController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  var opposingTeamImageUrl = ''.obs;
  Rx<File?> opposingTeamImage = Rx<File?>(null);
  var goalsList = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> playerList = <Map<String, dynamic>>[].obs;



  Future<void> fetchPlayers() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('players') // اسم جدول اللاعبين
          .get();

      playerList.value = snapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        return {
          'playerId': doc.id,
          'firstName': data['firstName'], // اسم اللاعب
        };
      }).toList();
    } catch (e) {
      print("Error fetching players: $e");
    }
  }

  var matchDate = DateTime.now().obs;

  void addPlayer(String playerId) {
    if (!playerIDs.contains(playerId)) {
      playerIDs.add(playerId);
    }
  }
  void updateGoalsListLength(int newLength) {
    if (newLength > goalsList.length) {
      // أضف عناصر جديدة
      goalsList.addAll(List.generate(newLength - goalsList.length, (_) => {'playerId': '', 'minute': 0}));
    } else if (newLength < goalsList.length) {
      // احذف العناصر الزائدة
      goalsList.removeRange(newLength, goalsList.length);
    }
  }

  Future<String> fetchFormation(String matchId) async {
    try {
      final data = await fetchMatchData(matchId); // افترض أن هذه الدالة تجلب بيانات المباراة
      return data['formation'] ?? ''; // استخراج التشكيلة من البيانات
    } catch (e) {
      throw Exception('Failed to fetch formation');
    }
  }


  Future<void> removePlayerFromDatabase(String matchId, String playerId) async {
    try {
      DocumentSnapshot matchDoc = await _firestore.collection('matches').doc(matchId).get();
      if (matchDoc.exists) {
        Map<String, dynamic> matchData = matchDoc.data() as Map<String, dynamic>;
        List<dynamic> currentPlayerIDs = List.from(matchData['playerIDs'] ?? []); // استخدم List.from للتأكد من عدم التأثير على البيانات الأصلية

        if (currentPlayerIDs.contains(playerId)) {
          currentPlayerIDs.remove(playerId); // إزالة اللاعب من القائمة
          await _firestore.collection('matches').doc(matchId).update({
            'playerIDs': currentPlayerIDs, // تحديث قاعدة البيانات
          });
          print("Player removed from database: $playerId");
        } else {
          print("Player not found in database: $playerId");
        }
      } else {
        print("Match document does not exist.");
      }
    } catch (e) {
      print("Error removing player from database: $e");
    }
  }


  void removePlayer(String playerId) {
    print("Current playerIDs: $playerIDs"); // اضافة هذه الجملة لمراقبة القائمة
    if (playerIDs.contains(playerId)) {
      playerIDs.remove(playerId);
      print("Player removed locally: $playerId"); // التأكيد على الإزالة
    } else {
      print("Player not found in list: $playerId"); // إذا لم يكن اللاعب موجودًا في القائمة
    }
  }


  List<String> playersToRemove = []; // Add your logic to populate this list

  bool shouldRemovePlayer(String playerId) {
    return playersToRemove.contains(playerId);
  }

  Future<Map<String, dynamic>> fetchMatchData(String matchId) async {
    try {
      // جلب بيانات المباراة
      DocumentSnapshot matchDoc = await _firestore.collection('matches').doc(
          matchId).get();
      if (matchDoc.exists) {
        var matchData = matchDoc.data() as Map<String, dynamic>;
        opposingTeamController.text = matchData['opponentTeamName'];
        myResultController.text = matchData['myResult'].toString();
        opponentResultController.text = matchData['opponentResult'].toString();
        selectedFormation.value = matchData['matchFormation'] ?? '4-4-1-1';
        opposingTeamImageUrl.value = matchData['opponentTeamImage'] ?? '';
        assistProviders.value = List<String>.from(matchData['assisters'] ?? []);

        // جلب معرفات اللاعبين المختارين
        playerIDs.value = List<String>.from(matchData['playerIDs'] ?? []);
        matchDate.value = (matchData['matchDate'] as Timestamp).toDate();
        goalsList.value = List<Map<String, dynamic>>.from(matchData['goalsList'] ?? []);

        matchDate.value = (matchData['matchDate'] as Timestamp).toDate();
        dateController.text = "${matchDate.value.year}-${matchDate.value.month}-${matchDate.value.day}";
        timeController.text = "${matchDate.value.hour}:${matchDate.value.minute.toString().padLeft(2, '0')}";

        // جلب تفاصيل اللاعبين المختارين
        List<Map<String, dynamic>> playerDetails = [];
        for (String playerId in playerIDs) {
          DocumentSnapshot<
              Map<String, dynamic>> playerSnapshot = await _firestore
              .collection('players').doc(playerId).get();
          if (playerSnapshot.exists) {
            var playerData = playerSnapshot.data();
            if (playerData != null) {
              playerDetails.add({
                'playerId': playerId,
                'firstName': playerData['firstName'] ?? 'Unknown',
                'image': playerData['image'] ?? '', // رابط الصورة
                'playerNumber': playerData['playerNumber'] ?? 0, // رقم اللاعب
              });
            }
          }
        }

        // إعادة البيانات
        return {
          'matchData': matchData,
          'playerDetails': playerDetails,
        };
      } else {
        throw Exception('Match not found');
      }
    } catch (e) {
      print('Error fetching match data: $e');
      throw e;
    }
  }

  void addGoal(int index, int minute, String playerId) {
    if (index < goalsList.length) {
      goalsList[index]['minute'] = minute;
      goalsList[index]['playerId'] = playerId;
    } else {
      goalsList.add({'minute': minute, 'playerId': playerId});
    }
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



  Future<List<String>> updateMatch(String matchId) async {
    try {
      // احذف اللاعبين الذين تم اختيارهم للحذف
      for (String playerId in List.from(playerIDs)) {
        if (shouldRemovePlayer(playerId)) {
          removePlayer(playerId); // احذف محليًا
          await removePlayerFromDatabase(matchId, playerId); // احذف من قاعدة البيانات
        }
      }

      // رفع صورة الفريق المنافس إذا كانت موجودة
      String? imageUrl;
      if (opposingTeamImage.value != null && opposingTeamImage.value!.path.isNotEmpty) {
        imageUrl = await uploadFile(opposingTeamImage.value!, 'matches/${opposingTeamImage.value!.path.split('/').last}');
      }

      // تحديث بيانات المباراة في قاعدة البيانات
      await _firestore.collection('matches').doc(matchId).update({
        'opponentTeamName': opposingTeamController.text.trim(),
        'myResult': int.tryParse(myResultController.text) ?? 0,
        'opponentResult': int.tryParse(opponentResultController.text) ?? 0,
        'matchFormation': selectedFormation.value,
        'playerIDs': playerIDs, // حفظ قائمة معرفات اللاعبين المحدثة
        'matchDate': matchDate.value,
        'goals': goalsList,
        'assistProviders': assistProviders,

        if (imageUrl != null) 'opponentTeamImage': 'image/icon.png',  // إضافة صورة الفريق إذا كانت موجودة
      });

      Get.snackbar('Success', 'Match updated successfully.',
          backgroundColor: Colors.green,
          colorText: Colors.white
      );

      // إرجاع قائمة المعرفات الجديدة
      return playerIDs;
    } catch (e) {
      print('Error updating match: $e');
      Get.snackbar('Error', 'Failed to update match profile.',
          backgroundColor: Colors.red,
          colorText: Colors.white
      );

      // إرجاع قائمة فارغة في حالة حدوث خطأ
      return [];
    }
  }


  Future<void> fetchTeamImage(String teamName) async {
    try {
      // جلب بيانات الفريق من Firestore باستخدام اسم الفريق
      DocumentSnapshot teamDoc = await _firestore.collection('team').doc(teamName).get();
      if (teamDoc.exists) {
        var teamData = teamDoc.data() as Map<String, dynamic>;
        String imageUrl = teamData['image'] ?? '';
        if (imageUrl.isNotEmpty) {
          // إذا كانت صورة موجودة في قاعدة البيانات، يتم تخزين الرابط
          opposingTeamImageUrl.value = imageUrl;
        } else {
          // إذا لم توجد صورة، يمكن رفع صورة جديدة (حسب منطقك)
          opposingTeamImageUrl.value = ''; // في حال كنت ستستخدم صورة جديدة
        }
      } else {
        // إذا لم تجد الفريق في قاعدة البيانات، يمكن أن تطلب من المستخدم رفع صورة
        opposingTeamImageUrl.value = '';
      }
    } catch (e) {
      print('Error fetching team image: $e');
    }
  }


}