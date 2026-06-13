import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../not_controller.dart';

class NotifyPlayerController extends GetxController{

  Future<void> notifyFollowersOnPlayerAdded(String teamId, String playerId, BuildContext context) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    // الحصول على جميع المستخدمين الذين يتابعون الفريق
    QuerySnapshot usersSnapshot = await firestore
        .collection('Users')
        .where('followTeams', arrayContains: teamId)
        .get();
    DocumentSnapshot teamSnapshot = await firestore.collection('team').doc(teamId).get();
    String teamName = teamSnapshot['teamName'] ?? 'Unknown Team';
    for (var doc in usersSnapshot.docs) {
      String userId = doc.id;
      String? token = doc.get('fcmToken'); // الحصول على توكن FCM لكل مستخدم
      // استدعاء دالة إرسال الإشعارات
      await PushNotificationsService.sendNotificationsTo(
          token,
          context,
          userId,
          'New Player Added',
          'A new player has been added to a team $teamName!',
      );

        }
  }
}