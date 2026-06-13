import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:saoutapp/core/color.dart';
import '../../../controllers/controller_coach/sign_up_coach_controller.dart';
import '../../../controllers/controller_coach/team_controller.dart';
import '../../../controllers/controller_coach/update_page_coach_controller.dart';
import '../../homePage/widget/bottom_navigation_bar.dart';
import '../../homePage/widget/text_title_add_player.dart';
import '../../login/loginScout/widget/text_form_login_widget.dart';

class UpdateProfileCoach extends StatefulWidget {
  @override
  _UpdateProfileCoachState createState() => _UpdateProfileCoachState();
}

class _UpdateProfileCoachState extends State<UpdateProfileCoach> with SingleTickerProviderStateMixin {
  final UpdateProfileController _updateProfileController = Get.put(UpdateProfileController());
  final CoachController _coachController = Get.find();
  final TeamController _teamController = Get.find();

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    String? passedCoachId = Get.arguments['coachId'];
    String? passedTeamId = Get.arguments['teamId'];

    _coachController.coachId.value = passedCoachId;
  
    _teamController.teamId.value = passedTeamId;
  
    // Fetch data after setting IDs
    _updateProfileController.fetchCoachData();
    _updateProfileController.fetchTeamData();
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorApp.background,
      appBar: AppBar(
        backgroundColor: Colors.white10,
        automaticallyImplyLeading: false,
        title: TextTitleAddPlayer(text: 'My Profile'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'My Information'),
            Tab(text: 'Team Information'),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: TabBarView(
          controller: _tabController,
          children: [
            // Tab 1: Personal Information
            _buildPersonalInfoTab(),
            // Tab 2: Team Information
            _buildTeamInfoTab(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBarWidget(
        selectedTab: "Profile",
        onTabSelected: (tab) {},
      ),
    );
  }

  Widget _buildPersonalInfoTab() {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            // Text("My Information", style: TextStyle(color: ColorApp.oasisGreen, fontSize: 20, fontWeight: FontWeight.w700)),
            SizedBox(height: 20),
            TextFormLoginWidget(
              text: 'User Name',
              hint: 'User Name',
              controller: _updateProfileController.userNameController,
              colorText: Colors.white,
              validator: (value) => value == null || value.isEmpty ? 'Please enter your name' : null,
              readOnly: false,
            ),
            TextFormLoginWidget(
              text: 'Phone Number',
              hint: 'Phone Number',
              controller: _updateProfileController.phoneNumberController,
              colorText: Colors.white,
              validator: (value) => _coachController.validateField(value!, "phoneNumber"),
              readOnly: false,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ButtonStyle(backgroundColor: MaterialStateProperty.all(ColorApp.oasisGreen)),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  await _updateProfileController.updateCoachAndTeam();
                }
              },
              child: Text('Update Profile', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamInfoTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          // Text("My Team Information", style: TextStyle(color: ColorApp.oasisGreen, fontSize: 20, fontWeight: FontWeight.w700)),
          SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              _updateProfileController.pickImage(); // Pick image
            },
            child: Obx(() {
              return Center(
                child: Container(
                  decoration: BoxDecoration(border: Border.all(color: ColorApp.yellow), shape: BoxShape.circle),
                  child: ClipOval(
                    child: _updateProfileController.profileImage.value != null
                        ? Image.file(_updateProfileController.profileImage.value!, width: 100, height: 100, fit: BoxFit.cover)
                        : _updateProfileController.imageUrl.isNotEmpty
                        ? Image.network(_updateProfileController.imageUrl, width: 100, height: 100, fit: BoxFit.cover)
                        : Icon(Icons.person, size: 100),
                  ),
                ),
              );
            }),
          ),
          SizedBox(height: 20),
          TextFormLoginWidget(
            text: 'Team Name',
            hint: 'Team Name',
            controller: _updateProfileController.teamNameController,
            colorText: Colors.white,
            validator: (value) => value == null || value.isEmpty ? 'Please enter your team name' : null,
            readOnly: false,
          ),
          TextFormLoginWidget(
            text: 'Team Location',
            hint: 'Team Location',
            controller: _updateProfileController.teamLocationController,
            colorText: Colors.white,
            validator: (value) => value == null || value.isEmpty ? 'Team Location is required' : null,
            onTap: () async {
              var selectedLocation = await Get.to(() => MapScreenTeam());
              if (selectedLocation != null) {
                _updateProfileController.latitudeController.text = selectedLocation.latitude.toString();
                _updateProfileController.longitudeController.text = selectedLocation.longitude.toString();
                List<Placemark> placemarks = await placemarkFromCoordinates(
                  selectedLocation.latitude,
                  selectedLocation.longitude,
                );

                if (placemarks.isNotEmpty) {
                  Placemark place = placemarks.first;
                  String fullAddress = '${place.name}, ${place.locality}, ${place.administrativeArea}, ${place.country}';
                  _updateProfileController.teamLocationController.text = fullAddress;
                }
              }
            },
            readOnly: true,
          ),
          TextFormLoginWidget(
            text: 'Team Description',
            hint: 'Team Description',
            controller: _updateProfileController.teamDescriptionController,
            colorText: Colors.white,
            validator: (value) => value == null || value.isEmpty ? 'Team Description' : null,
            readOnly: false,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            style: ButtonStyle(backgroundColor: MaterialStateProperty.all(ColorApp.oasisGreen)),
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                await _updateProfileController.updateCoachAndTeam();
              }
            },
            child: Text('Update Team Info', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class MapScreenTeam extends StatefulWidget {
  @override
  _MapScreenTeamState createState() => _MapScreenTeamState();
}

class _MapScreenTeamState extends State<MapScreenTeam> {
  final Completer<GoogleMapController> _mapController = Completer();
  LatLng? selectedLocation;
  Marker? currentMarker;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        selectedLocation = LatLng(position.latitude, position.longitude);
        currentMarker = Marker(
          markerId: MarkerId('current-location'),
          position: selectedLocation!,
        );
      });

      final GoogleMapController mapController = await _mapController.future;
      mapController.animateCamera(CameraUpdate.newLatLngZoom(selectedLocation!, 14));
    }
  }

  void _onMapTapped(LatLng position) {
    setState(() {
      selectedLocation = position;
      currentMarker = Marker(
        markerId: MarkerId('selected-location'),
        position: selectedLocation!,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Select Location")),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(0, 0),
          zoom: 2.0,
        ),
        onMapCreated: (GoogleMapController controller) {
          _mapController.complete(controller);
        },
        onTap: _onMapTapped,
        markers: currentMarker != null ? {currentMarker!} : {},
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (selectedLocation != null) {
            Get.back(result: selectedLocation);
          }
        },
        child: Icon(Icons.check),
      ),
    );
  }
}
