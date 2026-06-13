import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/color.dart';
import '../models/RequestModel.dart';
import 'not_request_coach_controller.dart';


class RequestController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  RxBool isLoading = false.obs;
  var requestsByStatus = <String, RxList<Map<String, dynamic>>>{
    'pending': <Map<String, dynamic>>[].obs,
    'accepted': <Map<String, dynamic>>[].obs,
    'rejected': <Map<String, dynamic>>[].obs,
  };
  // إرسال طلب من الكشاف إلى المدرب
  Future<void> sendRequest(
      BuildContext context,
      String scoutId,
      String coachId,
      String teamId) async {
    try {
      // إنشاء مستند جديد في مجموعة 'requests' باستخدام معرف مستند فريد (requestId)
      var requestRef = _firestore.collection('requests').doc();

      // إعداد بيانات الريكوست مع معرف الريكوست الذي تم إنشاؤه تلقائيًا
      var request = RequestModel(
        requestId: requestRef.id, // استخدام المعرف الفريد للمستند كـ requestId
        scoutId: scoutId,
        coachId: coachId,
        teamId: teamId,
        requestStatus: 'pending', // حالة الريكوست الأولية تكون "معلق"
        createdAt: Timestamp.now(), // تحديد الوقت الحالي عند إرسال الطلب
        updatedAt: Timestamp.now(), // تحديث الوقت عند إرسال الطلب
      );

      // إضافة البيانات إلى Firestore
      await requestRef.set(request.toMap());
      print('Request sent successfully');

      // استرجاع التوكن الخاص بالمدرب من Firestore
      var coachSnapshot = await FirebaseFirestore.instance.collection('Coaches').doc(coachId).get();
      if (coachSnapshot.exists) {
        var coachData = coachSnapshot.data() as Map<String, dynamic>;
        String? coachToken = coachData['fcmToken'];

        if (coachToken != null) {
          // إرسال الإشعار للمدرب
          await PushNotificationsServiceCoach.sendNotificationsTo(
            coachToken,
            context,
            scoutId,
            'New Request Received',
            'You have received a new request from scout $scoutId',
            coachId,
          );
        }
      }

      Get.snackbar("Success", 'Request sent successfully',
          backgroundColor: ColorApp.oasisGreen,
          colorText: Colors.white
      );
    } catch (e) {
      print('Error sending request: $e');
      Get.snackbar("Error", 'Error sending request',
          backgroundColor: ColorApp.red,
          colorText: Colors.white
      );
    }
  }


  // جلب الريكوستات للمدرب حسب الحالة
  Future<void> getRequestsByStatus(String coachId, String status) async {
    try {
      isLoading.value = true;  // عند بدء التحميل
      QuerySnapshot snapshot = await _firestore
          .collection('requests')
          .where('coachId', isEqualTo: coachId)
          .where('requestStatus', isEqualTo: status)
          .get();

      List<Map<String, dynamic>> requestList = [];

      for (var doc in snapshot.docs) {
        var request = RequestModel.fromMap(doc.data() as Map<String, dynamic>);
        var scoutDetails = await getScoutName(request.scoutId);
        requestList.add({
          'request': request,
          'scoutDetails': scoutDetails,
        });
      }

      // تحديث الـ RxList الخاصة بالحالة المحددة
      requestsByStatus[status]?.value = requestList;
    } catch (e) {
      print("Error fetching requests: $e");
    } finally {
      isLoading.value = false;  // عند الانتهاء من التحميل
    }
  }
  // جلب بيانات الكشاف بناءً على `scoutId`
  Future<String> getScoutName(String scoutId) async {
    try {
      DocumentSnapshot snapshot = await _firestore.collection('Users').doc(scoutId).get();

      if (snapshot.exists) {
        String firstName = snapshot['firstName'] ?? 'Unknown';
        String lastName = snapshot['lastName'] ?? 'Name';
        return '$firstName $lastName';
      } else {
        print("Scout not found!");
        return "Unknown Name";
      }
    } catch (e) {
      print("Error fetching scout details: $e");
      return "Unknown Name";
    }
  }

  // تحديث حالة الريكوست في Firestore
