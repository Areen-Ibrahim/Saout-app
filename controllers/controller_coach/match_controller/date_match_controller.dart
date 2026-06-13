import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DateMatchController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  RxList<Map<String, dynamic>> matches = <Map<String, dynamic>>[].obs;


  // دالة لجلب وتصفية المباريات
  Future<void> fetchAndFilterMatches({DateTime? date, String? coachId, String? teamId}) async {

    try {
      Query query = _firestore.collection('matches')
          .where('coachID', isEqualTo: coachId)
          .where('teamID', isEqualTo: teamId);

      if (date != null) {
        DateTime startOfDay = DateTime(date.year, date.month, date.day);
        DateTime endOfDay = startOfDay.add(Duration(days: 1)).subtract(Duration(seconds: 1));
        query = query
            .where('matchDate', isGreaterThanOrEqualTo: startOfDay)
            .where('matchDate', isLessThanOrEqualTo: endOfDay);
      }

      var querySnapshot = await query.get();
      matches.clear();

      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> matchData = doc.data() as Map<String, dynamic>;
        matchData['matchID'] = doc.id;

        // جلب صورة الفريق المنافس إذا كان اسمه موجودًا في جدول الفرق
        if (matchData.containsKey('opponentTeamName')) {
          var opponentDetails = await fetchOpponentTeamDetailsByName(matchData['opponentTeamName']);
          matchData['image'] = opponentDetails['image'] ?? ''; // صورة افتراضية إذا لم تكن موجودة
        } else {
          matchData['image'] = ''; // صورة افتراضية إذا لم يوجد اسم الفريق المنافس
        }

        // التحقق من وجود matchID مسبقًا لتجنب التكرار
        if (!matches.any((m) => m['matchID'] == matchData['matchID'])) {
          matches.add(matchData);
        }
      }

      print("Total Matches Count: ${matches.length}");
    } catch (e) {
      print('Error fetching matches: $e');
      Get.snackbar('Error', 'Failed to fetch matches',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  // دالة لجلب صورة الفريق المنافس عن طريق اسمه
  Future<Map<String, dynamic>> fetchOpponentTeamDetailsByName(String opponentTeamName) async {
    try {
      var teamQuery = await _firestore.collection('team')
          .where('teamName', isEqualTo: opponentTeamName)
          .get();

      if (teamQuery.docs.isNotEmpty) {
        var teamData = teamQuery.docs.first.data() as Map<String, dynamic>;
        return {
          'image': teamData['image'] ?? '', // إرجاع رابط الصورة أو فارغ
        };
      }
    } catch (e) {
      print('Error fetching opponent team details by name: $e');
    }
    return {'image': ''}; // إرجاع قيمة فارغة إذا لم يوجد الفريق المنافس
  }
}
