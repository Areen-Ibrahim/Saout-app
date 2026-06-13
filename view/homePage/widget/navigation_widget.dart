import 'package:flutter/material.dart';

class NavigationWidget extends StatelessWidget {
  final IconData iconData;
  final String textIcon;
  final VoidCallback onTap;
  final bool isSelected; // لتحديد ما إذا كان الزر مختارًا أم لا

  const NavigationWidget({
    required this.iconData,
    required this.textIcon,
    required this.onTap,
    this.isSelected = false, // القيمة الافتراضية غير مختار
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconData, color: isSelected ? Colors.green : Colors.white), // تغيير اللون هنا
          Text(textIcon, style: TextStyle(color: isSelected ? Colors.green : Colors.white)), // تغيير اللون هنا
        ],
      ),
    );
  }
}
