import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:saoutapp/core/loading.dart';
import '../../../../controllers/request_controller.dart';
import '../../../../core/color.dart';
import '../../widget/text_title_add_player.dart';

class CoachRequestsPage extends StatelessWidget {
  final String coachId;

  CoachRequestsPage({required this.coachId});

  @override
  Widget build(BuildContext context) {
    final RequestController requestController = Get.put(RequestController());

    // التبويبات الخاصة بحالة الريكوست
    final List<String> requestStatuses = ['pending', 'accepted', 'rejected'];

    // عند تحميل الصفحة، نقوم بتغيير حالة التحميل إلى true
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await requestController.getRequestsByStatus(coachId, 'pending');
      await requestController.getRequestsByStatus(coachId, 'accepted');
      await requestController.getRequestsByStatus(coachId, 'rejected');
    });

    return DefaultTabController(
      length: requestStatuses.length,
      child: Scaffold(
        backgroundColor: ColorApp.background,
        appBar: AppBar(
          backgroundColor: Colors.white10,
          title: TextTitleAddPlayer(text: 'Coach requests'),
          iconTheme: IconThemeData(color: Colors.white, size: 20),
          bottom: TabBar(
            labelColor: ColorApp.oasisGreen,
            unselectedLabelColor: Colors.white24,
            indicatorColor: ColorApp.oasisGreen,
            isScrollable: true,
            tabs: requestStatuses.map((status) => Tab(text: status.toUpperCase())).toList(),
          ),
        ),
        body: Obx(
              () {
            // تحقق من حالة التحميل
            if (requestController.isLoading.value) {
              return Loading();  // عرض شاشة Loading إذا كانت البيانات قيد التحميل
            }
            return TabBarView(
              children: requestStatuses.map((status) {
                return RefreshIndicator(
                  onRefresh: () async {
                    // عند السحب لإعادة التحميل، سيتم جلب البيانات مرة أخرى
                    await requestController.getRequestsByStatus(coachId, 'pending');
                    await requestController.getRequestsByStatus(coachId, 'accepted');
                    await requestController.getRequestsByStatus(coachId, 'rejected');
                  },
                  child: ListView.builder(
                    itemCount: requestController.requestsByStatus[status]!.length,
                    itemBuilder: (context, index) {
                      var request = requestController.requestsByStatus[status]![index]['request'];
                      var scoutName = requestController.requestsByStatus[status]![index]['scoutDetails'];
                      var requestDate = request.createdAt; // Assuming `createdAt` is the date when the request was created

                      return Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Card(
                          color: Colors.white10,
                          margin: EdgeInsets.symmetric( horizontal: 16),
                          child: ListTile(
                            title: Text('Request from $scoutName', style: TextStyle(color: Colors.white, fontFamily: 'play', fontWeight: FontWeight.w700, fontSize: 15)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Text('Status: ${request.requestStatus}', style: TextStyle(color: Colors.white70)),
                                // عرض التاريخ و "منذ متى تم إرسال الريكوست"
                                Text('Sent on: ${formatDateAch(_convertTimestampToDateTime(requestDate))}', style: TextStyle(color: Colors.white54, fontSize: 12)),
                                // Text('Since: ${timeAgo(requestDate)}', style: TextStyle(color: Colors.white54)),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (request.requestStatus == 'pending')
                                  IconButton(
                                    icon: Icon(Icons.check, color: ColorApp.oasisGreen),
                                    onPressed: () async {
                                      await requestController.updateRequestStatus(context,request, 'accepted');
                                    },
                                  ),
                                if (request.requestStatus == 'pending')
                                  IconButton(
                                    icon: Icon(Icons.cancel, color: ColorApp.red),
                                    onPressed: () async {
                                      await requestController.updateRequestStatus(context,request, 'rejected');
                                    },
                                  ),
                                if (request.requestStatus != 'pending')
                                  Text('Since: ${timeAgo(requestDate)}', style: TextStyle(color: Colors.white54)),

                              ],
                            ),
                          ),
                        ).animate().fadeIn().slide(
                            duration: 500.ms, curve: Curves.easeInOut),
                      ).animate().shimmer(
                          delay: 100.ms, duration: 300.ms);
                    },
                  ),
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }

  // دالة لحساب "منذ متى تم إرسال الريكوست"
  String timeAgo(dynamic timestamp) {
    try {
      DateTime requestDateTime = _convertTimestampToDateTime(timestamp);
      Duration difference = DateTime.now().difference(requestDateTime);

      if (difference.inDays > 0) {
        return "${difference.inDays} days ago";
      } else if (difference.inHours > 0) {
        return "${difference.inHours} hours ago";
      } else if (difference.inMinutes > 0) {
        return "${difference.inMinutes} minutes ago";
      } else {
        return "Just now";
      }
    } catch (e) {
      print("Error parsing date: $e");
      return "Invalid Date";
    }
  }

  // دالة لتحويل Timestamp إلى DateTime
  DateTime _convertTimestampToDateTime(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    } else if (timestamp is DateTime) {
      return timestamp;
    } else {
      throw Exception('Invalid timestamp type');
    }
  }

  // دالة لتحويل التاريخ إلى تنسيق "اليوم، الشهر، الساعة"
  String formatDateAch(DateTime dateTime) {
    return "${_getWeekday(dateTime.weekday)}, ${dateTime.day} ${_getMonth(dateTime.month)}";
  }

  // دالة لتحويل الرقم إلى اسم اليوم
  String _getWeekday(int weekday) {
    switch (weekday) {
      case DateTime.monday: return "Mon";
      case DateTime.tuesday: return "Tue";
      case DateTime.wednesday: return "Wed";
      case DateTime.thursday: return "Thu";
      case DateTime.friday: return "Fri";
      case DateTime.saturday: return "Sat";
      case DateTime.sunday: return "Sun";
      default: return "";
    }
  }

  // دالة لتحويل الرقم إلى اسم الشهر
  String _getMonth(int month) {
    switch (month) {
      case 1: return "Jan";
      case 2: return "Feb";
      case 3: return "Mar";
      case 4: return "Apr";
      case 5: return "May";
      case 6: return "Jun";
      case 7: return "Jul";
      case 8: return "Aug";
      case 9: return "Sep";
      case 10: return "Oct";
      case 11: return "Nov";
      case 12: return "Dec";
      default: return "";
    }
  }
}
