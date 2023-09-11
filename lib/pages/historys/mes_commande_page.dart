import 'package:client_control_car/constants/constants.dart';
import 'package:client_control_car/constants/route_helper.dart';
import 'package:client_control_car/controllers/auth_controller.dart';
import 'package:client_control_car/controllers/control_controller.dart';
import 'package:client_control_car/pages/book_rdv/functions/functions_date_time.dart';
import 'package:client_control_car/pages/historys/mes_commande_detail_page.dart';
import 'package:client_control_car/pages/menu/drawer_widget.dart';
import 'package:client_control_car/pages/menu/menu_bottom.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:timeline_tile/timeline_tile.dart';

class MesCommandePage extends StatefulWidget {
  const MesCommandePage({super.key});

  @override
  State<MesCommandePage> createState() => _MesCommandePageState();
}

class _MesCommandePageState extends State<MesCommandePage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  String dmnd = "CREE";
  bool isLoading = true;
  bool isLoadingFrist = true;
  String state = "CREE"; // CREE ,CANCEL, EN_COURS, TERMINE

  @override
  void initState() {
    super.initState();
    check().then((value) {
      getInfo();
      getData(page: 1);
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

  getData({String? stateChange, required int page}) async {
    ControlController controlController = Get.find();
    controlController
        .getAllControlsController(state: stateChange ?? state, page: page)
        .then((value) {
      setState(() {
        isLoading = false;
        isLoadingFrist = false;
      });
      if (value.isSuccess) {
        if (stateChange != null) {
          setState(() {
            state = stateChange;
          });
        }
      } else {}
    }).catchError((onError) {
      setState(() {
        isLoading = false;
        isLoadingFrist = false;
      });
    });
  }

  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      endDrawerEnableOpenDragGesture: true,
      key: scaffoldKey,
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
                  onThen: () {
                    setState(() {
                      isLoading = true;
                    });
                    getData(page: 1);
                  },
                );
              }),
      appBar: checkIsWeb(context: context)
          ? null
          : AppBar(
              backgroundColor: Colors.white,
              // elevation: 0,
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
        height: sizeHeight(context: context),
        width: sizeWidth(context: context),
        child: GetBuilder<ControlController>(builder: (controlController) {
          return LoadingOverlay(
            isLoading: isLoading,
            child: Row(
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
                                onThen: () {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  getData(page: 1);
                                },
                              );
                            }),
                      )
                    : Container(),
                Expanded(
                  child: Column(
                    children: [
                      checkIsWeb(context: context)
                          ? AppBar(
                              backgroundColor: Colors.transparent,
                              elevation: 0,
                            )
                          : Container(),
                      Expanded(
                        child: NotificationListener<ScrollNotification>(
                          onNotification: (ScrollNotification scrollInfo) {
                            if (scrollInfo.metrics.pixels ==
                                scrollInfo.metrics.maxScrollExtent) {
                              if (!isLoading &&
                                  controlController.currentPage <
                                      controlController.maxPage) {
                                setState(() {
                                  isLoading = true;
                                });

                                int page = 1;
                                if (controlController.currentPage <
                                    controlController.maxPage) {
                                  page = controlController.currentPage + 1;
                                }
                                getData(page: page);
                              }
                              // Load more data or trigger pagination
                              // Call a function here to fetch the next page of data
                            }
                            return false;
                          },
                          child: SingleChildScrollView(
                            child: isLoadingFrist
                                ? Container()
                                : Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 15),
                                    width: sizeWidth(context: context),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        // titile
                                        Container(
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 15),
                                          child: Text(
                                            "Suivi de commande",
                                            style: gothicBold.copyWith(
                                                fontSize: 25),
                                          ),
                                        ),
                                        // subtitle

                                        // rows
                                        SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Row(
                                            children: [
                                              // cree
                                              InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    isLoading = true;
                                                  });
                                                  getData(
                                                      stateChange: "CREE",
                                                      page: 1);
                                                },
                                                child: Container(
                                                  margin: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 5,
                                                      vertical: 15),
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 20,
                                                      vertical: 6),
                                                  decoration: BoxDecoration(
                                                    color: state == "CREE"
                                                        ? Colors.green
                                                        : blueColor
                                                            .withOpacity(.2),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6),
                                                  ),
                                                  child: Text(
                                                    "Créé",
                                                    style: gothicBold.copyWith(
                                                      color: state == "CREE"
                                                          ? Colors.white
                                                          : blueColor,
                                                      fontSize: 17,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              // EN_COURS
                                              InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    isLoading = true;
                                                  });
                                                  getData(
                                                      stateChange: "EN_COURS",
                                                      page: 1);
                                                },
                                                child: Container(
                                                  margin: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 5,
                                                      vertical: 15),
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 20,
                                                      vertical: 6),
                                                  decoration: BoxDecoration(
                                                    color: state == "EN_COURS"
                                                        ? const Color(
                                                                0xff1FE179)
                                                            .withOpacity(1)
                                                        : blueColor
                                                            .withOpacity(.2),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6),
                                                  ),
                                                  child: Text(
                                                    "En cours",
                                                    style: gothicBold.copyWith(
                                                      color: state == "EN_COURS"
                                                          ? Colors.white
                                                          : blueColor,
                                                      fontSize: 17,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              // Terminé
                                              InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    isLoading = true;
                                                  });
                                                  getData(
                                                      stateChange: "TERMINE",
                                                      page: 1);
                                                },
                                                child: Container(
                                                  margin: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 5,
                                                      vertical: 15),
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 20,
                                                      vertical: 6),
                                                  decoration: BoxDecoration(
                                                    color: state == "TERMINE"
                                                        ? blueColor
                                                        : blueColor
                                                            .withOpacity(.2),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6),
                                                  ),
                                                  child: Text(
                                                    "Terminé",
                                                    style: gothicBold.copyWith(
                                                      color: state == "TERMINE"
                                                          ? Colors.white
                                                          : blueColor,
                                                      fontSize: 17,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              // ANNULE
                                              InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    isLoading = true;
                                                  });
                                                  getData(
                                                      stateChange: "CANCEL",
                                                      page: 1);
                                                },
                                                child: Container(
                                                  margin: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 5,
                                                      vertical: 15),
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 20,
                                                      vertical: 6),
                                                  decoration: BoxDecoration(
                                                    color: state == "CANCEL"
                                                        ? Colors.red
                                                        : blueColor
                                                            .withOpacity(.2),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6),
                                                  ),
                                                  child: Text(
                                                    "Annulé",
                                                    style: gothicBold.copyWith(
                                                      color: state == "CANCEL"
                                                          ? Colors.white
                                                          : blueColor,
                                                      fontSize: 17,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // list controls
                                        if (controlController
                                            .listControlModel.isNotEmpty)
                                          for (int i = 0;
                                              i <
                                                  controlController
                                                      .listControlModel.length;
                                              i++)
                                            TimelineTile(
                                              alignment: TimelineAlign.manual,
                                              lineXY: 0.1,
                                              isFirst: i == 0,
                                              // isLast: i ==
                                              //     getListControlsByStatus(
                                              //                 listControl:
                                              //                     controlController
                                              //                         .listControlModel,
                                              //                 status: dmnd)
                                              //             .length -
                                              //         1,
                                              indicatorStyle: IndicatorStyle(
                                                width: 12,
                                                color: getColorinitial(
                                                    status: controlController
                                                        .listControlModel[i]
                                                        .status
                                                        .toString()),
                                              ),
                                              beforeLineStyle: LineStyle(
                                                  color: getColorinitial(
                                                      status: controlController
                                                          .listControlModel[i]
                                                          .status
                                                          .toString()),
                                                  thickness: 1),
                                              endChild: Container(
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 5),
                                                constraints:
                                                    const BoxConstraints(
                                                  minHeight: 120,
                                                ),
                                                child: Container(
                                                  margin: const EdgeInsets
                                                      .symmetric(horizontal: 0),
                                                  child: InkWell(
                                                    onTap: () {
                                                      Get.to(
                                                              () =>
                                                                  MesCommandeDetailPage(
                                                                    controlId: controlController
                                                                        .listControlModel[
                                                                            i]
                                                                        .id
                                                                        .toString(),
                                                                  ),
                                                              routeName: RouteHelper
                                                                  .getMesCommandeDetailRoute(
                                                                      countrolId: controlController
                                                                          .listControlModel[
                                                                              i]
                                                                          .id
                                                                          .toString()))!
                                                          .then((value) {
                                                        setState(() {
                                                          isLoading = true;
                                                        });
                                                        getData(page: 1);
                                                      });
                                                    },
                                                    child: Card(
                                                      elevation: 2,
                                                      color: Colors.white,
                                                      shadowColor: getColorinitial(
                                                          status: controlController
                                                              .listControlModel[
                                                                  i]
                                                              .status
                                                              .toString()),
                                                      borderOnForeground: true,
                                                      semanticContainer: true,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              //<-- SEE HERE
                                                              side: BorderSide(
                                                                color: getColorinitial(
                                                                    status: controlController
                                                                        .listControlModel[
                                                                            i]
                                                                        .status
                                                                        .toString()),
                                                              ),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          12)),
                                                      child: Container(
                                                        margin: const EdgeInsets
                                                                .symmetric(
                                                            horizontal: 10,
                                                            vertical: 10),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            // title
                                                            Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Text(
                                                                  "Commande n°00${controlController.listControlModel[i].id.toString()}",
                                                                  style: gothicBold
                                                                      .copyWith(
                                                                    color: Colors
                                                                        .black,
                                                                    fontSize:
                                                                        15,
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  width: 5,
                                                                ),
                                                                Container(
                                                                  padding: const EdgeInsets
                                                                          .symmetric(
                                                                      horizontal:
                                                                          10,
                                                                      vertical:
                                                                          5),
                                                                  decoration: BoxDecoration(
                                                                      color:
                                                                          blueColor,
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              6)),
                                                                  child: Text(
                                                                    "${double.parse(controlController.listControlModel[i].price.toString()).toStringAsFixed(2)}€",
                                                                    style: gothicBold
                                                                        .copyWith(
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          12,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            const SizedBox(
                                                              height: 10,
                                                            ),
                                                            // type
                                                            Container(
                                                              margin: const EdgeInsets
                                                                      .symmetric(
                                                                  vertical: 5),
                                                              child: Row(
                                                                children: [
                                                                  Image.asset(
                                                                    "assets/icons/Path 1472.png",
                                                                    width: 19,
                                                                    height: 19,
                                                                  ),
                                                                  const SizedBox(
                                                                    width: 15,
                                                                  ),
                                                                  Expanded(
                                                                    child: Text(
                                                                      "Gold",
                                                                      style: gothicRegular
                                                                          .copyWith(
                                                                        color: Colors
                                                                            .black,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),

                                                            // car
                                                            Container(
                                                              margin: const EdgeInsets
                                                                      .symmetric(
                                                                  vertical: 5),
                                                              child: Row(
                                                                children: [
                                                                  Image.asset(
                                                                    "assets/icons/Path 1467.png",
                                                                    width: 19,
                                                                    height: 19,
                                                                  ),
                                                                  const SizedBox(
                                                                    width: 15,
                                                                  ),
                                                                  Expanded(
                                                                    child: Text(
                                                                      // ignore: prefer_interpolation_to_compose_strings
                                                                      controlController
                                                                              .listControlModel[
                                                                                  i]
                                                                              .infoVehicule!
                                                                              .type_vehicule!
                                                                              .name_vehicule
                                                                              .toString() +
                                                                          " - " +
                                                                          controlController
                                                                              .listControlModel[i]
                                                                              .infoVehicule!
                                                                              .marque_vehicule!
                                                                              .name_marque
                                                                              .toString(),
                                                                      style: gothicRegular
                                                                          .copyWith(
                                                                        color: Colors
                                                                            .black,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),

                                                            // address
                                                            Container(
                                                              margin: const EdgeInsets
                                                                      .symmetric(
                                                                  vertical: 5),
                                                              child: Row(
                                                                children: [
                                                                  Image.asset(
                                                                    "assets/icons/location adresse.png",
                                                                    width: 19,
                                                                    height: 19,
                                                                  ),
                                                                  const SizedBox(
                                                                    width: 15,
                                                                  ),
                                                                  Expanded(
                                                                    child: Text(
                                                                      "${controlController.listControlModel[i].info_perso!.addresse.toString()}, ${controlController.listControlModel[i].info_perso!.code_postal.toString()} ${controlController.listControlModel[i].info_perso!.ville.toString()}, ${controlController.listControlModel[i].info_perso!.batiment}",
                                                                      style: gothicRegular
                                                                          .copyWith(
                                                                        color: Colors
                                                                            .black,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            // time
                                                            Container(
                                                              margin: const EdgeInsets
                                                                      .symmetric(
                                                                  vertical: 5),
                                                              child: Row(
                                                                children: [
                                                                  Image.asset(
                                                                    "assets/icons/Groupe 1544.png",
                                                                    width: 19,
                                                                    height: 19,
                                                                  ),
                                                                  const SizedBox(
                                                                    width: 15,
                                                                  ),
                                                                  Expanded(
                                                                    child: Text(
                                                                      getTimeAdd(
                                                                          time: controlController
                                                                              .listControlModel[
                                                                                  i]
                                                                              .rendez_vous!
                                                                              .time
                                                                              .toString(),
                                                                          date: controlController
                                                                              .listControlModel[i]
                                                                              .rendez_vous!
                                                                              .date
                                                                              .toString()),
                                                                      style: gothicRegular
                                                                          .copyWith(
                                                                        color: Colors
                                                                            .black,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            //
                                                            if (controlController
                                                                    .listControlModel[
                                                                        i]
                                                                    .infoVehicule!
                                                                    .lien_annonce
                                                                    .toString()
                                                                    .isNotEmpty &&
                                                                controlController
                                                                        .listControlModel[
                                                                            i]
                                                                        .infoVehicule!
                                                                        .lien_annonce
                                                                        .toString() !=
                                                                    "_")
                                                              Container(
                                                                margin: const EdgeInsets
                                                                        .symmetric(
                                                                    vertical:
                                                                        5),
                                                                child: Row(
                                                                  children: [
                                                                    const Icon(
                                                                      Icons
                                                                          .link,
                                                                      size: 20,
                                                                    ),
                                                                    const SizedBox(
                                                                      width: 15,
                                                                    ),
                                                                    Expanded(
                                                                      child:
                                                                          Text(
                                                                        controlController
                                                                            .listControlModel[i]
                                                                            .infoVehicule!
                                                                            .lien_annonce
                                                                            .toString(),
                                                                        maxLines:
                                                                            2,
                                                                        style: gothicRegular
                                                                            .copyWith(
                                                                          color:
                                                                              Colors.black,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            //
                                                            if (controlController
                                                                    .listControlModel[
                                                                        i]
                                                                    .info_perso!
                                                                    .demande_particuliere
                                                                    .toString()
                                                                    .isNotEmpty &&
                                                                controlController
                                                                        .listControlModel[
                                                                            i]
                                                                        .info_perso!
                                                                        .demande_particuliere
                                                                        .toString() !=
                                                                    "" &&
                                                                controlController
                                                                        .listControlModel[
                                                                            i]
                                                                        .info_perso!
                                                                        .demande_particuliere
                                                                        .toString() !=
                                                                    "-")
                                                              Container(
                                                                margin: const EdgeInsets
                                                                        .symmetric(
                                                                    vertical:
                                                                        5),
                                                                child: Row(
                                                                  children: [
                                                                    const Icon(
                                                                      Icons
                                                                          .info_outline,
                                                                      size: 20,
                                                                    ),
                                                                    const SizedBox(
                                                                      width: 15,
                                                                    ),
                                                                    Expanded(
                                                                      child:
                                                                          Text(
                                                                        controlController
                                                                            .listControlModel[i]
                                                                            .info_perso!
                                                                            .demande_particuliere
                                                                            .toString(),
                                                                        maxLines:
                                                                            2,
                                                                        style: gothicRegular
                                                                            .copyWith(
                                                                          color:
                                                                              Colors.black,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              startChild: Text(
                                                "${DateFormat('dd', 'fr').format(DateTime.parse(controlController.listControlModel[i].rendez_vous!.date.toString()))} ${DateFormat('EEE', 'fr').format(DateTime.parse(controlController.listControlModel[i].rendez_vous!.date.toString()))[0].toUpperCase()}${DateFormat('EEE', 'fr').format(DateTime.parse(controlController.listControlModel[i].rendez_vous!.date.toString())).substring(1)}",
                                                textAlign: TextAlign.center,
                                                style: gothicBold.copyWith(
                                                  color: normalText,
                                                ),
                                              ),
                                            )
                                        else
                                          SizedBox(
                                            width: sizeWidth(context: context),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                // image
                                                Container(
                                                  margin: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 15),
                                                  child: Image.asset(
                                                    "assets/images/empty_order.jpg",
                                                    width: 200,
                                                  ),
                                                ),
                                                // message
                                                Text(
                                                  "Aucune commande dans cet état",
                                                  style: gothicBold.copyWith(
                                                      color: blueColor),
                                                ),
                                              ],
                                            ),
                                          ),

                                        const SizedBox(
                                          height: 100,
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
              ],
            ),
          );
        }),
      )),
    );
  }

  Color getColorinitial({required String status}) {
    if (["1"].contains(status)) {
      // if (["2"].contains(status)) {
      return Colors.orange.withOpacity(1);
      // } else {
      //   return const Color(0xffF57A0F).withOpacity(.5);
      // }
    } else if (["2", "9"].contains(status)) {
      // if (["2"].contains(status)) {
      return Colors.green.withOpacity(1);
      // } else {
      //   return const Color(0xffF57A0F).withOpacity(.5);
      // }
    } else if (["3", "5"].contains(status)) {
      return const Color(0xff1FE179).withOpacity(1);
    } else if (["4", "6", "7"].contains(status)) {
      return blueColor;
    } else {
      return Colors.red;
      // return const Color(0xffE3E2E2).withOpacity(1);
    }
  }

  List<String> getStateControl({required String text}) {
    // ANNULE TERMINE EN_COURS CREE
    if (text == 'CREE') {
      return ["1", "2", "9"];
    } else if (text == 'EN_COURS') {
      return ["3", "5"];
    } else if (text == 'TERMINE') {
      return ["4", "6", "7"];
    } else {
      return ["8"];
    }
  }
}
