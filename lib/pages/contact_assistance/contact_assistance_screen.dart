import 'package:client_control_car/constants/constants.dart';
import 'package:client_control_car/controllers/auth_controller.dart';
import 'package:client_control_car/controllers/chat_controller.dart';
import 'package:client_control_car/pages/auth/widgets/custom_input_validator.dart';
import 'package:client_control_car/pages/menu/drawer_widget.dart';
import 'package:client_control_car/pages/menu/menu_bottom.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:loading_overlay/loading_overlay.dart';

class ContactAssistanceScreen extends StatefulWidget {
  const ContactAssistanceScreen({super.key});

  @override
  State<ContactAssistanceScreen> createState() =>
      _ContactAssistanceScreenState();
}

class _ContactAssistanceScreenState extends State<ContactAssistanceScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  bool isLoading = true;
  final _formKey = GlobalKey<FormState>();
  TextEditingController nomController = TextEditingController();
  TextEditingController prenomController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController messageController = TextEditingController();

  FocusNode nomFocus = FocusNode();
  FocusNode prenomFocus = FocusNode();
  FocusNode emailFocus = FocusNode();
  FocusNode messageFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    check().then((value) {
      AuthController authController = Get.find();
      nomController.text = authController.userModel!.first_name.toString();
      prenomController.text = authController.userModel!.last_name.toString();
      emailController.text = authController.userModel!.email.toString();
      getData(page: 1);
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
                        change.doc["user"].toString()) {
                  // Get.defaultDialog();
                  getData(page: 1);
                }
              }
            }
          });
        } else {}
      });
    });
  }

  getData({required int page}) async {
    ChatController chatController = Get.find();
    chatController.getListTeckets(page: 1).then((value) {
      setState(() {
        isLoading = false;
      });
    }).catchError((onError) {
      setState(() {
        isLoading = false;
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
          child: LoadingOverlay(
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
                              ChatController chatController = Get.find();
                              if (!isLoading &&
                                  chatController.currentPageTicket <
                                      chatController.maxPageTicket) {
                                setState(() {
                                  isLoading = true;
                                });

                                int page = 1;
                                if (chatController.currentPageTicket <
                                    chatController.maxPageTicket) {
                                  page = chatController.currentPageTicket + 1;
                                }
                                getData(page: page);
                              }
                              // Load more data or trigger pagination
                              // Call a function here to fetch the next page of data
                            }
                            return false;
                          },
                          child: SingleChildScrollView(
                            child: GetBuilder<ChatController>(
                                builder: (chatController) {
                              return Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 15),
                                width: sizeWidth(context: context),
                                child: Center(
                                  child: Container(
                                    constraints: const BoxConstraints(
                                      maxWidth: 500,
                                    ),
                                    child: Form(
                                      key: _formKey,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          // title
                                          Container(
                                            width: double.infinity,
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 15),
                                            child: Text(
                                              "CONTACT ET ASSISTANCE",
                                              textAlign: TextAlign.center,
                                              style: gothicBold.copyWith(
                                                  fontSize: 25),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 15,
                                          ),
                                          //
                                          Container(
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 15),
                                            alignment: Alignment.center,
                                            child: Text(
                                              "Un problème ou une question ?",
                                              textAlign: TextAlign.center,
                                              style: gothicBold.copyWith(
                                                  fontSize: 15,
                                                  color: blueColor),
                                            ),
                                          ),
                                          Container(
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 15),
                                            alignment: Alignment.center,
                                            child: Text(
                                              "L’équipe de control-car est à votre disposition.",
                                              textAlign: TextAlign.center,
                                              style: gothicBold.copyWith(
                                                  fontSize: 15,
                                                  color: blueColor),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 20,
                                          ),
                                          //
                                          Container(
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 15),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.phone,
                                                  color: blueColor,
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    "06 99 54 71 98",
                                                    style: gothicBold.copyWith(
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          //
                                          Container(
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 15),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.mail,
                                                  color: blueColor,
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    "contact@control-car.fr",
                                                    style: gothicBold.copyWith(
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          //

                                          const SizedBox(
                                            height: 30,
                                          ),
                                          //
                                          Container(
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 15),
                                            child: Text(
                                              "Nous contacter",
                                              style: gothicBold.copyWith(
                                                  fontSize: 15,
                                                  color: blueColor),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          //
                                          CustomInputValidatore(
                                            controller: nomController,
                                            labelText: null,
                                            labelWidget: labelInput(
                                                text: "Nom", req: true),
                                            marginContainer:
                                                const EdgeInsets.only(
                                                    bottom: 11,
                                                    left: 15,
                                                    right: 15),
                                            width: Get.width * .9,
                                            inputType: TextInputType.text,
                                            focusNode: nomFocus,
                                            nextFocus: prenomFocus,
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return '';
                                              }
                                              return null;
                                            },
                                          ),
                                          //
                                          CustomInputValidatore(
                                            controller: prenomController,
                                            labelText: null,
                                            labelWidget: labelInput(
                                                text: "Prénom", req: true),
                                            marginContainer:
                                                const EdgeInsets.only(
                                                    bottom: 11,
                                                    left: 15,
                                                    right: 15),
                                            width: Get.width * .9,
                                            inputType: TextInputType.text,
                                            focusNode: prenomFocus,
                                            nextFocus: emailFocus,
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return '';
                                              }
                                              return null;
                                            },
                                          ),
                                          //
                                          CustomInputValidatore(
                                            controller: emailController,
                                            labelText: null,
                                            labelWidget: labelInput(
                                                text: "Email", req: true),
                                            marginContainer:
                                                const EdgeInsets.only(
                                                    bottom: 11,
                                                    left: 15,
                                                    right: 15),
                                            width: Get.width * .9,
                                            inputType: TextInputType.text,
                                            focusNode: emailFocus,
                                            nextFocus: messageFocus,
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty ||
                                                  !value.isEmail) {
                                                return '';
                                              }
                                              return null;
                                            },
                                          ),
                                          //
                                          CustomInputValidatore(
                                            controller: messageController,
                                            labelText: null,
                                            labelWidget: labelInput(
                                                text: "Message", req: true),
                                            marginContainer:
                                                const EdgeInsets.only(
                                                    bottom: 11,
                                                    left: 15,
                                                    right: 15),
                                            width: Get.width * .9,
                                            inputType: TextInputType.text,
                                            focusNode: messageFocus,
                                            maxLines: 7,
                                            minLines: 5,
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return '';
                                              }
                                              return null;
                                            },
                                          ),
                                          //
                                          Container(
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 15, vertical: 3),
                                            width: sizeWidth(context: context) *
                                                .9,
                                            // height: 30,
                                            child: ElevatedButton(
                                              onPressed: () {
                                                if (!_formKey.currentState!
                                                    .validate()) {
                                                  Get.snackbar(
                                                    maxWidth: 500,
                                                    backgroundColor: blueColor
                                                        .withOpacity(.7),
                                                    "Certains champs sont vides",
                                                    "Veuillez confirmer les champs!",
                                                  );
                                                } else {
                                                  if (nomController
                                                          .text.isNotEmpty &&
                                                      prenomController
                                                          .text.isNotEmpty &&
                                                      emailController
                                                          .text.isNotEmpty &&
                                                      messageController
                                                          .text.isNotEmpty) {
                                                    // save message
                                                    setState(() {
                                                      isLoading = true;
                                                    });

                                                    chatController
                                                        .sendContactAssistance(
                                                            nom: nomController
                                                                .text,
                                                            prenom:
                                                                prenomController
                                                                    .text,
                                                            email:
                                                                emailController
                                                                    .text,
                                                            message:
                                                                messageController
                                                                    .text)
                                                        .then((value) {
                                                      if (value.isSuccess) {
                                                        setState(() {
                                                          messageController
                                                              .clear();
                                                        });
                                                        getData(page: 1);
                                                        Get.snackbar(
                                                          maxWidth: 500,
                                                          backgroundColor:
                                                              blueColor
                                                                  .withOpacity(
                                                                      .7),
                                                          "Votre message a été envoyé",
                                                          "Nous vous contacterons",
                                                        );
                                                      } else {
                                                        getData(page: 1);
                                                        Get.snackbar(
                                                          maxWidth: 500,
                                                          backgroundColor:
                                                              blueColor
                                                                  .withOpacity(
                                                                      .7),
                                                          "Votre message n'a pas été envoyé",
                                                          "Veuillez essayer à nouveau",
                                                        );
                                                      }
                                                    }).catchError((onError) {
                                                      setState(() {
                                                        isLoading = false;
                                                      });
                                                      Get.snackbar(
                                                        maxWidth: 500,
                                                        backgroundColor:
                                                            blueColor
                                                                .withOpacity(
                                                                    .7),
                                                        "Votre message n'a pas été envoyé",
                                                        "Veuillez essayer à nouveau",
                                                      );
                                                    });
                                                  } else {
                                                    Get.snackbar(
                                                      maxWidth: 500,
                                                      backgroundColor: blueColor
                                                          .withOpacity(.7),
                                                      "Certains champs sont vides",
                                                      "Veuillez confirmer les champs!",
                                                    );
                                                  }
                                                }
                                              },
                                              style: ButtonStyle(
                                                backgroundColor:
                                                    MaterialStateProperty.all(
                                                        blueColor),
                                                padding:
                                                    MaterialStateProperty.all(
                                                  const EdgeInsets.symmetric(
                                                      vertical: 15),
                                                ),
                                                shape:
                                                    MaterialStateProperty.all<
                                                        RoundedRectangleBorder>(
                                                  RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6),
                                                  ),
                                                ),
                                              ),
                                              child: Text(
                                                "ENVOYER",
                                                style: gothicBold.copyWith(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 30,
                                          ),

                                          // list tickets
                                          for (var ticket
                                              in chatController.listTickets)
                                            Container(
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 10),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 15,
                                                        vertical: 5),
                                                decoration: const BoxDecoration(
                                                  color: Colors.black26,
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    // row
                                                    Row(
                                                      // mainAxisAlignment:
                                                      //     MainAxisAlignment
                                                      //         .spaceBetween,
                                                      children: [
                                                        Text(
                                                          "Ticket N:00${ticket.id.toString()}",
                                                          style: gothicBold
                                                              .copyWith(),
                                                        ),
                                                        const SizedBox(
                                                          width: 15,
                                                        ),
                                                        const Spacer(),
                                                        Container(
                                                          decoration: BoxDecoration(
                                                              color: ticket
                                                                          .status !=
                                                                      "ouvert"
                                                                  ? greenColor
                                                                  : blueColor),
                                                          padding:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      10,
                                                                  vertical: 2),
                                                          child: InkWell(
                                                            onTap: () {
                                                              if (ticket.is_read
                                                                      .toString()
                                                                      .toLowerCase() ==
                                                                  "true") {
                                                                Get.defaultDialog(
                                                                    title: "Ticket n${ticket.id.toString()}",
                                                                    titleStyle: gothicBold.copyWith(
                                                                        // fontSize:
                                                                        //     20,
                                                                        ),
                                                                    titlePadding: const EdgeInsets.all(0),
                                                                    actions: [
                                                                      SizedBox(
                                                                        height:
                                                                            30,
                                                                        child:
                                                                            ElevatedButton(
                                                                          onPressed:
                                                                              () {
                                                                            Get.back();
                                                                          },
                                                                          style:
                                                                              ButtonStyle(backgroundColor: MaterialStatePropertyAll(blueColor)),
                                                                          child:
                                                                              Container(
                                                                            margin:
                                                                                const EdgeInsets.symmetric(horizontal: 20),
                                                                            child:
                                                                                Text(
                                                                              "OK",
                                                                              style: gothicBold.copyWith(fontSize: 18, color: Colors.white),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                    content: Container(
                                                                      constraints:
                                                                          BoxConstraints(
                                                                              maxHeight: sizeHeight(context: context) * .6),
                                                                      child:
                                                                          SingleChildScrollView(
                                                                        child:
                                                                            Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            // date
                                                                            Container(
                                                                              alignment: Alignment.center,
                                                                              child: Text(
                                                                                DateFormat("dd/MM/yyyy - HH'H'").format(DateTime.parse(ticket.create_date.toString())),
                                                                                textAlign: TextAlign.center,
                                                                                style: gothicBold.copyWith(fontSize: 10),
                                                                              ),
                                                                            ),
                                                                            const SizedBox(
                                                                              height: 10,
                                                                            ),
                                                                            //
                                                                            if (ticket.conversation!.length >
                                                                                1)
                                                                              for (int i = 1; i < ticket.conversation!.length; i++)
                                                                                Container(
                                                                                  margin: const EdgeInsets.symmetric(horizontal: 15),
                                                                                  width: sizeWidth(context: context),
                                                                                  child: Text(
                                                                                    ticket.conversation![i].message.toString(),
                                                                                    style: gothicRegular.copyWith(),
                                                                                  ),
                                                                                ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ));
                                                              }
                                                            },
                                                            child: Text(
                                                              ticket.status !=
                                                                      "ouvert"
                                                                  ? "En cours"
                                                                  : "Voir la réponse",
                                                              style: gothicBold
                                                                  .copyWith(
                                                                      color: Colors
                                                                          .white),
                                                            ),
                                                          ),
                                                        ),
                                                        const Spacer(),
                                                      ],
                                                    ),
                                                    if (ticket.conversation!
                                                        .isNotEmpty)
                                                      Text(
                                                        ticket.conversation!
                                                            .first.message
                                                            .toString(),
                                                        maxLines: 3,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: gothicBold
                                                            .copyWith(),
                                                      )
                                                  ],
                                                )),

                                          const SizedBox(
                                            height: 50,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
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
    );
  }
}
