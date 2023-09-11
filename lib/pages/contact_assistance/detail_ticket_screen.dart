import 'package:chat_bubbles/bubbles/bubble_normal.dart';
import 'package:client_control_car/constants/constants.dart';
import 'package:client_control_car/controllers/auth_controller.dart';
import 'package:client_control_car/controllers/chat_controller.dart';
import 'package:client_control_car/pages/chat/widgets/message_bar_wd.dart';
import 'package:client_control_car/pages/menu/drawer_widget.dart';
import 'package:client_control_car/pages/menu/menu_bottom.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:loading_overlay/loading_overlay.dart';

class DetailTicketScreen extends StatefulWidget {
  final String idTicket;
  const DetailTicketScreen({super.key, required this.idTicket});

  @override
  State<DetailTicketScreen> createState() => _DetailTicketScreenState();
}

class _DetailTicketScreenState extends State<DetailTicketScreen> {
  bool isLoading = true;
  bool isLoadingFirst = true;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  bool isLoadingSend = false;
  TextEditingController msgController = TextEditingController();

  @override
  void initState() {
    super.initState();
    check().then((value) {
      getData();
    });
  }

  getData() async {
    ChatController chatController = Get.find();

    chatController.getDetailTecket(idTicket: widget.idTicket).then((value) {
      setState(() {
        isLoading = false;
        isLoadingFirst = false;
      });
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
                    getData();
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
        child: LoadingOverlay(
          isLoading: isLoading,
          child: isLoadingFirst
              ? Container()
              : GetBuilder<ChatController>(builder: (chatController) {
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
                                  backgroundColor: Colors.transparent,
                                  elevation: 0,
                                )
                              : Container(),
                          Expanded(
                            child: ListView(
                              reverse: true,
                              children: [
                                if (chatController.detailTicketModel != null)
                                  for (var ticket in chatController
                                      .detailTicketModel!.conversation!)
                                    BubbleNormal(
                                      text: ticket.message.toString(),
                                      isSender:
                                          ticket.sender.toString() != "admin",
                                      color: ticket.sender.toString() != "admin"
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
                          //
                          MessageBarWd(
                            controller: msgController,
                            onSend: (_) {
                              if (msgController.text.isNotEmpty) {
                                // setState(() {
                                //   isLoadingSend = true;
                                // });
                              } else {}
                            },
                            onTextChanged: (p0) {},
                            actions: [
                              // if (isLoadingSend)
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 8, right: 8),
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
                      ))
                    ],
                  );
                }),
        ),
      )),
    );
  }
}
