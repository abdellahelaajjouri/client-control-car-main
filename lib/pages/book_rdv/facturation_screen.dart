import 'dart:developer';

import 'package:client_control_car/constants/constants.dart';
import 'package:client_control_car/constants/route_helper.dart';
import 'package:client_control_car/controllers/auth_controller.dart';
import 'package:client_control_car/controllers/control_controller.dart';
import 'package:client_control_car/pages/auth/widgets/custom_input_validator.dart';
import 'package:client_control_car/pages/book_rdv/resume_commande_screen.dart';
import 'package:client_control_car/pages/menu/drawer_widget.dart';
import 'package:client_control_car/pages/menu/menu_bottom.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class FacturationScreen extends StatefulWidget {
  const FacturationScreen({Key? key}) : super(key: key);

  @override
  State<FacturationScreen> createState() => _FacturationScreenState();
}

class _FacturationScreenState extends State<FacturationScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  bool isLoading = true;
  TextEditingController firstnameController = TextEditingController();
  TextEditingController lastnameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController codepostalController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  final FocusNode firstnameFocus = FocusNode();
  final FocusNode lastnameFocus = FocusNode();
  final FocusNode addressFocus = FocusNode();
  final FocusNode cityFocus = FocusNode();
  final FocusNode codepostalFocus = FocusNode();
  final FocusNode emailFocus = FocusNode();
  final FocusNode phoneFocus = FocusNode();
  var codePostalFormatter = MaskTextInputFormatter(
      mask: '#####',
      filter: {
        "#": RegExp(r'[0-9]'),
      },
      type: MaskAutoCompletionType.lazy);
  var phoneFormatter = MaskTextInputFormatter(
      mask: '##########',
      filter: {
        "#": RegExp(r'[0-9]'),
      },
      type: MaskAutoCompletionType.lazy);
  @override
  void initState() {
    super.initState();
    check().then((value) {
      AuthController authController = Get.find();
      authController.getCProfileController().then(
        (value) {
          getData();
        },
      ).catchError((onError) {
        getData();
      });
    });
  }

  getData() {
    AuthController authController = Get.find();
    if (authController.userModel != null) {
      setState(() {
        firstnameController.text =
            authController.userModel!.first_name.toString() == "null"
                ? ''
                : authController.userModel!.first_name.toString();
        lastnameController.text =
            authController.userModel!.last_name.toString() == "null"
                ? ""
                : authController.userModel!.last_name.toString();
        addressController.text =
            authController.userModel!.address.toString() == "null"
                ? ""
                : authController.userModel!.address.toString();
        cityController.text =
            authController.userModel!.city.toString() == "null"
                ? ""
                : authController.userModel!.city.toString();
        codepostalController.text =
            authController.userModel!.code_postal.toString() == "null"
                ? ""
                : authController.userModel!.code_postal.toString();
        emailController.text =
            authController.userModel!.email.toString() == "null"
                ? ""
                : authController.userModel!.email.toString();
        phoneController.text =
            authController.userModel!.phone.toString() == "null"
                ? ""
                : authController.userModel!.phone.toString().length == 9
                    ? "0${authController.userModel!.phone}"
                    : authController.userModel!.phone.toString();
        // if (controlController.facaddress != null) {
        //   addressController.text = controlController.facaddress.toString();
        // }
        // if (controlController.faccity != null) {
        //   cityController.text = controlController.faccity.toString();
        // }
        // if (controlController.faccodepostal != null) {
        //   codepostalController.text =
        //       controlController.faccodepostal.toString();
        // }
      });
      setState(() {
        isLoading = false;
      });
    }
  }

  final _formKey = GlobalKey<FormState>();
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
                  Get.back();
                },
                child: Icon(
                  Icons.arrow_back_ios,
                  color: normalText,
                ),
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
                                onThen: () {
                                  getData();
                                },
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
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 5),
                              width: sizeWidth(context: context),
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
                                  // title
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 15),
                                    child: Text(
                                      "Facturation",
                                      style: gothicBold.copyWith(fontSize: 25),
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
                                      "Veuillez vérifier les infos client",
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
                                    controller: addressController,
                                    labelText: null,
                                    labelWidget:
                                        labelInput(text: "Adresse", req: true),
                                    marginContainer:
                                        const EdgeInsets.only(bottom: 11),
                                    width: sizeWidth(context: context) * .9,
                                    inputType: TextInputType.text,
                                    focusNode: addressFocus,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return '';
                                      }
                                      return null;
                                    },
                                    // nextFocus: passwordFocus,
                                  ),
                                  CustomInputValidatore(
                                    controller: cityController,
                                    labelText: null,
                                    labelWidget:
                                        labelInput(text: "Ville", req: true),
                                    marginContainer:
                                        const EdgeInsets.only(bottom: 11),
                                    width: sizeWidth(context: context) * .9,
                                    inputType: TextInputType.text,
                                    focusNode: cityFocus,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return '';
                                      }
                                      return null;
                                    },
                                    // nextFocus: passwordFocus,
                                  ),
                                  CustomInputValidatore(
                                    controller: codepostalController,
                                    labelText: null,
                                    labelWidget: labelInput(
                                        text: "Code postal", req: true),
                                    marginContainer:
                                        const EdgeInsets.only(bottom: 11),
                                    width: sizeWidth(context: context) * .9,
                                    inputType: TextInputType.number,
                                    focusNode: codepostalFocus,
                                    inputFormatters: [
                                      codePostalFormatter,
                                    ],
                                    validator: (value) {
                                      if (value == null ||
                                          value.isEmpty ||
                                          value.length != 5) {
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
                                    // nextFocus: passwordFocus,
                                    validator: (value) {
                                      if (value == null ||
                                          value.isEmpty ||
                                          !value.isEmail) {
                                        return '';
                                      }
                                      return null;
                                    },
                                  ),
                                  CustomInputValidatore(
                                    controller: phoneController,
                                    labelText: null,
                                    labelWidget: labelInput(
                                        text: "Numéro de téléphone", req: true),
                                    marginContainer:
                                        const EdgeInsets.only(bottom: 11),
                                    width: sizeWidth(context: context) * .9,
                                    inputType: TextInputType.phone,
                                    inputFormatters: [phoneFormatter],
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
                        // btn
                        Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 5),
                          child: Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
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
                                          addressController.text.isEmpty ||
                                          cityController.text.isEmpty ||
                                          codepostalController.text.isEmpty ||
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
                                        setState(() {
                                          isLoading = true;
                                        });
                                        ControlController controlController =
                                            Get.find();
                                        // add control
                                        controlController
                                            .addController(
                                          rendez_vous: controlController
                                              .idRendezVous
                                              .toString(),
                                          info_perso: controlController
                                              .idInfoPersoVehicule
                                              .toString(),
                                          info_vehicule: controlController
                                              .idInfoVehicule
                                              .toString(),
                                          facturation: controlController
                                              .idFacturation
                                              .toString(),
                                          techniciens: controlController
                                              .listTechselected
                                              .toString(),
                                        )
                                            .then((value) {
                                          setState(() {
                                            isLoading = false;
                                          });
                                          if (value.isSuccess) {
                                            controlController
                                                .addfactureController(
                                              nom: firstnameController.text,
                                              prenom: lastnameController.text,
                                              ville: cityController.text,
                                              address: addressController.text,
                                              code_postal:
                                                  codepostalController.text,
                                              email: emailController.text,
                                              phone: phoneController.text,
                                              demande_control: controlController
                                                  .idControl
                                                  .toString(),
                                            )
                                                .then((value) {
                                              if (value.isSuccess) {
                                                Get.to(
                                                    () => ResumeCommandeScreen(
                                                          countrolId:
                                                              controlController
                                                                  .idControl
                                                                  .toString(),
                                                        ),
                                                    routeName: RouteHelper
                                                        .getResumCommandPageRoute(
                                                      countrolId:
                                                          controlController
                                                              .idControl
                                                              .toString(),
                                                    ));
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
                                                  duration: const Duration(
                                                      seconds: 6),
                                                );
                                              }
                                            }).catchError((onError) {
                                              setState(() {
                                                isLoading = false;
                                              });
                                              log(onError.toString());

                                              Get.snackbar(
                                                maxWidth: 500,
                                                backgroundColor:
                                                    blueColor.withOpacity(.7),
                                                "Votre demande n'a pas été enregistrée",
                                                "Veuillez réessayer",
                                                duration:
                                                    const Duration(seconds: 6),
                                              );
                                            });
                                          } else {
                                            Get.snackbar(
                                              maxWidth: 500,
                                              backgroundColor:
                                                  blueColor.withOpacity(.7),
                                              "Votre demande n'a pas été enregistrée",
                                              "Veuillez réessayer",
                                              duration:
                                                  const Duration(seconds: 6),
                                            );
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
                                            "Veuillez réessayers",
                                            duration:
                                                const Duration(seconds: 6),
                                          );
                                        });

                                        // add facture

                                        // FacturationModel facturationModel =
                                        //     FacturationModel(
                                        //   firstname: firstnameController.text,
                                        //   lastname: lastnameController.text,
                                        //   address: addressController.text,
                                        //   city: cityController.text,
                                        //   codepostal: codepostalController.text,
                                        //   email: emailController.text,
                                        //   phone: phoneController.text,
                                        // );
                                        // authController.facturationModel =
                                        //     facturationModel;
                                        // Timer(const Duration(seconds: 2), () {
                                        //   setState(() {
                                        //     isLoading = false;
                                        //   });
                                        //   Get.to(() => const ResumeCommandeScreen(),
                                        //       routeName:
                                        //           RouteHelper.getResumCommandPageRoute());
                                        // });
                                      }
                                    }
                                    // Get.toNamed(RouteHelper.homeMapPage);
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
