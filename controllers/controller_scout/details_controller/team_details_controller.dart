import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class TeamDetailsController extends GetxController{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> getTeamDetailsWithPlayerInfo(String teamID) async {
    try {
      // البحث عن الفريق بناءً على معرف الفريق
      DocumentSnapshot teamSnapshot = await _firestore.collection('team').doc(teamID).get();

      if (teamSnapshot.exists) {
        String teamType = teamSnapshot['teamType'];

        // التأكد من أن نوع الفريق لا يساوي "School Team"
        if (teamType != 'School Team') {
          // جلب بيانات المدرب باستخدام معرف المدرب
          String coachID = teamSnapshot['coachId'];
          DocumentSnapshot coachSnapshot = await _firestore.collection('Coaches').doc(coachID).get();

          String coachName = coachSnapshot.exists ? coachSnapshot['userName'] : 'لا يوجد اسم مدرب';
          String coachPhone = coachSnapshot.exists ? coachSnapshot['phoneNumber'] ?? 'لا يوجد رقم هاتف' : 'لا يوجد رقم هاتف';
          String coachEmail = coachSnapshot.exists ? coachSnapshot['email'] ?? 'لا يوجد بريد إلكتروني' : 'لا يوجد بريد إلكتروني';

          // جلب جميع المباريات المرتبطة بالفريق
          QuerySnapshot matchesSnapshot = await _firestore
              .collection('matches')
              .where('teamID', isEqualTo: teamID)
              .get();

          // عدد جميع المباريات
          int totalMatchesCount = matchesSnapshot.docs.length;

          // الحصول على قائمة اللاعبين من حقل playersId
          List<String> playersIds = List<String>.from(teamSnapshot['playersId'] ?? []); // تأكد من تحويل البيانات إلى قائمة

          // جلب معلومات اللاعبين مباشرة من جدول اللاعبين باستخدام قائمة المعرفات
          if (playersIds.isNotEmpty) {
            QuerySnapshot playersSnapshot = await _firestore
                .collection('players')
                .where(FieldPath.documentId, whereIn: playersIds) // استخدم FieldPath.documentId لجلب اللاعبين بناءً على معرفاتهم
                .get();

            // إضافة معلومات اللاعبين
            List<Map<String, dynamic>> playersInfo = playersSnapshot.docs.map((doc) {
              Map<String, dynamic> playerData = doc.data() as Map<String, dynamic>;
              return {
                'playerId': doc.id,
                'firstName': playerData['firstName'] ?? 'لا يوجد اسم',
                'lastName': playerData['lastName'] ?? 'لا يوجد لقب',
                'age': playerData['age'] ?? 0,
                'position': playerData['position'] ?? 'لا يوجد مركز',
                'image': playerData['image'] ?? 'لا يوجد صورة',
              };
            }).toList();
            // فقط للحصول على عدد اللاعبين:


            // إضافة جميع البيانات المسترجعة من جدول الفريق
            Map<String, dynamic> teamData = teamSnapshot.data() as Map<String, dynamic>;
            teamData['coachName'] = coachName;
            teamData['coachPhone'] = coachPhone;
            teamData['coachEmail'] = coachEmail;
            teamData['totalWins'] = teamSnapshot['numberOfWins'] ?? 0; // جلب عدد المباريات الفائزة من جدول الفريق
            teamData['totalMatchesCount'] = totalMatchesCount; // عدد جميع المباريات
            teamData['playersInfo'] = playersInfo; // إضافة معلومات اللاعبين
            teamData['averageAge'] = teamSnapshot['averageAgeOfPlayers'] ?? 0; // جلب متوسط العمر من جدول الفريق
            teamData['playerCount'] = playersInfo.length; // عدد اللاعبين
            teamData['matchesInfo'] = matchesSnapshot.docs.map((match) {
              Map<String, dynamic> matchData = match.data() as Map<String, dynamic>;
              return {
                'matchID': match.id,
                'opponentTeamName': matchData['opponentTeamName'] ?? 'لا يوجد فريق منافس',
                'matchFormation': matchData['matchFormation'] ?? 'غير محدد',
                'matchDate': matchData['matchDate'] ?? 'غير محدد',
                'opponentTeamImage': matchData['opponentTeamImage'] ?? 'image/icon.png',
              };
            }).toList(); // إضافة تفاصيل المباريات

            return teamData; // إعادة بيانات الفريق مع بيانات المدرب، اللاعبين، والمباريات
          } else {
            // إذا لم يكن هناك لاعبين
            Map<String, dynamic> teamData = teamSnapshot.data() as Map<String, dynamic>;
            teamData['playersInfo'] = []; // إضافة قائمة فارغة للاعبين
            return teamData; // إعادة البيانات حتى مع عدم وجود لاعبين
          }
        } else {
          print('Team type is not School Team for teamID: $teamID');
          return {}; // إعادة خريطة فارغة إذا كان نوع الفريق School Team
        }
      } else {
        print('No team found for teamID: $teamID');
        return {}; // إعادة خريطة فارغة إذا لم يتم العثور على فريق
      }
    } catch (e) {
      print('Error fetching team details: $e');
      return {}; // إعادة خريطة فارغة في حال حدوث خطأ
    }
  }



}