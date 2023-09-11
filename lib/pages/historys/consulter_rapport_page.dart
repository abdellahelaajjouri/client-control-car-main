import 'package:client_control_car/constants/constants.dart';
import 'package:client_control_car/constants/route_helper.dart';
import 'package:client_control_car/controllers/auth_controller.dart';
import 'package:client_control_car/controllers/control_controller.dart';
import 'package:client_control_car/models/control_model.dart';
import 'package:client_control_car/pages/book_rdv/functions/functions_date_time.dart';
import 'package:client_control_car/pages/historys/image_show_screen.dart';
import 'package:client_control_car/pages/info_vehicule/widgets/widgets.dart';
import 'package:client_control_car/pages/menu/drawer_widget.dart';
import 'package:client_control_car/pages/menu/menu_bottom.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:loading_overlay/loading_overlay.dart';

class ConsultRapportScreen extends StatefulWidget {
  final String idcontrol;
  const ConsultRapportScreen({super.key, required this.idcontrol});

  @override
  State<ConsultRapportScreen> createState() => _ConsultRapportScreenState();
}

class _ConsultRapportScreenState extends State<ConsultRapportScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  bool isLoading = true;
  bool isLoadingFirst = true;

  @override
  void initState() {
    super.initState();
    check().then((value) {
      getData();
    });
  }

  getData() async {
    ControlController controlController = Get.find();
    controlController
        .getControlDetailController(idcontrol: widget.idcontrol)
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
    }).catchError((onError) {
      setState(() {
        isLoading = false;
        isLoadingFirst = false;
      });
    });
  }

  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      key: scaffoldKey,
      extendBodyBehindAppBar: true,
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
                    getData();
                  },
                );
              }),
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
      appBar: checkIsWeb(context: context)
          ? null
          : AppBar(
              backgroundColor: Colors.white,
              // elevation: 0,
              iconTheme: IconThemeData(color: normalText),
            ),
      body: SafeArea(
        child: SizedBox(
          width: sizeWidth(context: context),
          height: sizeHeight(context: context),
          child: LoadingOverlay(
            isLoading: isLoading,
            child: isLoadingFirst
                ? Container()
                : GetBuilder<ControlController>(
                    builder: (controlController) {
                      return Row(
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
                                                : authController
                                                    .userModel!.access
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
                                                if (element["isvue"]
                                                            .toString() ==
                                                        "false" &&
                                                    payload["user_id"]
                                                            .toString() ==
                                                        element["user"]
                                                            .toString()) {
                                                  msgCont++;
                                                }
                                              } else {
                                                if (element["isvue"]
                                                            .toString() ==
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
                          //
                          Expanded(
                            child: Column(
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
                                //
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: SizedBox(
                                      width: sizeWidth(context: context),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          const SizedBox(
                                            height: 30,
                                          ),
                                          Container(
                                            width: sizeWidth(context: context),
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 10),
                                            child: Text(
                                              "Consulter rapport",
                                              style: gothicBold.copyWith(
                                                color: Colors.black,
                                                fontSize: 20,
                                              ),
                                            ),
                                          ),
                                          // Control id
                                          // Container(
                                          //   margin: const EdgeInsets.symmetric(
                                          //       horizontal: 15, vertical: 5),
                                          //   child: Text(
                                          //     "Commande n°${getIdControlFormat(id: widget.idcontrol)}",
                                          //     style: gothicBold.copyWith(
                                          //       color: Colors.black,
                                          //     ),
                                          //   ),
                                          // ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          // date & etat
                                          Container(
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 15, vertical: 1),
                                            child: Text(
                                              "Date : ${DateFormat('dd MMMM yyyy', 'fr').format(DateTime.parse(controlController.controlModel!.rendez_vous!.date.toString()))}",
                                              style: gothicRegular.copyWith(
                                                color: normalText,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 15, vertical: 10),
                                            child: Text(
                                              controlController.controlModel!
                                                          .diagnostic!.favorable
                                                          .toString() ==
                                                      "true"
                                                  ? "FAVORABLE"
                                                  : "DÉFAVORABLE",
                                              // "Etat : ${getStatusControlByIndex(status: controlController.controlModelDetail!.status.toString())}",
                                              style: gothicBold.copyWith(
                                                  color: controlController
                                                              .controlModel!
                                                              .diagnostic!
                                                              .favorable
                                                              .toString() ==
                                                          "true"
                                                      ? Colors.green
                                                      : Colors.red,
                                                  fontSize: 16),
                                            ),
                                          ),
                                          // Container(
                                          //   margin: const EdgeInsets.symmetric(
                                          //       horizontal: 15, vertical: 10),
                                          //   child: Text(
                                          //     "Etat : ${getStatusControlByIndex(status: controlController.controlModel!.status.toString())}",
                                          //     style: gothicRegular.copyWith(
                                          //       color: normalText,
                                          //     ),
                                          //   ),
                                          // ),
                                          Container(
                                            width: sizeWidth(context: context),
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 15),
                                            child: Card(
                                              elevation: 1,
                                              shadowColor:
                                                  getColorControlByPart(
                                                      partie: 0,
                                                      status: controlController
                                                          .controlModel!.status
                                                          .toString()),
                                              color: Colors.white,
                                              borderOnForeground: true,
                                              semanticContainer: true,
                                              shape: RoundedRectangleBorder(
                                                  //<-- SEE HERE
                                                  side: BorderSide(
                                                    color: getColorControlByPart(
                                                        partie: 0,
                                                        status:
                                                            controlController
                                                                .controlModel!
                                                                .status
                                                                .toString()),
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12)),
                                              child: Container(
                                                width:
                                                    sizeWidth(context: context),
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 5),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    // title
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    Text(
                                                      "Commande n°${getIdControlFormat(id: widget.idcontrol)}",
                                                      style:
                                                          gothicBold.copyWith(
                                                        color: Colors.black,
                                                        fontSize: 20,
                                                      ),
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
                                                          Text(
                                                            "Gold",
                                                            style: gothicRegular
                                                                .copyWith(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 13,
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
                                                          Text(
                                                            "${controlController.controlModel!.infoVehicule!.type_vehicule!.name_vehicule} - ${controlController.controlModel!.infoVehicule!.marque_vehicule!.name_marque}",
                                                            style: gothicRegular
                                                                .copyWith(
                                                                    color: Colors
                                                                        .black,
                                                                    fontSize:
                                                                        13),
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
                                                              "${controlController.controlModel!.info_perso!.addresse}, ${controlController.controlModel!.info_perso!.code_postal} ${controlController.controlModel!.info_perso!.ville}, ${controlController.controlModel!.info_perso!.batiment}",
                                                              style: gothicRegular
                                                                  .copyWith(
                                                                      color: Colors
                                                                          .black,
                                                                      fontSize:
                                                                          13),
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
                                                          Text(
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
                                                            style: gothicRegular
                                                                .copyWith(
                                                                    color: Colors
                                                                        .black,
                                                                    fontSize:
                                                                        13),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),

                                          // technicien
                                          Container(
                                            width: sizeWidth(context: context),
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 15),
                                            child: Card(
                                              elevation: 1,
                                              shadowColor:
                                                  getColorControlByPart(
                                                      partie: 0,
                                                      status: controlController
                                                          .controlModel!.status
                                                          .toString()),
                                              borderOnForeground: true,
                                              color: Colors.white,
                                              semanticContainer: true,
                                              shape: RoundedRectangleBorder(
                                                  //<-- SEE HERE
                                                  side: BorderSide(
                                                    color: getColorControlByPart(
                                                        partie: 0,
                                                        status:
                                                            controlController
                                                                .controlModel!
                                                                .status
                                                                .toString()),
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12)),
                                              child: Container(
                                                width:
                                                    sizeWidth(context: context),
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 5),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    // title
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    Text(
                                                      "Technicien",
                                                      style:
                                                          gothicBold.copyWith(
                                                        color: Colors.black,
                                                        fontSize: 20,
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    Container(
                                                      margin: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 10),
                                                      child: Row(
                                                        children: [
                                                          // image
                                                          CustomImageCircle(
                                                              width: 80,
                                                              height: 80,
                                                              image: controlController
                                                                  .controlModel!
                                                                  .listControlTechniciens!
                                                                  .first
                                                                  .technicienModel!
                                                                  .photo
                                                                  .toString()),
                                                          const SizedBox(
                                                            width: 10,
                                                          ),
                                                          Expanded(
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                                // name
                                                                Text(
                                                                  '${controlController.controlModel!.listControlTechniciens!.first.technicienModel!.userModel!.first_name.toString()} ${controlController.controlModel!.listControlTechniciens!.first.technicienModel!.userModel!.last_name.toString()}',
                                                                  style: gothicBold
                                                                      .copyWith(
                                                                    fontSize:
                                                                        16,
                                                                  ),
                                                                ),
                                                                // category
                                                                Text(
                                                                  "Technicien",
                                                                  style: gothicRegular
                                                                      .copyWith(
                                                                          color:
                                                                              normalText,
                                                                          fontSize:
                                                                              13),
                                                                ),
                                                                // start
                                                                getStart(
                                                                  start: int.parse(double.parse(controlController
                                                                          .controlModel!
                                                                          .listControlTechniciens!
                                                                          .first
                                                                          .technicienModel!
                                                                          .notation
                                                                          .toString())
                                                                      .toStringAsFixed(
                                                                          0)),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),

                                          // diagnosti
                                          Container(
                                            width: sizeWidth(context: context),
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 15),
                                            child: Card(
                                              elevation: 1,
                                              shadowColor:
                                                  getColorControlByPart(
                                                      partie: 0,
                                                      status: controlController
                                                          .controlModel!.status
                                                          .toString()),
                                              borderOnForeground: true,
                                              color: Colors.white,
                                              semanticContainer: true,
                                              shape: RoundedRectangleBorder(
                                                  //<-- SEE HERE
                                                  side: BorderSide(
                                                    color: getColorControlByPart(
                                                        partie: 0,
                                                        status:
                                                            controlController
                                                                .controlModel!
                                                                .status
                                                                .toString()),
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12)),
                                              child: Container(
                                                width:
                                                    sizeWidth(context: context),
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 5),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    // title
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    Text(
                                                      "Diagnostic",
                                                      style:
                                                          gothicBold.copyWith(
                                                        color: Colors.black,
                                                        fontSize: 20,
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    // type

                                                    for (var item
                                                        in getListDiagnostic(
                                                            diagnoString:
                                                                controlController
                                                                    .controlModel!
                                                                    .diagnostic!
                                                                    .diagnostic
                                                                    .toString()))
                                                      diagnoWd(
                                                          diagnoItem: item,
                                                          context: context),
                                                  ],
                                                ),
                                              ),
                                            ),
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
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }

  List<DiagnoItem> getListDiagnostic({required String diagnoString}) {
    List<DiagnoItem> listDiagno = [];

    if (diagnoString != '' && diagnoString != "null") {
      List listStr = diagnoString.split("\n");

      // for (var element in listStr) {
      for (var i = 0; i < listStr.length; i++) {
        if (listStr[i] != null) {
          listDiagno
              .add(DiagnoItem.fromString(diagn: listStr[i], id: i.toString()));
        }
      }
    }

    return listDiagno;
  }

  Widget diagnoWd(
      {required DiagnoItem diagnoItem, required BuildContext context}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      width: sizeWidth(context: context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (diagnoItem.id.toString() == "0")
            Container(
              margin: const EdgeInsets.only(bottom: 15, left: 15, right: 15),
              decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: linetimColor))),
              width: sizeWidth(context: context),
              child: Text(
                "DOCUMENTS",
                style: gothicBold.copyWith(fontSize: 17, color: linetimColor),
              ),
            ),
          if (diagnoItem.id.toString() == "6")
            Container(
              margin: const EdgeInsets.only(bottom: 15, left: 15, right: 15),
              decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: linetimColor))),
              width: sizeWidth(context: context),
              child: Text(
                "EXTERIEUR",
                style: gothicBold.copyWith(fontSize: 17, color: linetimColor),
              ),
            ),
          if (diagnoItem.id.toString() == "21")
            Container(
              margin: const EdgeInsets.only(bottom: 15, left: 15, right: 15),
              decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: linetimColor))),
              width: sizeWidth(context: context),
              child: Text(
                "INTERIEUR",
                style: gothicBold.copyWith(fontSize: 17, color: linetimColor),
              ),
            ),
          if (diagnoItem.id.toString() == "31")
            Container(
              margin: const EdgeInsets.only(bottom: 15, left: 15, right: 15),
              decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: linetimColor))),
              width: sizeWidth(context: context),
              child: Text(
                "MECANIQUE",
                style: gothicBold.copyWith(fontSize: 17, color: linetimColor),
              ),
            ),
          if (diagnoItem.id.toString() == "39")
            Container(
              margin: const EdgeInsets.only(bottom: 15, left: 15, right: 15),
              decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: linetimColor))),
              width: sizeWidth(context: context),
              child: Text(
                "TEST DU VECHICULE",
                style: gothicBold.copyWith(fontSize: 17, color: linetimColor),
              ),
            ),
          if (diagnoItem.id.toString() == "43")
            Container(
              margin: const EdgeInsets.only(bottom: 15, left: 15, right: 15),
              decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: linetimColor))),
              width: sizeWidth(context: context),
              child: Text(
                "DOMMAGE(S)",
                style: gothicBold.copyWith(fontSize: 17, color: linetimColor),
              ),
            ),
          if (diagnoItem.id.toString() != "43")
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    diagnoItem.title.toString(),
                    style: gothicBold.copyWith(
                      color: [
                        "bon état",
                        "oui",
                        "bon normal",
                      ].contains(diagnoItem.etat.toString().toLowerCase())
                          ? Colors.green
                          : [
                              "mauvais état",
                              "non",
                              "mauvais normal"
                            ].contains(diagnoItem.etat.toString().toLowerCase())
                              ? Colors.red
                              : normalText,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 15,
                ),
                Text(
                  diagnoItem.etat.toString(),
                  style: gothicBold.copyWith(
                    color: [
                      "bon état",
                      "oui",
                      "bon normal",
                    ].contains(diagnoItem.etat.toString().toLowerCase())
                        ? Colors.green
                        : [
                            "mauvais état",
                            "non",
                            "mauvais normal"
                          ].contains(diagnoItem.etat.toString().toLowerCase())
                            ? Colors.red
                            : normalText,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          // name + etat

          // comment
          if (diagnoItem.etat.toString() != "Bon état")
            if (diagnoItem.comment.toString() != "")
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                child: Text(
                  diagnoItem.comment.toString(),
                  style: gothicMediom.copyWith(
                    fontSize: 13,
                  ),
                ),
              ),
          // images
          if (diagnoItem.etat.toString() != "Bon état")
            if (diagnoItem.images!.isNotEmpty)
              Container(
                width: sizeWidth(context: context),
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                child: Wrap(
                  children: [
                    for (String img in diagnoItem.images!)
                      if (img != "")
                        Container(
                          height: 50,
                          width: 70,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          child: InkWell(
                              onTap: () {
                                Get.to(() => ImageShowScreen(url: img),
                                    routeName: RouteHelper.getShowImageRoute(
                                        url: img));
                              },
                              child: getImageDiagno(image: img)),
                        ),
                  ],
                ),
              ),
          const Divider(),
        ],
      ),
    );
  }

  Widget getImageDiagno({required String image}) {
    return CustomImage(
      height: 50,
      width: 70,
      image: image,
    );
  }
}
