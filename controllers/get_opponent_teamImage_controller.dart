// import 'dart:async';
//
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:internet_connection_checker/internet_connection_checker.dart';
//
// class HomeScout extends StatefulWidget {
//   const HomeScout({super.key});
//
//   @override
//   State<HomeScout> createState() => _HomeScoutState();
// }
//
// class _HomeScoutState extends State<HomeScout> {
//   late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
//   bool _isConnected = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _subscribeToConnectivityChanges();
//   }
//
//   void _subscribeToConnectivityChanges() {
//     _connectivitySubscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) async {
//       // إذا كانت القائمة تحتوي على نتيجة none
//       if (results.isEmpty || results.first == ConnectivityResult.none) {
//         setState(() {
//           _isConnected = false;
//         });
//         _showNoConnectionSnackbar();
//       } else {
//         // تحقق من الاتصال الفعلي بالإنترنت
//         bool hasConnection = await InternetConnectionChecker().hasConnection;
//         setState(() {
//           _isConnected = hasConnection;
//         });
//
//         if (!_isConnected) {
//           _showNoConnectionSnackbar();
//         }
//       }
//     });
//   }
//
//
//
//   void _showNoConnectionSnackbar() {
//     Get.snackbar(
//       'No Internet Connection',
//       'Please check your internet connection.',
//       backgroundColor: Colors.red,
//       colorText: Colors.white,
//     );
//   }
//
//   @override
//   void dispose() {
//     _connectivitySubscription.cancel(); // إلغاء الاشتراك عند إغلاق الصفحة
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Connectivity Check')),
//       body: Center(
//         child: _isConnected
//             ? Text('You are connected to the internet.')
//             : Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.wifi_off, size: 80, color: Colors.red),
//             SizedBox(height: 20),
//             Text('No Internet Connection', style: TextStyle(fontSize: 18)),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () => _checkConnection(),
//               child: Text('Retry'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // دالة لاختبار الاتصال بالإنترنت يدويًا عند الضغط على "Retry"
//   Future<void> _checkConnection() async {
//     bool hasConnection = await InternetConnectionChecker().hasConnection;
//     setState(() {
//       _isConnected = hasConnection;
//     });
//     if (!_isConnected) {
//       _showNoConnectionSnackbar();
//     }
//   }
// }
