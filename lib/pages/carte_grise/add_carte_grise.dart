import 'package:client_control_car/constants/constants.dart';
import 'package:client_control_car/controllers/auth_controller.dart';
import 'package:client_control_car/controllers/control_controller.dart';
import 'package:client_control_car/pages/auth/widgets/custom_input_validator.dart';
import 'package:client_control_car/pages/menu/drawer_widget.dart';
import 'package:client_control_car/pages/menu/menu_bottom.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class AddCarteGrise extends StatefulWidget {
  const AddCarteGrise({super.key});

  @override
  State<AddCarteGrise> createState() => _AddCarteGriseState();
}

class _AddCarteGriseState extends State<AddCarteGrise> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  bool isLoading = false;
  TextEditingController firstnameController = TextEditingController();
  TextEditingController lastnameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController communsController = TextEditingController();
  TextEditingController cityNaissanceController = TextEditingController();
  TextEditingController dateNaissanceController = TextEditingController();
  final FocusNode firstnameFocus = FocusNode();
  final FocusNode lastnameFocus = FocusNode();
  final FocusNode emailFocus = FocusNode();
  final FocusNode phoneFocus = FocusNode();
  final FocusNode communsFocus = FocusNode();
  final FocusNode cityNaissanceFocus = FocusNode();
  final FocusNode dateNaissanceFocus = FocusNode();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    check();
  }

  var phoneFormatter = MaskTextInputFormatter(
      mask: '##########',
      filter: {
        "#": RegExp(r'[0-9]'),
      },
      type: MaskAutoCompletionType.lazy);
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
                                onThen: () {},
                              );
                            }),
                      )
                    : Container(),
                Expanded(
                  child: Form(
                    key: _formKey,
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
                        // facturation
                        Expanded(
                          child: SingleChildScrollView(
                            child: SizedBox(
                              width: sizeWidth(context: context),
                              child: Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 15),
                                child: Column(
                                  children: [
                                    // title
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 15),
                                      child: Text(
                                        "Créer ma carte grise",
                                        style:
                                            gothicBold.copyWith(fontSize: 25),
                                      ),
                                    ),
                                    // subtitle
                                    const SizedBox(
                                      height: 15,
                                    ),
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 15),
                                      child: Text(
                                        "Veuillez complète les informations",
                                        style: gothicRegular.copyWith(
                                          color: normalText,
                                        ),
                                      ),
                                    ),
                                    // inputs
                                    const SizedBox(
                                      height: 50,
                                    ),
                                    CustomInputValidatore(
                                      controller: lastnameController,
                                      labelText: null,
                                      labelWidget:
                                          labelInput(text: "Prénom", req: true),
                                      marginContainer:
                                          const EdgeInsets.only(bottom: 11),
                                      width: sizeWidth(context: context) * .9,
                                      inputType: TextInputType.text,
                                      focusNode: lastnameFocus,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return '';
                                        }
                                        return null;
                                      },
                                      // nextFocus: passwordFocus,
                                    ),
                                    CustomInputValidatore(
                                      controller: firstnameController,
                                      labelText: null,
                                      labelWidget:
                                          labelInput(text: "Nom", req: true),
                                      marginContainer:
                                          const EdgeInsets.only(bottom: 11),
                                      width: sizeWidth(context: context) * .9,
                                      inputType: TextInputType.text,
                                      focusNode: firstnameFocus,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return '';
                                        }
                                        return null;
                                      },
                                      // nextFocus: passwordFocus,
                                    ),
                                    CustomInputValidatore(
                                      controller: dateNaissanceController,
                                      labelText: null,
                                      labelWidget: labelInput(
                                          text: "Date de naissance", req: true),
                                      marginContainer:
                                          const EdgeInsets.only(bottom: 11),
                                      width: sizeWidth(context: context) * .9,
                                      inputType: TextInputType.text,
                                      focusNode: dateNaissanceFocus,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return '';
                                        }
                                        return null;
                                      },
                                      // nextFocus: passwordFocus,
                                    ),
                                    CustomInputValidatore(
                                      controller: cityNaissanceController,
                                      labelText: null,
                                      labelWidget: labelInput(
                                          text: "Pays de naissance", req: true),
                                      marginContainer:
                                          const EdgeInsets.only(bottom: 11),
                                      width: sizeWidth(context: context) * .9,
                                      inputType: TextInputType.text,
                                      focusNode: cityNaissanceFocus,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return '';
                                        }
                                        return null;
                                      },
                                      // nextFocus: passwordFocus,
                                    ),
                                    CustomInputValidatore(
                                      controller: communsController,
                                      labelText: null,
                                      labelWidget: labelInput(
                                          text: "Communs de naissance",
                                          req: true),
                                      marginContainer:
                                          const EdgeInsets.only(bottom: 11),
                                      width: sizeWidth(context: context) * .9,
                                      inputType: TextInputType.number,
                                      focusNode: communsFocus,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return '';
                                        }
                                        return null;
                                      },
                                      // nextFocus: passwordFocus,
                                    ),
                                    CustomInputValidatore(
                                      controller: emailController,
                                      labelText: null,
                                      labelWidget:
                                          labelInput(text: "E-mail", req: true),
                                      marginContainer:
                                          const EdgeInsets.only(bottom: 11),
                                      width: sizeWidth(context: context) * .9,
                                      inputType: TextInputType.emailAddress,
                                      focusNode: emailFocus,
                                      validator: (value) {
                                        if (value == null ||
                                            value.isEmpty ||
                                            !value.isEmail) {
                                          return '';
                                        }
                                        return null;
                                      },
                                      // nextFocus: passwordFocus,
                                    ),
                                    CustomInputValidatore(
                                      controller: phoneController,
                                      labelText: null,
                                      labelWidget: labelInput(
                                        text: "Téléphone",
                                        req: true,
                                      ),
                                      inputFormatters: [phoneFormatter],
                                      marginContainer:
                                          const EdgeInsets.only(bottom: 11),
                                      width: sizeWidth(context: context) * .9,
                                      inputType: TextInputType.phone,
                                      focusNode: phoneFocus,
                                      validator: (value) {
                                        if (value == null ||
                                            value.isEmpty ||
                                            value.length != 10) {
                                          return '';
                                        }
                                        return null;
                                      },
                                      // nextFocus: passwordFocus,
                                    ),
                                    const SizedBox(
                                      height: 50,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        // btn
                        Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 5),
                          child: Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    ControlController controlController =
                                        Get.find();
                                    setState(() {
                                      isLoading = true;
                                    });
                                    controlController
                                        .addCarteGrise()
                                        .then((value) {
                                      setState(() {
                                        isLoading = false;
                                      });
                                    }).catchError((onError) {
                                      setState(() {
                                        isLoading = false;
                                      });
                                    });
                                    if (!_formKey.currentState!.validate()) {
                                      Get.snackbar(
                                        maxWidth: 500,
                                        backgroundColor:
                                            blueColor.withOpacity(.7),
                                        "Certains champs sont invalide",
                                        "Veuillez confirmer les champs!",
                                      );
                                    } else {
                                      if (firstnameController.text.isEmpty ||
                                          lastnameController.text.isEmpty ||
                                          dateNaissanceController
                                              .text.isEmpty ||
                                          cityNaissanceController
                                              .text.isEmpty ||
                                          communsController.text.isEmpty ||
                                          emailController.text.isEmpty ||
                                          phoneController.text.isEmpty) {
                                        Get.snackbar(
                                          maxWidth: 500,
                                          backgroundColor:
                                              blueColor.withOpacity(.7),
                                          "Certains champs sont vides",
                                          "Veuillez confirmer les champs!",
                                        );
                                      } else {
                                        Get.snackbar(
                                          maxWidth: 500,
                                          backgroundColor:
                                              blueColor.withOpacity(.7),
                                          "Opération en état du traitement",
                                          "opération en état du traitement",
                                        );

                                        //
                                      }
                                    }
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
                                  child: Text(
                                    "Enregistrer",
                                    style: gothicBold.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
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
