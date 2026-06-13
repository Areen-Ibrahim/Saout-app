import 'dart:async';
import 'dart:core';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:saoutapp/controllers/controller_scout/get_data_controller/get_match.dart';
import 'package:saoutapp/view/homePageScout/details_screen/details_match.dart';
import '../../../controllers/get_opponent_teamImage_controller.dart';
import '../../../core/color.dart';
import '../../../core/loading.dart';
import '../widget/bottom_navigation.dart';
import '../widget/match_list.dart';
import 'package:flutter_animate/flutter_animate.dart';

class MatchesList extends StatefulWidget {
  const MatchesList({super.key});

  @override
  State<MatchesList> createState() => _MatchesListState();
}

class _MatchesListState extends State<MatchesList> with SingleTickerProviderStateMixin {
  final GetMatchController getMatchController = Get.put(GetMatchController());
  String _selectedTab = 'yesterday';
  String _selectedTabNav = 'Matches';
  DateTime _selectedDate = DateTime.now();
  late Future<List<Map<String, dynamic>>> _matchesFuture;
  late TabController _tabController;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  bool _isConnected = true;

  @override
  void initState() {
    super.initState();
    _subscribeToConnectivityChanges();
    _checkConnection();
    _tabController = TabController(length: 3, vsync: this);
    _matchesFuture = _fetchMatchesForSelectedTab();
  }

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
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> _fetchMatchesForSelectedTab() async {
    DateTime dateToFetch;
    if (_selectedTab == 'yesterday') {
      dateToFetch = DateTime.now().subtract(Duration(days: 1));
    } else if (_selectedTab == 'tomorrow') {
      dateToFetch = DateTime.now().add(Duration(days: 1));
    } else {
      dateToFetch = DateTime.now();
    }

    _selectedDate = dateToFetch;
    return getMatchController.getMatchesByDate(dateToFetch);
  }

  void _onTabSelected(String tabName) {
    setState(() {
      _selectedTab = tabName;
      _matchesFuture = _fetchMatchesForSelectedTab();
      if (tabName == 'yesterday') {
        _tabController.index = 0;
      } else if (tabName == 'today') {
        _tabController.index = 1;
      } else if (tabName == 'tomorrow') {
        _tabController.index = 2;
      }
    });
  }

  Future<void> _selectDate() async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    setState(() {
      _selectedDate = selectedDate;
      if (selectedDate.isBefore(DateTime.now())) {
        _onTabSelected('yesterday');
      } else if (_isSameDate(selectedDate, DateTime.now())) {
        _onTabSelected('today');
      } else {
        _onTabSelected('tomorrow');
      }
      _matchesFuture = getMatchController.getMatchesByDate(selectedDate);
    });
    }

  bool _isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: ColorApp.background,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white10,
          title: const Text(
            "All Matches",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon:  Icon(Icons.refresh, color: ColorApp.oasisGreen,),
              onPressed: () {
                setState(() {
                  _matchesFuture = _fetchMatchesForSelectedTab();
                });
              },
            ).animate().scale(duration: 600.ms, curve: Curves.easeInOut),
            IconButton(
              icon:  Icon(Icons.calendar_today, color: ColorApp.oasisGreen),
              onPressed: _selectDate,
            ).animate().scale(duration: 600.ms, curve: Curves.easeInOut),
          ],
          bottom: TabBar(
            controller: _tabController,
            onTap: (index) {
              _onTabSelected(['yesterday', 'today', 'tomorrow'][index]);
            },
            labelColor: ColorApp.oasisGreen,
            unselectedLabelColor: Colors.white24,
            indicatorColor: ColorApp.oasisGreen,
            tabs: const [
              Tab(text: "Yesterday"),
              Tab(text: "Today"),
              Tab(text: "Tomorrow"),
            ],
          ),
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            setState(() {
              _matchesFuture = _fetchMatchesForSelectedTab();
            });
          },
          child: _isConnected ?
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _matchesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Loading();
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No matches found.'));
              } else {
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> match = snapshot.data![index];
                    Timestamp matchTime = match['matchDate'] ?? Timestamp.now();
                    String matchFormation = match['matchFormation'] ?? 'N/A';
                    String opponentTeamName = match['opponentTeamName'] ?? 'Unknown Team';
                    int myResult = match['myResult'] ?? 0;
                    int opponentResult = match['opponentResult'] ?? 0;
                    String teamName = match['teamName'] ?? 'My Team';
                    String teamImage = match['image'] ?? '';
                    String matchId = match['matchID'] ?? '';
                    String image = match['opponentTeamImage'] ?? '';


                    return AnimatedOpacity(
                      duration: Duration(milliseconds: 500),
                      opacity: 1.0,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 18),
                        child: MatchList(
                          matchName: '$opponentTeamName vs $teamName',
                          result: '$opponentResult - $myResult',
                          position: 'Formation: $matchFormation',
                          profile: _getImageProvider(teamImage),
                          date: '${matchTime.toDate().toLocal()}',
                          profileOP: _getImageProvider(image), // استخدام الصورة المحدثة
                          onTap: () {
                            // Get.to(() => DetailsMatchScreen(), arguments: {
                            //   'matchID': matchId,
                            // });
                            Future.delayed(Duration(milliseconds: 100), () {
                              Get.to(() => DetailsMatchScreen(), arguments: {
                                'matchID': matchId,
                              },
                                  transition: Transition.rightToLeft,
                                  duration: const Duration(milliseconds: 660));
                            });
                          },
                        ).animate().fadeIn().slide(duration: 500.ms, curve: Curves.easeInOut),  // تأثير الفايد والسلايد
                      ).animate().shimmer(delay: 100.ms, duration: 300.ms),  // تأثير Stagger
                    );
                  },
                );
              }
            },
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
        ),
        bottomNavigationBar: BottomNavigationBarWidgetScout(
          selectedTab: _selectedTabNav,
          onTabSelected: (tab) => setState(() => _selectedTabNav = tab),
        ),
      ),
    );
  }

  ImageProvider _getImageProvider(String? profile) {
    if (profile != null && profile.isNotEmpty) {
      if (profile.startsWith('http')) {
        return NetworkImage(profile);
      } else {
        return const AssetImage("image/basicicon.png");
      }
    } else {
      return const AssetImage("image/basicicon.png");
    }
  }

}

