import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:saoutapp/controllers/controller_coach/sign_up_coach_controller.dart';
import 'package:saoutapp/core/color.dart';
import '../../../controllers/controller_coach/team_controller.dart';
import '../../../core/next_button.dart';
import '../../../routes.dart';
import '../../signup/signupScout/widget/profile_picture.dart';
import '../../signup/signupScout/widget/text_form_field_widget.dart';

class CreateTeamView extends StatelessWidget {
  final TeamController _teamController = Get.put(TeamController());
  final CoachController _coachController = Get.find();

  final _formKey = GlobalKey<FormState>();
  final String defaultProfilePicture = 'image/avatarDefault.png';

  // قائمة خيارات teamType
  final List<String> teamTypeOptions = [
    'Academy Level A',
    'Academy Level B',
    'Academy Level C',
    'School Team',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorApp.blue,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Create Team',
                    style: TextStyle(
                      color: ColorApp.richLavender,
                      fontWeight: FontWeight.w700,
                      fontSize: 40,
                    ),
                  ),
                  SizedBox(height: 33),
                  Center(
                    child: ProfilePictureWidget(
                      pickImage: _teamController.pickImage,
                      image: _teamController.selectedImage,
                      defaultProfilePicture: _teamController.selectedImage.value?.path ?? defaultProfilePicture,
                    ),
                  ),
                  TextFormFieldWidget(
                    text: 'Team Name',
                    hint: 'Enter Team Name',
                    controller: _teamController.nameTeamController,
                    inputType: TextInputType.text,
                    validator: (value) => _teamController.validateField(value!, 'teamName'),
                  ),
                  GestureDetector(
                    onTap: () {
                      Get.to(() => MapScreenTeam()); // الانتقال إلى شاشة الخريطة
                    },
                    child: AbsorbPointer(
                      child: TextFormFieldWidget(
                        text: 'Location',
                        hint: 'Enter Location',
                        controller: _teamController.locationTeamController,
                        inputType: TextInputType.text,
                        validator: (value) => _teamController.validateField(value!, 'location'),
                      ),
                    ),
                  ),
                  TextFormFieldWidget(
                    text: 'Description',
                    hint: 'Enter Description',
                    controller: _teamController.descriptionController,
                    inputType: TextInputType.text,
                    validator: (value) => _teamController.validateField(value!, 'description'),
                  ),
                  const SizedBox(height: 20),
                  Obx(() {
                    return DropdownButtonFormField<String>(
                      value: _teamController.selectedTeamType.value.isNotEmpty
                          ? _teamController.selectedTeamType.value
                          : null,
                      hint: Text('Select Team Type'),
                      items: teamTypeOptions.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          _teamController.selectedTeamType.value = value; // تحديث القيمة المحددة في الكنترولر
                        }
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(color: Colors.black),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 20),
                  Obx(() {
                    return Align(
                      alignment: Alignment.centerRight,
                      child: NextButtonWidget(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            if (_teamController.selectedTeamType.value.isEmpty) {
                              Get.snackbar(
                                'Error',
                                'Select team type',
                                backgroundColor: Colors.red,
                                colorText: Colors.white,
                              );
                              return; // لا تتابع في حال كان نوع الفريق فارغًا
                            }

                            try {
                              await _teamController.createTeam(); // إنشاء الفريق
                              Get.offNamed(AppRoutes.homePage, arguments: {
                                'teamId': _teamController.teamId.value,
                                'coachId': _coachController.coachId.value,
                              }); // الانتقال للصفحة التالية بعد النجاح
                            } catch (e) {
                              Get.snackbar(
                                'Error',
                                e.toString(),
                                backgroundColor: Colors.red,
                                colorText: Colors.white,
                              );
                            }
                          }
                        },
                        loading: _teamController.isLoading.value,
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MapScreenTeam extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreenTeam> {
  final TeamController controller = Get.put(TeamController());

  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962), // الموقع الافتراضي
    zoom: 14.4746,
  );

  LatLng? selectedLocation; // لتخزين الموقع المحدد
  Marker? marker; // لتخزين إشارة الموقع
  TextEditingController _searchController = TextEditingController(); // حقل البحث
  List<String> _places = ["Place A", "Place B", "Place C"]; // قائمة ثابتة للأماكن
  List<String> _filteredPlaces = []; // الأماكن المفلترة بناءً على البحث

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

    if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
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

  void _filterPlaces(String query) {
    if (query.isNotEmpty) {
      setState(() {
        _filteredPlaces = _places.where((place) => place.toLowerCase().contains(query.toLowerCase())).toList();
      });
    } else {
      setState(() {
        _filteredPlaces.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select Location"),
        backgroundColor: Colors.green,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for places...',
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: _filterPlaces, // استدعاء دالة التصفية عند تغيير النص
            ),
          ),
        ),
      ),
      body: Column(
        children: [
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
          // عرض قائمة الأماكن المفلترة
          if (_filteredPlaces.isNotEmpty) Container(
            height: 200,
            child: ListView.builder(
              itemCount: _filteredPlaces.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_filteredPlaces[index]),
                  onTap: () {
                    // هنا يمكنك إضافة المنطق لنقل الكاميرا إلى الموقع المحدد
                    print("Selected Place: ${_filteredPlaces[index]}");
                    // هذا هو المكان الذي يمكنك فيه إضافة المنطق لتحريك الكاميرا إلى الموقع المحدد
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
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
      controller.locationTeamController.text = fullAddress;
    }
  }
}

