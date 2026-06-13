import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:saoutapp/routes.dart';
import 'package:saoutapp/view/login/loginCoachScreen/screen/log_in_coach.dart';
import 'package:saoutapp/view/login/loginScout/screens/login_scout_screen.dart';
import '../../../core/color.dart';
import '../../signup/signupScout/screen/sign_up_scout_screen.dart';


class Saouthome extends StatefulWidget {
  final String userType;
  const Saouthome({super.key, required this.userType});

  @override
  State<Saouthome> createState() => _SaoutHomeState();
}

class _SaoutHomeState extends State<Saouthome> with TickerProviderStateMixin{
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
      duration: const Duration(seconds: 1),
    );
    Future.delayed(const Duration(seconds: 1), () {
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
                scale: Tween<double>(begin: 0.5, end: 1.0).animate(
                  CurvedAnimation(
                    parent: _iconController,
                    curve: Curves.elasticOut,
                  ),
                ),
                child: Image.asset("image/basicicon.png")),
            const SizedBox(height: 22),
            const Text(
              "SAOUT",
              style: TextStyle(
                color: Colors.white,
                fontSize: 23,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                fontFamily: 'play'
              ),
            ),
            const SizedBox(height: 12),
            FadeTransition(
              opacity: _buttonController,

              child: ElevatedButton(
                onPressed: () {
                  if (widget.userType == 'scout') {
                    // Get.toNamed(AppRoutes.signupScout); // انتقل إلى صفحة تسجيل الدخول للمشرف
                    Get.to(() =>
                    SignupView(),
                      transition: Transition.downToUp,
                      duration: const Duration(milliseconds: 660),
                    );
                  } else {
                    Get.toNamed(AppRoutes.signupCoach); // انتقل إلى صفحة تسجيل الدخول للمدرب
                  }
                },
                child: Container(
                  // padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  // width: 250,
                  // padding: const EdgeInsets.all(18),
                  // decoration: const BoxDecoration(color: Colors.white),
                  child: Text(
                    "Sign Up",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: ColorApp.oasisGreen,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Already have an account?",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    if (widget.userType == 'scout') {
                      // Get.toNamed(AppRoutes.loginScout);
                     Future.delayed(Duration(milliseconds: 100), (){
                       Get.to(() =>
                           LoginScoutScreen(),
                         transition: Transition.downToUp,
                         duration: const Duration(milliseconds: 660),
                       );
                     });
                    } else {
                      // Get.toNamed(AppRoutes.loginCoach);
                     Future.delayed(Duration(milliseconds: 100), (){
                       Get.to(() =>
                           LoginCoachScreen(),
                         transition: Transition.downToUp,
                         duration: const Duration(milliseconds: 660),
                       );
                     });
                    }
                  },
                  child:  Text(
                    "Login",
                    style: TextStyle(
                      color: ColorApp.richLavender,
                      decoration: TextDecoration.underline,
                      decorationColor: ColorApp.richLavender,
                      decorationThickness: 2,
                      decorationStyle: TextDecorationStyle.solid,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
