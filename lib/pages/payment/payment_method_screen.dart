// ignore_for_file: use_build_context_synchronously
import 'package:client_control_car/constants/constants.dart';
import 'package:client_control_car/constants/route_helper.dart';
import 'package:client_control_car/controllers/auth_controller.dart';
import 'package:client_control_car/controllers/control_controller.dart';
import 'package:client_control_car/models/card_bank_model.dart';

import 'package:client_control_car/pages/info_vehicule/info_vehicule_screen.dart';
import 'package:client_control_car/pages/menu/drawer_widget.dart';
import 'package:client_control_car/pages/menu/menu_bottom.dart';
import 'package:client_control_car/pages/payment/add_card_payment_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:loading_overlay/loading_overlay.dart';

class PaymentMethodScreen extends StatefulWidget {
  final String controlId;
  final String total;
  final String hasCoupon;
  final String discount;
  const PaymentMethodScreen(
      {Key? key,
      required this.controlId,
      required this.total,
      required this.discount,
      required this.hasCoupon})
      : super(key: key);

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  CardBankModel? selectedCard;
  bool isLoading = false;
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

  getData() async {
    ControlController controlController = Get.find();
    controlController.getListCartBancair().then((value) {
      setState(() {});
    });
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
          child: SizedBox(
        width: sizeWidth(context: context),
        height: sizeHeight(context: context),
        child: LoadingOverlay(
          isLoading: isLoading,
          child: GetBuilder<ControlController>(builder: (controlController) {
            return Row(
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
                                // subtitle
                                const SizedBox(
                                  height: 20,
                                ),
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  child: Row(
                                    children: [
                                      Text(
                                        "Choisissez votre carte",
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
                                // list
                                for (var item in controlController.listCardBank)
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 5),
                                    decoration: BoxDecoration(
                                        color: selectedCard == null
                                            ? greyColor
                                            : selectedCard!.numberCard
                                                        .toString() ==
                                                    item.numberCard
                                                ? blueColor
                                                : greyColor,
                                        borderRadius: BorderRadius.circular(6)),
                                    child: ListTile(
                                      onTap: () {
                                        if (selectedCard == null) {
                                          selectedCard = item;
                                        } else {
                                          if (selectedCard!.numberCard
                                                  .toString() ==
                                              item.numberCard.toString()) {
                                            selectedCard = null;
                                          } else {
                                            selectedCard = item;
                                          }
                                        }
                                        setState(() {});
                                      },
                                      title: Text(
                                        item.namUser.toString(),
                                        style: gothicBold.copyWith(
                                            color: selectedCard == item
                                                ? Colors.white
                                                : Colors.black,
                                            fontSize: 18),
                                      ),
                                      subtitle: Text(
                                        '**** **** **** ${item.numberCard!.substring(item.numberCard!.length - 4)}',
                                        style: gothicBold.copyWith(
                                            color: selectedCard == null
                                                ? Colors.black
                                                : selectedCard!.numberCard
                                                            .toString() ==
                                                        item.numberCard
                                                            .toString()
                                                    ? Colors.white
                                                    : Colors.black,
                                            fontSize: 16),
                                      ),
                                      trailing:
                                          Image.asset(item.image.toString()),
                                    ),
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
                                        if (selectedCard == null) {
                                          Get.snackbar(
                                            maxWidth: 500,
                                            backgroundColor:
                                                blueColor.withOpacity(.7),
                                            "Vous n'avez pas spécifié de carte de paiement",
                                            "Veuillez sélectionner une carte de paiement",
                                          );
                                        } else {
                                          setState(() {
                                            isLoading = true;
                                          });
                                          AuthController authController =
                                              Get.find();

                                          if (double.parse(widget.total) > 0) {
                                            controlController
                                                .createPaymentController(
                                                    idControl: widget.controlId
                                                        .toString(),
                                                    card_number: selectedCard!
                                                        .numberCard
                                                        .toString(),
                                                    exp_month: selectedCard!
                                                        .monthCard
                                                        .toString(),
                                                    exp_year: selectedCard!.yearCard
                                                        .toString(),
                                                    cvc: selectedCard!.cvvCard
                                                        .toString(),
                                                    name: selectedCard!.namUser
                                                        .toString(),
                                                    email: authController
                                                        .userModel!.email
                                                        .toString(),
                                                    address_line1: authController
                                                        .userModel!.address
                                                        .toString(),
                                                    address_line2: "",
                                                    address_city: authController
                                                        .userModel!.city
                                                        .toString(),
                                                    address_state: "",
                                                    address_postal_code:
                                                        authController
                                                            .userModel!
                                                            .code_postal
                                                            .toString(),
                                                    address_country: "FR",
                                                    amount: (double.parse(
                                                                widget.total) *
                                                            100)
                                                        .toString(),
                                                    description:
                                                        "paiement du control car id=${widget.controlId.toString()}, par ${authController.userModel!.first_name} ${authController.userModel!.last_name}")
                                                .then((value) {
                                              if (value.isSuccess) {
                                                controlController
                                                    .checkPayControl(
                                                        idControl: widget
                                                            .controlId
                                                            .toString(),
                                                        hasCoupon:
                                                            widget.hasCoupon,
                                                        price: widget.total,
                                                        discount:
                                                            widget.discount)
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
                                                }).catchError((onError) {});
                                              } else {
                                                setState(() {
                                                  isLoading = false;
                                                });
                                                Get.snackbar(
                                                  maxWidth: 500,
                                                  backgroundColor:
                                                      blueColor.withOpacity(.7),
                                                  "Votre paiement n'est pas confirmé",
                                                  "Veuillez vérifier la validité de votre carte",
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
                                                "Votre paiement n'est pas confirmé",
                                                "Veuillez vérifier la validité de votre carte",
                                              );
                                            });
                                          } else {
                                            controlController
                                                .checkPayControl(
                                                    idControl: widget.controlId
                                                        .toString(),
                                                    hasCoupon: widget.hasCoupon,
                                                    price: widget.total,
                                                    discount: widget.discount)
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
                                              } else {
                                                setState(() {
                                                  isLoading = false;
                                                });
                                                Get.snackbar(
                                                  maxWidth: 500,
                                                  backgroundColor:
                                                      blueColor.withOpacity(.7),
                                                  "Votre paiement n'est pas confirmé",
                                                  "Veuillez vérifier la validité de votre carte",
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
                                                "Votre paiement n'est pas confirmé",
                                                "Veuillez vérifier la validité de votre carte",
                                              );
                                            });
                                          }
                                        }
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
                                        "Continuer",
                                        style: gothicBold.copyWith(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 5),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        if (selectedCard == null) {
                                          Get.to(
                                            () => const AddCardPaymentScreen(),
                                            routeName: RouteHelper
                                                .getAddCardPaymentRoute(),
                                          )?.then((value) {
                                            getData();
                                            setState(() {});
                                          });
                                        } else {
                                          ControlController controlController =
                                              Get.find();
                                          controlController
                                              .deleteCartBancair(
                                                  numberCard: selectedCard!
                                                      .numberCard
                                                      .toString())
                                              .then((value) {
                                            selectedCard = null;
                                          });
                                        }
                                      },
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                selectedCard == null
                                                    ? greyColor
                                                    : Colors.red),
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
                                        selectedCard == null
                                            ? "Ajouter une carte"
                                            : "Supprimer",
                                        style: gothicBold.copyWith(
                                          color: selectedCard == null
                                              ? Colors.black
                                              : Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ],
            );
          }),
        ),
      )),
    );
  }

  // payment

  calculateAmount(String amount) {
    final a = (double.parse(amount)) * 100;
    return a.toStringAsFixed(0);
  }
}

class CardPayment {
  String? id;
  String? name;
  String? code;
  String? image;

  CardPayment({this.id, this.name, this.code, this.image});
}
