import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:saoutapp/core/loading.dart';
import 'package:saoutapp/view/match/screen/add_match_screen.dart';
import 'package:saoutapp/view/match/screen/match_result.dart';
import '../../../controllers/controller_coach/fetch_current_team_details_controller.dart';
import '../../../controllers/controller_coach/match_controller/date_match_controller.dart';
import '../../../core/color.dart';
import '../../homePage/widget/bottom_navigation_bar.dart';
import '../../homePage/widget/text_title_add_player.dart';
import '../widget/card_widget_match.dart';

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key});

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateMatchController dateMatchController = Get.put(DateMatchController());
  FetchCurrentTeamDetailsController fetchCurrentTeamDetailsController = Get.put(FetchCurrentTeamDetailsController());

  List<Map<String, dynamic>> yesterdayMatches = [];
  List<Map<String, dynamic>> todayMatches = [];
  List<Map<String, dynamic>> tomorrowMatches = [];
  bool isLoading = false;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  bool _isConnected = true;

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

  String teamName = '';
  String teamImage = '';

  @override
  void initState() {
    super.initState();
    _subscribeToConnectivityChanges();
    _checkConnection();
    _tabController = TabController(length: 3, vsync: this);
    String? passedCoachId = Get.arguments['coachId'];
    String? passedTeamId = Get.arguments['teamId'];

    if (passedTeamId != null) {
      _fetchMatches(passedCoachId, passedTeamId);
      fetchCurrentTeamDetails(passedTeamId);

    } else {
      print("Error: One of the IDs is null.");
    }
  }

  Future<void> fetchCurrentTeamDetails(String teamID) async {
    var teamDetails = await fetchCurrentTeamDetailsController.fetchCurrentTeamDetails(teamID);
    setState(() {
      teamName = teamDetails['teamName']!;
      teamImage = teamDetails['image']!;
    });
  }

  Future<void> _fetchMatches(String coachId, String teamId) async {
    setState(() {
      isLoading = true;
    });

    await dateMatchController.fetchAndFilterMatches(coachId: coachId, teamId: teamId);
    _filterMatches(dateMatchController.matches);

    setState(() {
      isLoading = false;
    });
  }



  void _filterMatches(List<Map<String, dynamic>> matches) {
    setState(() {
      // Set default matches for yesterday and tomorrow
      yesterdayMatches = _filterByYesterday(matches);
      todayMatches = _filterByToday(matches);
      tomorrowMatches = _filterByTomorrow(matches);
    });
  }

  // Get matches for yesterday
  List<Map<String, dynamic>> _filterByYesterday(List<Map<String, dynamic>> matches) {
    DateTime yesterdayStart = DateTime.now().subtract(Duration(days: 1)).toLocal().copyWith(hour: 0, minute: 0, second: 0, millisecond: 0);
    DateTime yesterdayEnd = DateTime.now().subtract(Duration(days: 1)).toLocal().copyWith(hour: 23, minute: 59, second: 59, millisecond: 999);

    return matches.where((match) {
      DateTime matchDate = match['matchDate'].toDate();
      return matchDate.isAfter(yesterdayStart) && matchDate.isBefore(yesterdayEnd);
    }).toList();
  }

// Get matches for today
  List<Map<String, dynamic>> _filterByToday(List<Map<String, dynamic>> matches) {
    DateTime todayStart = DateTime.now().toLocal().copyWith(hour: 0, minute: 0, second: 0, millisecond: 0);
    DateTime todayEnd = DateTime.now().toLocal().copyWith(hour: 23, minute: 59, second: 59, millisecond: 999);

    return matches.where((match) {
      DateTime matchDate = match['matchDate'].toDate();
      return matchDate.isAfter(todayStart) && matchDate.isBefore(todayEnd);
    }).toList();
  }

