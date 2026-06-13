import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:saoutapp/controllers/controller_coach/player_controller/add_player_controller.dart';
import 'package:saoutapp/controllers/controller_coach/sign_up_coach_controller.dart';
import 'package:saoutapp/controllers/controller_coach/team_controller.dart';

import '../../../routes.dart';
import 'navigation_widget.dart';

class BottomNavigationBarWidget extends StatelessWidget {
  final PlayerController _playerController = Get.find();
  final CoachController _coachController = Get.find();
  final TeamController _teamController = Get.find();
  final String selectedTab; // تحديد الزر المختار
  final Function(String) onTabSelected; // دالة لتحديد الزر عند الضغط عليه

   BottomNavigationBarWidget({
    required this.selectedTab,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 9),
      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          NavigationWidget(
            iconData: Icons.home,
            textIcon: 'Home',
            isSelected: selectedTab == 'Home', // تحقق من ما إذا كان الزر مختارًا
            onTap: () {
              onTabSelected('Home'); // تحديث الحالة في الـ StatefulWidget
              Get.toNamed(
                AppRoutes.homePage,
                arguments: {
                  'coachId': _coachController.coachId.value,
                  'teamId': _teamController.teamId.value,
                },
              );
            },
          ),
          NavigationWidget(
            iconData: Icons.add,
            textIcon: 'Matches',
            isSelected: selectedTab == 'Matches',
            onTap: () {
              Get.toNamed(AppRoutes.matchHome, arguments: {
                'coachId': _coachController.coachId.value,
                'teamId': _teamController.teamId.value,
              });
            },
          ),
          NavigationWidget(
            iconData: Icons.person_outline,
            textIcon: 'Profile',
            isSelected: selectedTab == 'Profile',
            onTap: () {
              onTabSelected('Profile');
              Get.toNamed(
                AppRoutes.updateCoach,
                arguments: {
                  'coachId': _coachController.coachId.value,
                  'teamId': _teamController.teamId.value,
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
