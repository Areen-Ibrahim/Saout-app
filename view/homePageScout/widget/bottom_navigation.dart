import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../controllers/controller_scout/controller_scout_auth/user_controller.dart';
import '../../../routes.dart';
import '../../homePage/widget/navigation_widget.dart';

class BottomNavigationBarWidgetScout extends StatelessWidget {
  final String selectedTab;
  final Function(String) onTabSelected;
  final UserController userController = Get.find<UserController>();

  BottomNavigationBarWidgetScout({
    required this.selectedTab,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserController>(
      init: userController, // يقوم بتهيئة المتحكم مرة واحدة فقط
      builder: (_) => Container(
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
              isSelected: selectedTab == 'Home',
              onTap: () {
                onTabSelected('Home');
                Get.offNamed(
                  AppRoutes.homePageScout,
                  arguments: {
                    'userId': userController.currentUserUid.value,
                  },
                );
              },
            ),
            NavigationWidget(
              iconData: Icons.list,
              textIcon: 'List',
              isSelected: selectedTab == 'List',
              onTap: () {
                onTabSelected('List');
                Get.offNamed(AppRoutes.playersList);
              },
            ),
            NavigationWidget(
              iconData: Icons.groups,
              textIcon: 'Matches',
              isSelected: selectedTab == 'Matches',
              onTap: () {
                onTabSelected('Matches');
                Get.offNamed(AppRoutes.matchesList);
              },
            ),
            NavigationWidget(
              iconData: Icons.person_outline,
              textIcon: 'Profile',
              isSelected: selectedTab == 'Profile',
              onTap: () {
                onTabSelected('Profile');
                Get.offNamed(AppRoutes.profile, arguments: {
                  'userId': userController.currentUserUid.value,
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
