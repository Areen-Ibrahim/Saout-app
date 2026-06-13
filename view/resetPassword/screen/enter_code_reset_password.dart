// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../../controllers/controller_scout/controller_scout_auth/reset_password_controller.dart';
// import '../../../core/color.dart';
// import '../../../core/stack_background.dart';
//
// class EnterCodeResetPassword extends StatelessWidget {
//   EnterCodeResetPassword({super.key});
//
//   final PasswordResetController controller = Get.put(PasswordResetController()); // استدعاء وحدة التحكم
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           StackBackground(urlImage: 'image/background3.png'),
//           Center(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 190),
//               child: Column(
//                 children: [
//                   Text(
//                     "Enter the code",
//                     style: TextStyle(
//                       color: ColorApp.richLavender,
//                       fontWeight: FontWeight.w700,
//                       fontSize: 22,
//                     ),
//                   ),
//                   const SizedBox(height: 22),
//                   Container(
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(8.0),
//                       border: Border.all(color: Colors.grey),
//                     ),
//                     child:TextFormField(
//                       onChanged: (value) {
//                         controller.code.value = value; // تخزين الكود في المتغير
//                       },
//                       decoration: InputDecoration(
//                         hintText: "Code",
//                         border: InputBorder.none,
//                         contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 60),
//                   TextButton(
//                     onPressed: () {
//                       controller.verifyCode(); // التحقق من الكود
//                     },
//                     child: const Text(
//                       "Next",
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 20,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
