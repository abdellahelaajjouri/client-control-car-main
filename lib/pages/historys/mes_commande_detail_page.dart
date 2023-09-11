import 'dart:math';

import 'package:client_control_car/constants/constants.dart';
import 'package:client_control_car/constants/route_helper.dart';
import 'package:client_control_car/controllers/auth_controller.dart';
import 'package:client_control_car/controllers/control_controller.dart';
import 'package:client_control_car/pages/auth/widgets/custom_input_validator.dart';
import 'package:client_control_car/pages/book_rdv/functions/functions_date_time.dart';
import 'package:client_control_car/pages/historys/consulter_rapport_page.dart';
import 'package:client_control_car/pages/menu/drawer_widget.dart';
import 'package:client_control_car/pages/menu/menu_bottom.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:timeline_tile/timeline_tile.dart';

class MesCommandeDetailPage extends StatefulWidget {
  final String controlId;
  const MesCommandeDetailPage({super.key, required this.controlId});

  @override
  State<MesCommandeDetailPage> createState() => _MesCommandeDetailPageState();
}

class _MesCommandeDetailPageState extends State<MesCommandeDetailPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  bool isShowBtm = true;
  double nbrStart = 1;
  TextEditingController commentController = TextEditingController();
  FocusNode commentFocus = FocusNode();

  bool isLoading = true;
  bool isLoadingFirst = true;

  @override
  void initState() {
    super.initState();
    check().then((value) {
      getInfo();
      getData();
    });
  }

  getInfo() {
    ControlController controlController = Get.find();
    controlController.getListTypeVehiculeController().then((value) {
      if (value.isSuccess) {
        controlController.getListMarqueVehiculeController().then((value) {
          if (value.isSuccess) {
          } else {}
        }).catchError((onError) {});
      } else {}
    }).catchError((onError) {});
  }

  getData() {
    ControlController controlController = Get.find();

    controlController
        .getControlDetailController(idcontrol: widget.controlId)
        .then((value) {
      if (value.isSuccess) {
        setState(() {
          isLoading = false;
          isLoadingFirst = false;
        });
      } else {
        setState(() {
          isLoading = false;
          isLoadingFirst = false;
        });
      }
    }).catchError((error) {
      setState(() {
        isLoading = false;
        isLoadingFirst = false;
      });
    });
  }

  final _formKey = GlobalKey<FormState>();

  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        endDrawerEnableOpenDragGesture: true,
        drawer: checkIsWeb(context: context)
            ? null
            : StreamBuilder<QuerySnapshot>(
                stream:
                    firebaseFirestore.collection("notification").snapshots(),
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
                      getData();
                    },
                  );
                }),
        key: scaffoldKey,
        appBar: checkIsWeb(context: context)
            ? null
            : AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: InkWell(
                  onTap: () {
                    scaffoldKey.currentState!.openDrawer();
                  },
                  child: Image.asset("assets/icons/drawer.png"),
                ),
              ),
        bottomNavigationBar: checkIsWeb(context: context)
            ? null
            : StreamBuilder<QuerySnapshot>(
                stream:
                    firebaseFirestore.collection("notification").snapshots(),
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
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        body: SafeArea(
            child: SizedBox(
          width: sizeWidth(context: context),
          height: sizeHeight(context: context),
          child: GetBuilder<ControlController>(builder: (controlController) {
            return LoadingOverlay(
              isLoading: isLoading,
              child: isLoadingFirst
                  ? Container()
                  : Row(
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
                                        if (snapshotNotif
                                            .data!.docs.isNotEmpty) {
                                          AuthController authController =
                                              Get.find();
                                          String access = authController
                                                      .userModel!.access
                                                      .toString() ==
                                                  "null"
                                              ? authController.accessUserJWS
                                                  .toString()
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
                                                "Nouveau message"
                                                    .toLowerCase()) {
                                              if (element["isvue"].toString() ==
                                                      "false" &&
                                                  payload["user_id"]
                                                          .toString() ==
                                                      element["user"]
                                                          .toString()) {
                                                msgCont++;
                                              }
                                            } else {
                                              if (element["isvue"].toString() ==
                                                      "false" &&
                                                  payload["user_id"]
                                                          .toString() ==
                                                      element["user"]
                                                          .toString()) {
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
                                          getData();
                                        },
                                      );
                                    }),
                              )
                            : Container(),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Container(
                              constraints: const BoxConstraints(
                                maxWidth: 800,
                              ),
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  // titile
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 15),
                                    child: Text(
                                      "Commande n°00${widget.controlId}",
                                      style: gothicBold.copyWith(fontSize: 25),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  // image
                                  Center(
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      child: Image.asset(
                                          "assets/images/Groupe 343.png"),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  // timeline
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 2),
                                    height: 70,
                                    child: Center(
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            child: TimelineTile(
                                              alignment: TimelineAlign.manual,
                                              lineXY: 0.1,
                                              axis: TimelineAxis.horizontal,
                                              isFirst: false,
                                              isLast: false,
                                              indicatorStyle: IndicatorStyle(
                                                width: 15,
                                                color: ["8", "9"].contains(
                                                        controlController
                                                            .controlModel!
                                                            .status)
                                                    ? Colors.red
                                                    : blueColor,
                                              ),
                                              beforeLineStyle: LineStyle(
                                                  color: ["8", "9"].contains(
                                                          controlController
                                                              .controlModel!
                                                              .status)
                                                      ? Colors.red
                                                      : blueColor,
                                                  thickness: 1),
                                              endChild: Text(
                                                ["8", "9"].contains(
                                                        controlController
                                                            .controlModel!
                                                            .status)
                                                    ? "Annulée"
                                                    : "Créé",
                                                textAlign: TextAlign.center,
                                                style: gothicBold.copyWith(
                                                  color: ["8", "9"].contains(
                                                          controlController
                                                              .controlModel!
                                                              .status)
                                                      ? Colors.red
                                                      : blueColor,
                                                ),
                                              ),
                                            ),
                                          ),
                                          //
                                          Expanded(
                                            child: TimelineTile(
                                              alignment: TimelineAlign.manual,
                                              lineXY: 0.1,
                                              axis: TimelineAxis.horizontal,
                                              // isFirst: i == 0,
                                              // isLast: i == 2,
                                              indicatorStyle: IndicatorStyle(
                                                width: 15,
                                                color: [
                                                  "5",
                                                  "6",
                                                  "7",
                                                  "3",
                                                  "4"
                                                ].contains(controlController
                                                        .controlModel!.status)
                                                    ? blueColor
                                                    : normalText,
                                                // color: controlController
                                                //             .controlModel!
                                                //             .status ==
                                                //         "8"
                                                //     ? normalText
                                                //     : blueColor,
                                                // iconStyle: controlController
                                                //                 .controlModel!
                                                //                 .status !=
                                                //             "REJECTED" &&
                                                //         controlController
                                                //                 .controlModel!
                                                //                 .status !=
                                                //             "CANCELED"
                                                //     ? null
                                                //     : IconStyle(
                                                //         color: Colors.white,
                                                //         iconData: Icons.cancel,
                                                //         fontSize: 17,
                                                //       ),
                                              ),
                                              beforeLineStyle: LineStyle(
                                                  color: [
                                                    "5",
                                                    "6",
                                                    "7",
                                                    "3",
                                                    "4"
                                                  ].contains(controlController
                                                          .controlModel!.status)
                                                      ? blueColor
                                                      : normalText,
                                                  thickness: 1),

                                              endChild: Text(
                                                "En cours",
                                                textAlign: TextAlign.center,
                                                style: gothicBold.copyWith(
                                                  color: [
                                                    "5",
                                                    "6",
                                                    "7",
                                                    "3",
                                                    "4"
                                                  ].contains(controlController
                                                          .controlModel!.status)
                                                      ? blueColor
                                                      : normalText,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: TimelineTile(
                                              alignment: TimelineAlign.manual,
                                              lineXY: 0.1,
                                              axis: TimelineAxis.horizontal,
                                              // isFirst: i == 0,
                                              // isLast: i == 2,
                                              indicatorStyle: IndicatorStyle(
                                                width: 15,
                                                color: controlController
                                                            .controlModel!
                                                            .status ==
                                                        "4"
                                                    ? Colors.red
                                                    : controlController
                                                                    .controlModel!
                                                                    .status ==
                                                                "6" ||
                                                            controlController
                                                                    .controlModel!
                                                                    .status ==
                                                                "7"
                                                        ? blueColor
                                                        : normalText,
                                              ),
                                              beforeLineStyle: LineStyle(
                                                color: controlController
                                                            .controlModel!
                                                            .status ==
                                                        "4"
                                                    ? Colors.red
                                                    : controlController
                                                                    .controlModel!
                                                                    .status ==
                                                                "6" ||
                                                            controlController
                                                                    .controlModel!
                                                                    .status ==
                                                                "7"
                                                        ? blueColor
                                                        : normalText,
                                                thickness: 1,
                                              ),

                                              endChild: Text(
                                                "Terminée",
                                                textAlign: TextAlign.center,
                                                style: gothicBold.copyWith(
                                                  color: controlController
                                                              .controlModel!
                                                              .status ==
                                                          "4"
                                                      ? Colors.red
                                                      : controlController
                                                                      .controlModel!
                                                                      .status ==
                                                                  "6" ||
                                                              controlController
                                                                      .controlModel!
                                                                      .status ==
                                                                  "7"
                                                          ? blueColor
                                                          : normalText,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // champs status
                                  if (controlController.controlModel!.status
                                          .toString() ==
                                      "2")
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 15, vertical: 10),
                                      child: Row(children: [
                                        // text
                                        Text(
                                          "Accepté par:",
                                          style: gothicBold.copyWith(
                                            color: blueColor,
                                            fontSize: 11,
                                          ),
                                        ),
                                        Expanded(
                                          child: Container(
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 5, vertical: 1),
                                            child: InkWell(
                                              onTap: () {},
                                              child: Row(
                                                children: [
                                                  // image

                                                  Container(
                                                    width: 50,
                                                    height: 40,
                                                    margin: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 5,
                                                        vertical: 5),
                                                    decoration: BoxDecoration(
                                                        color: greyColor,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5)),
                                                    child: Image.network(
                                                      controlController
                                                          .controlModel!
                                                          .listControlTechniciens!
                                                          .first
                                                          .technicienModel!
                                                          .photo
                                                          .toString(),
                                                      errorBuilder: (context,
                                                          error, stackTrace) {
                                                        return Image.asset(
                                                            "assets/images/user.png");
                                                      },
                                                    ),
                                                  ),

                                                  // info
                                                  Expanded(
                                                      child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      // name
                                                      Text(
                                                        '${controlController.controlModel!.listControlTechniciens!.first.technicienModel!.userModel!.first_name.toString()} ${controlController.controlModel!.listControlTechniciens!.first.technicienModel!.userModel!.last_name.toString()}',
                                                        style:
                                                            gothicBold.copyWith(
                                                          fontSize: 12,
                                                        ),
                                                        maxLines: 2,
                                                      ),
                                                      // category
                                                      Text(
                                                        "Technicien",
                                                        style: gothicRegular
                                                            .copyWith(
                                                                color:
                                                                    normalText,
                                                                fontSize: 11),
                                                      ),
                                                      // start
                                                      getStart(
                                                          start: int.parse(
                                                            double.parse(controlController
                                                                    .controlModel!
                                                                    .listControlTechniciens!
                                                                    .first
                                                                    .technicienModel!
                                                                    .notation
                                                                    .toString())
                                                                .toStringAsFixed(
                                                                    0),
                                                          ),
                                                          size: 14),
                                                    ],
                                                  ))
                                                ],
                                              ),
                                            ),
                                          ),
                                        )
                                      ]),
                                    )
                                  else if (controlController
                                          .controlModel!.status
                                          .toString() ==
                                      "3")
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 15, vertical: 10),
                                      child: Text(
                                        "${controlController.controlModel!.listControlTechniciens!.first.technicienModel!.userModel!.first_name} ${controlController.controlModel!.listControlTechniciens!.first.technicienModel!.userModel!.last_name} est arrivé au lieu du contrôle",
                                        style: gothicBold.copyWith(
                                          color: blueColor,
                                          fontSize: 13,
                                        ),
                                      ),
                                    )
                                  else if (controlController
                                          .controlModel!.status
                                          .toString() ==
                                      "5")
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 15, vertical: 10),
                                      child: Text(
                                        "${controlController.controlModel!.listControlTechniciens!.first.technicienModel!.userModel!.first_name} ${controlController.controlModel!.listControlTechniciens!.first.technicienModel!.userModel!.last_name} a commencé le contrôle",
                                        style: gothicBold.copyWith(
                                          color: blueColor,
                                          fontSize: 13,
                                        ),
                                      ),
                                    )
                                  else if (controlController
                                          .controlModel!.status
                                          .toString() ==
                                      "4")
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 15, vertical: 10),
                                      child: Text(
                                        "${controlController.controlModel!.listControlTechniciens!.first.technicienModel!.userModel!.first_name} ${controlController.controlModel!.listControlTechniciens!.first.technicienModel!.userModel!.last_name} n'a pas pu effectuer le contrôle.\nVous allez recevoir un remboursement partiel",
                                        style: gothicBold.copyWith(
                                          color: Colors.red,
                                          fontSize: 13,
                                        ),
                                      ),
                                    )
                                  else if (controlController
                                          .controlModel!.status
                                          .toString() ==
                                      "8")
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 15, vertical: 10),
                                      child: Text(
                                        "Vous avez annulé le contrôle",
                                        style: gothicBold.copyWith(
                                          color: Colors.red,
                                          fontSize: 13,
                                        ),
                                      ),
                                    )
                                  else if (["6", "7"].contains(controlController
                                      .controlModel!.status
                                      .toString()))
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 15, vertical: 10),
                                      alignment: Alignment.center,
                                      child: Column(
                                        children: [
                                          TextButton(
                                            onPressed: () {},
                                            child: Text(
                                              controlController.controlModel!
                                                          .diagnostic!.favorable
                                                          .toString()
                                                          .toLowerCase() ==
                                                      "true"
                                                  ? "AVIS FAVORABLLE"
                                                  : "AVIS Défavorable"
                                                      .toUpperCase(),
                                              style: gothicBold.copyWith(
                                                  color: blueColor),
                                            ),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              Get.to(
                                                () => ConsultRapportScreen(
                                                  idcontrol: widget.controlId
                                                      .toString(),
                                                ),
                                                routeName: RouteHelper
                                                    .getConsultRapportRoute(
                                                  idcontrol: widget.controlId
                                                      .toString(),
                                                ),
                                              );
                                            },
                                            style: ButtonStyle(
                                              backgroundColor:
                                                  MaterialStateProperty.all(
                                                      blueColor),
                                              padding:
                                                  MaterialStateProperty.all(
                                                const EdgeInsets.symmetric(
                                                    vertical: 10,
                                                    horizontal: 15),
                                              ),
                                              shape: MaterialStateProperty.all<
                                                  RoundedRectangleBorder>(
                                                RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                            ),
                                            child: Text(
                                              "Consulter le rapport",
                                              style: gothicBold.copyWith(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 5,
                                          ),
                                          //
                                          // if (["6"].contains(controlController
                                          //     .controlModel!.status
                                          //     .toString()))
                                          ElevatedButton(
                                            onPressed: () {
                                              Get.bottomSheet(
                                                  Container(
                                                    height: sizeHeight(
                                                            context: context) *
                                                        .6,
                                                    decoration:
                                                        const BoxDecoration(
                                                            color:
                                                                Colors.white),
                                                    child: Form(
                                                      key: _formKey,
                                                      child:
                                                          SingleChildScrollView(
                                                        child: SizedBox(
                                                          width: sizeWidth(
                                                              context: context),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: [
                                                              const SizedBox(
                                                                height: 30,
                                                              ),
                                                              Container(
                                                                margin: const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        15),
                                                                child: Text(
                                                                  "Notez votre commande",
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style: gothicBold
                                                                      .copyWith(
                                                                    color:
                                                                        normalText,
                                                                    fontSize:
                                                                        18,
                                                                  ),
                                                                ),
                                                              ),
                                                              //
                                                              // image
                                                              Container(
                                                                width: 70,
                                                                height: 60,
                                                                margin: const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        5,
                                                                    vertical:
                                                                        5),
                                                                decoration: BoxDecoration(
                                                                    color:
                                                                        greyColor,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            5)),
                                                                child:
                                                                    CircleAvatar(
                                                                  child: Image
                                                                      .network(
                                                                    controlController
                                                                        .controlModel!
                                                                        .listControlTechniciens!
                                                                        .first
                                                                        .technicienModel!
                                                                        .photo
                                                                        .toString(),
                                                                    errorBuilder:
                                                                        (context,
                                                                            error,
                                                                            stackTrace) {
                                                                      return Image
                                                                          .asset(
                                                                              "assets/images/user.png");
                                                                    },
                                                                  ),
                                                                ),
                                                              ),
                                                              //
                                                              const SizedBox(
                                                                height: 5,
                                                              ),
                                                              Container(
                                                                margin: const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        15),
                                                                child: Text(
                                                                  "${controlController.controlModel!.listControlTechniciens!.first.technicienModel!.userModel!.first_name} ${controlController.controlModel!.listControlTechniciens!.first.technicienModel!.userModel!.last_name}",
                                                                  style: gothicBold
                                                                      .copyWith(
                                                                    color:
                                                                        normalText,
                                                                    fontSize:
                                                                        16,
                                                                  ),
                                                                ),
                                                              ),
                                                              //
                                                              const SizedBox(
                                                                height: 5,
                                                              ),
                                                              Container(
                                                                margin: const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        15),
                                                                child: Text(
                                                                  "Technicien",
                                                                  style: gothicBold
                                                                      .copyWith(
                                                                    color:
                                                                        normalText,
                                                                  ),
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                height: 5,
                                                              ),
                                                              Container(
                                                                margin: const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        15),
                                                                child: RatingBar
                                                                    .builder(
                                                                  initialRating:
                                                                      nbrStart,
                                                                  minRating: 1,
                                                                  direction: Axis
                                                                      .horizontal,
                                                                  allowHalfRating:
                                                                      false,
                                                                  itemCount: 5,
                                                                  itemPadding: const EdgeInsets
                                                                          .symmetric(
                                                                      horizontal:
                                                                          4.0),
                                                                  itemBuilder:
                                                                      (context,
                                                                              _) =>
                                                                          Icon(
                                                                    Icons.star,
                                                                    color:
                                                                        blueColor,
                                                                  ),
                                                                  onRatingUpdate:
                                                                      (rating) {
                                                                    setState(
                                                                        () {
                                                                      nbrStart =
                                                                          rating;
                                                                    });
                                                                  },
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                height: 10,
                                                              ),
                                                              //
                                                              Container(
                                                                margin: const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        15),
                                                                child:
                                                                    CustomInputValidatore(
                                                                  controller:
                                                                      commentController,
                                                                  labelText:
                                                                      null,
                                                                  hintText:
                                                                      "Ecrivez votre commentaire",
                                                                  maxLines: 5,
                                                                  minLines: 3,
                                                                  focusNode:
                                                                      commentFocus,
                                                                  width: sizeWidth(
                                                                      context:
                                                                          context),
                                                                  marginContainer:
                                                                      const EdgeInsets
                                                                              .symmetric(
                                                                          horizontal:
                                                                              2),
                                                                  validator:
                                                                      (value) {
                                                                    if (value ==
                                                                            null ||
                                                                        value
                                                                            .isEmpty) {
                                                                      return '';
                                                                    }
                                                                    return null;
                                                                  },
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                height: 10,
                                                              ),

                                                              SizedBox(
                                                                width: sizeWidth(
                                                                        context:
                                                                            context) *
                                                                    .8,
                                                                child:
                                                                    ElevatedButton(
                                                                        onPressed:
                                                                            () {
                                                                          if (nbrStart ==
                                                                              0) {
                                                                            Get.snackbar(
                                                                              maxWidth: 500,
                                                                              backgroundColor: blueColor.withOpacity(.7),
                                                                              "Veuillez sélectionner au moins un étoile",
                                                                              "Veuillez réessayer",
                                                                            );
                                                                          } else {
                                                                            Get.back();
                                                                            setState(() {
                                                                              isLoading = true;
                                                                            });
                                                                            ControlController
                                                                                controlController =
                                                                                Get.find();
                                                                            controlController.addreviewController(control: widget.controlId, comment: commentController.text.isEmpty ? "" : commentController.text, technicien: controlController.controlModel!.listControlTechniciens!.first.technicienModel!.id.toString(), notation: nbrStart.toStringAsFixed(0)).then((value) {
                                                                              if (value.isSuccess) {
                                                                                getData();
                                                                              } else {
                                                                                setState(() {
                                                                                  isLoading = false;
                                                                                });
                                                                                if (value.message.toLowerCase().contains("deja exist".toLowerCase())) {
                                                                                  Get.snackbar(
                                                                                    maxWidth: 500,
                                                                                    backgroundColor: blueColor.withOpacity(.7),
                                                                                    "Votre note existe déjà",
                                                                                    "Veuillez réessayer",
                                                                                  );
                                                                                } else {
                                                                                  Get.snackbar(
                                                                                    maxWidth: 500,
                                                                                    backgroundColor: blueColor.withOpacity(.7),
                                                                                    "Votre demande n'a pas été enregistrée",
                                                                                    "Veuillez réessayer",
                                                                                  );
                                                                                }
                                                                              }
                                                                            }).catchError((onError) {
                                                                              setState(() {
                                                                                isLoading = false;
                                                                              });
                                                                              Get.snackbar(
                                                                                maxWidth: 500,
                                                                                backgroundColor: blueColor.withOpacity(.7),
                                                                                "Votre demande n'a pas été enregistrée",
                                                                                "Veuillez réessayer",
                                                                              );
                                                                            });
                                                                          }
                                                                        },
                                                                        style:
                                                                            ButtonStyle(
                                                                          backgroundColor:
                                                                              MaterialStateProperty.all(blueColor),
                                                                          padding:
                                                                              MaterialStateProperty.all(
                                                                            const EdgeInsets.symmetric(
                                                                                vertical: 10,
                                                                                horizontal: 15),
                                                                          ),
                                                                          shape:
                                                                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                                                            RoundedRectangleBorder(
                                                                              borderRadius: BorderRadius.circular(0),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        child:
                                                                            Text(
                                                                          "Continuer",
                                                                          style:
                                                                              gothicBold.copyWith(color: Colors.white),
                                                                        )),
                                                              ),
                                                              SizedBox(
                                                                width: sizeWidth(
                                                                        context:
                                                                            context) *
                                                                    .8,
                                                                child:
                                                                    ElevatedButton(
                                                                        onPressed:
                                                                            () {
                                                                          // start pass
                                                                          Get.back();
                                                                          setState(
                                                                              () {
                                                                            isLoading =
                                                                                true;
                                                                          });
                                                                          controlController
                                                                              .updateStatuControlsController(idControl: widget.controlId, status: "7")
                                                                              .then((value) {
                                                                            if (value.isSuccess) {
                                                                              getData();
                                                                              passControlFini();
                                                                            } else {
                                                                              setState(() {
                                                                                isLoading = false;
                                                                              });
                                                                              Get.snackbar(
                                                                                maxWidth: 500,
                                                                                backgroundColor: blueColor.withOpacity(.7),
                                                                                "Votre demande n'a pas été enregistrée",
                                                                                "Veuillez réessayer",
                                                                              );
                                                                            }
                                                                          }).catchError((onerror) {
                                                                            setState(() {
                                                                              isLoading = false;
                                                                            });
                                                                            Get.snackbar(
                                                                              maxWidth: 500,
                                                                              backgroundColor: blueColor.withOpacity(.7),
                                                                              "Votre demande n'a pas été enregistrée",
                                                                              "Veuillez réessayer",
                                                                            );
                                                                          });

                                                                          // end pass
                                                                        },
                                                                        style:
                                                                            ButtonStyle(
                                                                          backgroundColor:
                                                                              MaterialStateProperty.all(Colors.white),
                                                                          padding:
                                                                              MaterialStateProperty.all(
                                                                            const EdgeInsets.symmetric(
                                                                                vertical: 10,
                                                                                horizontal: 15),
                                                                          ),
                                                                          shape:
                                                                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                                                            RoundedRectangleBorder(
                                                                              borderRadius: BorderRadius.circular(0),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        child:
                                                                            Text(
                                                                          "Passer",
                                                                          style:
                                                                              gothicBold.copyWith(color: Colors.black),
                                                                        )),
                                                              ),
                                                              const SizedBox(
                                                                height: 30,
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  isScrollControlled: true);
                                            },
                                            style: ButtonStyle(
                                              backgroundColor:
                                                  MaterialStateProperty.all(
                                                      blueColor),
                                              padding:
                                                  MaterialStateProperty.all(
                                                const EdgeInsets.symmetric(
                                                    vertical: 10,
                                                    horizontal: 15),
                                              ),
                                              shape: MaterialStateProperty.all<
                                                  RoundedRectangleBorder>(
                                                RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                            ),
                                            child: Text(
                                              "Noter le technicien",
                                              style: gothicBold.copyWith(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  else
                                    Container(),

                                  //
                                  Divider(color: normalText, thickness: 1),
                                  // detail
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        isShowBtm = !isShowBtm;
                                      });
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 15,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 2,
                                        vertical: 10,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          // title
                                          Text(
                                            "Détails de la commande",
                                            style: gothicRegular.copyWith(
                                              fontSize: 14,
                                              color: normalText,
                                            ),
                                          ),
                                          // icon
                                          Transform.rotate(
                                            angle:
                                                isShowBtm ? 90 * pi / 180 : 0,
                                            child: Icon(
                                              Icons.arrow_forward_ios,
                                              color: normalText,
                                              size: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // total
                                  if (isShowBtm)
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 15,
                                        vertical: 10,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: normalText,
                                          width: .5,
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          // total
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "Total",
                                                style: gothicBold.copyWith(
                                                  fontSize: 16,
                                                  color: normalText,
                                                ),
                                              ),
                                              Text(
                                                "${double.parse(controlController.controlModel!.price.toString()).toStringAsFixed(2)}€",
                                                style: gothicBold.copyWith(
                                                  fontSize: 16,
                                                  color: normalText,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Divider(
                                              color: normalText, thickness: .5),
                                          // address
                                          Container(
                                            margin: const EdgeInsets.symmetric(
                                                vertical: 5),
                                            child: Row(
                                              children: [
                                                Image.asset(
                                                  "assets/icons/location adresse.png",
                                                  width: 15,
                                                  height: 15,
                                                ),
                                                const SizedBox(
                                                  width: 15,
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    "${controlController.controlModel!.info_perso!.addresse}, ${controlController.controlModel!.info_perso!.code_postal} ${controlController.controlModel!.info_perso!.ville}, ${controlController.controlModel!.info_perso!.batiment}",
                                                    style:
                                                        gothicRegular.copyWith(
                                                      color: Colors.black,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            margin: const EdgeInsets.symmetric(
                                                vertical: 5),
                                            child: Row(
                                              children: [
                                                Image.asset(
                                                  "assets/icons/Groupe 319.png",
                                                  width: 15,
                                                  height: 15,
                                                ),
                                                const SizedBox(
                                                  width: 15,
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    getDateFormat(
                                                        selectdate:
                                                            controlController
                                                                .controlModel!
                                                                .rendez_vous!
                                                                .date
                                                                .toString(),
                                                        dateTime: DateTime.parse(
                                                            "${controlController.controlModel!.rendez_vous!.date.toString()} ${controlController.controlModel!.rendez_vous!.time.toString()}")),
                                                    style:
                                                        gothicRegular.copyWith(
                                                      color: Colors.black,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          // time
                                          Container(
                                            margin: const EdgeInsets.symmetric(
                                                vertical: 5),
                                            child: Row(
                                              children: [
                                                Image.asset(
                                                  "assets/icons/Groupe 1544.png",
                                                  width: 15,
                                                  height: 15,
                                                ),
                                                const SizedBox(
                                                  width: 15,
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    getTimeAdd(
                                                        time: controlController
                                                            .controlModel!
                                                            .rendez_vous!
                                                            .time
                                                            .toString(),
                                                        date: controlController
                                                            .controlModel!
                                                            .rendez_vous!
                                                            .date
                                                            .toString()),
                                                    style:
                                                        gothicRegular.copyWith(
                                                      color: Colors.black,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          // immat
                                          if (controlController.controlModel!
                                                  .infoVehicule!.immatriculation
                                                  .toString()
                                                  .isNotEmpty &&
                                              controlController
                                                      .controlModel!
                                                      .infoVehicule!
                                                      .immatriculation
                                                      .toString() !=
                                                  "-")
                                            Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 5),
                                              child: Row(
                                                children: [
                                                  const Icon(
                                                    Icons.car_crash,
                                                    size: 20,
                                                  ),
                                                  const SizedBox(
                                                    width: 15,
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      controlController
                                                          .controlModel!
                                                          .infoVehicule!
                                                          .immatriculation
                                                          .toString(),
                                                      style: gothicRegular
                                                          .copyWith(
                                                        color: Colors.black,
                                                        fontSize: 13,
                                                      ),
                                                      maxLines: 2,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          if (controlController.controlModel!
                                                  .infoVehicule!.lien_annonce
                                                  .toString()
                                                  .isNotEmpty &&
                                              controlController
                                                      .controlModel!
                                                      .infoVehicule!
                                                      .lien_annonce
                                                      .toString() !=
                                                  "_")
                                            Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 5),
                                              child: Row(
                                                children: [
                                                  const Icon(
                                                    Icons.link,
                                                    size: 20,
                                                  ),
                                                  const SizedBox(
                                                    width: 15,
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      controlController
                                                          .controlModel!
                                                          .infoVehicule!
                                                          .lien_annonce
                                                          .toString(),
                                                      style: gothicRegular
                                                          .copyWith(
                                                        color: Colors.black,
                                                        fontSize: 13,
                                                      ),
                                                      maxLines: 2,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          //
                                          if (controlController
                                                      .controlModel!
                                                      .info_perso!
                                                      .demande_particuliere
                                                      .toString() !=
                                                  "null" &&
                                              controlController
                                                  .controlModel!
                                                  .info_perso!
                                                  .demande_particuliere
                                                  .toString()
                                                  .isNotEmpty &&
                                              controlController
                                                      .controlModel!
                                                      .info_perso!
                                                      .demande_particuliere
                                                      .toString() !=
                                                  "-")
                                            Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 5),
                                              child: Row(
                                                children: [
                                                  const Icon(
                                                    Icons.info_outline,
                                                    size: 18,
                                                  ),
                                                  const SizedBox(
                                                    width: 15,
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      controlController
                                                          .controlModel!
                                                          .info_perso!
                                                          .demande_particuliere
                                                          .toString(),
                                                      style: gothicRegular
                                                          .copyWith(
                                                        color: Colors.black,
                                                        fontSize: 13,
                                                      ),
                                                      maxLines: 2,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),

                                  // option
                                  if (isShowBtm)
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 15, vertical: 10),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: normalText,
                                          width: .5,
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          // total
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "Options",
                                                style: gothicBold.copyWith(
                                                  fontSize: 16,
                                                  color: normalText,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Divider(
                                              color: normalText, thickness: .5),
                                          // type
                                          Container(
                                            margin: const EdgeInsets.symmetric(
                                                vertical: 5),
                                            child: Row(
                                              children: [
                                                Image.asset(
                                                  "assets/icons/Path 1472.png",
                                                  width: 15,
                                                  height: 15,
                                                ),
                                                const SizedBox(
                                                  width: 15,
                                                ),
                                                Text(
                                                  "Gold",
                                                  style: gothicRegular.copyWith(
                                                    color: Colors.black,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          // car
                                          Container(
                                            margin: const EdgeInsets.symmetric(
                                                vertical: 5),
                                            child: Row(
                                              children: [
                                                Image.asset(
                                                  "assets/icons/Path 1467.png",
                                                  width: 15,
                                                  height: 15,
                                                ),
                                                const SizedBox(
                                                  width: 15,
                                                ),
                                                Text(
                                                  "${controlController.controlModel!.infoVehicule!.type_vehicule!.name_vehicule.toString()} ${controlController.controlModel!.infoVehicule!.marque_vehicule!.name_marque.toString()}",
                                                  style: gothicRegular.copyWith(
                                                    color: Colors.black,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                  // ANNULER COMMANDE
                                  // Text(controlController.controlModel!.status
                                  //     .toString()),
                                  if (["1", "2", "3", "5"].contains(
                                      controlController.controlModel!.status
                                          .toString()))
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 15, vertical: 30),
                                      width: sizeWidth(context: context),
                                      child: ElevatedButton(
                                          onPressed: () {
                                            Get.defaultDialog(
                                                title:
                                                    "Vous êtes sur de vouloir annuler?",
                                                titleStyle: gothicBold.copyWith(
                                                  fontSize: 14,
                                                ),
                                                content: Container(
                                                  margin: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 15),
                                                  child: Column(
                                                    children: [
                                                      // sub
                                                      Text(
                                                        "Nous ne pourrons malheuresement pas vous rembourser",
                                                        style: gothicMediom
                                                            .copyWith(
                                                          fontSize: 12,
                                                        ),
                                                      ),

                                                      // button
                                                      Container(
                                                        margin: const EdgeInsets
                                                            .only(
                                                          top: 8,
                                                        ),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            SizedBox(
                                                              height: 30,
                                                              child:
                                                                  ElevatedButton(
                                                                onPressed: () {
                                                                  Get.back();
                                                                  setState(() {
                                                                    isLoading =
                                                                        true;
                                                                  });
                                                                  // update state
                                                                  controlController
                                                                      .updateStatuControlsController(
                                                                          idControl: widget
                                                                              .controlId,
                                                                          status:
                                                                              "8")
                                                                      .then(
                                                                          (value) {
                                                                    if (value
                                                                        .isSuccess) {
                                                                      getData();
                                                                    } else {
                                                                      setState(
                                                                          () {
                                                                        isLoading =
                                                                            false;
                                                                      });
                                                                      Get.snackbar(
                                                                        maxWidth:
                                                                            500,
                                                                        backgroundColor:
                                                                            blueColor.withOpacity(.7),
                                                                        "Votre demande n'a pas été enregistrée",
                                                                        "Veuillez réessayer",
                                                                      );
                                                                    }
                                                                  }).catchError(
                                                                          (onerror) {
                                                                    setState(
                                                                        () {
                                                                      isLoading =
                                                                          false;
                                                                    });
                                                                    Get.snackbar(
                                                                      maxWidth:
                                                                          500,
                                                                      backgroundColor:
                                                                          blueColor
                                                                              .withOpacity(.7),
                                                                      "Votre demande n'a pas été enregistrée",
                                                                      "Veuillez réessayer",
                                                                    );
                                                                  });
                                                                },
                                                                style:
                                                                    const ButtonStyle(
                                                                  backgroundColor:
                                                                      MaterialStatePropertyAll(
                                                                          Colors
                                                                              .red),
                                                                ),
                                                                child:
                                                                    Container(
                                                                  margin: const EdgeInsets
                                                                          .symmetric(
                                                                      horizontal:
                                                                          20),
                                                                  child: Text(
                                                                    "OUI",
                                                                    style: gothicBold
                                                                        .copyWith(
                                                                            color:
                                                                                Colors.white),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              width: 10,
                                                            ),
                                                            SizedBox(
                                                              height: 30,
                                                              child:
                                                                  ElevatedButton(
                                                                onPressed: () {
                                                                  Get.back();
                                                                },
                                                                style:
                                                                    ButtonStyle(
                                                                  backgroundColor:
                                                                      MaterialStatePropertyAll(
                                                                          blueColor),
                                                                ),
                                                                child:
                                                                    Container(
                                                                  margin: const EdgeInsets
                                                                          .symmetric(
                                                                      horizontal:
                                                                          20),
                                                                  child: Text(
                                                                    "NON",
                                                                    style: gothicBold
                                                                        .copyWith(
                                                                            color:
                                                                                Colors.white),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ));
                                          },
                                          style: const ButtonStyle(
                                              backgroundColor:
                                                  MaterialStatePropertyAll(
                                                      Colors.red)),
                                          child: Text(
                                            "Annuler la commande",
                                            style: gothicBold.copyWith(
                                                color: Colors.white),
                                          )),
                                    ),
                                  const SizedBox(
                                    height: 50,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
            );
          }),
        )));
  }

  void passControlFini() {
    Get.bottomSheet(
        Container(
          height: sizeHeight(context: context) * .5,
          decoration: const BoxDecoration(color: Colors.white),
          child: SingleChildScrollView(
            child: SizedBox(
              width: sizeWidth(context: context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 30,
                  ),
                  // image
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 15),
                    child: Image.asset("assets/images/fini_control.png"),
                  ),
                  //titla
                  const SizedBox(
                    height: 5,
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 15),
                    child: Text(
                      "Commande terminée",
                      style: gothicBold.copyWith(
                          fontSize: 16, color: Colors.black),
                    ),
                  ),
                  // sous title
                  const SizedBox(
                    height: 5,
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 15),
                    child: Text(
                      "Merci pour votre confiance",
                      style: gothicMediom.copyWith(
                          fontSize: 14, color: normalText),
                    ),
                  ),

                  const SizedBox(
                    height: 30,
                  )
                ],
              ),
            ),
          ),
        ),
        isScrollControlled: true);
  }

  String getDateFormat(
      {required String selectdate, required DateTime dateTime}) {
    String newDate = selectdate;
    // "${selectdate.split('-')[2]}-${selectdate.split('-')[1]}-${selectdate.split('-')[0]}";
    String testDay = "";
    testDay = DateFormat('EEE', 'fr')
            .format(DateTime.parse(newDate))[0]
            .toUpperCase() +
        DateFormat('EEEE dd MMMM yyyy', 'fr')
            .format(DateTime.parse(newDate))
            .substring(1);

    return testDay;
  }
}
