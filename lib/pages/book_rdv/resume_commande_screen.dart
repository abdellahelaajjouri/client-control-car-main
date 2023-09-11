import 'dart:convert';
import 'dart:developer';

import 'package:client_control_car/constants/app_constant.dart';
import 'package:client_control_car/constants/constants.dart';
import 'package:client_control_car/constants/route_helper.dart';
import 'package:client_control_car/controllers/auth_controller.dart';
import 'package:client_control_car/controllers/control_controller.dart';
import 'package:client_control_car/pages/auth/widgets/custom_input_logreg.dart';
import 'package:client_control_car/pages/book_rdv/dart_time_screen.dart';
import 'package:client_control_car/pages/book_rdv/functions/functions_date_time.dart';
import 'package:client_control_car/pages/info_vehicule/info_vehicule_screen.dart';
import 'package:client_control_car/pages/info_vehicule/widgets/widgets.dart';
import 'package:client_control_car/pages/menu/drawer_widget.dart';
import 'package:client_control_car/pages/menu/menu_bottom.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:http/http.dart' as http;
import 'package:stripe_checkout/stripe_checkout.dart';

class ResumeCommandeScreen extends StatefulWidget {
  final String countrolId;
  const ResumeCommandeScreen({Key? key, required this.countrolId})
      : super(key: key);

  @override
  State<ResumeCommandeScreen> createState() => _ResumeCommandeScreenState();
}

