import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // استيراد مكتبة الإشعارات المحلية

class PushNotificationsService {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> setupLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('icon');

    final InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  static Future<String> getAccessToken() async {
    final Map<String, dynamic> serviceAccountJson = {
      "type": "",
      "project_id": "saoutapp",
      "private_key_id": "",
      "private_key": "",
      "client_email": "",
      "client_id": "",
      "auth_uri": "",
      "token_uri": "",
      "auth_provider_x509_cert_url": "",
      "client_x509_cert_url": "",
      "universe_domain": ""
    };

    List<String> scopes = [
      "https://www.googleapis.com/auth/userinfo.email",
      "https://www.googleapis.com/auth/firebase.database",
      "https://www.googleapis.com/auth/firebase.messaging"
    ];

    http.Client client = await auth.clientViaServiceAccount(
        auth.ServiceAccountCredentials.fromJson(serviceAccountJson), scopes);

    auth.AccessCredentials credentials = await auth
        .obtainAccessCredentialsViaServiceAccount(
        auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
        scopes,
        client
    );

    client.close();
    return credentials.accessToken.data;
  }

  static Future<void> sendNotificationsTo(String token, BuildContext context,
      String userId, String title, String body) async {
    final String serverKey = await getAccessToken();
    String url = "https://fcm.googleapis.com/v1/projects/saoutapp/messages:send";

    final Map<String, dynamic> message = {
      'message': {
        'token': token,
        'notification': {
          'title': title,
          'body': body,
        },
        'data': {
          'userId': userId,
        }
      }
    };

    try {
      final http.Response response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $serverKey'
        },
        body: jsonEncode(message),
      );

      if (response.statusCode == 200) {
        // تأكيد إرسال الإشعار
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text("Notification sent successfully to $token")),
        // );
        print("Notification sent successfully to $token");
        print('Title: $title');
        print('Body: $body');
        print("Response: ${response.body}");
      } else {
        print("Failed to send notification: ${response.body}");
      }
    } catch (e) {
      print("Error sending notification: $e");

    }
  }

  static Future<void> setupFirebaseMessaging(BuildContext context,
      String userId) async {
    NotificationSettings settings = await FirebaseMessaging.instance.requestPermission();
    if (settings.authorizationStatus != AuthorizationStatus.authorized) {
      print("User has denied notification permissions.");
      return;
    }
    // إعداد الإشعارات المحلية
    await setupLocalNotifications();

    // احصل على التوكن عند التسجيل أو عند بدء التطبيق
    await saveFCMToken(userId);

    // استمع لتغييرات التوكن
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    messaging.onTokenRefresh.listen((newToken) async {
      if (newToken != null) {
        await saveFCMToken(userId, newToken); // احفظ التوكن الجديد
      }
    });
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // استمع للإشعارات عند التشغيل
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print('Received a message: ${message.notification?.title} ${message.notification?.body}');

      // عرض إشعار محلي عند تلقي إشعار
      await showLocalNotification(
        message.notification?.title ?? 'Notification', // العنوان
        message.notification?.body ?? 'You have a new message!', // المحتوى
      );
    });


    // إعداد معالج الإشعارات في الخلفية
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  static Future<void> showLocalNotification(String? title, String? body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
        'your_channel_id', // معرف القناة
        'your_channel_name', // اسم القناة
        channelDescription: 'your_channel_description', // وصف القناة
        importance: Importance.max,
        priority: Priority.high,
        showWhen: false);

    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
        0, title, body, platformChannelSpecifics,
        payload: 'Your payload here'); // يمكنك تمرير أي بيانات إضافية إذا لزم الأمر
  }


  static Future<void> firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    await Firebase.initializeApp();
    print('Handling a background message: ${message.messageId}');
    // يمكنك هنا إضافة كود لمعالجة الإشعار في الخلفية

  }

  static Future<void> saveFCMToken(String userId, [String? token]) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    if (token != null) {
      // احفظ التوكن في قاعدة البيانات
      await firestore.collection("Users").doc(userId).set(
          {"fcmToken": token}, SetOptions(merge: true));
      print(
          "FCM Token saved for user $userId: $token"); // طباعة تأكيد حفظ التوكن
    } else {
      // احصل على التوكن الحالي
      String? currentToken = await FirebaseMessaging.instance.getToken();
      await firestore.collection("Users").doc(userId).set(
          {"fcmToken": currentToken}, SetOptions(merge: true));
      print(
          "FCM Token retrieved and saved for user $userId: $currentToken"); // طباعة تأكيد حفظ التوكن
        }
  }
}
