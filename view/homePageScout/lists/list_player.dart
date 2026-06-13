import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:saoutapp/controllers/controller_scout/controller_scout_auth/user_controller.dart';
import 'package:saoutapp/view/homePageScout/widget/bottom_navigation.dart';
import '../../../core/color.dart';
import '../widget/lists/academy.dart';
import '../widget/lists/player.dart';
import '../widget/lists/school.dart';


class ListPlayer extends StatefulWidget {
  const ListPlayer({super.key});

  @override
  _ListPlayerState createState() => _ListPlayerState();
}

class _ListPlayerState extends State<ListPlayer> with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  final UserController userController = Get.find();
  String _selectedTab = 'Players';
  // PageController _pageController = PageController();
  late TabController _tabController;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  bool _isConnected = true;

  @override
  bool get wantKeepAlive => true;

  void _subscribeToConnectivityChanges() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) async {
      // إذا كانت القائمة تحتوي على نتيجة none
      if (results.isEmpty || results.first == ConnectivityResult.none) {
        setState(() {
          _isConnected = false;
        });
        _showNoConnectionSnackbar();
      } else {
        // تحقق من الاتصال الفعلي بالإنترنت
        bool hasConnection = await InternetConnectionChecker().hasConnection;
        setState(() {
          _isConnected = hasConnection;
        });

        if (!_isConnected) {
          _showNoConnectionSnackbar();
        }
      }
    });
  }


  void _showNoConnectionSnackbar() {
    Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off, size: 50, color: ColorApp.oasisGreen),
          SizedBox(height: 20),
          Text('No Internet Connection', style: TextStyle(fontSize: 12)),

        ],
      ),
    );
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel(); // إلغاء الاشتراك عند إغلاق الصفحة
    super.dispose();
  }

  Future<void> _checkConnection() async {
    bool hasConnection = await InternetConnectionChecker().hasConnection;
    setState(() {
      _isConnected = hasConnection;
    });
    if (!_isConnected) {
      _showNoConnectionSnackbar();
    }
  }
  @override
  void initState() {
    super.initState();
    _subscribeToConnectivityChanges();
    _checkConnection();
    _tabController = TabController(length: 3, vsync: this);

    // تعيين التاب المحدد عند بدء الصفحة
    setState(() {
      _selectedTab = 'Players'; // أو التاب الذي ترغب فيه
    });
  }


  @override
  Widget build(BuildContext context) {
    super.build(context); // لتمكين خاصية حفظ الحالة
    return Scaffold(
      backgroundColor: ColorApp.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white10,
        title: Text(
          "All List",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          labelColor: ColorApp.oasisGreen,
          unselectedLabelColor: Colors.white24,
          indicatorColor: ColorApp.oasisGreen,
          tabs: [
            Tab(text: "Players"),
            Tab(text: "School"),
            Tab(text: "Academy"),
          ],
        ),
      ),
      body:_isConnected?

      TabBarView(
        controller: _tabController,
        children: [
          PlayerWidgetList(),
          SchoolWidgetList(),
          AcademyWidgetList(),
        ],
      ):Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off, size: 50, color: ColorApp.oasisGreen),
            SizedBox(height: 20),
            Text('No Internet Connection', style: TextStyle(fontSize: 12)),

          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBarWidgetScout(
        selectedTab: _selectedTab,
        onTabSelected: (tab) => setState(() => _selectedTab = tab),
      ),
    );
  }

}
