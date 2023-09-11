import 'dart:async';
import 'dart:developer';

import 'package:client_control_car/constants/constants.dart';
import 'package:client_control_car/constants/route_helper.dart';
import 'package:client_control_car/controllers/auth_controller.dart';
import 'package:client_control_car/controllers/chat_controller.dart';
import 'package:client_control_car/pages/chat/list_chat_from_screen.dart';
import 'package:client_control_car/pages/menu/drawer_widget.dart';
import 'package:client_control_car/pages/menu/menu_bottom.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:loading_overlay/loading_overlay.dart';

class ListLastChatScreen extends StatefulWidget {
  const ListLastChatScreen({super.key});

  @override
  State<ListLastChatScreen> createState() => _ListLastChatScreenState();
}

class _ListLastChatScreenState extends State<ListLastChatScreen> {
  bool isLoading = true;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    check().then((value) {
      getData();
      Future.delayed(const Duration(seconds: 15), () {
        AuthController authController = Get.find();
        if (authController.userModel != null ||
            authController.accessUserJWS.toString() != "") {
          final CollectionReference controlRef =
              FirebaseFirestore.instance.collection('notification');
          String access = authController.userModel!.access.toString() == "null"
              ? authController.accessUserJWS.toString()
              : authController.userModel!.access.toString();
          controlRef.snapshots().listen((QuerySnapshot snapshot) {
            Map<String, dynamic> payload = Jwt.parseJwt(access);

            if (snapshot.docChanges.isNotEmpty) {
              DocumentChange change = snapshot.docChanges.last;
              if (change.type == DocumentChangeType.added ||
                  change.type == DocumentChangeType.modified) {
                if (change.doc["isvue"].toString() == "false" &&
                    payload["user_id"].toString() ==
                        change.doc["user"].toString() &&
                    change.doc["type"].toString().toLowerCase() ==
                        "Nouveau message".toLowerCase()) {
                  controlRef
                      .doc(change.doc.id.toString())
                      .update({"isvue": true}).then((value) => null);
                  // Get.defaultDialog();
                  getData();
                }
              }
            }
          });
        } else {}
      });
    });
  }

  getData() {
    ChatController chatController = Get.find();

    chatController.getLastMessagesController().then((value) {
      setState(() {
        isLoading = false;
      });
      FirebaseFirestore.instance.collection("notification").get().then(
        (value) {
          if (value.docs.isNotEmpty) {
            AuthController authController = Get.find();
            String access =
                authController.userModel!.access.toString() == "null"
                    ? authController.accessUserJWS.toString()
                    : authController.userModel!.access.toString();
            Map<String, dynamic> payload = Jwt.parseJwt(access);
            for (var element in value.docs) {
              if (element["type"].toString().toLowerCase() ==
                      "Nouveau message".toLowerCase() &&
                  payload["user_id"].toString() == element["user"].toString()) {
                FirebaseFirestore.instance
                    .collection("notification")
                    .doc(element.id)
                    .delete();
              }
            }
          }
        },
      );
    }).catchError((onError) {
      log("error : ${onError.toString()}");
      FirebaseFirestore.instance.collection("notification").get().then(
        (value) {
          if (value.docs.isNotEmpty) {
            AuthController authController = Get.find();
            String access =
                authController.userModel!.access.toString() == "null"
                    ? authController.accessUserJWS.toString()
                    : authController.userModel!.access.toString();
            Map<String, dynamic> payload = Jwt.parseJwt(access);
            for (var element in value.docs) {
              if (element["type"].toString().toLowerCase() ==
                      "Nouveau message".toLowerCase() &&
                  payload["user_id"].toString() == element["user"].toString()) {
                FirebaseFirestore.instance
                    .collection("notification")
                    .doc(element.id)
                    .delete();
              }
            }
          }
        },
      );
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
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
          child: GetBuilder<ChatController>(builder: (chatController) {
            return LoadingOverlay(
              isLoading: isLoading,
              child: isLoading
                  ? Container()
                  : Row(
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
                          child: Column(
                            children: [
                              checkIsWeb(context: context)
                                  ? AppBar(
                                      backgroundColor: Colors.transparent,
                                      elevation: 0,
                                    )
                                  : Container(),
                              SingleChildScrollView(
                                child: SizedBox(
                                  width: sizeWidth(context: context),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      Container(
                                        width: sizeWidth(context: context),
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                        child: Text(
                                          "Messages",
                                          style: gothicMediom.copyWith(
                                            color: Colors.black,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      // list last chat
                                      if (chatController
                                          .listLastMessages.isEmpty)
                                        SizedBox(
                                          width: sizeWidth(context: context),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              // image
                                              Container(
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 15),
                                                child: Image.asset(
                                                  "assets/images/empty_order.jpg",
                                                  width: 200,
                                                ),
                                              ),
                                              // message
                                            ],
                                          ),
                                        ),
                                      for (var message
                                          in chatController.listLastMessages)
                                        Column(
                                          children: [
                                            ListTile(
                                              onTap: () {
                                                Get.to(
                                                        () =>
                                                            ListChatFromScreen(
                                                                userChat:
                                                                    message
                                                                        .user!),
                                                        routeName: RouteHelper
                                                            .getListChatFromRoute(
                                                                userChat: message
                                                                    .user!))!
                                                    .then((value) {
                                                  getData();
                                                });
                                              },
                                              leading: CircleAvatar(
                                                child: Text(
                                                  "${message.user!.nom.toString()} ${message.user!.prenom.toString()}"[
                                                          0]
                                                      .toUpperCase(),
                                                  style: gothicBold.copyWith(
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ),
                                              trailing: const Icon(
                                                Icons.arrow_forward_ios,
                                                size: 20,
                                              ),
                                              title: Text(
                                                "${message.user!.nom.toString()} ${message.user!.prenom.toString()}",
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: gothicBold.copyWith(
                                                  color: Colors.black,
                                                  fontSize: 18,
                                                ),
                                              ),
                                              subtitle: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  // message
                                                  Text(
                                                    message.messageChat!.message
                                                        .toString(),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  // date
                                                  Container(
                                                    alignment:
                                                        Alignment.topRight,
                                                    child: Text(
                                                      DateFormat(
                                                        "dd MMMM yyyy - HH:mm",
                                                        "fr",
                                                      ).format(
                                                        DateTime.parse(
                                                          message.messageChat!
                                                              .timestamp
                                                              .toString(),
                                                        ),
                                                      ),
                                                      maxLines: 1,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const Divider(),
                                          ],
                                        )
                                    ],
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
        ),
      ),
    );
  }
}
