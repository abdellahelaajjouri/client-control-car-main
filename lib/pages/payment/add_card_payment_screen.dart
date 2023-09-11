import 'dart:async';

import 'package:client_control_car/constants/constants.dart';
import 'package:client_control_car/controllers/auth_controller.dart';
import 'package:client_control_car/controllers/control_controller.dart';
import 'package:client_control_car/models/card_bank_model.dart';
import 'package:client_control_car/pages/auth/widgets/custom_input_validator.dart';
import 'package:client_control_car/pages/menu/drawer_widget.dart';
import 'package:client_control_car/pages/menu/menu_bottom.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class AddCardPaymentScreen extends StatefulWidget {
  const AddCardPaymentScreen({Key? key}) : super(key: key);

  @override
  State<AddCardPaymentScreen> createState() => _AddCardPaymentScreenState();
}

class _AddCardPaymentScreenState extends State<AddCardPaymentScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  TextEditingController codeController = TextEditingController();
  TextEditingController moinController = TextEditingController();
  TextEditingController yearController = TextEditingController();
  TextEditingController cvvController = TextEditingController();
  TextEditingController nameController = TextEditingController();

  FocusNode codeFocus = FocusNode();
  FocusNode moinFocus = FocusNode();
  FocusNode yearFocus = FocusNode();
  FocusNode cvvFocus = FocusNode();
  FocusNode nameFocus = FocusNode();
  bool isLoading = false;

  var cardFormatter = MaskTextInputFormatter(
      mask: '#### #### #### #### ###',
      filter: {
        "#": RegExp(r'[0-9]'),
      },
      type: MaskAutoCompletionType.lazy);
  var monthFormatter = MaskTextInputFormatter(
      mask: '##',
      filter: {
        "#": RegExp(r'[0-9]'),
      },
      type: MaskAutoCompletionType.lazy);
  var yearFormatter = MaskTextInputFormatter(
      mask: '####',
      filter: {
        "#": RegExp(r'[0-9]'),
      },
      type: MaskAutoCompletionType.lazy);
  var cvvFormatter = MaskTextInputFormatter(
      mask: '###',
      filter: {
        "#": RegExp(r'[0-9]'),
      },
      type: MaskAutoCompletionType.lazy);
  @override
  void initState() {
    super.initState();
    codeController.addListener(() {
      setState(() {});
    });
    check();
  }

  @override
  void dispose() {
    codeController.dispose();
    super.dispose();
  }

  final _formKey = GlobalKey<FormState>();
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    setState(() {});
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
                                String access = authController.userModel!.access
                                            .toString() ==
                                        "null"
                                    ? authController.accessUserJWS.toString()
                                    : authController.userModel!.access
                                        .toString();
                                Map<String, dynamic> payload =
                                    Jwt.parseJwt(access);
                                int msgCont = 0;
                                int ntfCont = 0;
                                for (var element in snapshotNotif.data!.docs) {
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
                      // list payment
                      Expanded(
                        child: SingleChildScrollView(
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
                                  child: Text(
                                    "Méthode de paiement",
                                    style: gothicBold.copyWith(fontSize: 25),
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),

                                //

                                // inputs
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  child: Row(
                                    children: [
                                      Text(
                                        "Numéro de carte",
                                        style: gothicRegular.copyWith(
                                          color: normalText,
                                        ),
                                      ),
                                      Text(
                                        "*",
                                        style: gothicRegular.copyWith(
                                          color: Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                //
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: CustomInputValidatore(
                                    controller: codeController,
                                    labelText: null,
                                    hintText: "**** **** **** ****",
                                    inputFormatters: [cardFormatter],
                                    marginContainer:
                                        const EdgeInsets.only(bottom: 11),
                                    width: sizeWidth(context: context) * .9,
                                    inputType: TextInputType.text,
                                    focusNode: codeFocus,
                                    onChanged: (value) {
                                      setState(() {});
                                    },
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return '';
                                      } else if (value
                                                  .replaceAll(" ", "")
                                                  .length <
                                              10 ||
                                          value.replaceAll(" ", "").length >
                                              20) {
                                        return '';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 15),
                                  child: Row(
                                    children: [
                                      Text(
                                        "Date d'expiration",
                                        style: gothicRegular.copyWith(
                                          color: normalText,
                                        ),
                                      ),
                                      Text(
                                        "*",
                                        style: gothicRegular.copyWith(
                                          color: Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 15,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: CustomInputValidatore(
                                          controller: moinController,
                                          labelText: null,
                                          labelWidget: labelInput(
                                              text: "Mois", req: true),
                                          hintText: DateFormat("MM")
                                              .format(DateTime.now()),
                                          inputFormatters: [monthFormatter],
                                          marginContainer:
                                              const EdgeInsets.only(bottom: 11),
                                          width:
                                              sizeWidth(context: context) * .9,
                                          inputType: TextInputType.number,
                                          focusNode: moinFocus,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty ||
                                                value
                                                        .replaceAll(" ", "")
                                                        .length !=
                                                    2 ||
                                                int.tryParse(value) == null) {
                                              return '';
                                            } else if (int.tryParse(value) !=
                                                    null &&
                                                (int.parse(value) < 1 ||
                                                    int.parse(value) > 12)) {
                                              return '';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      //
                                      Expanded(
                                        child: Container(
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: SizedBox(
                                            height: 60,
                                            child: CustomInputValidatore(
                                              controller: yearController,
                                              labelText: null,
                                              labelWidget: labelInput(
                                                  text: "Année", req: true),
                                              hintText: DateFormat("yyyy")
                                                  .format(DateTime.now()),
                                              inputFormatters: [yearFormatter],
                                              marginContainer:
                                                  const EdgeInsets.only(
                                                      bottom: 11),
                                              width:
                                                  sizeWidth(context: context) *
                                                      .9,
                                              inputType: TextInputType.number,
                                              focusNode: yearFocus,
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty ||
                                                    value
                                                            .replaceAll(" ", "")
                                                            .length !=
                                                        4) {
                                                  return '';
                                                } else if (int.tryParse(
                                                        value) ==
                                                    null) {
                                                  return "null";
                                                } else if (int.parse(value) <
                                                    DateTime.now().year) {
                                                  return "";
                                                }
                                                return null;
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                //
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 15),
                                  child: Row(
                                    children: [
                                      Text(
                                        "cvv",
                                        style: gothicRegular.copyWith(
                                          color: normalText,
                                        ),
                                      ),
                                      Text(
                                        "*",
                                        style: gothicRegular.copyWith(
                                          color: Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 15,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: CustomInputValidatore(
                                          controller: cvvController,
                                          labelText: null,
                                          hintText: "***",
                                          inputFormatters: [cvvFormatter],
                                          marginContainer:
                                              const EdgeInsets.only(bottom: 11),
                                          width:
                                              sizeWidth(context: context) * .9,
                                          inputType: TextInputType.number,
                                          focusNode: cvvFocus,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty ||
                                                value.length != 3) {
                                              return '';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      //
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: Text(
                                            "les trois derniers chiffre\nau dos de votre carte",
                                            style: gothicRegular.copyWith(
                                                color: normalText,
                                                fontSize: 11),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 15),
                                  child: Row(
                                    children: [
                                      Text(
                                        "Nom sur la carte",
                                        style: gothicRegular.copyWith(
                                          color: normalText,
                                        ),
                                      ),
                                      Text(
                                        "*",
                                        style: gothicRegular.copyWith(
                                          color: Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: CustomInputValidatore(
                                    controller: nameController,
                                    labelText: null,
                                    hintText: "Nom complete",
                                    marginContainer:
                                        const EdgeInsets.only(bottom: 11),
                                    width: sizeWidth(context: context) * .9,
                                    inputType: TextInputType.text,
                                    focusNode: nameFocus,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return '';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(
                                  height: 60,
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      // btn
                      Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 5),
                        child: Column(
                          children: [
                            Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 5),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        if (!_formKey.currentState!
                                            .validate()) {
                                          Get.snackbar(
                                            maxWidth: 500,
                                            backgroundColor:
                                                blueColor.withOpacity(.7),
                                            "Certains champs sont invalide",
                                            "Veuillez confirmer les champs!",
                                          );
                                        } else {
                                          if (codeController.text.isEmpty ||
                                              moinController.text.isEmpty ||
                                              yearController.text.isEmpty ||
                                              cvvController.text.isEmpty ||
                                              nameController.text.isEmail) {
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
                                            AuthController authController =
                                                Get.find();
                                            Map<String, dynamic> payload =
                                                Jwt.parseJwt(authController
                                                    .userModel!.access
                                                    .toString());

                                            CardBankModel cardBankModel =
                                                CardBankModel(
                                              id: payload["user_id"].toString(),
                                              numberCard: codeController.text
                                                  .replaceAll(" ", ""),
                                              monthCard: moinController.text,
                                              yearCard: yearController.text,
                                              cvvCard: cvvController.text,
                                              namUser: nameController.text,
                                              image: codeController.text.isEmpty
                                                  ? "assets/icons/number-card.png"
                                                  : codeController.text[0] ==
                                                          "3"
                                                      ? "assets/icons/american-express.png"
                                                      : codeController
                                                                  .text[0] ==
                                                              "4"
                                                          ? "assets/icons/visa.png"
                                                          : codeController.text[
                                                                      0] ==
                                                                  "5"
                                                              ? "assets/icons/Master.png"
                                                              : "assets/icons/number-card.png",
                                            );
                                            ControlController
                                                controlController = Get.find();

                                            controlController
                                                .getListCartBancair()
                                                .then((value) {
                                              Map<String, dynamic> payload =
                                                  Jwt.parseJwt(authController
                                                      .accessUserJWS
                                                      .toString());
                                              bool checkE = false;
                                              for (var carde
                                                  in controlController
                                                      .listCardBank) {
                                                if (carde.numberCard
                                                            .toString() ==
                                                        cardBankModel.numberCard
                                                            .toString() &&
                                                    carde.id ==
                                                        payload["user_id"]
                                                            .toString()) {
                                                  checkE = true;
                                                }
                                              }
                                              if (checkE == true) {
                                                setState(() {
                                                  isLoading = false;
                                                });
                                                Get.snackbar(
                                                  maxWidth: 500,
                                                  backgroundColor:
                                                      blueColor.withOpacity(.7),
                                                  "Le numéro de carte est exist",
                                                  "Veuillez ajouter une autre carte bancaire",
                                                );
                                              } else {
                                                controlController
                                                    .addCartBancair(
                                                        cardBankModel:
                                                            cardBankModel)
                                                    .then((value) {
                                                  Timer(
                                                      const Duration(
                                                          seconds: 3), () {
                                                    setState(() {
                                                      isLoading = false;
                                                    });
                                                    Get.back();
                                                    Get.bottomSheet(Container(
                                                      color: Colors.white,
                                                      height: sizeHeight(
                                                              context:
                                                                  context) *
                                                          .45,
                                                      child:
                                                          SingleChildScrollView(
                                                        child: SizedBox(
                                                          width: sizeWidth(
                                                              context: context),
                                                          child: Column(
                                                            children: [
                                                              const SizedBox(
                                                                height: 15,
                                                              ),
                                                              Image.asset(
                                                                  "assets/images/Groupe 327.png"),
                                                              const SizedBox(
                                                                height: 15,
                                                              ),
                                                              Text(
                                                                "Carte enregistrée",
                                                                style: gothicBold
                                                                    .copyWith(
                                                                  fontSize: 18,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                height: 20,
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ));
                                                  });
                                                });
                                              }
                                            });
                                          }
                                        }

                                        // Get.to(() => const DatTimeScreen(),
                                        //     routeName:
                                        //         RouteHelper.getBookRdvDateTimeRoute());
                                      },
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                blueColor),
                                        padding: MaterialStateProperty.all(
                                          const EdgeInsets.symmetric(
                                              vertical: 15, horizontal: 15),
                                        ),
                                        shape: MaterialStateProperty.all<
                                            RoundedRectangleBorder>(
                                          const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.zero,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        "Enregistrer la carte",
                                        style: gothicBold.copyWith(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
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
            ],
          ),
        ),
      )),
    );
  }

  Widget getIconCard() {
    setState(() {});
    return Container(
      // color: blueColor,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      child: Image.asset(
        codeController.text.isEmpty
            ? "assets/icons/number-card.png"
            : codeController.text[0] == "3"
                ? "assets/icons/american-express.png"
                : codeController.text[0] == "4"
                    ? "assets/icons/visa.png"
                    : codeController.text[0] == "5"
                        ? "assets/icons/Master.png"
                        : "assets/icons/number-card.png",
        width: 20,
        // height: 10,
      ),
    );
  }
}
