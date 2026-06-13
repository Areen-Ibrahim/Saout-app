import 'package:get/get.dart';
import 'package:get/get_instance/src/bindings_interface.dart';
import 'package:saoutapp/controllers/controller_coach/match_controller/add_match_controller.dart';
import 'package:saoutapp/controllers/controller_coach/match_controller/date_match_controller.dart';
import 'package:saoutapp/controllers/controller_coach/match_controller/update_match.dart';
import 'package:saoutapp/controllers/controller_scout/controller_scout_auth/user_controller.dart';

import 'controllers/controller_coach/player_controller/add_player_controller.dart';
import 'controllers/controller_coach/player_controller/update_player_controller.dart';
import 'controllers/controller_coach/sign_up_coach_controller.dart';
import 'controllers/controller_coach/team_controller.dart';
import 'controllers/controller_coach/update_page_coach_controller.dart';

class InitialBindings extends Bindings{
  @override
  void dependencies() {
    Get.lazyPut(() => UpdatePlayerController());

    Get.lazyPut<UserController>(() => UserController());
    Get.lazyPut<CoachController>(() => CoachController());
    Get.lazyPut<TeamController>(() => TeamController());
    Get.lazyPut<UpdateProfileController>(() => UpdateProfileController());
    Get.lazyPut<PlayerController>(() => PlayerController());
    Get.lazyPut<AddMatchController>(() => AddMatchController());
    Get.lazyPut<DateMatchController>(() => DateMatchController());
    Get.lazyPut<UpdateMatchController>(() => UpdateMatchController());
  }

}