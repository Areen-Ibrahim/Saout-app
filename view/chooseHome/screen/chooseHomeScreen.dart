import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart'; // استيراد الحزمة للأنيميشن النصي
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';
import 'package:saoutapp/view/saout/screen/saout_screen.dart';
import '../../../core/color.dart';

class ChooseHome extends StatefulWidget {
  const ChooseHome({super.key});

  @override
  _ChooseHomeState createState() => _ChooseHomeState();
}

class _ChooseHomeState extends State<ChooseHome> with TickerProviderStateMixin {
  late AnimationController _iconController;
  late AnimationController _buttonController;

  @override
  void initState() {
    super.initState();

    // إعدادات تحريك الأيقونة
    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..forward();

    // إعدادات تحريك الأزرار
    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    Future.delayed(const Duration(seconds: 2), () {
      _buttonController.forward();
    });
  }

  @override
  void dispose() {
    _iconController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorApp.background,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ScaleTransition(
            scale: Tween<double>(begin: 0.5, end: 1.0).animate(
              CurvedAnimation(
                parent: _iconController,
                curve: Curves.elasticOut,
              ),
            ),
            child: Image.asset("image/basicicon.png"),
          ),
          const SizedBox(height: 22),
          // النص مع تأثير الكتابة حرفًا حرفًا
          AnimatedTextKit(
            animatedTexts: [
              TypewriterAnimatedText(
                "Choose Your Account Type",
                textStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  fontFamily : 'play',
                ),
                speed: const Duration(milliseconds: 100),
              ),
            ],
            totalRepeatCount: 1,
          ),
          const SizedBox(height: 18),
          FadeTransition(
            opacity: _buttonController,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Future.delayed(Duration(milliseconds: 100), (){
                      Get.to(() =>
                          Saouthome(userType: 'coach'),
                        transition: Transition.downToUp,
                        duration: const Duration(milliseconds: 660),
                      );
                    });
                  },
                  child: Container(
                    decoration: const BoxDecoration(color: Colors.white),
                    child: Text(
                      "Coach",
                      style: TextStyle(
                        color: ColorApp.oasisGreen,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 19),
                ElevatedButton(
                  onPressed: () {
                   Future.delayed(Duration(milliseconds: 100), (){
                     Get.to(() =>
                         Saouthome(userType: 'scout'),
                       transition: Transition.downToUp,
                       duration: const Duration(milliseconds: 660),
                     );
                   });
                  },
                  child: Container(
                    decoration: const BoxDecoration(color: Colors.white),
                    child: Text(
                      "Scout",
                      style: TextStyle(
                        color: ColorApp.oasisGreen,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
