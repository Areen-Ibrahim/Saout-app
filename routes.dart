import 'package:get/get.dart';
import 'package:saoutapp/view/chooseHome/screen/chooseHomeScreen.dart';
import 'package:saoutapp/view/homePage/screen/add_player/add_player_screen.dart';
import 'package:saoutapp/view/homePage/screen/add_player/goalkeeper_statistics.dart';
import 'package:saoutapp/view/homePage/screen/add_player/player_statistics.dart';
import 'package:saoutapp/view/homePage/screen/home_page_coach/chart.dart';
import 'package:saoutapp/view/homePage/screen/home_page_coach/home_page_coach.dart';
import 'package:saoutapp/view/homePage/screen/update_player/update_goalKeeper_statistics.dart';
import 'package:saoutapp/view/homePage/screen/update_player/update_player-statistics.dart';
import 'package:saoutapp/view/homePage/screen/update_player/update_player_screen.dart';
import 'package:saoutapp/view/homePageScout/details_screen/details_match.dart';
import 'package:saoutapp/view/homePageScout/details_screen/details_player.dart';
import 'package:saoutapp/view/homePageScout/details_screen/details_team.dart';
import 'package:saoutapp/view/homePageScout/details_screen/details_team_ac.dart';
import 'package:saoutapp/view/homePageScout/lists/home_lists/matches_by_team.dart';
import 'package:saoutapp/view/homePageScout/lists/home_lists/player_by_goals.dart';
import 'package:saoutapp/view/homePageScout/lists/list_matches.dart';
import 'package:saoutapp/view/homePageScout/screen/chart_players_screen.dart';
import 'package:saoutapp/view/homePageScout/screen/compare_player.dart';
import 'package:saoutapp/view/homePageScout/screen/home_scout.dart';
import 'package:saoutapp/view/homePageScout/lists/list_player.dart';
import 'package:saoutapp/view/homePageScout/screen/update_profile.dart';
import 'package:saoutapp/view/login/loginCoachScreen/screen/log_in_coach.dart';
import 'package:saoutapp/view/login/loginScout/screens/login_scout_screen.dart';
import 'package:saoutapp/view/match/screen/add_match_screen.dart';
import 'package:saoutapp/view/match/screen/match_result.dart';
import 'package:saoutapp/view/match/screen/home_match.dart';
import 'package:saoutapp/view/match/screen/match_screen_add_player.dart';
import 'package:saoutapp/view/resetPassword/screen/enter_email_reset_password.dart';
import 'package:saoutapp/view/resetPassword/screen/enter_new_password.dart';
import 'package:saoutapp/view/signup/signupCoach/screen/sign_up_coach.dart';
import 'package:saoutapp/view/signup/signupScout/screen/sign_up_scout_screen.dart';
import 'package:saoutapp/view/team/screen/create_team.dart';
import 'package:saoutapp/view/update/coach/update_profile_coach.dart';
import 'package:saoutapp/view/welcome/screen/welcome_screen.dart';



class AppRoutes {
  // ====================================Scout======================================
  // Auth Scout
  static const String chooseUser       = '/chooseUser';
  static const String welcomePage      = '/welcomePage';
  static const String loginScout       = '/login';
  static const String signupScout      = '/signup';

  // Reset Password
  static const String sendEmail        = '/sendEmail';
  static const String enterCode        = '/enterCode';
  static const String enterNewPassword = '/enterNewPassword';

  // Home Page
  static const String homePageScout       = '/homePageScout';
  // Players Lists Page
  static const String playersList         = '/playersList';
  static const String playerDetailScreen  = '/playerDetailScreen';
  static const String homeListsPlayer  = '/homeListsPlayer';
  // Matches List
  static const String matchesList          = '/matchesList';
  static const String matchesDetailScreen  = '/matchesDetailScreen';
  static const String homeListsMatch  = '/homeListsMatch';

  // profile
  static const String profile      = '/profile';
  // compare
  static const String compare      ='/compare';
  // team Details
  static const String detailsTeam      ='/detailsTeam';
  static const String detailsTeamAc      ='/detailsTeamAc';
  // chart
  static const String chartPlayersScreen      ='/chartPlayersScreen';








  // ====================================Coach======================================


