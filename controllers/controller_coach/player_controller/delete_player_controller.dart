import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:saoutapp/controllers/controller_coach/player_controller/add_player_controller.dart';
import 'package:saoutapp/view/homePage/screen/add_player/add_player_screen.dart';

class DeletePlayerController extends GetxController{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final PlayerController playerController = Get.put(PlayerController());

  Future<void> removePlayerFromTeam(String playerId) async {
    try {
      // تحديث قائمة اللاعبين في جدول الفريق عبر إزالة المعرف
      await _firestore.collection('team').doc(playerController.teamId.value).update({
        'playersId': FieldValue.arrayRemove([playerId]) // إزالة اللاعب
      });
      print("Player removed from team's playersId successfully.");
    } catch (e) {
      print("Error removing player from team's playersList: $e");
    }
  }


  Future<void> deletePlayer(String playerId) async {
    if (playerId.isEmpty) {
      print('Player ID cannot be empty.');
      return;
    }

    try {
      // Get the player document
      DocumentSnapshot playerDoc = await _firestore.collection('players').doc(playerId).get();

      if (playerDoc.exists) {
        // Get the image and video URLs (if any) to delete them
        String? imageUrl = playerDoc['image'];
        String? videoUrl = playerDoc['videoUrl'];

        // Delete the player's document from Firestore
        await _firestore.collection('players').doc(playerId).delete();

        // Delete the image from Firebase Storage if it exists
        final Reference imageRef = FirebaseStorage.instance.refFromURL(imageUrl);
        await imageRef.delete();
      
        // Delete the video from Firebase Storage if it exists
        final Reference videoRef = FirebaseStorage.instance.refFromURL(videoUrl);
        await videoRef.delete();
      
        // Remove player from local list
        playerController.playersList.removeWhere((player) => player['playerId'] == playerId);
        update(); // Call update to refresh the UI
        await removePlayerFromTeam(playerId);
        Get.snackbar('Success', 'Player deleted successfully.',
            backgroundColor: Colors.green,
            colorText: Colors.white
        );
      } else {
        Get.snackbar('Error', 'Player not found.');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete player',
          backgroundColor: Colors.red,
          colorText: Colors.white
      );
      print(e);
    }
  }
}