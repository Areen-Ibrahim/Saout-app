import 'dart:io';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:saoutapp/controllers/not_controller.dart';
import 'package:saoutapp/routes.dart';
import 'core/network.dart';
import 'initial_bindings.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Platform.isAndroid?
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey           : "",
      appId            : "",
      messagingSenderId: "",
      projectId        : "saoutapp",
      storageBucket: "saoutapp.appspot.com",

    ),
  ):await Firebase.initializeApp();
  await FirebaseAppCheck.instance.activate();
  FirebaseMessaging.onBackgroundMessage(PushNotificationsService.firebaseMessagingBackgroundHandler);
  await PushNotificationsService.setupLocalNotifications();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
     debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.chooseUser,
      initialBinding: InitialBindings(),
      getPages: AppRoutes.routes,
    );
  }
}

