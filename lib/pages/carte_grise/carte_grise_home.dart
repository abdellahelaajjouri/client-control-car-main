import 'package:client_control_car/constants/constants.dart';
import 'package:client_control_car/constants/route_helper.dart';
import 'package:client_control_car/controllers/auth_controller.dart';
import 'package:client_control_car/pages/carte_grise/add_carte_grise.dart';
import 'package:client_control_car/pages/menu/drawer_widget.dart';
import 'package:client_control_car/pages/menu/menu_bottom.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jwt_decode/jwt_decode.dart';

class CarteGriseHomePage extends StatefulWidget {
  const CarteGriseHomePage({super.key});

  @override
  State<CarteGriseHomePage> createState() => _CarteGriseHomePageState();
}

class _CarteGriseHomePageState extends State<CarteGriseHomePage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  @override
  void initState() {
    super.initState();
    check();
  }

  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
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
              // leading: InkWell(
              //   onTap: () {
              //     Get.back();
              //   },
              //   child: Icon(
              //     Icons.arrow_back_ios,
              //     color: normalText,
              //   ),
              // ),
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
                              String access = authController.userModel!.access
                                          .toString() ==
                                      "null"
                                  ? authController.accessUserJWS.toString()
                                  : authController.userModel!.access.toString();
                              Map<String, dynamic> payload =
                                  Jwt.parseJwt(access);
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
                  )
                : Container(),
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
                  Expanded(
                    child: SingleChildScrollView(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 15),
                        width: sizeWidth(context: context),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            // titile
                            Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              child: Text(
                                "Facturation",
                                style: gothicBold.copyWith(fontSize: 25),
                              ),
                            ),
                            // subtitle
                            const SizedBox(
                              height: 15,
                            ),
                            // btns
                            Container(
                              width: double.infinity,
                              margin: const EdgeInsets.symmetric(vertical: 7),
                              child: ElevatedButton(
                                onPressed: () {
                                  Get.to(() => const AddCarteGrise(),
                                      routeName:
                                          RouteHelper.getAddCarteGriseRoute());
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
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  child: Text(
                                    "Créer ma carte grise",
                                    textAlign: TextAlign.start,
                                    style: gothicBold.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            Container(
                              width: double.infinity,
                              margin: const EdgeInsets.symmetric(vertical: 7),
                              child: OutlinedButton(
                                onPressed: () {},
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all(Colors.white),
                                  foregroundColor:
                                      MaterialStateProperty.all(normalText),
                                  padding: MaterialStateProperty.all(
                                    const EdgeInsets.symmetric(vertical: 15),
                                  ),
                                ),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  child: Text(
                                    "Changer l'adresse de ma carte grise",
                                    textAlign: TextAlign.start,
                                    style: gothicBold.copyWith(
                                      color: normalText,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            Container(
                              width: double.infinity,
                              margin: const EdgeInsets.symmetric(vertical: 7),
                              child: OutlinedButton(
                                onPressed: () {},
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all(Colors.white),
                                  foregroundColor:
                                      MaterialStateProperty.all(normalText),
                                  padding: MaterialStateProperty.all(
                                    const EdgeInsets.symmetric(vertical: 15),
                                  ),
                                ),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  child: Text(
                                    "Duplicata de ma carte grise",
                                    textAlign: TextAlign.start,
                                    style: gothicBold.copyWith(
                                      color: normalText,
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
                ],
              ),
            ),
          ],
        ),
      )),
    );
  }
}
