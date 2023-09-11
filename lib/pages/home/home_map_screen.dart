import 'dart:async';

import 'package:client_control_car/constants/constants.dart';
import 'package:client_control_car/constants/route_helper.dart';
import 'package:client_control_car/controllers/auth_controller.dart';
import 'package:client_control_car/controllers/control_controller.dart';
import 'package:client_control_car/pages/info_vehicule/info_vehicule_screen.dart';
import 'package:client_control_car/pages/menu/drawer_widget.dart';
import 'package:client_control_car/pages/menu/menu_bottom.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:loading_overlay/loading_overlay.dart';

class HomeMapScreen extends StatefulWidget {
  const HomeMapScreen({Key? key}) : super(key: key);

  @override
  State<HomeMapScreen> createState() => _HomeMapScreenState();
}

class _HomeMapScreenState extends State<HomeMapScreen> {
  TextEditingController searchController = TextEditingController();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  String? currentAddress;
  Position? currentPosition;
  Set<Marker> listMarker = {};
  Set<Circle> listCircle = {};

  CameraPosition kGooglePlex = const CameraPosition(
    target: LatLng(47.442685, 2.273293),
    zoom: 6.4746,
  );

  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    check();
    getCurrentPosition();
  }

  getCurrentPosition() async {
    AuthController authController = Get.find();

    final hasPermission = await handleLocationPermission();
    if (!hasPermission) {
      setState(() {
        listCircle.clear();
        listCircle = {
          Circle(
              circleId: CircleId((DateTime.now().second + 100).toString()),
              center: const LatLng(47.442685, 2.273293),
              radius: 10000,
              fillColor: greyColor.withOpacity(.7),
              strokeColor: greyColor.withOpacity(.9),
              strokeWidth: 1
              // strokeWidth: (sizeWidth(context:context)*.3).toInt()
              )
        };
      });
      authController
          .getAddressFromGeocode(
        latLng: const LatLng(47.442685, 2.273293),
      )
          .then((value) {
        setState(() {
          isLoading = false;
          searchController.text = value;
        });
      }).catchError((onError) {
        setState(() {
          isLoading = false;
          searchController.text = "";
        });
      });
      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(kGooglePlex));
      setState(() {});
      return;
    } else {
      Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
          .then((Position position) async {
        currentPosition = position;
        // isLoading = false;
        kGooglePlex = CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 10,
        );
        // getAddressFromLatLng(position: position);
        listMarker.clear();
        listMarker.add(
          Marker(
            markerId: MarkerId(
                "${position.latitude}-${position.longitude}-${DateTime.now().second}"),
            position: LatLng(position.latitude, position.longitude),
          ),
        );
        listCircle.clear();
        listCircle = {
          Circle(
              circleId: CircleId((DateTime.now().second + 100).toString()),
              center: LatLng(position.latitude, position.longitude),
              radius: 10000,
              fillColor: greyColor.withOpacity(.7),
              strokeColor: greyColor.withOpacity(.9),
              strokeWidth: 1
              // strokeWidth: (sizeWidth(context:context)*.3).toInt()
              )
        };
        authController
            .getAddressFromGeocode(
          latLng: LatLng(position.latitude, position.longitude),
        )
            .then((value) {
          setState(() {
            searchController.text = value;
          });
        }).catchError((onError) {
          setState(() {
            searchController.text = "";
          });
        });
        // get list technicien
        getListTechniciens(curentPosition: position);
        final GoogleMapController controller = await _controller.future;
        controller.animateCamera(CameraUpdate.newCameraPosition(kGooglePlex));

        setState(() {});
      }).catchError((e) {
        setState(() {
          isLoading = false;
          listCircle.clear();
          listCircle = {
            Circle(
                circleId: CircleId((DateTime.now().second + 100).toString()),
                center: const LatLng(47.442685, 2.273293),
                radius: 10000,
                fillColor: greyColor.withOpacity(.7),
                strokeColor: greyColor.withOpacity(.9),
                strokeWidth: 1
                // strokeWidth: (sizeWidth(context:context)*.3).toInt()
                )
          };

          isLoading = false;
        });
      });
    }
  }

  getListTechniciens({required Position curentPosition}) {
    ControlController controlController = Get.find();
    controlController.currentPosition = currentPosition;
    controlController.getListTechniciensController().then((value) {
      setState(() {
        isLoading = false;
      });

      if (value.isSuccess) {
        for (var element in controlController.listTechniciens) {
          if (element.location_x.toString() != 'null' &&
              element.location_y.toString() != "null") {
            listMarker.add(
              Marker(
                markerId: MarkerId(
                    "${element.location_x}-${element.location_y}-${DateTime.now().second}"),
                position: LatLng(double.parse(element.location_x.toString()),
                    double.parse(element.location_y.toString())),
                infoWindow: InfoWindow(
                  title:
                      '${element.userModel!.first_name} ${element.userModel!.last_name}',
                  snippet: "Technicien",
                ),
              ),
            );
          }
        }
      } else {}
      Get.offAll(() => const InfoVehiculeScreen(),
          routeName: RouteHelper.getInfoVehiculeRoute());
    }).catchError((onError) {
      Get.offAll(() => const InfoVehiculeScreen(),
          routeName: RouteHelper.getInfoVehiculeRoute());
    });
  }

  Future<void> getAddressFromLatLng({required Position position}) async {
    await placemarkFromCoordinates(position.latitude, position.longitude)
        .then((List<Placemark> placemarks) {
      Placemark place = placemarks[0];
      setState(() {
        currentAddress =
            '${place.street}, ${place.subLocality},${place.subAdministrativeArea}, ${place.postalCode}';
        searchController.text = currentAddress!;
      });
    }).catchError((e) {});
  }

  Future<bool> handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Get.showSnackbar(const GetSnackBar(
        message:
            "Les services de localisation sont désactivés. Veuillez activer les services",
      ));
      // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      //     content: Text(
      //         'Les services de localisation sont désactivés. Veuillez activer les services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Get.showSnackbar(const GetSnackBar(
          message: "Les autorisations de localisation sont refusées",
        ));
        // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        //     content: Text('Les autorisations de localisation sont refusées')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      Get.showSnackbar(const GetSnackBar(
        message:
            "Les autorisations de localisation sont définitivement refusées, nous ne pouvons pas demander d'autorisations.",
      ));
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(
      //     content: Text(
      //         ""),
      //   ),
      // );
      return false;
    }
    return true;
  }

  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      key: scaffoldKey,
      extendBodyBehindAppBar: true,
      drawer: StreamBuilder<QuerySnapshot>(
          stream: firebaseFirestore.collection("notification").snapshots(),
          builder: (context, snapshotNotif) {
            int countMessage = 0;
            int countNotif = 0;
            if (snapshotNotif.hasData) {
              if (snapshotNotif.data!.docs.isNotEmpty) {
                AuthController authController = Get.find();
                String access =
                    authController.userModel!.access.toString() == "null"
                        ? authController.accessUserJWS.toString()
                        : authController.userModel!.access.toString();
                Map<String, dynamic> payload = Jwt.parseJwt(access);
                int msgCont = 0;
                int ntfCont = 0;
                for (var element in snapshotNotif.data!.docs) {
                  if (element["type"].toString().toLowerCase() ==
                      "Nouveau message".toLowerCase()) {
                    if (element["isvue"].toString() == "false" &&
                        payload["user_id"].toString() ==
                            element["user"].toString()) {
                      msgCont++;
                    }
                  } else {
                    if (element["isvue"].toString() == "false" &&
                        payload["user_id"].toString() ==
                            element["user"].toString()) {
                      ntfCont++;
                    }
                  }
                }
                countMessage = msgCont;
                countNotif = ntfCont;
              }
            }
            return DrawerWidget(
              countMessage: countMessage,
              countNotification: countNotif,
              onThen: () {
                setState(() {
                  isLoading = true;
                });
                getCurrentPosition();
              },
            );
          }),
      bottomNavigationBar: StreamBuilder<QuerySnapshot>(
          stream: firebaseFirestore.collection("notification").snapshots(),
          builder: (context, snapshotNotif) {
            int countMessage = 0;
            int countNotif = 0;
            if (snapshotNotif.hasData) {
              if (snapshotNotif.data!.docs.isNotEmpty) {
                AuthController authController = Get.find();
                String access =
                    authController.userModel!.access.toString() == "null"
                        ? authController.accessUserJWS.toString()
                        : authController.userModel!.access.toString();
                Map<String, dynamic> payload = Jwt.parseJwt(access);
                int msgCont = 0;
                int ntfCont = 0;
                for (var element in snapshotNotif.data!.docs) {
                  if (element["type"].toString().toLowerCase() ==
                      "Nouveau message".toLowerCase()) {
                    if (element["isvue"].toString() == "false" &&
                        payload["user_id"].toString() ==
                            element["user"].toString()) {
                      msgCont++;
                    }
                  } else {
                    if (element["isvue"].toString() == "false" &&
                        payload["user_id"].toString() ==
                            element["user"].toString()) {
                      ntfCont++;
                    }
                  }
                }
                countMessage = msgCont;
                countNotif = ntfCont;
              }
            }
            return MenuBottom(
              countMessages: countMessage,
              countNotification: countNotif,
            );
          }),
      body: SafeArea(
        child: SizedBox(
          width: sizeWidth(context: context),
          height: sizeHeight(context: context),
          // child: isLoading
          //     ? const Center(
          //         child: CircularProgressIndicator(),
          //       )
          //     :
          child: LoadingOverlay(
            isLoading: isLoading,
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : GetBuilder<AuthController>(builder: (authController) {
                    return Column(
                      children: [
                        // map && head && ..
                        Expanded(
                            child: Stack(
                          children: [
                            // home
                            SizedBox(
                              width: sizeWidth(context: context),
                              height: sizeHeight(context: context),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // image
                                  Image.asset(
                                    "assets/icons/logo-store.png",
                                    // color: blueColor,
                                  )
                                ],
                              ),
                            ),
                            // maps

                            // appbar
                            Positioned(
                              top: 15,
                              left: 20,
                              child: SizedBox(
                                width: sizeWidth(context: context) - 40,
                                height: 120,
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        // drawer
                                        InkWell(
                                          onTap: () {
                                            scaffoldKey.currentState!
                                                .openDrawer();
                                          },
                                          child: Image.asset(
                                              "assets/icons/drawer.png"),
                                        ),
                                        // notification
                                        // InkWell(
                                        //   onTap: () {
                                        //     Get.to(() => const NotificationScreen(),
                                        //         routeName: RouteHelper
                                        //             .getNotificationRoute());
                                        //   },
                                        //   child: Icon(
                                        //     Icons.notifications_none,
                                        //     color: normalText,
                                        //   ),
                                        // ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // list technitien
                          ],
                        )),

                        // button
                        Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 20),
                          width: sizeWidth(context: context) * .8,
                          child: ElevatedButton(
                            onPressed: () {
                              // Get.to(() => const DatTimeScreen(),
                              //     routeName: RouteHelper.getBookRdvDateTimeRoute());
                              // Get.toNamed(RouteHelper.getBookRdvDateTimeRoute());
                              Get.to(() => const InfoVehiculeScreen(),
                                  routeName:
                                      RouteHelper.getInfoVehiculeRoute());
                            },
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(blueColor),
                              padding: MaterialStateProperty.all(
                                const EdgeInsets.symmetric(vertical: 15),
                              ),
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.zero,
                                ),
                              ),
                            ),
                            child: Text(
                              "Trouver un technicien",
                              style: gothicBold.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
          ),
        ),
      ),
    );
  }
}
