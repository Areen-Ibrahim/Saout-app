import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:saoutapp/controllers/controller_coach/match_controller/add_match_controller.dart';
import 'package:saoutapp/controllers/controller_coach/sign_up_coach_controller.dart';
import 'package:saoutapp/controllers/controller_coach/team_controller.dart';
import 'package:saoutapp/routes.dart';
import '../../../core/color.dart';
import 'match_screen_add_player.dart';

class AddMatchScreen extends StatefulWidget {
  const AddMatchScreen({super.key});

  @override
  State<AddMatchScreen> createState() => _AddMatchScreenState();
}

class _AddMatchScreenState extends State<AddMatchScreen> {
  final TeamController _teamController = Get.find();
  final CoachController _coachController = Get.find();
  final AddMatchController _controller = Get.put(AddMatchController());
  List<Map<String, String>> _teams = [];
  String _selectedTeam = '';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _clearFields();
      _fetchTeams();
    });
    String? passedCoachId = Get.arguments['coachId'];
    String? passedTeamId = Get.arguments['teamId'];

    if (passedTeamId != null) {
      _coachController.coachId.value = passedCoachId;
      _teamController.teamId.value = passedTeamId;
    }
  }

  void _fetchTeams() {
    _controller.fetchTeams().then((teams) {
      setState(() {
        _teams = teams;
      });
    });
  }

  void _clearFields() {
    _controller.opposingTeamController.clear();
    _controller.locationController.clear();
    _controller.myResultController.clear();
    _controller.opponentResultController.clear();
    _controller.selectedDate.value = '';
    _controller.selectedTime.value = '';
    _controller.selectedPlayerIDs.clear();
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorApp.background,
      appBar: AppBar(
        backgroundColor: Colors.white10,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          "Add Match",
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              // Opposing team input
              _buildTeamDropdownField(
                "Opposing Team",
                _controller.opposingTeamController,
                _teams,
                    (value) {
                  setState(() {
                    _selectedTeam = value;
                  });
                },
              ),
              SizedBox(height: 20),
              // Date picker
              Obx(() => _buildDateField("Date", _controller.selectedDate.value, () => _controller.selectDate(context), Icons.calendar_today)),
              SizedBox(height: 20),
              // Time picker
              Obx(() => _buildDateField("Time", _controller.selectedTime.value, () => _controller.selectTime(context), Icons.timelapse)),
              SizedBox(height: 20),
              // Location input
              _buildLocationField(),
              SizedBox(height: 20),
              // Results input
              _buildResultsRow(),
              SizedBox(height: 20),
              // Button to save match details
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final imageFile = _controller.opponentTeamImage.value;
                    if (imageFile != null) {
                      print("Image saved: ${imageFile.path}");
                    } else {
                      print("No image to save");
                    }
                    Future.delayed(Duration(milliseconds: 20), () {
                      Get.to(() => MatchScreenAddPlayer(),
                          arguments: {
                            'opposingTeamName': _controller.opposingTeamController.text,
                            'goals': int.tryParse(_controller.myResultController.text),
                            'coachId': _coachController.coachId.value,
                            'teamId': _teamController.teamId.value,
                          },
                          transition: Transition.rightToLeft,
                          duration: const Duration(milliseconds: 770));
                    });
                  }
                },
                child: Text("Next", style: TextStyle(color: ColorApp.oasisGreen)),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, TextInputType keyboardType) {
    return TextFormField(
      controller: controller,
      style: TextStyle(color: Colors.white),
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: ColorApp.oasisGreen),
        filled: true,
        fillColor: Colors.grey[800],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Enter $label";
        }
        return null;
      },
    );
  }

  Widget _buildTeamDropdownField(
      String label,
      TextEditingController controller,
      List<Map<String, String>> teams,
      Function(String) onChanged,
      ) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: controller,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: label,
              labelStyle: TextStyle(color: ColorApp.oasisGreen),
              filled: true,
              fillColor: Colors.grey[800],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: ColorApp.oasisGreen, width: 2),
              ),
              suffixIcon: PopupMenuButton<String>(
                icon: Icon(Icons.arrow_drop_down, color: ColorApp.oasisGreen),
                onSelected: (value) {
                  setState(() {
                    controller.text = value;
                    // إذا تم اختيار فريق من القائمة، يتم تعيين الصورة
                    var selectedTeam = teams.firstWhere((team) => team['teamName'] == value, orElse: () => {});
                    String? imageUrl = selectedTeam['image'];
                    if (imageUrl != null && imageUrl.isNotEmpty) {
                      // حفظ الصورة
                      _controller.loadOpponentImage(imageUrl);
                    } else {
                      _controller.opponentTeamImage.value = null; // إزالة الصورة إذا لم تكن موجودة
                    }
                  });
                  onChanged(value);
                },
                itemBuilder: (context) {
                  return teams.map((team) {
                    return PopupMenuItem<String>(
                      value: team['teamName'],
                      child: Row(
                        children: [
                          team['image'] != null && team['image']!.isNotEmpty
                              ? CircleAvatar(
                            backgroundImage: NetworkImage(team['image']!),
                            radius: 16,
                          )
                              : Container(),
                          SizedBox(width: 10),
                          Text(
                            team['teamName'] ?? '',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    );
                  }).toList();
                },
                elevation: 5,
                color: ColorApp.background,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Enter $label";
              }
              return null;
            },
            onChanged: (text) {
              // إذا تم إدخال اسم فريق يدويًا، يتم إلغاء أي صورة موجودة
              setState(() {
                _controller.opponentTeamImage.value = null;
              });
            },
          ),
        ),
      ],
    );
  }



  Widget _buildDateField(String label, String hint, VoidCallback onTap, IconData icon) {
    return TextFormField(
      style: TextStyle(color: Colors.white),
      readOnly: true,
      onTap: onTap,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: ColorApp.oasisGreen),
        labelStyle: TextStyle(color: ColorApp.oasisGreen),
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white),
        filled: true,
        fillColor: Colors.grey[800],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) {
        if (hint.isEmpty) {
          return '$label is required';
        }
        return null;
      },
    );
  }

  Widget _buildLocationField() {
    return GestureDetector(
      onTap: () {
        Get.to(() => MapScreen());
      },
      child: AbsorbPointer(
        child: TextFormField(
          controller: _controller.locationController,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: "Location",
            labelStyle: TextStyle(color: ColorApp.oasisGreen),
            filled: true,
            fillColor: Colors.grey[800],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Enter location";
            }
            return null;
          },
        ),
      ),
    );
  }

  Widget _buildResultsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: _buildTextField("Opposing Result", _controller.opponentResultController, TextInputType.number)),
        SizedBox(width: 10),
        Expanded(child: _buildTextField("Your Result", _controller.myResultController, TextInputType.number)),
      ],
    );
  }
}

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final AddMatchController controller = Get.put(AddMatchController());

  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962), // الموقع الافتراضي
    zoom: 14.4746,
  );

  LatLng? selectedLocation; // لتخزين الموقع المحدد
  Marker? marker; // لتخزين إشارة الموقع
  TextEditingController searchController = TextEditingController(); // تحكم في حقل البحث

  @override
  void initState() {
    super.initState();
    _getCurrentLocation(); // الحصول على الموقع الحالي عند بدء التطبيق
  }

  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        selectedLocation = LatLng(position.latitude, position.longitude);
        controller.latitude.value = position.latitude; // تحديث خطوط العرض
        controller.longitude.value = position.longitude; // تحديث خطوط الطول
        _moveCameraToCurrentLocation(); // تحريك الكاميرا إلى الموقع الحالي
      });
    }
  }

  void _moveCameraToCurrentLocation() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLng(selectedLocation!));
  }

  Future<void> _searchLocation(String query) async {
    try {
      List<Location> locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        final newLocation = LatLng(locations.first.latitude, locations.first.longitude);
        setState(() {
          selectedLocation = newLocation;
          marker = Marker(
            markerId: MarkerId('searched-location'),
            position: newLocation,
          );
        });
        final GoogleMapController mapController = await _controller.future;
        mapController.animateCamera(CameraUpdate.newLatLng(newLocation));
      }
    } catch (e) {
      // تعامل مع الأخطاء
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select Location"),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search for a location",
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    _searchLocation(searchController.text);
                  },
                ),
                border: OutlineInputBorder(),
              ),
              onSubmitted: (value) {
                _searchLocation(value);
              },
            ),
          ),
          Expanded(
            child: GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: _kGooglePlex,
              markers: marker != null ? {marker!} : {},
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              onTap: (LatLng latLng) {
                _onMapTapped(latLng);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // تحقق مما إذا كان المستخدم قد حدد موقعًا
          if (selectedLocation != null) {
            print("Saved Location: Latitude: ${selectedLocation!.latitude}, Longitude: ${selectedLocation!.longitude}");
          } else {
            await _getCurrentLocation();
            print("Current Location Saved: Latitude: ${controller.latitude.value}, Longitude: ${controller.longitude.value}");
          }
          Get.back(); // العودة إلى الصفحة السابقة
        },
        child: Icon(Icons.save),
      ),
    );
  }

  void _onMapTapped(LatLng latLng) async {
    setState(() {
      controller.latitude.value = latLng.latitude; // تحديث خطوط العرض
      controller.longitude.value = latLng.longitude; // تحديث خطوط الطول
    });

    print("==================================Selected Location: Latitude: ${latLng.latitude}, Longitude: ${latLng.longitude}");

    // إضافة إشارة عند النقر
    setState(() {
      marker = Marker(
        markerId: MarkerId('selected-location'),
        position: latLng,
      );
    });

    List<Placemark> placemarks = await placemarkFromCoordinates(latLng.latitude, latLng.longitude);
    if (placemarks.isNotEmpty) {
      Placemark place = placemarks.first;
      String fullAddress = '${place.name}, ${place.locality}, ${place.administrativeArea}, ${place.country}';

      print("Full Location Details: $fullAddress");

      // تحديث حقل الموقع بالتفاصيل الكاملة
      controller.locationController.text = fullAddress;
    }
  }
}
