import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:saoutapp/controllers/controller_coach/sign_up_coach_controller.dart';

import '../../not_controller.dart';

class NotificationsController extends GetxController{
  final CoachController _controller = Get.find();
  Future<List<Map<String, String>>> getTokensAndNamesOfFollowers(List<String> playerIDs) async {
    List<Map<String, String>> followerData = [];

    print("خطوة 6: استرجاع توكنات وأسماء المتابعين من قاعدة بيانات المتابعين.");
    for (String playerId in playerIDs) {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('follow', arrayContains: playerId)
          .get();

      for (var user in snapshot.docs) {
        followerData.add({
          'token': user['fcmToken'],
          'name': user['firstName'] // تأكد من وجود حقل 'firstName' في المستند
        });
        print("تمت إضافة توكن المتابع: ${user['fcmToken']} مع الاسم: ${user['firstName']}");
      }
    }

    print("بيانات المتابعين النهائية: $followerData");
    return followerData;
  }

// دالة لاسترجاع أسماء اللاعبين بناءً على معرّفاتهم
  Future<List<String>> getPlayerNames(List<String> playerIDs) async {
    List<String> playerNames = [];
    print("خطوة 7: استرجاع أسماء اللاعبين من قاعدة البيانات.");

    for (String playerId in playerIDs) {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('players').doc(playerId).get();
      if (snapshot.exists) {
        playerNames.add(snapshot['firstName']); // تأكد من أن لديك حقل 'name' في المستند
        print("تمت إضافة اسم اللاعب: ${snapshot['firstName']}");
      } else {
        print("خطأ: اللاعب ذو المعرف $playerId غير موجود.");
      }
    }

    print("الأسماء النهائية: $playerNames");
    return playerNames;
  }

  Future<void> sendNotificationsToFollowers(List<String> playerIDs, BuildContext context) async {
    print("خطوة 4: استرجاع توكنات المتابعين.");
    List<Map<String, String>> followerData = await getTokensAndNamesOfFollowers(playerIDs);
    print("بيانات المتابعين المسترجعة: $followerData");

    // استرجاع أسماء اللاعبين
    List<String> playerNames = await getPlayerNames(playerIDs);

    // حالة لتتبع ما إذا تم إرسال الإشعارات
    Set<String> sentTokens = {};

    // إرسال إشعارات للمتابعين
    for (var follower in followerData) {
      String? token = follower['token'];
      String? userName = follower['name'];

      if (token != null && userName != null && !sentTokens.contains(token)) {
        print("خطوة 5: إعداد وإرسال الإشعار إلى التوكن $token.");
        String notificationTitle = 'New Match Added';
        String notificationBody = 'A new Match has been added to a player $userName! ${playerNames.join(', ')}';

        await PushNotificationsService.sendNotificationsTo(
            token, context, _controller.coachId.value, notificationTitle, notificationBody);

        print('تم إرسال الإشعار إلى التوكن: $token');
        print('العنوان: $notificationTitle');
        print('المحتوى: $notificationBody');

        // إضافة التوكن إلى مجموعة التوكنات المرسلة
        sentTokens.add(token);

      } else {
        print("خطأ: التوكن أو الاسم فارغ أو تم إرسال الإشعار سابقًا.");
      }
    }
  }



}