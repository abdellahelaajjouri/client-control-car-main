import 'dart:developer';

import 'package:client_control_car/constants/constants.dart';
import 'package:client_control_car/constants/route_helper.dart';
import 'package:client_control_car/controllers/auth_controller.dart';
import 'package:client_control_car/controllers/control_controller.dart';
import 'package:client_control_car/controllers/notification_controller.dart';
import 'package:client_control_car/models/control_model.dart';
import 'package:client_control_car/models/last_messages_model.dart';
import 'package:client_control_car/models/notification_model.dart';
import 'package:client_control_car/pages/auth/widgets/custom_input_validator.dart';
import 'package:client_control_car/pages/chat/list_chat_from_screen.dart';
import 'package:client_control_car/pages/chat/list_last_chat_screen.dart';
import 'package:client_control_car/pages/contact_assistance/contact_assistance_screen.dart';
import 'package:client_control_car/pages/historys/consulter_rapport_page.dart';
import 'package:client_control_car/pages/historys/mes_commande_detail_page.dart';
import 'package:client_control_car/pages/info_vehicule/info_vehicule_screen.dart';
import 'package:client_control_car/pages/menu/drawer_widget.dart';
import 'package:client_control_car/pages/menu/menu_bottom.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:loading_overlay/loading_overlay.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  ScrollController scrollController = ScrollController();
  bool isLoading = true;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  final _formKey = GlobalKey<FormState>();
  TextEditingController commentController = TextEditingController();
  FocusNode commentFocus = FocusNode();
  double nbrStart = 0;

  @override
  void initState() {
    super.initState();
    check().then((value) {
      getData(isFirst: true, page: 1);
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
            if (snapshot.docs.isNotEmpty) {
              DocumentChange change = snapshot.docChanges.last;
              if (change.type == DocumentChangeType.added ||
                  change.type == DocumentChangeType.modified) {
                if (change.doc["isvue"].toString() == "false" &&
                    payload["user_id"].toString() ==
                        change.doc["user"].toString() &&
                    change.doc["type"].toString().toLowerCase() !=
                        "Nouveau message".toLowerCase()) {
                  controlRef
                      .doc(change.doc.id.toString())
                      .update({"isvue": true}).then((value) => null);
                  // Get.defaultDialog();
                  NotificationControl notificationControl = Get.find();
                  int page = 1;
                  if (notificationControl.currentPage <
                      notificationControl.maxPage) {
                    page = notificationControl.currentPage + 1;
                  } else {
                    page = notificationControl.maxPage;
                  }
                  getData(page: page, isFirst: false);
                }
              }
            }
          });
        }
      });
    });
  }

  getData({int page = 1, bool isFirst = true}) async {
    NotificationControl notificationControl = Get.find();
    notificationControl
        .getAllNotificationController(isvuupdate: true, page: page)
        .then((value) {
      setState(() {
        isLoading = false;
      });
      if (isFirst) {
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
                if (element["type"].toString().toLowerCase() !=
                        "Nouveau message".toLowerCase() &&
                    payload["user_id"].toString() ==
                        element["user"].toString()) {
                  FirebaseFirestore.instance
                      .collection("notification")
                      .doc(element.id)
                      .delete();
                }
              }
            }
          },
        );
      }
    }).catchError((onError) {
      log("error : ${onError.toString()}");
      setState(() {
        isLoading = false;
      });
      if (isFirst) {
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
                if (element["type"].toString().toLowerCase() !=
                        "Nouveau message".toLowerCase() &&
                    payload["user_id"].toString() ==
                        element["user"].toString()) {
                  FirebaseFirestore.instance
                      .collection("notification")
                      .doc(element.id)
                      .delete();
                }
              }
            }
          },
        );
      }
    });
  }

  // getControls() async {
  //   ControlController controlController = Get.find();
  //   controlController
  //       .getAllControlsController()
  //       .then((value) {})
  //       .catchError((onError) {});
  // }

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
          width: sizeWidth(context: context),
          height: sizeHeight(context: context),
          child: LoadingOverlay(
            isLoading: isLoading,
            child:
                GetBuilder<NotificationControl>(builder: (notificationControl) {
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
                                    AuthController authController = Get.find();
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
                          child: NotificationListener<ScrollNotification>(
                            onNotification: (ScrollNotification scrollInfo) {
                              if (scrollInfo.metrics.pixels ==
                                  scrollInfo.metrics.maxScrollExtent) {
                                if (!isLoading &&
                                    notificationControl.currentPage <
                                        notificationControl.maxPage) {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  NotificationControl notificationControl =
                                      Get.find();
                                  int page = 1;
                                  if (notificationControl.currentPage <
                                      notificationControl.maxPage) {
                                    page = notificationControl.currentPage + 1;
                                  }
                                  getData(page: page, isFirst: false);
                                }
                                // Load more data or trigger pagination
                                // Call a function here to fetch the next page of data
                              }
                              return false;
                            },
                            child: SingleChildScrollView(
                              controller: scrollController,
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
                                      width: double.infinity,
                                      child: Text(
                                        "Notification",
                                        textAlign: TextAlign.center,
                                        style:
                                            gothicBold.copyWith(fontSize: 25),
                                      ),
                                    ),
                                    // list
                                    const SizedBox(
                                      height: 30,
                                    ),
                                    if (notificationControl
                                        .listNotification.isEmpty)
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
                                    for (var notification
                                        in notificationControl.listNotification)
                                      Center(
                                        child: Container(
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 15, vertical: 5),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 7),
                                          constraints: const BoxConstraints(
                                              maxWidth: 800),
                                          decoration: BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(
                                                color: blueColor,
                                                width: 4,
                                              ),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              // icon
                                              getIconNotification(
                                                  notificationModel:
                                                      notification),
                                              // content
                                              Expanded(
                                                child: Column(
                                                  children: [
                                                    Container(
                                                      margin: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 3),
                                                      child: Text(
                                                        notification.title
                                                            .toString(),
                                                        style:
                                                            gothicBold.copyWith(
                                                          fontSize: 15,
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      margin: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 3),
                                                      child: Text(
                                                        notification.body
                                                            .toString(),
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: gothicMediom
                                                            .copyWith(
                                                          fontSize: 11,
                                                        ),
                                                      ),
                                                    ),
                                                    getInfoControl(
                                                        notification:
                                                            notification),
                                                    getButtonNotification(
                                                        notification:
                                                            notification),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
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
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget getInfoControl({required NotificationModel notification}) {
    if (["Controle accepte".toLowerCase(), "Lancement commande".toLowerCase()]
        .contains(notification.type.toString().toLowerCase())) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        margin: const EdgeInsets.only(bottom: 5, top: 3),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(
            child: Row(
              children: [
                Text(
                  "Date du contrôle: ",
                  style: gothicBold.copyWith(
                    fontSize: 9,
                  ),
                ),
                Text(
                  DateFormat("dd MMMM yyyy", "fr").format(
                    DateTime.parse(
                        "${notification.demandecontrol!.rendez_vous!.date} ${notification.demandecontrol!.rendez_vous!.time}"),
                  ),
                  style: gothicBold.copyWith(
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          // date
          const SizedBox(
            width: 10,
          ),
          // hour
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                "Heure: ",
                style: gothicBold.copyWith(fontSize: 9),
              ),
              Text(
                DateFormat("HH:mm").format(
                  DateTime.parse(
                      "${notification.demandecontrol!.rendez_vous!.date} ${notification.demandecontrol!.rendez_vous!.time}"),
                ),
                style: gothicBold.copyWith(
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ]),
      );
    } else if ([
      "Controle refuse".toLowerCase(),
      "Annulation technicien".toLowerCase(),
      "Diagnostic disponible".toLowerCase(),
      "Technicien arrive".toLowerCase(),
      "Controle annule".toLowerCase(),
      "Annulation client".toLowerCase(),
      "Controle j-1 accepte".toLowerCase(),
      "Controle j-1 suspens".toLowerCase(),
      "Controle h-1 accepte".toLowerCase(),
      "Controle h-1 suspens".toLowerCase(),
    ].contains(notification.type.toString().toLowerCase())) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        margin: const EdgeInsets.only(bottom: 5, top: 3),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(
            child: Row(
              children: [
                Text(
                  DateFormat("dd MMMM yyyy - HH:mm", "fr").format(
                    DateTime.parse(
                        "${notification.demandecontrol!.rendez_vous!.date} ${notification.demandecontrol!.rendez_vous!.time}"),
                  ),
                  style: gothicBold.copyWith(
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          // date
          const SizedBox(
            width: 10,
          ),
          // hour
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                "Commande n°",
                style: gothicBold.copyWith(fontSize: 9),
              ),
              Text(
                notification.demandecontrol!.id.toString(),
                style: gothicBold.copyWith(
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ]),
      );
    } else {
      return Container();
    }
  }

  Widget getButtonNotification({required NotificationModel notification}) {
    if (notification.type.toString().toLowerCase() ==
        "Inscription client".toLowerCase()) {
      return Container(
        height: 25,
        margin: const EdgeInsets.symmetric(vertical: 5),
        child: ElevatedButton(
          onPressed: () {
            Get.to(() => const InfoVehiculeScreen(),
                routeName: RouteHelper.getInfoVehiculeRoute());
          },
          style:
              ButtonStyle(backgroundColor: MaterialStatePropertyAll(blueColor)),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              "LANCER MA DEMANDE",
              style: gothicBold.copyWith(color: Colors.white, fontSize: 12),
            ),
          ),
        ),
      );
    } else if (notification.type.toString().toLowerCase() ==
        "Lancement commande".toLowerCase()) {
      return Container(
        height: 25,
        margin: const EdgeInsets.symmetric(vertical: 5),
        child: ElevatedButton(
          onPressed: () {
            Get.to(
              () => MesCommandeDetailPage(
                controlId: notification.demandecontrol!.id.toString(),
              ),
              routeName: RouteHelper.getMesCommandeDetailRoute(
                countrolId: notification.demandecontrol!.id.toString(),
              ),
            );
          },
          style:
              ButtonStyle(backgroundColor: MaterialStatePropertyAll(blueColor)),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              "VOIR MA COMMANDE",
              style: gothicBold.copyWith(color: Colors.white, fontSize: 10),
            ),
          ),
        ),
      );
    } else if (["Technicien arrive".toLowerCase()]
        .contains(notification.type.toString().toLowerCase())) {
      return Container(
        height: 25,
        margin: const EdgeInsets.symmetric(vertical: 5),
        child: ElevatedButton(
          onPressed: () {
            UserChat userChat = UserChat(
              id: notification.demandecontrol!.listControlTechniciens!.first
                  .technicienModel!.userModel!.id,
              phone: notification.demandecontrol!.listControlTechniciens!.first
                  .technicienModel!.userModel!.phone,
              username: notification.demandecontrol!.listControlTechniciens!
                  .first.technicienModel!.userModel!.first_name,
              role: notification.demandecontrol!.listControlTechniciens!.first
                  .technicienModel!.userModel!.role,
              email: notification.demandecontrol!.listControlTechniciens!.first
                  .technicienModel!.userModel!.email,
              nom: notification.demandecontrol!.listControlTechniciens!.first
                  .technicienModel!.userModel!.first_name
                  .toString(),
              prenom: notification.demandecontrol!.listControlTechniciens!.first
                  .technicienModel!.userModel!.last_name,
              photo: notification.demandecontrol!.listControlTechniciens!.first
                  .technicienModel!.userModel!.photo
                  .toString(),
            );
            Get.to(() => ListChatFromScreen(userChat: userChat),
                routeName:
                    RouteHelper.getListChatFromRoute(userChat: userChat));
          },
          style:
              ButtonStyle(backgroundColor: MaterialStatePropertyAll(blueColor)),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              "ENVOYER UN MESSAGE",
              style: gothicBold.copyWith(color: Colors.white, fontSize: 10),
            ),
          ),
        ),
      );
    } else if (["Diagnostic disponible".toLowerCase()]
        .contains(notification.type.toString().toLowerCase())) {
      return Container(
        height: 25,
        margin: const EdgeInsets.symmetric(vertical: 5),
        child: ElevatedButton(
          onPressed: () {
            Get.to(
              () => ConsultRapportScreen(
                idcontrol: notification.demandecontrol!.id.toString(),
              ),
              routeName: RouteHelper.getConsultRapportRoute(
                idcontrol: notification.demandecontrol!.id.toString(),
              ),
            );
          },
          style:
              ButtonStyle(backgroundColor: MaterialStatePropertyAll(blueColor)),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              "VOIR LE RAPPORT",
              style: gothicBold.copyWith(color: Colors.white, fontSize: 10),
            ),
          ),
        ),
      );
    }
    // else if (["Controle annule".toLowerCase()]
    //     .contains(notification.type.toString().toLowerCase())) {
    //   return Container(
    //     height: 25,
    //     margin: const EdgeInsets.symmetric(vertical: 5),
    //     child: ElevatedButton(
    //       onPressed: () {},
    //       style:
    //           ButtonStyle(backgroundColor: MaterialStatePropertyAll(blueColor)),
    //       child: Container(
    //         margin: const EdgeInsets.symmetric(horizontal: 10),
    //         child: Text(
    //           "VOIR LE CODE PROMO",
    //           style: gothicBold.copyWith(color: Colors.white, fontSize: 10),
    //         ),
    //       ),
    //     ),
    //   );
    // }
    else if (["Nouveau message".toLowerCase()]
        .contains(notification.type.toString().toLowerCase())) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        height: 25,
        child: ElevatedButton(
          onPressed: () {
            Get.to(
              () => const ListLastChatScreen(),
              routeName: RouteHelper.getListLastChatRoute(),
            );
          },
          style:
              ButtonStyle(backgroundColor: MaterialStatePropertyAll(blueColor)),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              "VOIR MES MESSAGES",
              style: gothicBold.copyWith(color: Colors.white, fontSize: 10),
            ),
          ),
        ),
      );
    } else if (["Avis client".toLowerCase()]
            .contains(notification.type.toString().toLowerCase()) &&
        notification.demandecontrol!.status.toString() == "6") {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        height: 25,
        child: ElevatedButton(
          onPressed: () {
            Get.bottomSheet(
                Container(
                  height: sizeHeight(context: context) * .6,
                  decoration: const BoxDecoration(color: Colors.white),
                  child: Form(
                    key: _formKey,
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
                            Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              child: Text(
                                "Notez votre commande",
                                textAlign: TextAlign.center,
                                style: gothicBold.copyWith(
                                  color: normalText,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            //
                            // image
                            Container(
                              width: 70,
                              height: 60,
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 5),
                              decoration: BoxDecoration(
                                  color: greyColor,
                                  borderRadius: BorderRadius.circular(5)),
                              child: CircleAvatar(
                                child: Image.network(
                                  notification
                                      .demandecontrol!
                                      .listControlTechniciens!
                                      .first
                                      .technicienModel!
                                      .photo
                                      .toString(),
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.asset(
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
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              child: Text(
                                "${notification.demandecontrol!.listControlTechniciens!.first.technicienModel!.userModel!.first_name} ${notification.demandecontrol!.listControlTechniciens!.first.technicienModel!.userModel!.last_name}",
                                style: gothicBold.copyWith(
                                  color: normalText,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            //
                            const SizedBox(
                              height: 5,
                            ),
                            Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              child: Text(
                                "Technicien",
                                style: gothicBold.copyWith(
                                  color: normalText,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              child: RatingBar.builder(
                                initialRating: nbrStart,
                                minRating: 1,
                                direction: Axis.horizontal,
                                allowHalfRating: false,
                                itemCount: 5,
                                maxRating: 1,
                                itemPadding:
                                    const EdgeInsets.symmetric(horizontal: 4.0),
                                itemBuilder: (context, _) => Icon(
                                  Icons.star,
                                  color: blueColor,
                                ),
                                onRatingUpdate: (rating) {
                                  setState(() {
                                    nbrStart = rating;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            //
                            Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              child: CustomInputValidatore(
                                controller: commentController,
                                labelText: null,
                                hintText: "Ecrivez votre commentaire",
                                maxLines: 5,
                                minLines: 3,
                                focusNode: commentFocus,
                                width: sizeWidth(context: context),
                                marginContainer:
                                    const EdgeInsets.symmetric(horizontal: 2),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
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
                              width: sizeWidth(context: context) * .8,
                              child: ElevatedButton(
                                  onPressed: () {
                                    if (nbrStart == 0) {
                                      Get.snackbar(
                                        maxWidth: 500,
                                        backgroundColor:
                                            blueColor.withOpacity(.7),
                                        "Veuillez sélectionner au moins un étoile",
                                        "Veuillez réessayer",
                                      );
                                    } else {
                                      Get.back();
                                      setState(() {
                                        isLoading = true;
                                      });
                                      ControlController controlController =
                                          Get.find();
                                      controlController
                                          .addreviewController(
                                              control: notification
                                                  .demandecontrol!.id
                                                  .toString(),
                                              comment:
                                                  commentController.text.isEmpty
                                                      ? ""
                                                      : commentController.text,
                                              technicien: notification
                                                  .demandecontrol!
                                                  .listControlTechniciens!
                                                  .first
                                                  .technicienModel!
                                                  .id
                                                  .toString(),
                                              notation:
                                                  nbrStart.toStringAsFixed(0))
                                          .then((value) {
                                        if (value.isSuccess) {
                                          // add message
                                          Get.snackbar(
                                            maxWidth: 500,
                                            backgroundColor:
                                                blueColor.withOpacity(.7),
                                            "votre avis a été ajouté",
                                            "",
                                          );
                                          getData(page: 1, isFirst: false);
                                        } else {
                                          setState(() {
                                            isLoading = false;
                                          });
                                          if (value.message
                                              .toLowerCase()
                                              .contains(
                                                  "deja exist".toLowerCase())) {
                                            Get.snackbar(
                                              maxWidth: 500,
                                              backgroundColor:
                                                  blueColor.withOpacity(.7),
                                              "Votre note existe déjà",
                                              "Veuillez réessayer",
                                            );
                                          } else {
                                            Get.snackbar(
                                              maxWidth: 500,
                                              backgroundColor:
                                                  blueColor.withOpacity(.7),
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
                                          backgroundColor:
                                              blueColor.withOpacity(.7),
                                          "Votre demande n'a pas été enregistrée",
                                          "Veuillez réessayer",
                                        );
                                      });
                                    }
                                  },
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all(blueColor),
                                    padding: MaterialStateProperty.all(
                                      const EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 15),
                                    ),
                                    shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(0),
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    "Continuer",
                                    style: gothicBold.copyWith(
                                        color: Colors.white),
                                  )),
                            ),
                            SizedBox(
                              width: sizeWidth(context: context) * .8,
                              child: ElevatedButton(
                                  onPressed: () {
                                    // start pass
                                    Get.back();
                                    setState(() {
                                      isLoading = true;
                                    });
                                    ControlController controlController =
                                        Get.find();
                                    controlController
                                        .updateStatuControlsController(
                                            idControl: notification
                                                .demandecontrol!.id
                                                .toString(),
                                            status: "7")
                                        .then((value) {
                                      if (value.isSuccess) {
                                        getData(page: 1, isFirst: false);
                                        passControlFini();
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
                                    }).catchError((onerror) {
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

                                    // end pass
                                  },
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all(Colors.white),
                                    padding: MaterialStateProperty.all(
                                      const EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 15),
                                    ),
                                    shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(0),
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    "Passer",
                                    style: gothicBold.copyWith(
                                        color: Colors.black),
                                  )),
                            ),
                            SizedBox(
                              width: sizeWidth(context: context) * .8,
                              child: ElevatedButton(
                                onPressed: () {
                                  Get.dialog(Scaffold(
                                    // appBar: AppBar(),
                                    floatingActionButton: FloatingActionButton(
                                      onPressed: () {
                                        Get.back();
                                      },
                                      child: const BackButton(),
                                    ),
                                    floatingActionButtonLocation:
                                        FloatingActionButtonLocation
                                            .miniEndFloat,
                                    body: ConsultRapportScreen(
                                      idcontrol: notification.demandecontrol!.id
                                          .toString(),
                                    ),
                                  ));
                                  // Get.to(
                                  //   () => ConsultRapportScreen(
                                  //     idcontrol: listCntrols.first.id.toString(),
                                  //   ),
                                  //   routeName: RouteHelper.getConsultRapportRoute(
                                  //     idcontrole: listCntrols.first.id.toString(),
                                  //   ),
                                  // );
                                },
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all(blueColor),
                                  padding: MaterialStateProperty.all(
                                    const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 15),
                                  ),
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(0),
                                    ),
                                  ),
                                ),
                                child: Text(
                                  "Voir le diagnostic",
                                  style:
                                      gothicBold.copyWith(color: Colors.white),
                                ),
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
                ),
                isScrollControlled: true);
          },
          style:
              ButtonStyle(backgroundColor: MaterialStatePropertyAll(blueColor)),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              "NOTER LE TECHNICIEN",
              style: gothicBold.copyWith(color: Colors.white, fontSize: 12),
            ),
          ),
        ),
      );
    } else if (["Controle j-1 suspens".toLowerCase()]
            .contains(notification.type.toString().toLowerCase()) &&
        notification.demandecontrol!.status.toString() == "1") {
      return Column(
        children: [
          // first
          Container(
            margin: const EdgeInsets.symmetric(vertical: 5),
            height: 25,
            child: ElevatedButton(
              onPressed: () {
                ControlController controlController = Get.find();
                Get.defaultDialog(
                    title: "Vous êtes sur de vouloir annuler?",
                    titleStyle: gothicBold.copyWith(
                      fontSize: 14,
                    ),
                    content: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 15),
                      child: Column(
                        children: [
                          // sub
                          Text(
                            "Nous ne pourrons malheuresement pas vous rembourser",
                            style: gothicMediom.copyWith(
                              fontSize: 12,
                            ),
                          ),

                          // button
                          Container(
                            margin: const EdgeInsets.only(
                              top: 8,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  height: 30,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Get.back();
                                      setState(() {
                                        isLoading = true;
                                      });
                                      // update state
                                      controlController
                                          .updateStatuControlsController(
                                              idControl: notification
                                                  .demandecontrol!.id
                                                  .toString(),
                                              status: "8")
                                          .then((value) {
                                        if (value.isSuccess) {
                                          Get.snackbar(
                                            maxWidth: 500,
                                            backgroundColor:
                                                blueColor.withOpacity(.7),
                                            "Votre commande a été annulée",
                                            "Nous vous enverrons un code de coupon à utiliser une seule fois et dans un délai maximum d'un an.",
                                          );
                                          scrollController.animateTo(
                                              //go to top of scroll
                                              0, //scroll offset to go
                                              duration: const Duration(
                                                  milliseconds:
                                                      500), //duration of scroll
                                              curve: Curves
                                                  .fastOutSlowIn //scroll type
                                              );
                                          getData(page: 1, isFirst: false);
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
                                      }).catchError((onerror) {
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
                                    style: const ButtonStyle(
                                      backgroundColor:
                                          MaterialStatePropertyAll(Colors.red),
                                    ),
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 20),
                                      child: Text(
                                        "OUI",
                                        style: gothicBold.copyWith(
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                SizedBox(
                                  height: 30,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Get.back();
                                    },
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStatePropertyAll(blueColor),
                                    ),
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 20),
                                      child: Text(
                                        "NON",
                                        style: gothicBold.copyWith(
                                            color: Colors.white),
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
              style: ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(blueColor)),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  "Annuler pour remboursement",
                  style: gothicBold.copyWith(color: Colors.white, fontSize: 10),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 3,
          ),

          // last
          Container(
            margin: const EdgeInsets.symmetric(vertical: 5),
            height: 25,
            child: ElevatedButton(
              onPressed: () {
                Get.snackbar(
                  maxWidth: 500,
                  backgroundColor: blueColor.withOpacity(.7),
                  "Votre commande est en attente",
                  "Nous recherchons le technicien de votre choix en priorité",
                );
              },
              style: ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(blueColor)),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  "Attendre encore",
                  style: gothicBold.copyWith(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          ),
        ],
      );
    } else if (['ticket_answered'].contains(notification.type.toString())) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        height: 25,
        child: ElevatedButton(
          onPressed: () {
            Get.to(() => const ContactAssistanceScreen(),
                routeName: RouteHelper.getContactAssistanceRoute());
          },
          style:
              ButtonStyle(backgroundColor: MaterialStatePropertyAll(blueColor)),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              "VOIR MES TICKETS",
              style: gothicBold.copyWith(color: Colors.white, fontSize: 10),
            ),
          ),
        ),
      );
    } else {
      return Container();
    }
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

  Widget getIconNotification({required NotificationModel notificationModel}) {
    if (notificationModel.type.toString().toLowerCase() ==
        "Inscription client".toLowerCase()) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        width: 80,
        child: Image.asset("assets/icons/inscription-icon-notif.png"),
      );
    } else if (notificationModel.type.toString().toLowerCase() ==
        "Lancement commande".toLowerCase()) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        width: 80,
        child: Image.asset("assets/icons/lancement_control_icon_notif.png"),
      );
    } else if ([
      "Controle accepte".toLowerCase(),
      "ticket_answered".toLowerCase()
    ].contains(notificationModel.type.toString().toLowerCase())) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        width: 80,
        child: Image.asset("assets/icons/control_accept-icon_notif.png"),
      );
    } else if ([
      "Controle refuse".toLowerCase(),
      "Annulation technicien".toLowerCase(),
    ].contains(notificationModel.type.toString().toLowerCase())) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        width: 80,
        child: Image.asset("assets/icons/control-refuse-notif-icon.png"),
      );
    } else if (["Technicien arrive".toLowerCase()]
        .contains(notificationModel.type.toString().toLowerCase())) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        width: 80,
        child: Image.asset("assets/icons/technicien-arrive-icon-notif.png"),
      );
    } else if (["Diagnostic disponible".toLowerCase()]
        .contains(notificationModel.type.toString().toLowerCase())) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        width: 80,
        child: Image.asset("assets/icons/diagno-despo-icon-notif.png"),
      );
    } else if (["Diagnostic impossible".toLowerCase()]
        .contains(notificationModel.type.toString().toLowerCase())) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        width: 80,
        child: Image.asset("assets/icons/diagno-imposible-icon-notif.png"),
      );
    } else if (["Controle annule".toLowerCase()]
            .contains(notificationModel.type.toString().toLowerCase()) ||
        notificationModel.body
            .toString()
            .toLowerCase()
            .contains("prochain controle")) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        width: 80,
        child: Image.asset("assets/icons/controle-annule-icon-notif.png"),
      );
    } else if (["Annulation client".toLowerCase()]
        .contains(notificationModel.type.toString().toLowerCase())) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        width: 80,
        child: Image.asset("assets/icons/profil_non_valid_icon_notif.png"),
      );
    } else if (["Nouveau message".toLowerCase()]
        .contains(notificationModel.type.toString().toLowerCase())) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        width: 80,
        child: Image.asset("assets/icons/new-message-icon-notif.png"),
      );
    } else if (["Avis client".toLowerCase()]
        .contains(notificationModel.type.toString().toLowerCase())) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        width: 80,
        child: Image.asset("assets/icons/avis-client-icon-notif.png"),
      );
    } else if (["Controle j-1 accepte".toLowerCase()]
        .contains(notificationModel.type.toString().toLowerCase())) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        width: 80,
        child: Image.asset("assets/icons/controle_j-1_accept_cl.png"),
      );
    } else if (["Controle j-1 suspens".toLowerCase()]
        .contains(notificationModel.type.toString().toLowerCase())) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        width: 80,
        child: Image.asset("assets/icons/controle_j-1_suspens.png"),
      );
    } else if (["Controle h-1 accepte".toLowerCase()]
        .contains(notificationModel.type.toString().toLowerCase())) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        width: 80,
        child: Image.asset("assets/icons/controle_h_1_accepte_cl.png"),
      );
    } else if (["Controle h-1 suspens".toLowerCase()]
        .contains(notificationModel.type.toString().toLowerCase())) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        width: 80,
        child: Image.asset("assets/icons/Controle_h_1_suspens_cl.png"),
      );
    } else {
      return Container();
    }
  }

  String getTimeNotification({required String createdAt}) {
    return DateFormat("dd MMMM yyyy - HH:mm", "fr")
        .format(DateTime.parse(createdAt));
  }

  String getSubTitle({required ControlModel controlModel}) {
    return "${controlModel.plan!.name} - ${getDateForm(date: controlModel.rendez_vous!.date.toString())} ${getTimeFormat(date: controlModel.rendez_vous!.date.toString(), time: controlModel.rendez_vous!.time.toString())}";
  }

  String getTimeFormat({required String date, required String time}) {
    String newDate = "$date $time";

    DateTime dateTime = DateTime.parse(newDate);

    String firstTime = DateFormat('HH:mm', 'fr').format(dateTime);
    String lastTime = DateFormat('HH:mm', 'fr')
        .format(dateTime.add(const Duration(hours: 1)));

    return "[$firstTime - $lastTime]";
  }

  String getDateForm({required String date}) {
    return DateFormat("dd MMMM", "fr").format(DateTime.parse(date));
  }

  ControlModel? getController({required String idController}) {
    ControlController controlController = Get.find();
    ControlModel? controller;
    for (var control in controlController.listControlModel) {
      if (control.id == idController) {
        controller = control;
        break;
      }
    }
    return controller;
  }
}