// تحديث حالة الريكوست في Firestore
  Future<void> updateRequestStatus(BuildContext context, RequestModel request, String status) async {
    try {
      var requestId = request.requestId;

      // تحديث حالة الريكوست في Firestore
      await _firestore.collection('requests').doc(requestId).update({
        'requestStatus': status,
        'updatedAt': Timestamp.now(),
      });

      // إظهار رسالة نجاح
      Get.snackbar(
        'Success', 'Request $status successfully',
        snackPosition: SnackPosition.BOTTOM,
      );

      // جلب اسم المدرب والكشاف لإضافته إلى الإشعار
      String scoutName = await getScoutName(request.scoutId);
      String coachName = await getCoachName(request.coachId);

      // جلب توكن الكشاف من Firestore
      String scoutToken = await _getTokenFromUsers(request.scoutId);

      // إرسال إشعار للكشاف
      await PushNotificationsServiceCoach.sendNotificationsTo(
        scoutToken, // توكن الكشاف الذي تم جلبه من Firestore
        context,
        request.scoutId, // userId الخاص بالكشاف
        'Request $status', // عنوان الإشعار
        'Coach $coachName has $status your request', // محتوى الإشعار
        request.coachId, // الـ coachId لإضافة المزيد من البيانات للإشعار
      );

      // بعد التحديث بنجاح، نقوم بتحديث قائمة الريكوستات
      updateRequestList();

    } catch (e) {
      print("Error updating request status: $e");
      Get.snackbar(
        'Error', 'Error updating request status',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

// دالة لجلب التوكن من جدول المستخدمين
  // دالة لجلب التوكن من جدول المستخدمين
  Future<String> _getTokenFromUsers(String userId) async {
    final firestore = FirebaseFirestore.instance;
    DocumentSnapshot doc = await firestore.collection('Users').doc(userId).get();

    if (doc.exists && doc.data() != null) {
      // تحويل البيانات إلى Map لكي نتمكن من الوصول إليها
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      if (data.containsKey('fcmToken')) {
        return data['fcmToken'];
      } else {
        throw Exception("FCM Token not found for user $userId");
      }
    } else {
      throw Exception("User not found with ID $userId");
    }
  }




  // تحديث قائمة الريكوستات
  Future<void> updateRequestList() async {
    try {
      // جلب الريكوستات من جديد
      QuerySnapshot snapshot = await _firestore.collection('requests').get();

      List<Map<String, dynamic>> updatedRequests = [];

      for (var doc in snapshot.docs) {
        var request = RequestModel.fromMap(doc.data() as Map<String, dynamic>);
        var scoutDetails = await getScoutName(request.scoutId);
        updatedRequests.add({
          'request': request,
          'scoutDetails': scoutDetails,
        });
      }

      // تحديث الريكوستات في الـ RxList الخاصة بالحالات المختلفة
      for (var status in ['pending', 'accepted', 'rejected']) {
        requestsByStatus[status]?.value = updatedRequests.where((req) => req['request'].requestStatus == status).toList();
      }

    } catch (e) {
      print("Error fetching updated request list: $e");
    }
  }

  Future<List<Map<String, dynamic>>> getRequestsByStatusScout(String scoutId, String status) async {
    try {
      isLoading.value = true;  // عند بدء التحميل
      QuerySnapshot snapshot = await _firestore
          .collection('requests')
          .where('scoutId', isEqualTo: scoutId)
          .where('requestStatus', isEqualTo: status)
          .get();

      List<Map<String, dynamic>> requestList = [];

      for (var doc in snapshot.docs) {
        var request = RequestModel.fromMap(doc.data() as Map<String, dynamic>);
        var coachName = await getCoachName(request.coachId); // جلب اسم المدرب
        var scoutDetails = await getScoutName(request.scoutId);
        requestList.add({
          'request': request,
          'scoutDetails': scoutDetails,
          'coachName': coachName, // إضافة اسم المدرب إلى البيانات
        });
      }

      // إرجاع قائمة الريكوستات
      return requestList;

    } catch (e) {
      print("Error fetching requests: $e");
      return [];  // في حال وجود خطأ، نرجع قائمة فارغة
    } finally {
      isLoading.value = false;  // عند الانتهاء من التحميل
    }
  }

// جلب بيانات المدرب بناءً على `coachId`
  Future<String> getCoachName(String coachId) async {
    try {
      DocumentSnapshot snapshot = await _firestore.collection('Coaches').doc(coachId).get();

      if (snapshot.exists) {
        String firstName = snapshot['userName'] ?? 'Unknown';
        return '$firstName';
      } else {
        print("Coach not found!");
        return "Unknown Coach";
      }
    } catch (e) {
      print("Error fetching coach details: $e");
      return "Unknown Coach";
    }
  }

}
