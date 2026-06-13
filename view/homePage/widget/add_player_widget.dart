import 'package:flutter/material.dart';
import '../../../core/color.dart';

class AddPlayerWidget extends StatelessWidget {
  final void Function()? onTap;
  final void Function()? onTapDialog;
  final void Function()? onTapRef;
  final void Function(String)? onChange;

  const AddPlayerWidget({
    super.key,
    required this.onTap,
    required this.onTapDialog,
    required this.onChange,
    required this.onTapRef});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 12),
        // زر الإضافة يأخذ العرض بالكامل
        InkWell(
          onTap: onTap,
          child: Container(
            width: double.infinity, // يجعل الزر يأخذ العرض الكامل
            padding: const EdgeInsets.symmetric(vertical: 6), // تعديل الحشوة
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: ColorApp.oasisGreen, width: 2),
            ),
            child: Center(
              child: Icon(Icons.add, color: ColorApp.oasisGreen, size: 34),
            ),
          ),
        ),
        SizedBox(height: 14),
        Row(
          children: [
            // زر الفلترة
            InkWell(
              onTap: onTapDialog,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: ColorApp.oasisGreen, width: 2),
                ),
                child: Icon(Icons.filter_list, color: Colors.green, size: 19),
              ),
            ),
            SizedBox(width: 8), // مسافة بين الزر ومربع البحث
            InkWell(
              onTap: onTapRef,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: ColorApp.oasisGreen, width: 2),
                ),
                child: Icon(Icons.refresh, color: Colors.green, size: 19),
              ),
            ),
            // مربع البحث
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  onChanged: onChange,
                  style: TextStyle(color: Colors.white), // لون النص الأبيض
                  decoration: InputDecoration(
                    labelText: 'Search Players',
                    labelStyle: TextStyle(color: ColorApp.oasisGreen), // لون النص للـ label
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.green, // إطار أخضر
                        width: 2.0,
                      ),
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.green, // إطار أخضر عند التركيز
                        width: 2.0,
                      ),
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    suffixIcon: Icon(
                      Icons.search,
                      color: Colors.green, // لون أيقونة البحث
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
