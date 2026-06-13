import 'dart:async';
import 'dart:typed_data' as typed_data;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:saoutapp/controllers/controller_coach/match_controller/add_match_controller.dart';
import 'package:saoutapp/controllers/controller_coach/player_controller/update_player_controller.dart';
import 'package:saoutapp/core/loading.dart';
import 'package:saoutapp/view/homePage/screen/add_player/add_player_screen.dart';
import 'package:saoutapp/view/homePage/screen/home_page_coach/chart.dart';
import 'package:saoutapp/view/homePage/screen/home_page_coach/pdf_screen.dart';
import 'package:saoutapp/view/homePage/screen/home_page_coach/request_screen.dart';
import 'package:saoutapp/view/homePage/screen/update_player/update_player_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../controllers/controller_coach/player_controller/add_player_controller.dart';
import '../../../../controllers/controller_coach/sign_up_coach_controller.dart';
import '../../../../controllers/controller_coach/team_controller.dart';
import '../../../../core/color.dart';
import '../../../../core/network.dart';
import '../../widget/add_player_widget.dart';
import '../../widget/bottom_navigation_bar.dart';
import '../../widget/container_details_home_page.dart';
import '../../widget/image_profile.dart';
import '../../widget/players_list_home_page_widget.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class HomePageCoach extends StatefulWidget {
  const HomePageCoach({super.key});

  @override
  State<HomePageCoach> createState() => HomePageCoachState();
}

class HomePageCoachState extends State<HomePageCoach> {
  final PlayerController _playerController = Get.put(PlayerController());
  final UpdatePlayerController playerUpdateController = Get.put(UpdatePlayerController());
  final AddMatchController addMatchController = Get.put(AddMatchController());
  final CoachController _coachController = Get.put(CoachController());
  final TeamController _teamController = Get.put(TeamController());
  String _searchQuery = '';
  final List<String> _filterCriteria = []; // قائمة للفلترة
  bool sortByGoals = false; // حالة ترتيب الأهداف
  bool sortByAssists = false; // حالة ترتيب المساعدات
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
    _subscribeToConnectivityChanges();
    _checkConnection();
    _playerController.requestStoragePermission();

    String? passedCoachId = Get.arguments['coachId'];
    String? passedTeamId = Get.arguments['teamId'];

    if (passedTeamId != null) {
      _coachController.coachId.value = passedCoachId;
      _teamController.teamId.value = passedTeamId;

// جلب البيانات عند تعيين المعرفات
      _coachController.fetchCoachData();
      _teamController.fetchTeamData();
      _playerController.fetchPlayers(passedCoachId, passedTeamId);
      addMatchController.fetchMatches(passedCoachId, passedTeamId);
      playerUpdateController.fetchPlayerData(_playerController.playerId.value);
    }