  // Auth Coach
  static const String loginCoach       = '/loginCoach';
  static const String signupCoach      = '/signupCoach';
  // Create Team
  static const String createTeam       = '/createTeam';
  // update coach
  static const String updateCoach      = '/updateCoach';
  // Home Page
  static const String homePage         = '/homePage';
  // create a new player
  static const String newPlayer         = '/newPlayer';
  static const String playerStatistics           = '/player';
  static const String goalKeeperStatistics       = '/goalKeeper';
  // update player
  static const String updatePlayer       = '/updatePlayer';
  static const String updateGoalKeeperStatistics       = '/updateGoalKeeperStatistics';
  static const String updatePlayerStatistics       = '/updatePlayerStatistics';
  // matches
  static const String matchHome       = '/matchHome';
  static const String addMatch     = '/addMatch';
  static const String addMatchFormations      = '/addMatchFormations';
  static const String matchResultUpdate      = '/matchResultUpdate';
  static const String newPassword      = '/newPassword';
  static const String dateMatch      = '/dateMatch';
  // chartPlayer
  static const String chartPlayer      = '/chartPlayer';








  static List<GetPage> routes = [
    // ====================================Scout======================================

    GetPage(name: loginScout,  page: () =>  LoginScoutScreen()),
    GetPage(name: signupScout, page: () => SignupView()),
    GetPage(name: chooseUser,  page: () => ChooseHome()),
    GetPage(name: welcomePage, page: () => WelcomePage()),
    // Reset Password
    GetPage(name: sendEmail,   page: () => EnterEmailResetPassword()),
    // GetPage(name: enterCode, page: () => EnterCodeResetPassword()),
    GetPage(name: newPassword, page: () => EnterNewPassword()),
    GetPage(name: homePageScout,   page: () => HomeScout()),
    // Players Lists Page
    GetPage(name: playersList,           page: () => ListPlayer()),
    GetPage(name: playerDetailScreen,    page: () => PlayerDetailScreen()),
    GetPage(name: homeListsPlayer,    page: () => PlayerByGoals()),
    // Matches List page
    GetPage(name: matchesList,           page: () => MatchesList()),
    GetPage(name: matchesDetailScreen,   page: () => DetailsMatchScreen()),
    GetPage(name: homeListsMatch,   page: () => MatchesByTeam()),
    // profile
    GetPage(name: profile,   page: () => UpdateProfile()),
    // compare
    GetPage(name: compare,   page: () => ComparePlayer()),
    // detailsTeam
    GetPage(name: detailsTeam,   page: () => DetailsTeam()),
    GetPage(name: detailsTeamAc,   page: () => DetailsTeamAc()),
    // chart
    GetPage(name: chartPlayersScreen,   page: () => ChartPlayersScreen()),





    // ====================================Coach======================================

    // Auth Coach
    GetPage(name: loginCoach,  page: () => LoginCoachScreen()),
    GetPage(name: signupCoach, page: () => SignUpCoach()),
    // Create Team
    GetPage(name: createTeam,  page: () => CreateTeamView()),
    // update coach
    GetPage(name: updateCoach, page: () => UpdateProfileCoach()),
    // Home Pages
    GetPage(name: homePage,    page: () => HomePageCoach()),
    // create a new player
    GetPage(name: newPlayer,    page: () => AddPlayerScreen()),
    GetPage(name: playerStatistics,    page: () => PlayerStatistics()),
    GetPage(name: goalKeeperStatistics,    page: () => GoalkeeperStatistics()),
    // update player
    GetPage(name: updatePlayer,    page: () => UpdatePlayerScreen()),
    GetPage(name: updateGoalKeeperStatistics,    page: () => UpdateGoalkeeperStatistics()),
    GetPage(name: updatePlayerStatistics,    page: () => UpdatePlayerStatistics()),
    // matches
    GetPage(name: matchHome,    page: () => MatchesScreen()),
    GetPage(name: addMatch,    page: () => AddMatchScreen()),
    GetPage(name: addMatchFormations,    page: () => MatchScreenAddPlayer()),
    GetPage(name: matchResultUpdate,    page: () => MatchResultsScreen()),
    // chartPlayer
    GetPage(name: chartPlayer,    page: () => ChartPlayers()),







  ];
}
