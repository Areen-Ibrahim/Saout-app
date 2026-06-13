import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class SearchPlayerController extends GetxController{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> searchPlayers(String query) async {
    QuerySnapshot querySnapshot = await _firestore
        .collection('players')
        .where('firstName', isGreaterThanOrEqualTo: query)
        .where('firstName', isLessThanOrEqualTo: query + '\uf8ff')
        .get();

    List<Map<String, dynamic>> players = querySnapshot.docs
        .map((doc) => {
      'id': doc.id, // تأكد من أنك تضيف معرف الوثيقة
      ...doc.data() as Map<String, dynamic>
    })
        .toList();

    return players;
  }
}