// Get matches for tomorrow
  List<Map<String, dynamic>> _filterByTomorrow(List<Map<String, dynamic>> matches) {
    DateTime tomorrowStart = DateTime.now().add(Duration(days: 1)).toLocal().copyWith(hour: 0, minute: 0, second: 0, millisecond: 0);
    DateTime tomorrowEnd = DateTime.now().add(Duration(days: 1)).toLocal().copyWith(hour: 23, minute: 59, second: 59, millisecond: 999);

    return matches.where((match) {
      DateTime matchDate = match['matchDate'].toDate();
      return matchDate.isAfter(tomorrowStart) && matchDate.isBefore(tomorrowEnd);
    }).toList();
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorApp.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white10,
        title: TextTitleAddPlayer(text: 'Matches'),

        actions: [
          IconButton(
            onPressed: _selectDate,
            icon: Icon(Icons.calendar_today, color: ColorApp.oasisGreen, size: 17,),
          ),
          IconButton(
            onPressed: _resetMatches,
            icon: Icon(Icons.refresh, color: ColorApp.oasisGreen, size: 21,),
          ),
        ],
        iconTheme: const IconThemeData(
          color: Colors.white,

        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: ColorApp.oasisGreen,
          unselectedLabelColor: Colors.white24,
          indicatorColor: ColorApp.oasisGreen,
          labelStyle: TextStyle(fontFamily: 'play', letterSpacing: 1),
          tabs: const [
            Tab(text: 'Previous'),
            Tab(text: 'Today'),
            Tab(text: 'Upcoming'),
          ],
        ),
      ),
      body: _isConnected?
      TabBarView(
        controller: _tabController,
        children: [
          _buildMatchList(yesterdayMatches, 'Yesterday\'s Matches'),
          _buildMatchList(todayMatches, 'Today\'s Matches'),
          _buildMatchList(tomorrowMatches, 'Tomorrow\'s Matches'),
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
      bottomNavigationBar: BottomNavigationBarWidget(
        selectedTab: 'Matches',
        onTabSelected: (tabName) {},
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Future.delayed(Duration(milliseconds: 20), () {
            Get.to(() => AddMatchScreen(), arguments: {
              'coachId': Get.arguments['coachId'],
              'teamId': Get.arguments['teamId'],
            },
                transition: Transition.zoom,
                duration: const Duration(milliseconds: 770))?.then((_) async {
              // هنا يتم تنفيذ جلب البيانات مرة واحدة فقط عند العودة
              await _fetchMatches(Get.arguments['coachId'], Get.arguments['teamId']);
            });
          });

        },
        backgroundColor: ColorApp.oasisGreen,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    // Determine which tab to switch to
    if (picked.isBefore(DateTime.now())) {
      _tabController.index = 0; // Yesterday
      await _fetchMatchesByDate(picked, Get.arguments['coachId'], Get.arguments['teamId'], 'yesterday');
    } else if (_isSameDate(picked, DateTime.now())) {
      _tabController.index = 1; // Today
      await _fetchMatchesByDate(picked, Get.arguments['coachId'], Get.arguments['teamId'], 'today');
    } else {
      _tabController.index = 2; // Tomorrow
      await _fetchMatchesByDate(picked, Get.arguments['coachId'], Get.arguments['teamId'], 'tomorrow');
    }
    }

  Future<void> _fetchMatchesByDate(DateTime date, String coachId, String teamId, String tab) async {
    setState(() {
      isLoading = true;
    });

    await dateMatchController.fetchAndFilterMatches(date: date, coachId: coachId, teamId: teamId);
    _filterMatches(dateMatchController.matches); // Filter matches based on the selected date

    // Update matches based on the selected tab
    if (tab == 'yesterday') {
      yesterdayMatches = dateMatchController.matches; // Update yesterday matches with the fetched ones
    } else if (tab == 'today') {
      todayMatches = dateMatchController.matches; // Update today matches with the fetched ones
    } else {
      tomorrowMatches = dateMatchController.matches; // Update tomorrow matches with the fetched ones
    }

    setState(() {
      isLoading = false;
    });
  }

  void _resetMatches() {
    _fetchMatches(Get.arguments['coachId'], Get.arguments['teamId']);
  }

  Widget _buildMatchList(List<Map<String, dynamic>> matches, String title) {
    if (isLoading) {
      return Loading();
    }

    if (matches.isEmpty) {
      return Center(
        child: Text(
          'No matches available for this date.',
          style: TextStyle(color: Colors.white),
        ),
      );
    }
   return ListView.builder(
      padding: EdgeInsets.only(top: 13),
      itemCount: matches.length,
      itemBuilder: (context, index) {
        // String teamName = matches[index]['teamName'] ?? '';
        String opponentName = matches[index]['opponentTeamName']  ?? '';
        String matchStr = '$teamName vs $opponentName';
        String matchId = matches[index]['matchID'];
        var matchDate = matches[index]['matchDate'];
        // String teamImage = matches[index]['image'];
        String opponentImage = matches[index]['image'] ?? '';
        String date;
        if (matchDate is Timestamp) {
          date = matchDate.toDate().toIso8601String();
        } else if (matchDate is DateTime) {
          date = matchDate.toIso8601String();
        } else {
          date = matchDate.toString();
        }



        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          child: GestureDetector(
            onTap: () {
              Future.delayed(Duration(milliseconds: 20), () {
                Get.to(() => MatchResultsScreen(), arguments: {
                  'matchID': matchId,
                  'coachId': Get.arguments['coachId'],
                  'teamId': Get.arguments['teamId'],
                },
                    transition: Transition.zoom,
                    duration: const Duration(milliseconds: 770));
              });
            },
            child: CardWidgetMatch(
              matchStr: matchStr,
              date: date,
              imageOne: teamImage,
              title: title,
              imageTwo: opponentImage,
            ),
          ),
        );
      },
    );
  }

  bool _isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }
}