class _ResumeCommandeScreenState extends State<ResumeCommandeScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  TextEditingController codePromoController = TextEditingController();
  FocusNode codePromoFocus = FocusNode();

  //

  //

  bool isLoading = true;
  bool isLoadingFirst = true;

  bool isValidePromo = false;

  double priceControl = 150;
  double priceControlOrigin = 150;
  int discount = 0;

  @override
  void initState() {
    super.initState();
    check().then((value) {
      getInfo();
      getData();
    });
  }

  getInfo() {
    ControlController controlController = Get.find();
    controlController.getListTypeVehiculeController().then((value) {
      if (value.isSuccess) {
        controlController.getListMarqueVehiculeController().then((value) {
          if (value.isSuccess) {
          } else {}
        }).catchError((onError) {});
      } else {}
    }).catchError((onError) {});
  }

  getData() {
    ControlController controlController = Get.find();

    controlController
        .getControlDetailController(idcontrol: widget.countrolId)
        .then((value) {
      if (value.isSuccess) {
        setState(() {
          isLoading = false;
          isLoadingFirst = false;
        });
      } else {
        setState(() {
          isLoading = false;
          isLoadingFirst = false;
        });
      }
    }).catchError((error) {
      setState(() {
        isLoading = false;
        isLoadingFirst = false;
      });
    });
  }

  String getDateFormat(
      {required String selectdate, required DateTime dateTime}) {
    String newDate = selectdate;
    // "${selectdate.split('-')[2]}-${selectdate.split('-')[1]}-${selectdate.split('-')[0]}";
    String test = "";
    String testDay = "";
    testDay = DateFormat('EEE', 'fr')
            .format(DateTime.parse(newDate))[0]
            .toUpperCase() +
        DateFormat('EEE dd', 'fr').format(DateTime.parse(newDate)).substring(1);
    test = DateFormat("HH:mm", 'fr').format(dateTime);

    return "$testDay, $test";
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
        child: GetBuilder<ControlController>(builder: (controlController) {
          return SizedBox(
            width: sizeWidth(context: context),
            height: sizeHeight(context: context),
            child: LoadingOverlay(
              isLoading: isLoading,
              child: isLoadingFirst
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
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        // title
                                        Container(
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 15),
                                          width: double.infinity,
                                          child: Text(
                                            "Résumé de la commande",
                                            textAlign: TextAlign.center,
                                            style: gothicBold.copyWith(
                                                fontSize: 25),
                                          ),
                                        ),
                                        // inputs
                                        const SizedBox(
                                          height: 30,
                                        ),
                                        // location
                                        Container(
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: ListTile(
                                            leading: SizedBox(
                                              width: 40,
                                              height: 40,
                                              child: Center(
                                                child: Image.asset(
                                                    "assets/icons/Groupe 13.png"),
                                              ),
                                            ),
                                            title: Text(
                                              "Lieu de rendez-vous",
                                              style: gothicBold.copyWith(
                                                  fontSize: 18),
                                            ),
                                            subtitle: Text(
                                              "${controlController.controlModel!.info_perso!.addresse.toString()}, ${controlController.controlModel!.info_perso!.code_postal.toString()}, ${controlController.controlModel!.info_perso!.ville.toString()},  ${controlController.controlModel!.info_perso!.batiment.toString() != "null" ? controlController.controlModel!.info_perso!.batiment.toString() : ""}",
                                              style: gothicRegular.copyWith(
                                                  color: normalText,
                                                  fontSize: 13),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: Divider(
                                            thickness: 1,
                                            color: normalText,
                                          ),
                                        ),
                                        Container(
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: ListTile(
                                            leading: SizedBox(
                                              width: 40,
                                              height: 40,
                                              child: Center(
                                                child: Image.asset(
                                                    "assets/icons/Groupe 178.png"),
                                              ),
                                            ),
                                            //
                                            title: Text(
                                              getDateFormat(
                                                  selectdate: controlController
                                                      .controlModel!
                                                      .rendez_vous!
                                                      .date
                                                      .toString(),
                                                  dateTime: DateTime.parse(
                                                      "${controlController.controlModel!.rendez_vous!.date.toString()} ${controlController.controlModel!.rendez_vous!.time.toString()}")),
                                              style: gothicBold.copyWith(
                                                  fontSize: 18),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: Divider(
                                            thickness: 1,
                                            color: normalText,
                                          ),
                                        ),
                                        //
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        Container(
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 10),
                                            child: Row(
                                              children: [
                                                getVehiculeType(
                                                    controlController:
                                                        controlController,
                                                    type: controlController
                                                        .controlModel!
                                                        .infoVehicule!
                                                        .type_vehicule!
                                                        .id
                                                        .toString()),
                                                const SizedBox(
                                                  width: 15,
                                                ),
                                                getVehiculeMarque(
                                                    controlController:
                                                        controlController,
                                                    marque: controlController
                                                        .controlModel!
                                                        .infoVehicule!
                                                        .marque_vehicule!
                                                        .id
                                                        .toString()),
                                              ],
                                            )),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        Container(
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: Divider(
                                            thickness: 1,
                                            color: normalText,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        for (var item in controlController
                                            .controlModel!
                                            .listControlTechniciens!)
                                          Container(
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 5, vertical: 1),
                                            child: InkWell(
                                              onTap: () {},
                                              child: Row(
                                                children: [
                                                  // image
                                                  Container(
                                                    width: 80,
                                                    height: 80,
                                                    margin: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 10,
                                                        vertical: 10),
                                                    padding:
                                                        const EdgeInsets.all(5),
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                              0xffE3E2E2)
                                                          .withOpacity(.2),
                                                      // borderRadius:
                                                      //     BorderRadius.circular(
                                                      //         80),
                                                    ),
                                                    child: CustomImageCircle(
                                                      image: item
                                                          .technicienModel!
                                                          .photo
                                                          .toString(),
                                                      width: 80,
                                                      height: 80,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),

                                                  // info
                                                  Expanded(
                                                      child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      // name
                                                      Text(
                                                        '${item.technicienModel!.userModel!.first_name.toString()} ${item.technicienModel!.userModel!.last_name.toString()}',
                                                        style:
                                                            gothicBold.copyWith(
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                      // category
                                                      Text(
                                                        "Technicien",
                                                        style: gothicRegular
                                                            .copyWith(
                                                                color:
                                                                    normalText,
                                                                fontSize: 13),
                                                      ),
                                                      // start
                                                      getStart(
                                                        start: int.parse(double
                                                                .parse(item
                                                                    .technicienModel!
                                                                    .notation
                                                                    .toString())
                                                            .toStringAsFixed(
                                                                0)),
                                                      ),
                                                    ],
                                                  ))
                                                ],
                                              ),
                                            ),
                                          ),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        Container(
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: Divider(
                                            thickness: 1,
                                            color: normalText,
                                          ),
                                        ),
                                        //
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        Container(
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: SizedBox(
                                            height: 60,
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Expanded(
                                                  child: CustomInputLogReg(
                                                    controller:
                                                        codePromoController,
                                                    labelText: "Code Promo",
                                                    marginContainer:
                                                        const EdgeInsets.only(
                                                            bottom: 11),
                                                    width: sizeWidth(
                                                            context: context) *
                                                        .9,
                                                    inputType:
                                                        TextInputType.text,
                                                    focusNode: codePromoFocus,
                                                    isReadOnly: isValidePromo,
                                                    icon: Image.asset(
                                                        "assets/icons/Trac‚ 1375.png"),
                                                    // nextFocus: passwordFocus,
                                                  ),
                                                ),
                                                if (!isValidePromo)
                                                  InkWell(
                                                    onTap: () {
                                                      if (codePromoController
                                                          .text.isNotEmpty) {
                                                        setState(() {
                                                          isLoading = true;
                                                        });
                                                        controlController
                                                            .checkCodePromoController(
                                                                promocode:
                                                                    codePromoController
                                                                        .text)
                                                            .then((value) {
                                                          setState(() {
                                                            isLoading = false;
                                                          });
                                                          if (value.isSuccess) {
                                                            Get.snackbar(
                                                              "le code promo est correct",
                                                              "${value.message}% du montant a été déduit",
                                                            );
                                                            setState(() {
                                                              priceControl = priceControlOrigin -
                                                                  (priceControlOrigin *
                                                                      int.parse(
                                                                          value
                                                                              .message) /
                                                                      100);
                                                              isValidePromo =
                                                                  true;
                                                              discount = int
                                                                  .parse(value
                                                                      .message);
                                                            });
                                                          } else {
                                                            Get.snackbar(
                                                              "le code promo n'est pas valide",
                                                              "Veuillez confirmer le code promo!",
                                                              duration:
                                                                  const Duration(
                                                                      seconds:
                                                                          6),
                                                            );
                                                            setState(() {
                                                              priceControl =
                                                                  priceControlOrigin;
                                                              isValidePromo =
                                                                  false;
                                                              discount = 0;
                                                            });
                                                          }
                                                        }).catchError(
                                                                (onError) {
                                                          Get.snackbar(
                                                            "le code promo n'est pas valide",
                                                            "Veuillez confirmer le code promo!",
                                                            duration:
                                                                const Duration(
                                                                    seconds: 6),
                                                          );
                                                          setState(() {
                                                            priceControl =
                                                                priceControlOrigin;
                                                            isValidePromo =
                                                                false;
                                                            discount = 0;

                                                            isLoading = false;
                                                          });
                                                        });
                                                      }
                                                    },
                                                    child: Container(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 5,
                                                          vertical: 8),
                                                      margin:
                                                          const EdgeInsets.only(
                                                              bottom: 11,
                                                              left: 11,
                                                              right: 11),
                                                      decoration: BoxDecoration(
                                                          border: Border.all(
                                                            color: greyColor,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5)),
                                                      child: Text(
                                                        "Vérifier",
                                                        style:
                                                            gothicBold.copyWith(
                                                                color:
                                                                    normalText),
                                                      ),
                                                    ),
                                                  )
                                              ],
                                            ),
                                          ),
                                        ),
                                        Container(
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 13),
                                          child: Divider(
                                            thickness: 1,
                                            color: normalText,
                                          ),
                                        ),
                                        //
                                        Container(
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: Text(
                                            "Total :",
                                            style: gothicBold.copyWith(
                                              fontSize: 23,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          margin: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                          ),
                                          child: Row(
                                            children: [
                                              Text(
                                                "${(priceControl).toStringAsFixed(2)}€",
                                                style: gothicBold.copyWith(
                                                  fontSize: 25,
                                                ),
                                              ),
                                              // Text(
                                              //   "${(priceControl + priceControl * 0.2).toStringAsFixed(2)}€",
                                              //   style: gothicBold.copyWith(
                                              //     fontSize: 25,
                                              //   ),
                                              // ),
                                              const SizedBox(
                                                width: 15,
                                              ),
                                              Container(
                                                decoration: BoxDecoration(
                                                  border: Border(
                                                      left: BorderSide(
                                                    color: normalText,
                                                  )),
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 12),
                                                child: Text(
                                                  "Prix HT : 125 + TVA : 20%",
                                                  style: gothicRegular.copyWith(
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        //
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
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Get.to(() => const DatTimeScreen(),
                                              routeName: RouteHelper
                                                  .getBookRdvDateTimeRoute());
                                        },
                                        style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                                  greyColor),
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
                                          "Modifier",
                                          style: gothicBold.copyWith(
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          log(priceControl.toString());
                                          if (priceControl == 0) {
                                            setState(() {
                                              isLoading = true;
                                            });
                                            controlController
                                                .checkPayControl(
                                                    idControl:
                                                        widget.countrolId,
                                                    hasCoupon: isValidePromo
                                                        .toString(),
                                                    price: (priceControl)
                                                        .toString(),
                                                    discount:
                                                        discount.toString())
                                                .then((value) {
                                              setState(() {
                                                isLoading = false;
                                              });
                                              if (value.isSuccess) {
                                                Get.to(
                                                    () =>
                                                        const InfoVehiculeScreen(),
                                                    routeName: RouteHelper
                                                        .getInfoVehiculeRoute());
                                                // Get.to(() => const HomeMapScreen(),
                                                //     routeName: RouteHelper.getHomeMapRoute());
                                                Get.bottomSheet(Container(
                                                  color: Colors.white,
                                                  height: sizeHeight(
                                                          context: context) *
                                                      .45,
                                                  child: SingleChildScrollView(
                                                    child: SizedBox(
                                                      width: sizeWidth(
                                                          context: context),
                                                      child: Column(
                                                        children: [
                                                          const SizedBox(
                                                            height: 15,
                                                          ),
                                                          Image.asset(
                                                            "assets/images/Groupe 422.png",
                                                          ),
                                                          const SizedBox(
                                                            height: 15,
                                                          ),
                                                          Text(
                                                            "Paiement effectué avec succès",
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
                                              } else {}
                                            }).catchError((onError) {
                                              setState(() {
                                                isLoading = false;
                                              });
                                            });
                                          } else if (kIsWeb) {
                                            setState(() {
                                              isLoading = true;
                                            });

                                            controlController
                                                .sessionCheckoutStripeControl(
                                                    idControl:
                                                        widget.countrolId,
                                                    price: (priceControl)
                                                        .toString(),
                                                    hasCoupon: isValidePromo
                                                        .toString(),
                                                    discount:
                                                        discount.toString())
                                                .then((value) async {
                                              log(value.message.toString());
                                              setState(() {
                                                isLoading = false;
                                              });
                                              if (value.isSuccess) {
                                                final result =
                                                    await redirectToCheckout(
                                                  context: context,
                                                  sessionId:
                                                      value.message.toString(),
                                                  publishableKey: AppConstant
                                                      .publishableKey,
                                                  successUrl:
                                                      'http://client.control-car.fr/',
                                                  canceledUrl:
                                                      'http://client.control-car.fr/',
                                                );

                                                if (mounted) {
                                                  log("message start");
                                                  log(result.toString());
                                                  final text = result.when(
                                                    success: () =>
                                                        "Payé avec succès",
                                                    canceled: () =>
                                                        'Paiement annulé',
                                                    error: (e) => 'Error $e',
                                                    redirected: () =>
                                                        'Redirigé avec succès',
                                                  );
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                        content: Text(text)),
                                                  );
                                                }
                                              }
                                            }).catchError((onError) {
                                              setState(() {
                                                isLoading = false;
                                              });
                                            });
                                          } else {
                                            // Stripe.publishableKey =
                                            //     "pk_test_51LOP9yC6otGGSz7JRj6dxrA7sNIRIuIgdRqq6duGqSemHgJDpkq65RkBQOHU6uf3Gdbx XrM0C0yyXwV5VprrVVXe00mD0IZnsF";
                                            await makePayment(
                                              controlId: widget.countrolId,
                                              total: (priceControl)
                                                  .toStringAsFixed(2),
                                              hasCoupon:
                                                  isValidePromo.toString(),
                                              discount: discount.toString(),
                                            );
                                          }
                                        },
                                        style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                                  blueColor),
                                          padding: MaterialStateProperty.all(
                                            const EdgeInsets.symmetric(
                                                vertical: 15),
                                          ),
                                          shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(
                                            const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.zero,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          "Valider paiement",
                                          style: gothicBold.copyWith(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
          );
        }),
      ),
    );
  }

  // make Payment
  Map<String, dynamic>? paymentIntent;
  // Map<String, dynamic>? paymentCustom;
  Future<void> makePayment(
      {required String total,
      required String controlId,
      required String hasCoupon,
      required String discount}) async {
    try {
      setState(() {
        isLoading = true;
      });
      AuthController authController = Get.find();

      // initPaymentSheet

      //

      paymentIntent = await createPaymentIntent(
          amount: total, currency: "EUR", controlId: controlId);

      //

      //    'name':
      //     "${authController.userModel!.first_name} ${authController.userModel!.last_name}",
      // 'email': authController.userModel!.email,
      // 'address[line1]': authController.userModel!.address,
      // 'address[city]': authController.userModel!.city,
      // 'address[state]': '',
      // 'address[postal_code]': authController.userModel!.code_postal,
      // 'address[country]': "",
      final billingDetails = BillingDetails(
        name:
            "${authController.userModel!.first_name} ${authController.userModel!.last_name}",
        email: authController.userModel!.email,
        phone: "0${authController.userModel!.phone}",
        address: Address(
          city: authController.userModel!.city,
          country: 'FR',
          line1: authController.userModel!.address,
          line2: '',
          state: '',
          postalCode: authController.userModel!.code_postal,
        ),
      );
      // paymentCustom = await createCustomerIntent(token: paymentIntent!["id"]);
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          isLoading = false;
        });
      });

      // Stripe.instance.createPaymentMethod(params: params)
      //Payment Sheet
      await Stripe.instance
          .initPaymentSheet(
              paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: paymentIntent!['client_secret'],
            billingDetails: billingDetails,
            // customerId: paymentCustom!["id"],
            // applePay: const PaymentSheetApplePay(merchantCountryCode: '+92',),
            // googlePay: const PaymentSheetGooglePay(testEnv: true, currencyCode: "US", merchantCountryCode: "+92"),
            style: ThemeMode.system,
            merchantDisplayName: 'Control-car payment by stripe',
          ))
          .then((value) {});

      ///now finally display payment sheeet
      displayPaymentSheet(
          total: total,
          controlId: controlId,
          hasCoupon: hasCoupon,
          discount: discount);
    } catch (e, s) {
      if (kDebugMode) {
        print('exception:$e$s');
      }
    }
  }

  // this

  // end this

  displayPaymentSheet(
      {required String total,
      required String controlId,
      required String hasCoupon,
      required String discount}) async {
    // try {
    ControlController controlController = Get.find();
    try {
      await Stripe.instance.presentPaymentSheet().then((value) {
        setState(() {
          isLoading = true;
        });
        controlController
            .checkPayControl(
                idControl: controlId,
                hasCoupon: hasCoupon,
                price: total,
                discount: discount)
            .then((value) {
          setState(() {
            isLoading = false;
          });
          if (value.isSuccess) {
            Get.to(() => const InfoVehiculeScreen(),
                routeName: RouteHelper.getInfoVehiculeRoute());
            // Get.to(() => const HomeMapScreen(),
            //     routeName: RouteHelper.getHomeMapRoute());
            Get.bottomSheet(Container(
              color: Colors.white,
              height: sizeHeight(context: context) * .45,
              child: SingleChildScrollView(
                child: SizedBox(
                  width: sizeWidth(context: context),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 15,
                      ),
                      Image.asset(
                        "assets/images/Groupe 422.png",
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Text(
                        "Paiement effectué avec succès",
                        style: gothicBold.copyWith(
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
          } else {}
        }).catchError((onError) {});
      });
    } on Exception catch (e) {
      if (e is StripeException) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${e.error.localizedMessage}'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unforeseen error: $e'),
          ),
        );
      }
    }
    // .then((value) {

    // controlController
    //     .checkPayControl(
    //         idControl: controlId,
    //         hasCoupon: hasCoupon,
    //         price: total,
    //         discount: discount)
    //     .then((value) {
    //   setState(() {
    //     isLoading = false;
    //   });
    //   if (value.isSuccess) {
    //     Get.to(() => const InfoVehiculeScreen(),
    //         routeName: RouteHelper.getInfoVehiculeRoute());
    //     // Get.to(() => const HomeMapScreen(),
    //     //     routeName: RouteHelper.getHomeMapRoute());
    //     Get.bottomSheet(Container(
    //       color: Colors.white,
    //       height: sizeHeight(context: context) * .45,
    //       child: SingleChildScrollView(
    //         child: SizedBox(
    //           width: sizeWidth(context: context),
    //           child: Column(
    //             children: [
    //               const SizedBox(
    //                 height: 15,
    //               ),
    //               Image.asset(
    //                 "assets/images/Groupe 422.png",
    //               ),
    //               const SizedBox(
    //                 height: 15,
    //               ),
    //               Text(
    //                 "Paiement effectué avec succès",
    //                 style: gothicBold.copyWith(
    //                   fontSize: 18,
    //                 ),
    //               ),
    //               const SizedBox(
    //                 height: 20,
    //               ),
    //             ],
    //           ),
    //         ),
    //       ),
    //     ));
    //   } else {}
    // }).catchError((onError) {});
    // ScaffoldMessenger.of(context)
    //     .showSnackBar(const SnackBar(content: Text("paid successfully")));
    // }).catchError((error) {
    //   if (kDebugMode) {
    //     log("error: $error");
    //     print('Error is:--->$error ');
    //   }
    // });
    // } on StripeException catch (e) {
    //   if (kDebugMode) {
    //     print('Errord is:---> $e');
    //   }
    //   showDialog(
    //       context: context,
    //       builder: (_) => const AlertDialog(
    //             content: Text("Cancelled "),
    //           ));
    // } catch (e) {
    //   if (kDebugMode) {
    //     print('$e');
    //   }
    // }
  }

  createPaymentIntent(
      {required String amount,
      required String currency,
      required String controlId}) async {
    AuthController authController = Get.find();
    try {
      Map<String, dynamic> body = {
        'amount': calculateAmount(amount),
        'currency': currency,
        'payment_method_types[]': 'card',
        'description':
            "paiement du control car id=$controlId, par ${authController.userModel!.first_name} ${authController.userModel!.last_name}",
      };

      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer ${AppConstant.secruteKey}',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: body,
      );
      // ignore: avoid_print
      print(response.body.toString());
      return jsonDecode(response.body.toString());
    } catch (err) {
      // ignore: avoid_print
      print('err charging user: ${err.toString()}');
    }
  }

  createCustomerIntent({required String token}) async {
    AuthController authController = Get.find();
    try {
      Map<String, dynamic> body = {
        'name':
            "${authController.userModel!.first_name} ${authController.userModel!.last_name}",
        'email': authController.userModel!.email,
        'address[line1]': authController.userModel!.address,
        'address[city]': authController.userModel!.city,
        'address[state]': '',
        'address[postal_code]': authController.userModel!.code_postal,
        'address[country]': "",
      };

      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/customers'),
        headers: {
          'Authorization': 'Bearer ${AppConstant.secruteKey}',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: body,
      );
      // ignore: avoid_print
      log(response.body.toString());

      // print('Payment Intent Body->>> ${response.body.toString()}');
      return jsonDecode(response.body);
    } catch (err) {
      // ignore: avoid_print
      print('err charging user: ${err.toString()}');
    }
  }

  calculateAmount(String amount) {
    final calculatedAmout = (double.parse(amount)) * 100;
    return calculatedAmout.toStringAsFixed(0);
  }
}
