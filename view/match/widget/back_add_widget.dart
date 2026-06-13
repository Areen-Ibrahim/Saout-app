import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/color.dart';

class BackAddWidget extends StatelessWidget {
  final void Function() addMatch;
  final Widget add;
  const BackAddWidget({super.key,
    required this.addMatch,
    required this.add});

  @override
  Widget build(BuildContext context) {
    return     Container(
      // height: 100,
      padding: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
          color: ColorApp.background
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(onPressed: (){
            Get.back();
          }, icon: Icon(Icons.arrow_circle_left_rounded, color: Colors.white, size: 30,)),
          ElevatedButton(
              style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(ColorApp.oasisGreen)
              ),
              onPressed: addMatch,
              child: add )
        ],
      ),
    );
  }
}
