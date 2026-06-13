import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:saoutapp/controllers/controller_coach/match_controller/add_match_controller.dart';
import 'package:saoutapp/controllers/controller_scout/welcome_controller/all_match_controller.dart';
import 'package:saoutapp/core/loading.dart';
import 'package:saoutapp/core/color.dart';
import 'package:saoutapp/view/match/screen/formatios/4-4-1-1.dart';
import '../screen/formations/F433.dart';
import '../screen/formations/F4231.dart';
import '../screen/formations/F4411.dart';
import '../screen/formations/F442.dart';
import '../screen/formations/F532.dart';
import '../screen/map.dart';

class DetailsMatchScreen extends StatefulWidget {
  const DetailsMatchScreen({super.key});

  @override
  State<DetailsMatchScreen> createState() => _DetailsMatchScreenState();
}

class _DetailsMatchScreenState extends State<DetailsMatchScreen> with SingleTickerProviderStateMixin {
  AddMatchController _addMatchController = Get.put(AddMatchController());
  AllMatchesController _allMatchesController = Get.put(AllMatchesController());
  late String matchId;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    String? id = Get.arguments['matchID'];
    matchId = Get.arguments['matchID'];
    _addMatchController.matchId.value = id;
    print('matchID ID: $id');
  
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorApp.background,
      appBar: AppBar(
        backgroundColor: Colors.white10,
        title: Text('Match Details', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
        iconTheme: IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          labelColor: ColorApp.oasisGreen,
          unselectedLabelColor: Colors.white24,
          indicatorColor: ColorApp.oasisGreen,
          tabs: const [
            Tab(text: 'LineUp'),
            Tab(text: 'Goals & Assists'),
            Tab(text: 'Location'),
          ],
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _allMatchesController.getDetailsMatch(matchId),
        builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Loading();
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading match details: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Match not found.'));
          } else {
            Map<String, dynamic> match = snapshot.data!;
            List<Map<String, dynamic>> players = match['playerDetails'];
            List<Map<String, dynamic>> goalsList = match['goalsList'] ?? [];
            String teamImage = match['image'] ?? 'image/avatar.png';
            String teamName = match['teamName'] ?? 'Unknown Team';
            String opponentTeamImage = match['opponentTeamImage'] ?? '';
            Map<String, String> playerNameMap = {
              for (var player in players)
                player['playerId']: "${player['firstName']} ${player['lastName']}",
            };

            Map<String, String> playerImageMap = {
              for (var player in players)
                player['playerId']: player['image'] ?? 'image/avatar.png', // رابط الصورة أو صورة افتراضية إذا لم توجد
            };
            String formation = match['matchFormation'];
            List<String> selectedPlayerImages = List.generate(11, (index) => '');
            List<String> selectedPlayerNames = List.generate(11, (index) => '');
            List<String> selectedPlayerNumbers = List.generate(11, (index) => '');

            for (int i = 0; i < players.length; i++) {
              if (i < 11) {
                selectedPlayerImages[i] = players[i]['image'] ?? '';
                selectedPlayerNames[i] = "${players[i]['firstName']} ${players[i]['lastName']}";
                selectedPlayerNumbers[i] = players[i]['playerNumber'].toString();
                selectedPlayerNumbers[i] = players[i]['playerId'];
              }
            }

            return Column(
              children: [
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildTeamInfoSection(match['opponentTeamName'], opponentTeamImage),
                    Row(
                      children: [
                        Text("${match['opponentResult']} - ", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
                        Text(match['myResult'].toString(), style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
                      ],
                    ),
                    _buildTeamInfoSection(teamName, teamImage),
                  ],
                ),
                SizedBox(height: 30),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // LineUp Tab
                      SingleChildScrollView(
                        child: Column(
                          children: [
                            Text(match['matchFormation'], style: TextStyle(color: ColorApp.richLavender, fontSize: 22, fontWeight: FontWeight.w700)),
                            _buildFormation(formation, selectedPlayerImages, selectedPlayerNames, selectedPlayerNumbers, goalsList, match['assisters']),
                          ],
                        ),
                      ),
                      // Goals and Assists Tab
                      SingleChildScrollView(
                        child: Column(
                          children: [
                            _buildGoalsSection(goalsList, players),
                            SizedBox(height: 20),
                            _buildPassesSection(match['assisters'], playerNameMap, playerImageMap),
                          ],
                        ),
                      ),
                      // Location Tab
                      SingleChildScrollView(
                        child: Column(
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                double latitude = match['latitude'];
                                double longitude = match['longitude'];
                                String matchLocation = match['matchLocation'];
                                Future.delayed(Duration(milliseconds: 100), () {
                                  Get.to(() => MapScreen(latitude: latitude, longitude: longitude, matchLocation: matchLocation), transition: Transition.zoom, duration: const Duration(milliseconds: 660));
                                });
                              },
                              child: Text('View the location'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildGoalsSection(List<Map<String, dynamic>> goalsList, List<Map<String, dynamic>> players) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Card(
        elevation: 8,
        color: Colors.grey[850],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Goals", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: ColorApp.richLavender)),
              Divider(color: Colors.white54),
              if (goalsList.isEmpty)
                Text("No goals scored.", style: TextStyle(color: Colors.white54))
              else
                ...goalsList.map((goal) {
                  String playerId = goal['playerId'];
                  String minute = goal['minute'].toString();
                  var player = players.firstWhere((player) => player['playerId'] == playerId, orElse: () => {'firstName': 'Unknown', 'lastName': 'Player', 'image': ''});
                  String fullPlayerName = "${player['firstName']} ${player['lastName']}";
                  String playerImage = player['image'];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Container(
                      decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(10)),
                      child: ListTile(
                        leading: playerImage.isNotEmpty
                            ? ClipOval(child: Image.network(playerImage, width: 40, height: 40, fit: BoxFit.cover))
                            : CircleAvatar(child: Icon(Icons.person, color: Colors.white), backgroundColor: Colors.grey),
                        title: Text(fullPlayerName, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                        subtitle: Text("Minute: $minute", style: TextStyle(color: Colors.white70)),
                      ),
                    ),
                  );
                }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPassesSection(List<String> assistProviders, Map<String, String> playerNameMap, Map<String, String> playerImageMap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Card(
        elevation: 8,
        color: Colors.grey[850],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Passes", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: ColorApp.richLavender)),
              Divider(color: Colors.white54),
              if (assistProviders.isEmpty)
                Text("No passes recorded.", style: TextStyle(color: Colors.white54))
              else
                ...assistProviders.map((providerId) {
                  String playerName = playerNameMap[providerId] ?? 'Unknown Player';
                  String playerImage = playerImageMap[providerId] ?? '';  // رابط الصورة للاعب
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Container(
                      decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(10)),
                      child: ListTile(
                        leading: playerImage.isNotEmpty
                            ? ClipOval(
                          child: Image.network(playerImage, width: 40, height: 40, fit: BoxFit.cover),
                        )
                            : CircleAvatar(
                          child: Icon(Icons.person, color: Colors.white),
                          backgroundColor: Colors.grey,
                        ),
                        title: Text(playerName, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  );
                }).toList(),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildFormation(String formation, List<String> selectedPlayerImages, List<String> selectedPlayerNames, List<String> selectedPlayerNumbers,List<Map<String, dynamic>> goalsList, List<String> assistProviders) {
    Map<String, List<Map<String, dynamic>>> playerGoals = {};
    for (var goal in goalsList) {
      String playerId = goal['playerId'];
      print(playerGoals);
      if (!playerGoals.containsKey(playerId)) {
        playerGoals[playerId] = [];
      }
      playerGoals[playerId]?.add(goal);
    }
    Map<String, List<String>> playerAssists = {};
    for (var assistId in assistProviders) {
      if (!playerAssists.containsKey(assistId)) {
        playerAssists[assistId] = [];
      }
      playerAssists[assistId]?.add(assistId);  // تخصيص المعرف حسب الحاجة
    }
    switch (formation) {
      case '4-3-3':
        return FourThreeThreeScout(selectedPlayerImages: selectedPlayerImages, selectedPlayerNames: selectedPlayerNames, selectedPlayerNumbers: selectedPlayerNumbers,  playerGoals: playerGoals, assistProviders: assistProviders);
      case '4-2-3-1':
        return FourTwoThreeOneScout(selectedPlayerImages: selectedPlayerImages, selectedPlayerNames: selectedPlayerNames, selectedPlayerNumbers: selectedPlayerNumbers,  playerGoals: playerGoals, assistProviders: assistProviders);
      case '4-4-1-1':
        return FourFourOneOneScout(selectedPlayerImages: selectedPlayerImages, selectedPlayerNames: selectedPlayerNames, selectedPlayerNumbers: selectedPlayerNumbers, playerGoals: playerGoals, assistProviders: assistProviders);
      case '4-4-2':
        return FourFourTwoScout(selectedPlayerImages: selectedPlayerImages, selectedPlayerNames: selectedPlayerNames, selectedPlayerNumbers: selectedPlayerNumbers,  playerGoals: playerGoals, assistProviders: assistProviders);
      case '5-3-2':
        return FiveThreeTwoScout(selectedPlayerImages: selectedPlayerImages, selectedPlayerNames: selectedPlayerNames, selectedPlayerNumbers: selectedPlayerNumbers, playerGoals: playerGoals, assistProviders: assistProviders);
      default:
        return Container();
    }
  }

  Widget _buildTeamInfoSection(String teamName, String? teamImage) {
    return Column(
      children: [
        teamImage != null
            ? ClipOval(child: Image.network(teamImage, width: 50, height: 50, fit: BoxFit.cover))
            : CircleAvatar(child: Icon(Icons.sports_soccer), backgroundColor: Colors.grey),
        SizedBox(height: 5),
        Text(teamName, style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
