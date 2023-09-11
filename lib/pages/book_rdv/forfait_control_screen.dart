import 'package:client_control_car/constants/constants.dart';
import 'package:client_control_car/constants/route_helper.dart';
import 'package:client_control_car/controllers/auth_controller.dart';
import 'package:client_control_car/controllers/control_controller.dart';
import 'package:client_control_car/pages/book_rdv/facturation_screen.dart';
import 'package:client_control_car/pages/book_rdv/functions/functions_date_time.dart';
import 'package:client_control_car/pages/info_vehicule/widgets/widgets.dart';
import 'package:client_control_car/pages/menu/drawer_widget.dart';
import 'package:client_control_car/pages/menu/menu_bottom.dart';
import 'package:client_control_car/pages/splash/splash_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:loading_overlay/loading_overlay.dart';

class ForfaitControlScreen extends StatefulWidget {
  const ForfaitControlScreen({Key? key}) : super(key: key);

  @override
  State<ForfaitControlScreen> createState() => _ForfaitControlScreenState();
}

class _ForfaitControlScreenState extends State<ForfaitControlScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  bool isLoading = false;
  String selectedControl = "";
  List<String> selectedTechnicient = [];
  List<String> listselectedItemControl = ["0", "1", "2", "3"];
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  List<Control> listControls = [
    Control(
        id: "0",
        name: "Contrôle en 160 points",
        image: "assets/icons/route.png"),
    Control(
        id: "1",
        name: "Professionnels de l'automobile",
        image: "assets/icons/certificate.png"),
    Control(
        id: "2",
        name: "Prix unique 150€",
        image: "assets/icons/piggy-bank.png"),
  ];
  List<ItemControl> listItemControl = [
    ItemControl(
        id: "0",
        name: "Photo du véhicule",
        category: "Offert",
        description: "Option description"),
    ItemControl(
        id: "1",
        name: "Négociation du prix",
        category: "Offert",
        description: "Option description"),
    ItemControl(
        id: "2",
        name: "Rendez-vous le week-end",
        category: "Offert",
        description: "Option description"),
    ItemControl(
        id: "3",
        name: "Déplacement +30 Km",
        category: "Offert",
        description: "Option description"),
  ];

  List<Technicien> listTechnicien = [
    Technicien(
        id: "0",
        name: "Jean Jack",
        category: "Technicien",
        start: 3,
        image: "assets/images/Image 1.png"),
    Technicien(
        id: "1",
        name: "Frederic Noa",
        category: "Technicien",
        start: 4,
        image: "assets/images/Image 2.png"),
    Technicien(
        id: "2",
        name: "Norman Leclerc",
        category: "Technicien",
        start: 2,
        image: "assets/images/Image 5.png"),
  ];

  @override
  void initState() {
    super.initState();
    check().then((value) {
      ControlController controlController = Get.find();
      if (controlController.faclocation_x == null) {
        Get.offAll(() => const SplashScreen(),
            routeName: RouteHelper.getSplashRoute());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // setState(() {
    //   isLoading = false;
    // });
    return Scaffold(
      backgroundColor: Colors.white,
      endDrawerEnableOpenDragGesture: true,
      drawer: checkIsWeb(context: context)
          ? null
          : StreamBuilder<QuerySnapshot>(
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
                  onThen: () {},
                );
              }),
      key: scaffoldKey,
      appBar: checkIsWeb(context: context)
          ? null
          : AppBar(
              backgroundColor: Colors.white,
              // elevation: 0,
              leading: InkWell(
                onTap: () {
                  Get.back();
                },
                child: Icon(
                  Icons.arrow_back_ios,
                  color: normalText,
                ),
              ),
            ),
      bottomNavigationBar:
          checkIsWeb(context: context) ? null : const MenuBottom(isGet: false),
      body: SafeArea(
        child: SizedBox(
          width: sizeWidth(context: context),
          height: sizeHeight(context: context),
          child: LoadingOverlay(
            isLoading: isLoading,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                checkIsWeb(context: context)
                    ? Container(
                        margin: const EdgeInsets.only(right: 10),
                        child: StreamBuilder<QuerySnapshot>(
                            stream: firebaseFirestore
                                .collection("notification")
                                .snapshots(),
                            builder: (context, snapshotNotif) {
                              int countMessage = 0;
                              int countNotif = 0;
                              if (snapshotNotif.hasData) {
                                if (snapshotNotif.data!.docs.isNotEmpty) {
                                  AuthController authController = Get.find();
                                  String access = authController
                                              .userModel!.access
                                              .toString() ==
                                          "null"
                                      ? authController.accessUserJWS.toString()
                                      : authController.userModel!.access
                                          .toString();
                                  Map<String, dynamic> payload =
                                      Jwt.parseJwt(access);
                                  int msgCont = 0;
                                  int ntfCont = 0;
                                  for (var element
                                      in snapshotNotif.data!.docs) {
                                    if (element["type"]
                                            .toString()
                                            .toLowerCase() ==
                                        "Nouveau message".toLowerCase()) {
                                      if (element["isvue"].toString() ==
                                              "false" &&
                                          payload["user_id"].toString() ==
                                              element["user"].toString()) {
                                        msgCont++;
                                      }
                                    } else {
                                      if (element["isvue"].toString() ==
                                              "false" &&
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
                                onThen: () {},
                              );
                            }),
                      )
                    : Container(),
                //
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      checkIsWeb(context: context)
                          ? AppBar(
                              backgroundColor: Colors.transparent,
                              elevation: 0,
                              leading: InkWell(
                                onTap: () {
                                  Get.back();
                                },
                                child: Icon(
                                  Icons.arrow_back_ios,
                                  color: normalText,
                                ),
                              ),
                            )
                          : Container(),
                      // controle
                      Expanded(
                        child: SingleChildScrollView(
                          child: SizedBox(
                            width: sizeWidth(context: context),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                // title
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  child: Text(
                                    "Le contrôle",
                                    style: gothicBold.copyWith(fontSize: 25),
                                  ),
                                ),
                                // list horisental
                                const SizedBox(
                                  height: 15,
                                ),
                                SizedBox(
                                  height: 180,
                                  width: sizeWidth(context: context),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: Row(children: [
                                      for (var item in listControls)
                                        Expanded(
                                          child: InkWell(
                                            onTap: () {
                                              // if (selectedControl == item.id.toString()) {
                                              //   selectedControl = "";
                                              // } else {
                                              //   selectedControl = item.id.toString();
                                              // }
                                              // setState(() {});
                                            },
                                            child: Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 3),
                                              decoration: BoxDecoration(
                                                  color: blueColor,
                                                  borderRadius:
                                                      BorderRadius.circular(5)),
                                              child: Column(
                                                children: [
                                                  // image
                                                  Container(
                                                    height: 80,
                                                    margin: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 5,
                                                        vertical: 5),
                                                    width: double.infinity,
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                              0xffE3E2E2)
                                                          .withOpacity(.2),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                        5,
                                                      ),
                                                    ),
                                                    child: Image.asset(
                                                      item.image.toString(),
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  // name
                                                  Container(
                                                    margin: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 5,
                                                        vertical: 5),
                                                    child: Text(
                                                      item.name.toString(),
                                                      textAlign:
                                                          TextAlign.center,
                                                      maxLines: 3,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style:
                                                          gothicBold.copyWith(
                                                        fontSize: 14,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        )
                                    ]),
                                  ),
                                ),
                                // list
                                const SizedBox(
                                  height: 20,
                                ),
                                for (var item in listItemControl)
                                  InkWell(
                                    onTap: () {
                                      // if (listselectedItemControl
                                      //     .contains(item.id.toString())) {
                                      //   listselectedItemControl
                                      //       .remove(item.id.toString());
                                      // } else {
                                      //   listselectedItemControl.add(item.id.toString());
                                      // }
                                      // setState(() {});
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5),
                                      decoration: BoxDecoration(
                                          border: Border(
                                              bottom: item.id.toString() !=
                                                      listItemControl.last.id
                                                          .toString()
                                                  ? BorderSide(
                                                      width: .5,
                                                      color: normalText)
                                                  : BorderSide.none)),
                                      child: Row(
                                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          // desc&name
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.name.toString(),
                                                style: gothicBold.copyWith(
                                                  fontSize: 15,
                                                ),
                                              ),
                                              Text(
                                                item.description.toString(),
                                                style: gothicRegular.copyWith(
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const Spacer(),
                                          // check
                                          Container(
                                            width: 30,
                                            height: 30,
                                            padding: const EdgeInsets.all(3),
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 5),
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                                color: blueColor,
                                                borderRadius:
                                                    BorderRadius.circular(30)),
                                            child: const Icon(
                                              Icons.check,
                                              color: Colors.white,
                                              size: 24,
                                            ),
                                          ),
                                          // Checkbox(
                                          //   value: listselectedItemControl
                                          //       .contains(item.id.toString()),
                                          //   checkColor: Colors.white,
                                          //   activeColor: blueColor,
                                          //   onChanged: (value) {
                                          //     // if (listselectedItemControl
                                          //     //     .contains(item.id.toString())) {
                                          //     //   listselectedItemControl
                                          //     //       .remove(item.id.toString());
                                          //     // } else {
                                          //     //   listselectedItemControl
                                          //     //       .add(item.id.toString());
                                          //     // }
                                          //     // setState(() {});
                                          //   },
                                          // ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          // category
                                          Text(
                                            item.category.toString(),
                                            style: gothicBold.copyWith(
                                              fontSize: 15,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                const SizedBox(
                                  height: 100,
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      // price
                      Divider(
                        thickness: 1,
                        color: normalText,
                      ),

                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          children: [
                            // price
                            Expanded(
                              // flex: 2,
                              child: Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Total :",
                                      style: gothicMediom.copyWith(
                                        fontSize: 16,
                                        color: Colors.black,
                                      ),
                                    ),
                                    Text("150.00€",
                                        style: gothicBold.copyWith(
                                            color: Colors.black, fontSize: 25)),
                                  ],
                                ),
                              ),
                            ),
                            // btn
                            Expanded(
                              child: Container(
                                width: double.infinity,
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 20),
                                child: ElevatedButton(
                                  onPressed: () {
                                    ControlController controlController =
                                        Get.find();
                                    setState(() {
                                      isLoading = true;
                                    });
                                    selectedTechnicient.clear();
                                    controlController
                                        .getListTechniciensController(
                                            rdv: controlController.idRendezVous
                                                .toString())
                                        .then((value) {
                                      setState(() {
                                        isLoading = false;
                                      });
                                      if (value.isSuccess) {
                                        bool checkIn = false;
                                        for (var technicien in controlController
                                            .listTechniciens) {
                                          //
                                          if (double.tryParse(controlController.faclocation_x.toString()) != null &&
                                              double.tryParse(controlController
                                                      .faclocation_y
                                                      .toString()) !=
                                                  null &&
                                              double.tryParse(technicien
                                                      .zone_location_x
                                                      .toString()) !=
                                                  null &&
                                              double.tryParse(technicien
                                                      .zone_location_y
                                                      .toString()) !=
                                                  null) {
                                            if ((Geolocator.distanceBetween(
                                                        double.parse(controlController
                                                            .faclocation_x
                                                            .toString()),
                                                        double.parse(
                                                            controlController
                                                                .faclocation_y
                                                                .toString()),
                                                        double.parse(technicien
                                                            .zone_location_x
                                                            .toString()),
                                                        double.parse(technicien
                                                            .zone_location_y
                                                            .toString())) /
                                                    1000) <=
                                                (double.tryParse(technicien.rayon
                                                            .toString()) !=
                                                        null
                                                    ? double.parse(
                                                        technicien.rayon.toString())
                                                    : 70)) {
                                              setState(() {
                                                checkIn = true;
                                              });
                                            }
                                          }
                                        }

                                        if (checkIn) {
                                          // show list techniciens
                                          Get.bottomSheet(StatefulBuilder(
                                              builder: (BuildContext context,
                                                  StateSetter setState) {
                                            return Container(
                                              color: Colors.white,
                                              child: Column(
                                                children: [
                                                  // users
                                                  Expanded(
                                                    child:
                                                        SingleChildScrollView(
                                                      child: SizedBox(
                                                        width: sizeWidth(
                                                            context: context),
                                                        child: Column(
                                                          children: [
                                                            for (var item
                                                                in controlController
                                                                    .listTechniciens)
                                                              if (double.tryParse(item.zone_location_x.toString()) != null &&
                                                                  double.tryParse(item
                                                                          .zone_location_y
                                                                          .toString()) !=
                                                                      null &&
                                                                  double.tryParse(controlController
                                                                          .faclocation_x
                                                                          .toString()) !=
                                                                      null &&
                                                                  double.tryParse(controlController
                                                                          .faclocation_y
                                                                          .toString()) !=
                                                                      null)
                                                                if ((Geolocator.distanceBetween(double.parse(controlController.faclocation_x.toString()), double.parse(controlController.faclocation_y.toString()), double.parse(item.zone_location_x.toString()), double.parse(item.zone_location_y.toString())) /
                                                                        1000) <=
                                                                    (double.tryParse(item.rayon.toString()) !=
                                                                            null
                                                                        ? double.parse(item.rayon.toString())
                                                                        : 70))
                                                                  Container(
                                                                    margin: const EdgeInsets
                                                                            .symmetric(
                                                                        horizontal:
                                                                            5,
                                                                        vertical:
                                                                            1),
                                                                    child:
                                                                        InkWell(
                                                                      onTap:
                                                                          () {
                                                                        if (selectedTechnicient
                                                                            .contains(item.id)) {
                                                                          selectedTechnicient
                                                                              .remove(item.id);
                                                                        } else {
                                                                          if (selectedTechnicient.length <
                                                                              5) {
                                                                            selectedTechnicient.add(item.id.toString());
                                                                          }
                                                                        }
                                                                        setState(
                                                                            () {
                                                                          isLoading =
                                                                              false;
                                                                        });
                                                                      },
                                                                      child:
                                                                          Card(
                                                                        child:
                                                                            Container(
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            color: selectedTechnicient.contains(item.id)
                                                                                ? blueColor
                                                                                : const Color(0xffE3E2E2).withOpacity(.2),
                                                                          ),

                                                                          // elevation: 2,
                                                                          child:
                                                                              Row(
                                                                            children: [
                                                                              // image
                                                                              Container(
                                                                                width: 80,
                                                                                height: 80,
                                                                                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                                                                padding: const EdgeInsets.all(5),
                                                                                decoration: BoxDecoration(
                                                                                  color: const Color(0xffE3E2E2).withOpacity(.2),
                                                                                  // borderRadius:
                                                                                  //     BorderRadius.circular(80),
                                                                                ),
                                                                                child: CustomImageCircle(
                                                                                  image: item.userModel!.photo.toString(),
                                                                                  width: 80,
                                                                                  height: 80,
                                                                                  fit: BoxFit.cover,
                                                                                ),
                                                                              ),

                                                                              // info
                                                                              Expanded(
                                                                                child: Column(
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                                                  children: [
                                                                                    // name
                                                                                    Text(
                                                                                      "${item.userModel!.first_name} ${item.userModel!.last_name}",
                                                                                      style: gothicBold.copyWith(fontSize: 16, color: selectedTechnicient.contains(item.id) ? Colors.white : Colors.black),
                                                                                    ),
                                                                                    // category
                                                                                    Text(
                                                                                      "Technicien",
                                                                                      style: gothicRegular.copyWith(color: selectedTechnicient.contains(item.id) ? Colors.white : normalText, fontSize: 13),
                                                                                    ),
                                                                                    // start
                                                                                    getStart(start: int.parse(double.parse(item.notation.toString()).toStringAsFixed(0)), isCheck: selectedTechnicient.contains(item.id)),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  // btns
                                                  Container(
                                                    margin: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 15,
                                                        vertical: 10),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceAround,
                                                      children: [
                                                        Expanded(
                                                          child: ElevatedButton(
                                                            onPressed: () {
                                                              Get.back();
                                                              Get.back();
                                                            },
                                                            style: ButtonStyle(
                                                              backgroundColor:
                                                                  MaterialStateProperty
                                                                      .all(
                                                                          greyColor),
                                                              padding:
                                                                  MaterialStateProperty
                                                                      .all(
                                                                const EdgeInsets
                                                                        .symmetric(
                                                                    vertical:
                                                                        15,
                                                                    horizontal:
                                                                        15),
                                                              ),
                                                              shape: MaterialStateProperty
                                                                  .all<
                                                                      RoundedRectangleBorder>(
                                                                const RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .zero,
                                                                ),
                                                              ),
                                                            ),
                                                            child: Text(
                                                              "Modifier",
                                                              style: gothicBold
                                                                  .copyWith(
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 10,
                                                        ),
                                                        Expanded(
                                                          child: ElevatedButton(
                                                            onPressed: () {
                                                              // Get.back();
                                                              if (selectedTechnicient
                                                                  .isEmpty) {
                                                                Get.snackbar(
                                                                  maxWidth: 500,
                                                                  backgroundColor:
                                                                      blueColor
                                                                          .withOpacity(
                                                                              .7),
                                                                  "Vous n'avez sélectionné aucun technicien",
                                                                  "Veuillez sélectionner au moins un technicien",
                                                                );
                                                              } else {
                                                                setState(() {
                                                                  isLoading =
                                                                      true;
                                                                });
                                                                ControlController
                                                                    controlController =
                                                                    Get.find();
                                                                String tech =
                                                                    "";
                                                                for (var element
                                                                    in selectedTechnicient) {
                                                                  if (tech !=
                                                                      "") {
                                                                    tech += ",";
                                                                  }
                                                                  tech +=
                                                                      element;
                                                                }
                                                                controlController
                                                                        .listTechselected =
                                                                    tech;
                                                                Get.to(
                                                                    () =>
                                                                        const FacturationScreen(),
                                                                    routeName:
                                                                        RouteHelper
                                                                            .getFacturationPageRoute());

                                                                // Future.delayed(
                                                                //     const Duration(
                                                                //         seconds: 2),
                                                                //     () {
                                                                //   // setState(() {
                                                                //   isLoading = false;
                                                                //   // });

                                                                //   Get.to(
                                                                //       () =>
                                                                //           const FacturationScreen(),
                                                                //       routeName: RouteHelper
                                                                //           .getFacturationPageRoute());
                                                                // });
                                                              }
                                                            },
                                                            style: ButtonStyle(
                                                              backgroundColor:
                                                                  MaterialStateProperty
                                                                      .all(
                                                                          blueColor),
                                                              padding:
                                                                  MaterialStateProperty
                                                                      .all(
                                                                const EdgeInsets
                                                                        .symmetric(
                                                                    vertical:
                                                                        15,
                                                                    horizontal:
                                                                        15),
                                                              ),
                                                              shape: MaterialStateProperty
                                                                  .all<
                                                                      RoundedRectangleBorder>(
                                                                const RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .zero,
                                                                ),
                                                              ),
                                                            ),
                                                            child: Text(
                                                              "Valider",
                                                              style: gothicBold
                                                                  .copyWith(
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 15,
                                                  ),
                                                ],
                                              ),
                                            );
                                          })).then((value) {
                                            setState(() {
                                              isLoading = false;
                                            });
                                          });
                                        } else {
                                          setState(() {
                                            isLoading = false;
                                          });
                                          Get.snackbar(
                                            maxWidth: 500,
                                            backgroundColor:
                                                blueColor.withOpacity(.7),
                                            "il n'y a pas de technicien disponible ",
                                            "Veuillez réessayer",
                                          );
                                        }

                                        // end shoz list techniciens
                                      } else {
                                        setState(() {
                                          isLoading = false;
                                        });
                                        Get.snackbar(
                                          maxWidth: 500,
                                          backgroundColor:
                                              blueColor.withOpacity(.7),
                                          "Votre demande n'a pas été enregistrée",
                                          "Veuillez réessayer",
                                        );
                                      }
                                    }).catchError((onError) {
                                      setState(() {
                                        isLoading = false;
                                      });

                                      Get.snackbar(
                                        maxWidth: 500,
                                        backgroundColor:
                                            blueColor.withOpacity(.7),
                                        "Votre demande n'a pas été enregistrée",
                                        "Veuillez réessayer",
                                      );
                                    });
                                  },
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all(blueColor),
                                    padding: MaterialStateProperty.all(
                                      const EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 10),
                                    ),
                                    shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                      const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.zero,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    "Choisir un technicien",
                                    textAlign: TextAlign.center,
                                    style: gothicBold.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Control {
  String? id;
  String? name;
  String? image;

  Control({this.id, this.name, this.image});
}

class ItemControl {
  String? id;
  String? name;
  String? category;
  String? description;

  ItemControl({this.id, this.name, this.category, this.description});
}

class Technicien {
  String? id;
  String? name;
  String? category;
  String? image;
  int start;

  Technicien({this.id, this.name, this.category, this.image, this.start = 0});
}
