import 'dart:async';
import 'dart:developer';

import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:client_control_car/constants/constants.dart';
import 'package:client_control_car/controllers/auth_controller.dart';
import 'package:client_control_car/controllers/chat_controller.dart';
import 'package:client_control_car/models/last_messages_model.dart';
import 'package:client_control_car/pages/chat/widgets/message_bar_wd.dart';
import 'package:client_control_car/pages/menu/drawer_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jwt_decode/jwt_decode.dart';

class ListChatFromScreen extends StatefulWidget {
  final UserChat userChat;
  const ListChatFromScreen({super.key, required this.userChat});

  @override
  State<ListChatFromScreen> createState() => _ListChatFromScreenState();
}

class _ListChatFromScreenState extends State<ListChatFromScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  bool isLoading = true;
  bool isLoadingSend = false;
  TextEditingController msgController = TextEditingController();

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
        }
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  getData() async {
    ChatController chatController = Get.find();
    chatController
        .getListMessagesController(userId: widget.userChat.id.toString())
        .then((value) {
      setState(() {
        isLoading = false;
        isLoadingSend = false;
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
      if (mounted) {
        setState(() {
          isLoading = false;
          isLoadingSend = false;
        });
      }
    });
  }

  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
      key: scaffoldKey,
      appBar: checkIsWeb(context: context)
          ? null
          : AppBar(
              title: GetBuilder<ChatController>(builder: ((chatController) {
                return Text(
                  "${widget.userChat.nom.toString()} ${widget.userChat.prenom.toString()}",
                  style: gothicBold.copyWith(
                    color: const Color(0xff0044AD),
                    fontSize: 18,
                  ),
                );
              })),
              iconTheme: IconThemeData(color: normalText),
              leading: InkWell(
                onTap: () {
                  Get.back();
                },
                child: const Icon(Icons.chevron_left),
              ),
              centerTitle: false,
              elevation: 0,
              backgroundColor: Colors.white,
            ),
      body: SafeArea(
          child: Container(
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : GetBuilder<ChatController>(
                builder: (chatController) {
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
                                      if (snapshotNotif.data!.docs.isNotEmpty) {
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
                                              "Nouveau message".toLowerCase()) {
                                            if (element["isvue"].toString() ==
                                                    "false" &&
                                                payload["user_id"].toString() ==
                                                    element["user"]
                                                        .toString()) {
                                              msgCont++;
                                            }
                                          } else {
                                            if (element["isvue"].toString() ==
                                                    "false" &&
                                                payload["user_id"].toString() ==
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
                                    title: GetBuilder<ChatController>(
                                        builder: ((chatController) {
                                      return Text(
                                        "${widget.userChat.nom.toString()} ${widget.userChat.prenom.toString()}",
                                        style: gothicBold.copyWith(
                                          color: const Color(0xff0044AD),
                                          fontSize: 18,
                                        ),
                                      );
                                    })),
                                    iconTheme: IconThemeData(color: normalText),
                                    leading: InkWell(
                                      onTap: () {
                                        Get.back();
                                      },
                                      child: const Icon(Icons.chevron_left),
                                    ),
                                    centerTitle: false,
                                    elevation: 0,
                                    backgroundColor: Colors.white,
                                  )
                                : Container(),
                            // list chats
                            Expanded(
                              child: ListView(
                                reverse: true,
                                children: [
                                  if (chatController.listMessages.isNotEmpty)
                                    for (var message
                                        in chatController.listMessages.reversed)
                                      BubbleNormal(
                                        text: message.message.toString(),
                                        isSender: message.sender.toString() !=
                                            widget.userChat.id.toString(),
                                        color: message.sender.toString() !=
                                                widget.userChat.id.toString()
                                            ? const Color(0xffE8E8EE)
                                            : const Color(0xff1B97f3),
                                        tail: true,
                                        sent: true,
                                      ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),

                            // inputs
                            MessageBarWd(
                              controller: msgController,
                              onSend: (_) {
                                if (msgController.text.isNotEmpty) {
                                  FirebaseFirestore firebaseFirestore =
                                      FirebaseFirestore.instance;
                                  setState(() {
                                    isLoadingSend = true;
                                  });
                                  chatController
                                      .addFromToListMessages(
                                          userId: widget.userChat.id.toString(),
                                          message: msgController.text)
                                      .then((value) {
                                    getData();
                                    firebaseFirestore
                                        .collection("notification")
                                        .add({
                                      "type": "Nouveau message",
                                      "user": widget.userChat.id.toString(),
                                      "isvue": false,
                                      "title": "Nouveau Message !",
                                      "body":
                                          "${widget.userChat.nom} ${widget.userChat.prenom}  vous a envoyé un message.",
                                      "demande_control": null
                                    });
                                    setState(() {
                                      isLoadingSend = false;
                                      msgController.clear();
                                    });
                                  }).catchError((onError) {
                                    setState(() {
                                      isLoadingSend = false;
                                    });
                                  });
                                } else {}
                              },
                              onTextChanged: (p0) {},
                              actions: [
                                if (isLoadingSend)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 8, right: 8),
                                    child: SizedBox(
                                      width: 10,
                                      height: 10,
                                      child: InkWell(
                                        onTap: () {},
                                        child: const CircularProgressIndicator(
                                            strokeWidth: 2),
                                      ),
                                    ),
                                  )
                                // Padding(
                                //   padding: const EdgeInsets.only(left: 8, right: 8),
                                //   child: InkWell(
                                //     onTap: () {},
                                //     child: Icon(
                                //       Icons.camera_alt,
                                //       color: Colors.green,
                                //       size: 24,
                                //     ),
                                //   ),
                                // )
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
      )),
    );
  }
}
