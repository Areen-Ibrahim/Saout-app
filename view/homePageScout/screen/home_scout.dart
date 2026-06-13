import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:saoutapp/controllers/controller_scout/controller_scout_auth/user_controller.dart';
import 'package:saoutapp/core/loading.dart';
import 'package:saoutapp/routes.dart';
import 'package:saoutapp/view/homePageScout/screen/request_screen_scout.dart';
import 'package:saoutapp/view/homePageScout/screen/update_profile.dart';
import '../../../controllers/controller_scout/welcome_controller/search_player.dart';
import '../../../core/color.dart';
import '../../homePage/screen/home_page_coach/request_screen.dart';
import '../lists/list_matches.dart';
import '../widget/bottom_navigation.dart';
import '../widget/home_page/high_light_widget.dart';
import '../widget/home_page/latest_match_widget.dart';
import '../widget/home_page/my_players_list_widget.dart';
import '../widget/home_page/my_team_list_widget.dart';
import '../widget/home_page/player_two_goals_widget.dart';
import '../widget/home_page/upcoming_widget.dart';
import '../lists/list_player.dart';


class HomeScout extends StatefulWidget {
  const HomeScout({super.key});

  @override
  State<HomeScout> createState() => _HomeScoutState();
}

class _HomeScoutState extends State<HomeScout> with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  // final AllPlayersController allPlayersController = Get.put(AllPlayersController());
  final UserController userController = Get.put(UserController());
  final SearchPlayerController searchController = Get.put(SearchPlayerController());
  String _selectedTab = 'Home';
  String _searchQuery = '';
  bool _isSearching = false;
  List<Map<String, dynamic>> _searchResults = [];
  late TabController _tabController;
  late Future<void> _initFuture;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  bool _isConnected = true;


  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _subscribeToConnectivityChanges();
    _checkConnection();
    _initializeTabController();
    _initFuture = _fetchFollowData();
  }



  Future<void> _fetchFollowData() async {
    String? userId = Get.arguments['userId'];
    if (_isConnected) {
      userController.currentUserUid.value = userId;
      await userController.fetchFollowList(); // جلب قائمة اللاعبين المتبعين
      await userController.fetchFollowListTeam(); // جلب قائمة الفرق المتبعة
    } else if (!_isConnected) {
      _showNoConnectionSnackbar(); // عرض رسالة إذا لم يكن هناك اتصال
    }
  }

  void _initializeTabController() {
    _tabController = TabController(length: 3, vsync: this);
  }

  void _searchPlayers() async {
    if (_searchQuery.isNotEmpty) {
      List<Map<String, dynamic>> results = await searchController.searchPlayers(_searchQuery);
      setState(() {
        _searchResults = results;
      });
    } else {
      setState(() {
        _searchResults = [];
      });
    }
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) _searchResults.clear();
    });
  }

  void _navigateToDetail(String? id, String routeName) {
    if (id != null) {
      Get.toNamed(AppRoutes.playerDetailScreen, arguments: {'playerId': id});
    }
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

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: ColorApp.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: _isSearching ? _buildSearchField() : _buildGreeting(),
        backgroundColor: Colors.white10,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search, color: Colors.white),
            onPressed: _toggleSearch,
          ),
          IconButton(
            icon: Icon(Icons.menu, color: Colors.white),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
        ],

        bottom: TabBar(
          controller: _tabController,
          labelColor: ColorApp.oasisGreen,
          unselectedLabelColor: Colors.white24,
          indicatorColor: ColorApp.oasisGreen,
          tabs: [
            Tab(text: "Trending"),
            Tab(text: "My Teams"),
            Tab(text: "My Players"),
          ],
        ),
      ),
      drawer: Drawer(
        backgroundColor: ColorApp.background,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _buildHeader(),
            ListTile(
              leading: Icon(Icons.home, color: Colors.white54,),
              title: Text('Home', style: TextStyle( color: Colors.white54),),
              onTap: () {
                Get.to(() =>
                    HomeScout());
              },
            ),
            ListTile(
              leading: Icon(Icons.person, color: Colors.white54),
              title: Text('Profile', style: TextStyle( color: Colors.white54),),
              onTap: () {
                Get.to(() =>
                    UpdateProfile(), arguments: {
                  'userId' : userController.currentUserUid.value
                });
              },
            ),
            ListTile(
              leading: Icon(Icons.list, color: Colors.white54),
              title: Text('All Players', style: TextStyle(color: Colors.white54)),
              onTap: () {
                Get.to(() => ListPlayer());
              },
              trailing: _playerCount(),
            ),
            ListTile(
              leading: Icon(Icons.request_page_outlined, color: Colors.white54),
              title: Text('Request',style: TextStyle( color: Colors.white54),),
              onTap: () {
                Get.to(() => ScoutRequestsPage(scoutId: userController.currentUserUid.value));
              },
            ),
            ListTile(
              leading: Icon(Icons.logout, color: ColorApp.red),
              title: Text('Logout',style: TextStyle( color: Colors.white54),),
              onTap: () {
                _showLogoutConfirmationDialog(context);
              },
            ),

          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBarWidgetScout(
        selectedTab: _selectedTab,
        onTabSelected: (tab) => setState(() => _selectedTab = tab),
      ),
      body: _isConnected ?
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: FutureBuilder<void>(
            future: _initFuture, // انتظار تحميل البيانات
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Loading(); // عرض مؤشر التحميل
              } else if (snapshot.hasError) {
                return Center(child: Text('Error loading data')); // عرض رسالة خطأ
              }

              // عرض القوائم عند وجود اتصال بالإنترنت
              return TabBarView(
                controller: _tabController,
                children: [
                  _isSearching
                      ? _buildSearchResults()
                      : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "LATEST MATCH ",
                                style: TextStyle(color: Colors.white54, fontSize: 16, letterSpacing: 2),
                              ),
                              IconButton(
                                onPressed: () {
                                  Future.delayed(Duration(milliseconds: 100), () {
                                    Get.to(
                                          () => MatchesList(),
                                      transition: Transition.rightToLeft,
                                      duration: const Duration(milliseconds: 660),
                                    );
                                  });
                                },
                                icon: Icon(Icons.arrow_forward),
                              ),
                            ],
                          ),
                        ),
                        FollowingTeamsListPage(ids: userController.followTeamList),
                        Align(
                          alignment: Alignment.topRight,
                          child: IconButton(
                            onPressed: () {
                              Future.delayed(Duration(milliseconds: 100), () {
                                Get.to(
                                      () => ListPlayer(),
                                  transition: Transition.rightToLeft,
                                  duration: const Duration(milliseconds: 660),
                                );
                              });
                            },
                            icon: Icon(Icons.arrow_forward),
                          ),
                        ),
                        PlayerTwoGoalsWidget(ids: userController.followList),
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                          child: Text(
                            "UPCOMING MATCH ",
                            style: TextStyle(color: Colors.white54, fontSize: 16, letterSpacing: 2),
                          ),
                        ),
                        UpcomingMatchesWidget(ids: userController.followTeamList),
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                          child: Text(
                            "HIGHLIGHTS",
                            style: TextStyle(color: Colors.white54, fontSize: 16, letterSpacing: 2),
                          ),
                        ),
                        HighlightsWidget(playerIds: userController.followList),
                      ],
                    ),
                  ),
                  _isSearching ? _buildSearchResults() : MyTeamListWidget(teamIds: userController.followTeamList),
                  _isSearching ? _buildSearchResults() : MyPlayersListWidget(playerIds: userController.followList),
                ],
              );
            },
          ),

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

    );
  }

  Widget _buildSearchField() {
    return TextField(
      onChanged: (query) {
        setState(() {
          _searchQuery = query;
        });
        _searchPlayers();
      },
      style: TextStyle(color: Colors.black),
      decoration: InputDecoration(
        hintText: 'Search...',
        hintStyle: TextStyle(color: Colors.grey),
        border: InputBorder.none,
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildGreeting() {
    return FutureBuilder<Map<String, String>>(
      future: userController.fetchFirstName(),
      builder: (context, snapshot) {
        String firstName = snapshot.data?['firstName'] ?? 'User';
        String lastName = snapshot.data?['lastName'] ?? '';
        String profilePicture = snapshot.data?['profilePicture'] ?? '';
        return ListTile(
          title: Text('Hi,', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w400, fontSize: 14),),
          subtitle: Text("${firstName} ${lastName}", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontFamily: 'play')),
          leading: CircleAvatar(
            backgroundImage: _getImageProvider(profilePicture),
          )
        );

      },
    );
  }

  Widget _buildHeader() {
    return FutureBuilder<Map<String, String>>(
      future: userController.fetchFirstName(),
      builder: (context, snapshot) {
        String firstName = snapshot.data?['firstName'] ?? 'User';
        String lastName = snapshot.data?['lastName'] ?? '';
        String email = snapshot.data?['email'] ?? '';
        String profilePicture = snapshot.data?['profilePicture'] ?? '';
        return UserAccountsDrawerHeader(
          accountName: Text("$firstName $lastName"),
          accountEmail: Text('${email}'), // استبدال الإيميل الفعلي إذا لزم الأمر
          currentAccountPicture: CircleAvatar(
            backgroundImage: _getImageProvider(profilePicture),
          ),
          decoration: BoxDecoration(color: Colors.grey.shade900),
        );
      },
    );
  }

  Widget _playerCount(){
    return FutureBuilder<int>(
      future: userController.fetchPlayerCount(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Loading();
        } else if (snapshot.hasError) {
          return Icon(Icons.error, color: Colors.red);
        } else {
          return Container(
            padding: EdgeInsets.symmetric(vertical: 2, horizontal: 7),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text("${snapshot.data ?? 0}", style: TextStyle(fontSize: 12),));
        }
      },
    );
  }

  Widget _buildSearchResults() {
    return _searchResults.isNotEmpty
        ? TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 470),
      builder: (context, double opacity, child) {
        return AnimatedOpacity(
          opacity: opacity,
          duration: Duration(milliseconds: 400),
          child: child,
        );
      },
      child: ListView.builder(
        itemCount: _searchResults.length,
        itemBuilder: (context, index) {
          var player = _searchResults[index];
          return ListTile(
            title: Text(
              "${player['firstName']} ${player['lastName']}",
              style: TextStyle(color: Colors.white),
            ),
            leading: CircleAvatar(
              backgroundImage: _getImageProvider(player['image'] ?? ''),
              radius: 40,
            ),
            subtitle: Text(player['lastName'], style: TextStyle(color: Colors.white)),
            onTap: () => _navigateToDetail(player['playerId'], AppRoutes.playerDetailScreen),
          );
        },
      ),
    )
        : Center(child: Text('No players found', style: TextStyle(color: Colors.black)));
  }

  ImageProvider _getImageProvider(String imageUrl) {
    if (imageUrl.isNotEmpty) {
      if (imageUrl.startsWith('http')) {
        return NetworkImage(imageUrl);
      } else {
        return FileImage(File(imageUrl));
      }
    } else {
      return AssetImage('image/icon.png');
    }
  }
  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Logout'),
          content: Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // إغلاق الـ Dialog دون تسجيل الخروج
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await userController.logout();
                Navigator.of(context).pop(); // إغلاق الـ Dialog بعد تسجيل الخروج
                Get.toNamed(AppRoutes.chooseUser);
              },
              child: Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}
