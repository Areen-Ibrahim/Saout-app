import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:saoutapp/core/loading.dart';
import '../../../controllers/request_controller.dart';
import '../../../core/color.dart';
import '../../homePage/widget/text_title_add_player.dart';


class ScoutRequestsPage extends StatelessWidget {
  final String scoutId;

  ScoutRequestsPage({required this.scoutId});

  @override
  Widget build(BuildContext context) {
    final RequestController requestController = Get.put(RequestController());

    // التبويبات الخاصة بحالة الريكوست
    final List<String> requestStatuses = ['pending', 'accepted', 'rejected'];

    return DefaultTabController(
      length: requestStatuses.length,
      child: Scaffold(
        backgroundColor: ColorApp.background,
        appBar: AppBar(
          backgroundColor: Colors.white10,
          title: TextTitleAddPlayer(text: 'Scout Requests'),
          iconTheme: IconThemeData(color: Colors.white, size: 20),
          bottom: TabBar(
            labelColor: ColorApp.oasisGreen,
            unselectedLabelColor: Colors.white24,
            indicatorColor: ColorApp.oasisGreen,
            isScrollable: true,
            tabs: requestStatuses.map((status) => Tab(text: status.toUpperCase())).toList(),
          ),
        ),
        body: TabBarView(
              children: requestStatuses.map((status) {
                return FutureBuilder(
                  future: requestController.getRequestsByStatusScout(scoutId, status),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Loading(); // عرض شاشة تحميل
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text("Error loading requests"));
                    }
                    var requests = snapshot.data;
                    return RefreshIndicator(
                      onRefresh: () async {
                        await requestController.getRequestsByStatus(scoutId, status);
                      },
                      child: ListView.builder(
                        itemCount: requests?.length ?? 0,
                        itemBuilder: (context, index) {
                          var request = requests?[index]['request'];
                          var coachName = requests?[index]['coachName'];
                          var requestDate = request.createdAt.toDate();
                          var modifiedDate = request.updatedAt.toDate();

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Card(
                              color: Colors.white10,
                              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                              child: ListTile(
                                title: Text('Request from $coachName', style:  TextStyle(color: Colors.white, fontFamily: 'play', fontWeight: FontWeight.w700, fontSize: 15)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 8),
                                    // Text('Status: ${request.requestStatus}', style: TextStyle(color: Colors.white54, fontSize: 12)),
                                    Text('Sent on: ${formatDateAch(requestDate)}', style: TextStyle(color: Colors.white54, fontSize: 12)),
                                    Text('Modified on: ${formatDateAch(modifiedDate)}', style: TextStyle(color: Colors.white54, fontSize: 12)),
                                    // Text('Since: ${timeAgo(requestDate)}', style: TextStyle(color: Colors.white54, fontSize: 12)),
                                  ],
                                ),
                                  trailing : Text('${timeAgo(requestDate)}', style: TextStyle(color: Colors.white54, fontSize: 12)),

                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              }).toList(),
            ),
      ),
    );
  }

  // دالة لحساب "منذ متى تم إرسال الريكوست"
  String timeAgo(DateTime timestamp) {
    Duration difference = DateTime.now().difference(timestamp);

    if (difference.inDays > 0) {
      return "${difference.inDays} days ago";
    } else if (difference.inHours > 0) {
      return "${difference.inHours} hours ago";
    } else if (difference.inMinutes > 0) {
      return "${difference.inMinutes} minutes ago";
    } else {
      return "Just now";
    }
  }

  // دالة لتحويل التاريخ إلى تنسيق "اليوم، الشهر"
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