    ever(addMatchController.totalMatchesCount, (value) {
      setState(() {});
    });
    _coachController.updateTokenInFirestore(_coachController.coachId.value);
    super.initState();
  }

  String _selectedTab = 'Home';

  void _onTabSelected(String tabName) {
    setState(() {
      _selectedTab = 'Home';
    });
  }
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: ColorApp.background,
        appBar: AppBar(
          backgroundColor: Colors.white10,
            leading: Obx(() {
              return Container(
                margin: EdgeInsets.only(left: 12),
                child: ImageProfile(
                playerImageUrl: _teamController.teamImage.value.isNotEmpty ? _teamController.teamImage.value : 'image/avatar.png',
                ),
              );
              }),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Welcome back!",
                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600, fontSize: 14),
              ),
              Obx(() {
                if (_coachController.coachName.value.isEmpty) {
                  return Text('Coach...',);
                }
                return Text(
                  _coachController.coachName.value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }),
            ],
          ),
          actions: [
            IconButton(
              onPressed: () {
                _scaffoldKey.currentState?.openDrawer();
              },
              icon: Icon(Icons.menu_open, color: Colors.white, size: 24),
            ),
            IconButton(
              onPressed: () {
                Future.delayed(Duration(milliseconds: 20), () {
                  Get.to(() => CoachRequestsPage(coachId: _coachController.coachId.value,),
                      transition: Transition.zoom,
                      duration: const Duration(milliseconds: 660));
                });
              },
              icon: Icon(Icons.request_page_outlined, color: Colors.white, size: 24),
            ),
          ],
                ),
        drawer: Drawer(
          backgroundColor: ColorApp.background,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                accountName: Text("${_coachController.coachName.value}"),
                accountEmail: Text("${_coachController.coachEmail.value}"), // استبدال الإيميل الفعلي إذا لزم الأمر
                currentAccountPicture: CircleAvatar(
                  backgroundImage:_getImageProvider(_teamController.teamImage.value),
                ),
                decoration: BoxDecoration(color: Colors.grey.shade900),
              ),
              _buildDrawerItem(
                icon: Icons.info,
                label: 'About Application',
                onTap: () {
                  // Navigator.of(context).pop();
                  _showAboutDialog(context);
                },
              ),

              _buildDrawerItem(
                icon: Icons.email,
                label: 'Contact via Email',
                onTap: () {
                  // Navigator.of(context).pop();
                  _contactByEmail();
                },
              ),

              _buildDrawerItem(
                icon: Icons.phone,
                label: 'Contact via WhatsApp',
                onTap: () {
                  // Navigator.of(context).pop();
                  _contactByWhatsApp();
                },
              ),
            Divider(color: Colors.white10,),
              _buildDrawerItem(
                icon: Icons.logout,
                label: 'Logout',
                onTap: () async {
                  // Navigator.of(context).pop();
                  await _coachController.logout();
                },
              ),
            ],
          ),
        ),

        body:  _isConnected // التحقق من حالة الاتصال
            ? Padding(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white60,
                        borderRadius: BorderRadius.circular(25)
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ContainerDetailsHomePage(
                                iconData: Icons.person,
                                numberSt: "${_playerController.getNumberOfPlayers()}",
                                textSt: 'Total Players',),
                              ContainerDetailsHomePage(
                                iconData: Icons.calculate,
                                numberSt: "${_playerController.getAverageAge().toStringAsFixed(1)}",
                                textSt: 'Average age',),
                            ],
                          ),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ContainerDetailsHomePage(
                                iconData: Icons.sports_soccer,
                                numberSt: "${addMatchController.totalMatchesCount}",
                                textSt: 'Total Matches',),
                              ContainerDetailsHomePage(
                                iconData: Icons.gamepad_outlined,
                                numberSt: "${_teamController.winningMatchesCount}",
                                textSt: 'winning Matches',),
                            ],
                          ),
                        ],
                      ).animate().scale(delay: 180.ms, duration: 460.ms),
                    ),
                    SizedBox(height: 20),
                    Container(
                      height: 700,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                "My Players",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  fontFamily: 'play',
                                  letterSpacing: 2
                                ),
                              ),
                              SizedBox(width: 12),
                            ],
                          ),
                          SizedBox(height: 24),
                          AddPlayerWidget(
                            onTap: () {
                              Future.delayed(Duration(milliseconds: 20), () {
                                Get.to(() => AddPlayerScreen(), arguments: {
                                  'coachId': _coachController.coachId.value,
                                  'teamId': _teamController.teamId.value,
                                },
                                    transition: Transition.rightToLeft,
                                    duration: const Duration(milliseconds: 770));
                              });

                            },
                            onTapDialog: () {
                              _showFilterDialog(context);
                            },
                            onChange: (value) {
                              setState(() {
                                _searchQuery = value.toLowerCase();
                              });
                            },
                            onTapRef: () {
                              resetFilters();
                            },
                          ).animate().shimmer(delay: 180.ms, duration: 460.ms),
                          SizedBox(height: 19),
                          Expanded(
                            child: FutureBuilder(
                              future: _playerController.fetchPlayers(_coachController.coachId.value, _teamController.teamId.value),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return Loading();
                                } else if (snapshot.hasError) {
                                  return Center(child: Text('Wrong${snapshot.error}'));
                                } else {
                                  if (_playerController.playersList.isEmpty) {
                                    return const Center(
                                      child: Text(
                                        'No players added yet.',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    );
                                  }

                                  List<dynamic> filteredPlayers = _playerController.playersList;

                                                // التحقق من وجود استعلام بحث
                                  if (_searchQuery.isNotEmpty) {
                                    filteredPlayers = filteredPlayers.where((player) {
                                      var playerName = "${player['firstName']} ${player['lastName']}".toLowerCase();
                                      return playerName.contains(_searchQuery);
                                    }).toList();
                                  }

                                                // تطبيق الفلاتر من قائمة الفلترة
                                  if (_filterCriteria.isNotEmpty) {
                                    for (var criteria in _filterCriteria) {
                                      if (criteria.startsWith('age:')) {
                                        var age = int.tryParse(criteria.split(':')[1]);
                                        if (age != null) {
                                          filteredPlayers = filteredPlayers.where((player) {
                                            return player['age'] != null && player['age'] == age;
                                          }).toList();
                                        }
                                      } else if (criteria == 'sortByGoals') {
                                        filteredPlayers.sort((a, b) => b['goals'].compareTo(a['goals']));
                                      } else if (criteria == 'sortByAssists') {
                                        filteredPlayers.sort((a, b) => b['assists'].compareTo(a['assists']));
                                      }
                                    }
                                  }

                                  return GridView.builder(
                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 10,
                                      mainAxisSpacing: 10,
                                      childAspectRatio: 0.8,
                                    ),
                                    itemCount: filteredPlayers.length,
                                    itemBuilder: (context, index) {
                                      var player = filteredPlayers[index];
                                      if (player == null || player['coachId'] == null) {
                                        return const Center(
                                          child: Text('Invalid player data.'),
                                        );
                                      }

                                      return PlayersListHomePageWidget(
                                        playerName: "${player['firstName']} ${player['lastName']}",
                                        playerCountry: player['city'],
                                        playerImageUrl: player['image'] ?? '',
                                        onTap: () {
                                          Future.delayed(Duration(milliseconds: 20), () {
                                            Get.to(() => UpdatePlayerScreen(), arguments: {
                                              'playerId': player['playerId'],
                                              'coachId': _playerController.coachId.value,
                                              'teamId': _playerController.teamId.value,
                                            },
                                                transition: Transition.rightToLeft,
                                                duration: const Duration(milliseconds: 770));
                                          });
                                        },
                                        onChart: () {
                                          Future.delayed(Duration(milliseconds: 20), () {
                                            Get.to(() => ChartPlayers(), arguments: {
                                              'playerId': player['playerId'],
                                              'position' : player['position'],
                                            },
                                                transition: Transition.zoom,
                                                duration: const Duration(milliseconds: 660));
                                          });
                                      },
                                        onFile: () {
                                          generatePlayerPDF(player);
                                        },

                                      ).animate().scale(delay: 180.ms, duration: 460.ms);
                                    },
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
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
        bottomNavigationBar: BottomNavigationBarWidget(
          selectedTab: _selectedTab,
          onTabSelected: _onTabSelected,
        ),
      ),
    );
  }
  void _showFilterDialog(BuildContext context) {
    final TextEditingController ageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Filter Players'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: ageController,
                decoration: InputDecoration(labelText: 'Player Age (6-18)'),
                keyboardType: TextInputType.number,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Sort by Goals'),
                  Checkbox(
                    value: sortByGoals,
                    onChanged: (value) {
                      setState(() {
                        sortByGoals = value ?? false; // Toggle state
                      });
                    },
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Sort by Assists'),
                  Checkbox(
                    value: sortByAssists,
                    onChanged: (value) {
                      setState(() {
                        sortByAssists = value ?? false; // Toggle state
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                int? age;
                if (ageController.text.isNotEmpty) {
                  age = int.tryParse(ageController.text);
                }

                // Clear previous filter criteria and update based on selections
                _filterCriteria.clear();
                if (age != null) {
                  _filterCriteria.add('age:$age');
                }
                if (sortByGoals) {
                  _filterCriteria.add('sortByGoals');
                }
                if (sortByAssists) {
                  _filterCriteria.add('sortByAssists');
                }

                // Apply the filters
                setState(() {}); // Refresh the UI to reflect changes

                Navigator.of(context).pop();
              },
              child: Text('Apply Filter'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("About application"),
          content: Text("Saout creates new opportunities for young football talents in Saudi Arabia, making it easier for professional clubs to scout, evaluate, and track players from school leagues and academies to prepare them for WORLD CUP 2034"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("إغلاق"),
            ),
          ],
        );
      },
    );
  }
  void _contactByEmail() async {
    final Uri emailLaunchUri = Uri(
        scheme: 'mailto',
        path: 'saout444@gmail.com',
        queryParameters: {
          'subject': 'Support Request'
        }
    );
    launch(emailLaunchUri.toString());
  }

  void _contactByWhatsApp() async {
    final String phoneNumber = '+963 953 419 647'; // ضع هنا رقم الهاتف المطلوب بصيغة دولية
    final Uri whatsappUri = Uri.parse("https://wa.me/$phoneNumber");

    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri);
    } else {
      // التعامل مع حالة عدم القدرة على فتح الرابط
      print("Could not launch WhatsApp");
    }
  }
  Widget _buildDrawerItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return AnimatedOpacity(
      opacity: 1.0,
      duration: Duration(milliseconds: 370),
      curve: Curves.easeIn,
      child: ListTile(
        leading: Icon(icon, color: Colors.white54),
        title: Text(
          label,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white54),
        ),
        onTap: onTap,
      ),
    ).animate().fadeIn(duration: 800.ms); // تأثير التلاشي (fade in)
  }
  void resetFilters() {
    setState(() {
      _searchQuery = '';
      _filterCriteria.clear(); // Clear the filters
      sortByGoals = false;     // Reset sort by goals
      sortByAssists = false;   // Reset sort by assists
    });
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
}
