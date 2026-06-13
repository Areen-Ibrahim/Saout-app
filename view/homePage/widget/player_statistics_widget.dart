import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PlayerStatisticsWidget extends StatelessWidget {
  final String text;
  final RxInt value; // متغير Rx لقيمة الإحصائية
  final VoidCallback onIncrement; // دالة للإضافة
  final VoidCallback onDecrement; // دالة للنقصان

  const PlayerStatisticsWidget({
    super.key,
    required this.text,
    required this.value,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(text, style: TextStyle(color: Colors.white, fontSize: 18)),
          Row(
            children: [
              InkWell(
                onTap: onDecrement, // ربط دالة النقصان
                child: Icon(Icons.remove, size: 22, color: Colors.white),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Obx(() => Text(
                  value.toString(), // عرض القيمة القابلة للتغيير
                  style: TextStyle(color: Colors.white, fontSize: 18),
                )),
              ),
              InkWell(
                onTap: onIncrement, // ربط دالة الإضافة
                child: Icon(Icons.add, size: 22, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
