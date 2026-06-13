import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:saoutapp/controllers/controller_scout/welcome_controller/all_players_controller.dart';
import 'package:saoutapp/core/loading.dart';
import '../../../controllers/controller_scout/controller_scout_auth/chart_player_controller.dart';
import '../../../core/color.dart';

class ChartPlayersScreen extends StatefulWidget {
  final String playerId;
  final String position;

  const ChartPlayersScreen({Key? key, required this.playerId, required this.position}) : super(key: key);

  @override
  State<ChartPlayersScreen> createState() => _ChartPlayersState();
}

class _ChartPlayersState extends State<ChartPlayersScreen> {
  final ChartPlayerController chartPlayerController = Get.put(ChartPlayerController());
  late String selectedMetric;
  late String selectedPlayerId;


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
    return chartPlayerController.fetchPlayerWithTeammates(widget.playerId);
  }

  @override
  void initState() {
    super.initState();
    selectedMetric = widget.position == 'Goalkeeper'
        ? goalkeeperMetrics.first
        : generalMetrics.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorApp.background,
      appBar: AppBar(
        backgroundColor: Colors.white10,
        title: Text(
          'Graph',
          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700),
        ),
        iconTheme: IconThemeData(color: Colors.white),
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
          final isGoalkeeper = widget.position == 'Goalkeeper';
          final metricsList = isGoalkeeper ? goalkeeperMetrics : generalMetrics;

          final filteredPlayers = isGoalkeeper
              ? playersData.where((player) => player['position'] == 'Goalkeeper').toList()
              : playersData.where((player) => player['position'] != 'Goalkeeper').toList();

          final maxMetricValue = filteredPlayers.map((player) {
            final value = player[selectedMetric];
            return value is int ? value.toDouble() : (value as double);
          }).reduce((a, b) => a > b ? a : b);

          return Scrollbar(
            thumbVisibility: true,
            trackVisibility: true,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
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
                  const SizedBox(height: 10), // تقليل المسافة بين الأسماء والخطوط البيانية
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.withOpacity(0.5), Colors.purple.withOpacity(0.5)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    height: 660, // ارتفاع الرسم البياني
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: maxMetricValue,
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
                                reservedSize: 60,
                                getTitlesWidget: (value, meta) {
                                  final index = value.toInt();
                                  if (index < filteredPlayers.length) {
                                    final player = filteredPlayers[index];
                                    final isSelected = player['playerId'].toString() == widget.playerId;
                                    return Container(
                                      margin: EdgeInsets.only(right: 10, top: 4), // تقليل المسافة العمودية
                                      child: Text(
                                        player['firstName'],
                                        style: TextStyle(
                                          color: isSelected ? Colors.purpleAccent : Colors.white, // تغيير اللون إلى زهري
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                        ),
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
                            selectedPlayerId = widget.playerId;
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
                                  color: barColor, // يجب أن يتم تعيين اللون هنا
                                  width: 4, // عرض الشريط
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
