import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:saoutapp/controllers/controller_coach/team_controller.dart';
import 'package:saoutapp/controllers/controller_scout/controller_scout_auth/user_controller.dart';
import 'package:saoutapp/controllers/controller_scout/details_controller/school_details_controller.dart';
import 'package:saoutapp/core/loading.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/color.dart';
import '../../../routes.dart';
import 'package:saoutapp/view/homePageScout/screen/chart_players_screen.dart';
import '../../homePage/widget/text_title_add_player.dart';
import '../screen/map.dart';

class DetailsTeam extends StatefulWidget {
  const DetailsTeam({super.key});

  @override
  State<DetailsTeam> createState() => _DetailsTeamState();
}

class _DetailsTeamState extends State<DetailsTeam> {
  final TeamController teamController = Get.put(TeamController());
  // final AllMatchesController allMatchesController = Get.put(AllMatchesController());
  final SchoolDetailsController schoolDetailsController = Get.put(SchoolDetailsController());
  late String teamId;
  final PageController _pageController = PageController();
  final UserController userController = Get.put(UserController());

  // متغير حالة الصفحة النشطة
  RxInt activePage = 0.obs;
  @override
  void initState() {
    super.initState();
    String? id = Get.arguments['teamId'];
    teamId = id;
    teamController.teamId.value = id;
    print('teamId : $teamId');
    }
  String _formatDate(Timestamp timestamp) {
    // تحويل الـ Timestamp إلى DateTime
    DateTime date = timestamp.toDate();

    // تنسيق التاريخ بالشكل المطلوب (يمكن تغييره حسب احتياجك)
    return DateFormat('yyyy-MM-dd').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorApp.background,
      appBar: AppBar(
        backgroundColor: Colors.white10,
        title: TextTitleAddPlayer(text: 'School Details',),
        iconTheme: IconThemeData(color: Colors.white, size: 20),

      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: schoolDetailsController.getTeamDetailsWithPlayerInfoSchool(teamId),
        builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Loading();
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading team details: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('team not found.'));
          } else {
            Map<String, dynamic> team = snapshot.data!;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      radius: 23,
                      backgroundImage: _getImageProvider(team['image']),
                    ),
                    title: Text('${team['teamName']}',
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                    subtitle: Text("Coach : ${team['coachName']}",
                        style: const TextStyle(
                          color: Colors.white,
                        )),
                    trailing:Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Obx(() {
                          bool isFollowing = userController.isFollowingTeam(teamId);
                          bool isLoading = userController.loadingTeamId.value == teamId;

                          return isLoading
                              ? const SizedBox(
                            width: 23,
                            height: 23,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                              : IconButton(
                            onPressed: () async {
                              await userController.toggleFollowTeams(userController.currentUserUid.value, teamId);
                            },
                            icon: Icon(
                              isFollowing ? Icons.check_circle : Icons.add_circle_outline_rounded,
                              color: isFollowing ? Colors.green : Colors.white,
                              size: 23,
                            ),
                          );
                        }),
                        // زر القائمة المنبثقة
                        PopupMenuButton<int>(
                          icon: Icon(
                            Icons.more_vert_rounded,
                            color: Colors.white, // لون الأيقونة
                          ),
                          onSelected: (value) {
                            if (value == 0) {
                              // الانتقال إلى الخريطة
                              double latitude = team['latitude'];
                              double longitude = team['longitude'];
                              String matchLocation = team['location'];

                              Future.delayed(Duration(milliseconds: 100), () {
                                Get.to(
                                      () => MapScreen(
                                      latitude: latitude,
                                      longitude: longitude,
                                      matchLocation: matchLocation),
                                  transition: Transition.zoom,
                                  duration: const Duration(milliseconds: 660),
                                );
                              });
                            } else if (value == 1) {
                              launchWhatsApp(team['coachPhone']);
                            } else if (value == 2) {
                              launchEmail(
                                toEmail: '${team['coachEmail']}',
                                subject: 'Hello, Team ${team['coachEmail']}',
                              );
                            }else if (value == 3) {
                              Future.delayed(Duration(milliseconds: 100), () {
                                Get.to(
                                      () =>ChartPlayersScreen(),
                                  arguments: {
                                    'teamId': teamId,
                                  },
                                  transition: Transition.zoom,
                                  duration: const Duration(milliseconds: 660),
                                );
                              });
                            }
                          },
                          itemBuilder: (context) => [
                            // زر الخريطة
                            PopupMenuItem<int>(
                              value: 0,
                              child: Row(
                                children: [
                                  Icon(Icons.map, color: Colors.greenAccent), // أيقونة الخريطة
                                  SizedBox(width: 8),
                                  Text("View on Map", style: TextStyle(color: Colors.white)), // تغيير النص إلى اللون الأبيض
                                ],
                              ),
                            ),
                            // زر الواتساب
                            PopupMenuItem<int>(
                              value: 1,
                              child: Row(
                                children: [
                                  Icon(Icons.message, color: Colors.green), // أيقونة الواتساب
                                  SizedBox(width: 8),
                                  Text("WhatsApp", style: TextStyle(color: Colors.white)), // تغيير النص إلى اللون الأبيض
                                ],
                              ),
                            ),
                            // زر البريد الإلكتروني
                            PopupMenuItem<int>(
                              value: 2,
                              child: Row(
                                children: [
                                  Icon(Icons.email, color: Colors.blue), // أيقونة البريد الإلكتروني
                                  SizedBox(width: 8),
                                  Text("Email", style: TextStyle(color: Colors.white)), // تغيير النص إلى اللون الأبيض
                                ],
                              ),
                            ),
                            PopupMenuItem<int>(
                              value: 3,
                              child: Row(
                                children: [
                                  Icon(Icons.bar_chart_outlined, color: ColorApp.orange), // أيقونة البريد الإلكتروني
                                  SizedBox(width: 8),
                                  Text("view Graph", style: TextStyle(color: Colors.white)), // تغيير النص إلى اللون الأبيض
                                ],
                              ),
                            ),
                          ],
                          // تعديل مظهر القائمة
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                              side: BorderSide(color: ColorApp.oasisGreen)

                          ),
                          color: Colors.black, // تغيير خلفية القائمة إلى اللون الأسود
                          elevation: 4,
                          padding: EdgeInsets.zero, // إزالة أي مسافة غير مرغوب فيها داخل القائمة
                          constraints: BoxConstraints(maxWidth: 200), // تخصيص عرض القائمة
                        )



                      ],
                    ),
                  ),
                  SizedBox(height: 50),
                  // أزرار التنقل بين الصفحات
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildPageButton('Overview', 0),
                      _buildPageButton('Players', 1),
                      _buildPageButton('Matches', 2),
                    ],
                  ),
                  SizedBox(height: 20),
                  // PageView لعرض الصفحات الثلاث
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (index) {
                        activePage.value = index;
                      },
                      children: [
                        // الصفحة الأولى - Overview
                        SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 12),
                              Text("${team['teamName']} Team", style: TextStyle(
                                color: ColorApp.richLavender,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),),
                              SizedBox(height: 20),
                              Text("${team['description']}",
                                  style: TextStyle(
                                      color: Colors.white,
                                      // fontWeight: FontWeight.w700,
                                      fontSize: 16)),
                              SizedBox(height: 12),
                              _buildInfo('Number of team players', '${team['playerCount'] != null ? team['playerCount'] : 0}'),
                              _buildInfo('Average age of team players',
                                  '${team['averageAge'] != null ? team['averageAge'].toStringAsFixed(0) : '0'}'),
                              _buildInfo('Number of team matches', '${team['totalMatchesCount'] != null ? team['totalMatchesCount'] : 0}'),
                              _buildInfo('Number of times the team wins', '${team.containsKey('totalWins') && team['totalWins'] != null ? team['totalWins'] : 0}'),

                              SizedBox(height: 16),
                            ],
                          ),
                        ),
                        // الصفحة الثانية - Players
                        Column(
                          children: [
                            Expanded(
                              child: (team['playerCount'] ?? 0) > 0  // تحقق إذا كان هناك لاعبين
                                  ? ListView.builder(
                                itemCount: team['playerCount'], // استخدام العدد المحسوب
                                itemBuilder: (context, index) {
                                  var playerInfo = team['playersInfo'][index]; // جلب تفاصيل اللاعب
                                  return Container(
                                    padding: EdgeInsets.all(8),
                                    margin: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                        color: Colors.white10,
                                        borderRadius: BorderRadius.circular(12)
                                    ),
                                    child: InkWell(
                                      onTap: (){
                                        Get.toNamed(AppRoutes.playerDetailScreen,arguments: {
                                          'playerId' : team['playersInfo'][index]['playerId'],
                                        });
                                      },
                                      child: ListTile(
                                        leading: CircleAvatar(
                                          backgroundImage: _getImageProvider(playerInfo['image']),
                                          radius: 22,
                                        ),
                                        title: Text('${playerInfo['firstName']} ${playerInfo['lastName']}', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),),
                                        subtitle: Text('Age: ${playerInfo['age']} - Position: ${playerInfo['position']}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w300, color: Colors.grey),),
                                      ),
                                    ),
                                  ).animate().fadeIn().slide(duration: 500.ms, curve: Curves.easeInOut);
                                },
                              ).animate().shimmer(delay: 100.ms, duration: 300.ms)
                                  :Center(
                                child: Text("The team has no players", style: TextStyle(color: Colors.white, fontSize: 14)),
                              ),
                            ),
                          ],
                        ),
                        // الصفحة الثالثة - Matches)
                        Column(
                          children: [
                            Expanded(
                              child:(team['matchesInfo']?.isNotEmpty ?? false)
                                  ? ListView.builder(
                                itemCount: team['matchesInfo']?.length ?? 0, // تأكد من وجود بيانات
                                itemBuilder: (context, index) {
                                  // التحقق من أن الفهرس صالح
                                  if (index >= 0 && index < team['matchesInfo'].length) {
                                    var matchInfo = team['matchesInfo'][index]; // جلب تفاصيل المباراة

                                    return Container(
                                      margin: EdgeInsets.all(12),
                                      padding: EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.white10,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: InkWell(
                                        onTap: () {
                                          Get.toNamed(AppRoutes.matchesDetailScreen, arguments: {
                                            'matchID': matchInfo['matchID'],
                                          });
                                        },
                                        child: ListTile(
                                          leading: CircleAvatar(
                                            backgroundImage: _getImageProviderTeam(matchInfo['opponentTeamImage']),
                                            radius: 22,
                                          ),
                                          title: Text(
                                            '${matchInfo['opponentTeamName']}',
                                            style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w700),
                                          ),
                                          subtitle: Text(
                                            'Date: ${_formatDate(matchInfo['matchDate'])}',
                                            style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w400),
                                          ),
                                        ),
                                      ),
                                    ).animate().fadeIn().slide(duration: 500.ms, curve: Curves.easeInOut);
                                  } else {
                                    // إرجاع حاوية فارغة إذا كان الفهرس غير صالح
                                    return Container();
                                  }
                                },
                              ).animate().shimmer(delay: 100.ms, duration: 300.ms)
                                  :Center(
                                child: Text(
                                    'The team has no matches',
                                    style: TextStyle(color: Colors.white, fontSize: 14)
                                ),

                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
  Widget _buildInfo(String title, String value) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
      ),
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        trailing: Container(
          padding: EdgeInsets.symmetric(vertical: 4, horizontal: 9),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
  // دالة لإنشاء الأزرار في الأعلى
  Widget _buildPageButton(String title, int pageIndex) {
    return Obx(() => Column(
      children: [
        TextButton(
          onPressed: () {
            _pageController.jumpToPage(pageIndex);
            activePage.value = pageIndex;
          },
          child: Text(
            title,
            style: TextStyle(
                color: activePage.value == pageIndex ? Colors.white : Colors.grey,
                fontWeight: FontWeight.w700, fontSize: 13, fontFamily: 'play'),
          ),
        ),
        if (activePage.value == pageIndex)
          Container(height: 2, width: 71, color: Colors.green),
      ],
    ));
  }
  ImageProvider _getImageProvider(String? profile) {
    if (profile != null && profile.isNotEmpty) {
      if (profile.startsWith('http')) {
        return NetworkImage(profile); // إذا كان الرابط من الإنترنت
      } else {
        return AssetImage("image/avatar.png"); // صورة افتراضية
      }
    } else {
      return AssetImage("image/avatar.png"); // صورة افتراضية
    }
  }
  ImageProvider _getImageProviderTeam(String? profile) {
    if (profile != null && profile.isNotEmpty) {
      if (profile.startsWith('http')) {
        return NetworkImage(profile);
      } else {
        return AssetImage("image/icon.png");
      }
    } else {
      return AssetImage("image/icon.png");
    }
  }
  Future<void> launchWhatsApp(String phoneNumber) async {
    final Uri whatsappUri = Uri(
      scheme: 'https',
      host: 'api.whatsapp.com',
      path: '/send',
      queryParameters: {
        'phone': phoneNumber, // رقم الهاتف مع كود الدولة
        'text': 'Hello',      // الرسالة الافتراضية
      },
    );
    await launchUrl(whatsappUri);
  }
  Future<void> launchEmail({
    required String toEmail,
    String subject = '',
    String body = '',
  }) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: toEmail,
      queryParameters: {
        'subject': subject,
        'body': body,
      },
    );
    await launchUrl(emailUri);
  }
}
// class MapScreen extends StatelessWidget {
//   final double latitude;
//   final double longitude;
//   final String matchLocation;
//
//   const MapScreen({Key? key, required this.latitude, required this.longitude, required this.matchLocation}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Match Location: $matchLocation'),
//       ),
//       body: GoogleMap(
//         initialCameraPosition: CameraPosition(
//           target: LatLng(latitude, longitude),
//           zoom: 14,
//         ),
//         markers: {
//           Marker(
//             markerId: MarkerId('matchLocation'),
//             position: LatLng(latitude, longitude),
//             infoWindow: InfoWindow(title: matchLocation),
//           ),
//         },
//       ),
//     );
//   }
// }
