// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../../controllers/controller_scout/welcome_controller/all_players_controller.dart';
//
// class SearchPlayersScreen extends StatefulWidget {
//   const SearchPlayersScreen({super.key});
//
//   @override
//   State<SearchPlayersScreen> createState() => _SearchPlayersScreenState();
// }
//
// class _SearchPlayersScreenState extends State<SearchPlayersScreen> {
//   final AllPlayersController allPlayersController = Get.find();
//   String _searchQuery = ''; // استعلام البحث
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           "Search Players",
//           style: TextStyle(color: Colors.white),
//         ),
//         backgroundColor: Colors.blue,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(
//               onChanged: (value) {
//                 setState(() {
//                   _searchQuery = value; // تحديث استعلام البحث
//                 });
//               },
//               decoration: InputDecoration(
//                 hintText: 'Search by name or school...',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             SizedBox(height: 16.0),
//             Expanded(
//               child: GetBuilder<AllPlayersController>(
//                 builder: (controller) {
//                   // تصفية اللاعبين بناءً على استعلام البحث
//                   List<Map<String, dynamic>> filteredPlayers = controller.addedPlayers.where((player) {
//                     String playerName = '${player['firstName']} ${player['lastName']}';
//                     String schoolName = player['school'] ?? ''; // تأكد من أن المدرسة موجودة
//                     // تحقق مما إذا كان الاسم أو المدرسة تحتوي على استعلام البحث
//                     return playerName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
//                         schoolName.toLowerCase().contains(_searchQuery.toLowerCase());
//                   }).toList();
//
//                   if (filteredPlayers.isEmpty) {
//                     return Center(child: Text('No players found.')); // إذا لم يكن هناك لاعبين يطابقون البحث
//                   }
//
//                   return ListView.builder(
//                     itemCount: filteredPlayers.length,
//                     itemBuilder: (context, index) {
//                       Map<String, dynamic> player = filteredPlayers[index];
//                       return ListTile(
//                         title: Text('${player['firstName']} ${player['lastName']}'),
//                         subtitle: Text(player['school'] ?? ''),
//                         leading: CircleAvatar(
//                           backgroundImage: _getImageProvider(player['image']),
//                         ),
//                         onTap: () {
//                           // يمكنك إضافة إجراء عند الضغط على اللاعب
//                         },
//                       );
//                     },
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   ImageProvider _getImageProvider(String? profile) {
//     if (profile != null && profile.isNotEmpty) {
//       if (profile.startsWith('http')) {
//         return NetworkImage(profile); // إذا كان الرابط من الإنترنت
//       } else {
//         return AssetImage("image/avatar.png"); // صورة افتراضية
//       }
//     } else {
//       return AssetImage("image/avatar.png"); // صورة افتراضية
//     }
//   }
// }

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/color.dart';

class MapScreen extends StatelessWidget {
  final double latitude;
  final double longitude;
  final String matchLocation;

  const MapScreen({
    Key? key,
    required this.latitude,
    required this.longitude,
    required this.matchLocation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Match Location: $matchLocation', style: TextStyle(color: Colors.white),),
        backgroundColor: ColorApp.background,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(latitude, longitude),
          zoom: 14,
        ),
        markers: {
          Marker(
            markerId: MarkerId('matchLocation'),
            position: LatLng(latitude, longitude),
            infoWindow: InfoWindow(title: matchLocation),
          ),
        },
        // onMapCreated: (GoogleMapController controller) {
        //   controller.setMapStyle(mapStyle);
        // },
      ),
    );
  }

  // نمط الخريطة الداكن مع الألوان الجميلة
  final String _darkMapStyleWithColors = '''
  [
    {
      "elementType": "geometry",
      "stylers": [
        {
          "color": "#212121"
        }
      ]
    },
    {
      "elementType": "labels.icon",
      "stylers": [
        {
          "visibility": "off"
        }
      ]
    },
    {
      "elementType": "labels.text.fill",
      "stylers": [
        {
          "color": "#757575"
        }
      ]
    },
    {
      "elementType": "labels.text.stroke",
      "stylers": [
        {
          "color": "#212121"
        }
      ]
    },
    {
      "featureType": "administrative",
      "elementType": "geometry",
      "stylers": [
        {
          "color": "#757575"
        }
      ]
    },
    {
      "featureType": "administrative.country",
      "elementType": "labels.text.fill",
      "stylers": [
        {
          "color": "#9e9e9e"
        }
      ]
    },
    {
      "featureType": "administrative.land_parcel",
      "elementType": "labels.text.fill",
      "stylers": [
        {
          "color": "#bdbdbd"
        }
      ]
    },
    {
      "featureType": "poi",
      "elementType": "geometry",
      "stylers": [
        {
          "color": "#eeeeee"
        }
      ]
    },
    {
      "featureType": "poi",
      "elementType": "labels.text.fill",
      "stylers": [
        {
          "color": "#757575"
        }
      ]
    },
    {
      "featureType": "road",
      "elementType": "geometry",
      "stylers": [
        {
          "color": "#616161"
        }
      ]
    },
    {
      "featureType": "road",
      "elementType": "labels.icon",
      "stylers": [
        {
          "visibility": "off"
        }
      ]
    },
    {
      "featureType": "road",
      "elementType": "labels.text.fill",
      "stylers": [
        {
          "color": "#9e9e9e"
        }
      ]
    },
    {
      "featureType": "road",
      "elementType": "labels.text.stroke",
      "stylers": [
        {
          "color": "#212121"
        }
      ]
    },
    {
      "featureType": "road.highway",
      "elementType": "geometry",
      "stylers": [
        {
          "color": "#757575"
        }
      ]
    },
    {
      "featureType": "road.highway",
      "elementType": "labels.text.fill",
      "stylers": [
        {
          "color": "#616161"
        }
      ]
    },
    {
      "featureType": "road.highway",
      "elementType": "labels.text.stroke",
      "stylers": [
        {
          "color": "#212121"
        }
      ]
    },
    {
      "featureType": "transit",
      "elementType": "geometry",
      "stylers": [
        {
          "color": "#616161"
        }
      ]
    },
    {
      "featureType": "transit",
      "elementType": "labels.text.fill",
      "stylers": [
        {
          "color": "#757575"
        }
      ]
    },
    {
      "featureType": "transit",
      "elementType": "labels.text.stroke",
      "stylers": [
        {
          "color": "#212121"
        }
      ]
    },
    {
      "featureType": "water",
      "elementType": "geometry",
      "stylers": [
        {
          "color": "#00bcd4"  // اللون الأزرق للماء
        }
      ]
    },
    {
      "featureType": "water",
      "elementType": "labels.text.fill",
      "stylers": [
        {
          "color": "#3d3d3d"
        }
      ]
    },
    {
      "featureType": "landscape",
      "elementType": "geometry",
      "stylers": [
        {
          "color": "#2e7d32"  // اللون الأخضر للأراضي الطبيعية
        }
      ]
    }
  ]
  ''';
}

