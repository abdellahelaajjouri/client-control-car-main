import 'package:client_control_car/constants/constants.dart';
import 'package:client_control_car/controllers/auth_controller.dart';
import 'package:client_control_car/pages/menu/drawer_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jwt_decode/jwt_decode.dart';

class MatsterWidget extends StatelessWidget {
  final BuildContext context;
  final Widget widget;
  const MatsterWidget({super.key, required this.context, required this.widget});
  @override
  Widget build(BuildContext context) {
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    check();
    return SafeArea(
      child: SizedBox(
        height: sizeHeight(context: context),
        width: sizeWidth(context: context),
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
            Expanded(child: widget),
          ],
        ),
      ),
    );
  }
}

class MasterScreen extends StatefulWidget {
  final Widget widget;
  const MasterScreen({super.key, required this.widget});

  @override
  State<MasterScreen> createState() => _MasterScreenState();
}

class _MasterScreenState extends State<MasterScreen> {
  @override
  void initState() {
    super.initState();
    check();
  }

  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        height: sizeHeight(context: context),
        width: sizeWidth(context: context),
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
            Expanded(child: widget),
          ],
        ),
      ),
    );
  }
}
