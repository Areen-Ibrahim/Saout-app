import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:saoutapp/controllers/controller_coach/player_controller/add_player_controller.dart';
import 'package:flutter/material.dart';
import 'package:saoutapp/core/loading.dart';
import '../../../../core/color.dart';

class ChartPlayers extends StatefulWidget {
  const ChartPlayers({super.key});

  @override
  State<ChartPlayers> createState() => _ChartPlayersState();
}

class _ChartPlayersState extends State<ChartPlayers> {
  final PlayerController _playerController = Get.find();
  late String selectedPlayerId;
  late String playerPosition;
  late String selectedMetric;

  final List<String> generalMetrics = [
    'goals', 'assists', 'shotsOnTarget', 'tackles', 'interceptions',
    'passAccuracy', 'dribblesCompleted', 'yellowCards', 'redCards',
    'foulGoals', 'penaltyGoals'
  ];

  final List<String> goalkeeperMetrics = [
    'cleanSheets', 'saves', 'penaltiesSaved', 'ownGoals', 'goalsConceded'
  ];

  Future<List<dynamic>> fetchPlayersData() async {
    await Future.delayed(const Duration(seconds: 2));
    return _playerController.playersList;
  }

  @override
  void initState() {
    super.initState();
    String? playerId = Get.arguments['playerId'];
    String? position = Get.arguments['position'];
    selectedPlayerId = playerId;
    playerPosition = position ?? 'Forward';
    print("Selected Player ID: $selectedPlayerId, Position: $playerPosition");

    selectedMetric = playerPosition == 'Goalkeeper'
        ? goalkeeperMetrics.first
        : generalMetrics.first;
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorApp.background,
      appBar: AppBar(
        backgroundColor: Colors.white10,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'Performance per Player',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: fetchPlayersData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Loading();
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No player data available.'));
          }

          final playersData = snapshot.data!;
          final isGoalkeeper = playerPosition == 'Goalkeeper';
          final metricsList = isGoalkeeper ? goalkeeperMetrics : generalMetrics;

          final filteredPlayers = isGoalkeeper
              ? playersData.where((player) => player['position'] == 'Goalkeeper').toList()
              : playersData.where((player) => player['position'] != 'Goalkeeper').toList();

          // احصل على أعلى قيمة للإحصائية المحددة بدون إضافة أي قيمة
          final maxMetricValue = filteredPlayers.map((player) {
            final value = player[selectedMetric];
            return value is int ? value.toDouble() : (value as double);
          }).reduce((a, b) => a > b ? a : b);

          // قم بتحديد قيم Y بشكل مرن لتناسب الأرقام الكبيرة
          final yInterval = maxMetricValue / 5; // تقسيم المحور Y إلى 5 فئات مرنة

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // const Text(
                //   'Performance per Player',
                //   style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                // ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<String>(
                    value: selectedMetric,
                    dropdownColor: ColorApp.background,
                    iconEnabledColor: Colors.white,
                    underline: SizedBox(),
                    items: metricsList.map((metric) {
                      return DropdownMenuItem(
                        value: metric,
                        child: Text(metric, style: TextStyle(color: Colors.white)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedMetric = value;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.withOpacity(0.5), Colors.purple.withOpacity(0.5)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: maxMetricValue, // استخدم القيمة القصوى بدون إضافة
                          barTouchData: BarTouchData(
                            enabled: true,
                            touchTooltipData: BarTouchTooltipData(
                              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                final player = filteredPlayers[group.x.toInt()];
                                return BarTooltipItem(
                                  '${player['firstName']}\n${player[selectedMetric]}',
                                  TextStyle(color: Colors.white),
                                );
                              },
                            ),
                          ),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    value.toInt().toString(),
                                    style: const TextStyle(color: Colors.white),
                                  );
                                },
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 38,
                                getTitlesWidget: (value, meta) {
                                  final index = value.toInt();
                                  if (index < filteredPlayers.length) {
                                    final player = filteredPlayers[index];
                                    final isSelected = player['playerId'].toString() == selectedPlayerId;
                                    return Text(
                                      player['firstName'],
                                      style: TextStyle(
                                        color: isSelected ? Colors.purpleAccent : Colors.white,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    );
                                  }
                                  return const Text('');
                                },
                              ),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          barGroups: filteredPlayers.asMap().entries.map((entry) {
                            final index = entry.key;
                            final player = entry.value;

                            Color barColor = player['playerId'].toString() == selectedPlayerId
                                ? Colors.purpleAccent
                                : Colors.blueAccent;

                            return BarChartGroupData(
                              x: index,
                              barRods: [
                                BarChartRodData(
                                  toY: player[selectedMetric] is int
                                      ? player[selectedMetric].toDouble()
                                      : (player[selectedMetric] as double),
                                  color: barColor,
                                  width: 20,
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
