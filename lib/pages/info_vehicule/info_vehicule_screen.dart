import 'dart:async';
// import 'dart:math';

import 'package:client_control_car/constants/app_constant.dart';
import 'package:client_control_car/constants/constants.dart';
import 'package:client_control_car/constants/route_helper.dart';
import 'package:client_control_car/controllers/auth_controller.dart';
import 'package:client_control_car/controllers/control_controller.dart';
import 'package:client_control_car/pages/auth/widgets/custom_input_validator.dart';
import 'package:client_control_car/pages/book_rdv/dart_time_screen.dart';
import 'package:client_control_car/pages/comment-ca-march/comment_ca_marche_screen.dart';
import 'package:client_control_car/pages/historys/consulter_rapport_page.dart';
import 'package:client_control_car/pages/info_vehicule/widgets/widgets.dart';
import 'package:client_control_car/pages/menu/drawer_widget.dart';
import 'package:client_control_car/pages/menu/menu_bottom.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class InfoVehiculeScreen extends StatefulWidget {
  const InfoVehiculeScreen({Key? key}) : super(key: key);

  @override
  State<InfoVehiculeScreen> createState() => _InfoVehiculeScreenState();
}

class _InfoVehiculeScreenState extends State<InfoVehiculeScreen> {
  // variables
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  int steps = 0;
  String typeVehicule = "";
  String marqueVehicule = "";
  TextEditingController lienController = TextEditingController();
  TextEditingController immatriculController = TextEditingController();
  TextEditingController demandeController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController codepostalController = TextEditingController();
  TextEditingController batimentController = TextEditingController();
  bool isPresent = true;
  FocusNode lienFocus = FocusNode();
  FocusNode immatriculFocus = FocusNode();
  FocusNode demandeFocus = FocusNode();
  FocusNode addressFocus = FocusNode();
  FocusNode cityFocus = FocusNode();
  FocusNode codepostalFocus = FocusNode();
  FocusNode batimentFocus = FocusNode();
  final _formKeyComment = GlobalKey<FormState>();
  TextEditingController commentController = TextEditingController();
  FocusNode commentFocus = FocusNode();
  double nbrStart = 0;
  bool isLoading = true;
  bool isLoadingShow = true;
  bool isErrors = false;
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  var maskFormatter = MaskTextInputFormatter(
      mask: '## - *** - ##',
      filter: {
        "#": RegExp(r'[A-Z|a-z|0-9]'),
        "*": RegExp(r'[A-Z|a-z|0-9]'),
      },
      type: MaskAutoCompletionType.lazy);
  var codePostalFormatter = MaskTextInputFormatter(
      mask: "#####",
      filter: {
        "#": RegExp(r'[0-9]'),
      },
      type: MaskAutoCompletionType.lazy);
  LatLng latLng = const LatLng(47.442685, 2.273293);




  @override
  void initState() {
    super.initState();
    check().then((value) {
      Future.delayed(const Duration(seconds: 1), () {
        getData();
        // get data notif
        // getDataControls();
        // checkFirestore();
      });
    });
    setState(() {});
  }

  // Get Data from db
  getData() async {
    ControlController controlController = Get.find();
    setState(() {
      isErrors = false;
    });
    controlController.getListTypeVehiculeController().then((value) {
      if (value.isSuccess) {
        controlController.getListMarqueVehiculeController().then((value) {
          if (value.isSuccess) {
            setState(() {
              typeVehicule =
                  controlController.listVehiculeType.first.id.toString();
              marqueVehicule =
                  controlController.listVehiculeMarque.first.id.toString();
              isErrors = false;
              isLoadingShow = false;
              isLoading = false;
            });
          }
          else {
            setState(() {
              isErrors = true;
              isLoadingShow = false;
              isLoading = false;
            });
          }
        })
            .catchError((onError) {
          setState(() {
            isErrors = true;
            isLoadingShow = false;
            isLoading = false;
          });
        });
      } else {
        setState(() {
          isErrors = true;
          isLoadingShow = false;
          isLoading = false;
        });
      }
    }).catchError((onError) {
      setState(() {
        isErrors = true;
        isLoadingShow = false;
        isLoading = false;
      });
    });
  }


  StreamSubscription<QuerySnapshot>? subscription;

  final _formKey = GlobalKey<FormState>();
  final _formKeyfirst = GlobalKey<FormState>();

  getDataControls({required String id, required String idControl}) async {
    ControlController controlController = Get.find();
    final CollectionReference controlRef =
        FirebaseFirestore.instance.collection('control');
    controlController
        .getControlDetailController(idcontrol: idControl)
        .then((value) {
      if (value.isSuccess) {
        if (controlController.controlModel != null) {
          // if (listCntrols.length == 1) {

          // 1 controle
          Get.bottomSheet(
                  Container(
                    height: sizeHeight(context: context) * .6,
                    decoration: const BoxDecoration(color: Colors.white),
                    child: Form(
                      key: _formKeyComment,
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
                                  "Notez votre commande N:${controlController.controlModel!.id}",
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
                                    controlController
                                        .controlModel!
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
                                  "${controlController.controlModel!.listControlTechniciens!.first.technicienModel!.userModel!.first_name} ${controlController.controlModel!.listControlTechniciens!.first.technicienModel!.userModel!.last_name}",
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
                                  itemPadding: const EdgeInsets.symmetric(
                                      horizontal: 4.0),
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
                                                control: controlController
                                                    .controlModel!.id
                                                    .toString(),
                                                comment: commentController
                                                        .text.isEmpty
                                                    ? ""
                                                    : commentController.text,
                                                technicien: controlController
                                                    .controlModel!
                                                    .listControlTechniciens!
                                                    .first
                                                    .technicienModel!
                                                    .id
                                                    .toString(),
                                                notation:
                                                    nbrStart.toStringAsFixed(0))
                                            .then((value) {
                                          if (value.isSuccess) {
                                            getData();
                                          } else {
                                            setState(() {
                                              isLoading = false;
                                            });
                                            if (value.message
                                                .toLowerCase()
                                                .contains("deja exist"
                                                    .toLowerCase())) {
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
                                          borderRadius:
                                              BorderRadius.circular(0),
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
                                              idControl: controlController
                                                  .controlModel!.id
                                                  .toString(),
                                              status: "7")
                                          .then((value) {
                                        if (value.isSuccess) {
                                          getData();
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
                                          MaterialStateProperty.all(
                                              Colors.white),
                                      padding: MaterialStateProperty.all(
                                        const EdgeInsets.symmetric(
                                            vertical: 10, horizontal: 15),
                                      ),
                                      shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(0),
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      "Passer",
                                      style: gothicBold.copyWith(
                                          color: Colors.black),
                                    )),
                              ),
                              //
                              SizedBox(
                                width: sizeWidth(context: context) * .8,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Get.dialog(Scaffold(
                                      // appBar: AppBar(),
                                      floatingActionButton:
                                          FloatingActionButton(
                                        onPressed: () {
                                          Get.back();
                                        },
                                        child: const BackButton(),
                                      ),
                                      floatingActionButtonLocation:
                                          FloatingActionButtonLocation
                                              .miniEndFloat,
                                      body: ConsultRapportScreen(
                                        idcontrol: controlController
                                            .controlModel!.id
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
                                    style: gothicBold.copyWith(
                                        color: Colors.white),
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
                  isScrollControlled: true)
              .then(
            (value) => controlRef.doc(id).delete(),
          );
          // } else {
          //   // multicontrols
          // }
        }
      } else {}
    }).catchError((onError) {});
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

  @override
  void dispose() {
    subscription!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    check();
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
          :
          AppBar(
              backgroundColor: Colors.white,
              // elevation: 0,
              leading: steps == 0
                  ? InkWell(
                      onTap: () {
                        scaffoldKey.currentState!.openDrawer();
                      },
                      child: Image.asset("assets/icons/drawer.png"))
                  : InkWell(
                      onTap: () {
                        if (steps == 0) {
                          Get.back();
                        } else {
                          setState(() {
                            steps = 0;
                          });
                        }
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
        child:
        SizedBox(
          height: sizeHeight(context: context),
          width: sizeWidth(context: context),
          child: GetBuilder<ControlController>(builder: (controlController) {
            return LoadingOverlay(
              isLoading: isLoading,
              child: isLoadingShow
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              checkIsWeb(context: context)
                                  ? AppBar(
                                      backgroundColor: Colors.transparent,
                                      elevation: 0,
                                      leading: steps == 0
                                          ? null
                                          : InkWell(
                                              onTap: () {
                                                if (steps == 0) {
                                                  Get.back();
                                                } else {
                                                  setState(() {
                                                    steps = 0;
                                                  });
                                                }
                                              },
                                              child: Icon(
                                                Icons.arrow_back_ios,
                                                color: normalText,
                                              ),
                                            ),
                                    )
                                  : Container(),
                              //
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Center(
                                    child: Container(
                                      constraints: const BoxConstraints(
                                        maxWidth: 800,
                                      ),
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 15),
                                      alignment: Alignment.center,
                                      child: steps == 0
                                          ? Form(
                                              key: _formKeyfirst,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      InkWell(
                                                        onTap: () {
                                                          Get.dialog(
                                                            const CommentCaMarechScreen(),
                                                          );
                                                        },
                                                        child: Container(
                                                          margin:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      15),
                                                          padding:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal: 6,
                                                                  vertical: 4),
                                                          decoration: BoxDecoration(
                                                              color: blueColor,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          6)),
                                                          child: Text(
                                                            "Comment ça marche?",
                                                            style: gothicBold
                                                                .copyWith(
                                                              fontSize: 10,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  // TITLE
                                                  Container(
                                                    margin: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 15),
                                                    child: Text(
                                                      "Demande de contrôle",
                                                      style:
                                                          gothicBold.copyWith(
                                                              fontSize: 25),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 15,
                                                  ),
                                                  // Type de véhicule
                                                  Container(
                                                    margin: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 15),
                                                    child: Row(
                                                      children: [
                                                        Text(
                                                          "Type de véhicule",
                                                          style: gothicRegular
                                                              .copyWith(
                                                            color: normalText,
                                                          ),
                                                        ),
                                                        Text(
                                                          "*",
                                                          style: gothicRegular
                                                              .copyWith(
                                                            color: Colors.red,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 15,
                                                  ),
                                                  Container(
                                                    width: sizeWidth(
                                                        context: context),
                                                    height: 100,
                                                    margin: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 15),
                                                    child: ListView(
                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      children: [
                                                        for (var typeItem
                                                            in controlController
                                                                .listVehiculeType)
                                                          typeVehiculeItems(
                                                            typeItem: typeItem,
                                                            typeVehicule:
                                                                typeVehicule,
                                                            onTap: () {
                                                              setState(() {
                                                                typeVehicule =
                                                                    typeItem.id
                                                                        .toString();
                                                              });
                                                            },
                                                          ),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 15,
                                                  ),
                                                  // Marque du véhicule
                                                  Container(
                                                    margin: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 15),
                                                    child: Row(
                                                      children: [
                                                        Text(
                                                          "Marque du véhicule",
                                                          style: gothicRegular
                                                              .copyWith(
                                                            color: normalText,
                                                          ),
                                                        ),
                                                        Text(
                                                          "*",
                                                          style: gothicRegular
                                                              .copyWith(
                                                            color: Colors.red,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 15,
                                                  ),
                                                  Container(
                                                    width: sizeWidth(
                                                        context: context),
                                                    height: 100,
                                                    margin: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 15),
                                                    child: ListView(
                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      children: [
                                                        for (var marqueItem
                                                            in controlController
                                                                .listVehiculeMarque)
                                                          marqueVehiculeItems(
                                                            marqueItem:
                                                                marqueItem,
                                                            onTap: () {
                                                              setState(() {
                                                                marqueVehicule =
                                                                    marqueItem
                                                                        .id
                                                                        .toString();
                                                              });
                                                            },
                                                            marqueVehicule:
                                                                marqueVehicule,
                                                          )
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 15,
                                                  ),
                                                  // Lien de l’offre
                                                  Container(
                                                    margin: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 15),
                                                    child: Text(
                                                      "Lien de l’offre",
                                                      style: gothicRegular
                                                          .copyWith(
                                                        color: normalText,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 15,
                                                  ),
                                                  Container(
                                                    margin: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 15),
                                                    child:
                                                        CustomInputValidatore(
                                                      controller:
                                                          lienController,
                                                      labelText: null,
                                                      marginContainer:
                                                          const EdgeInsets.only(
                                                              bottom: 0,
                                                              top: 0),
                                                      width: sizeWidth(
                                                          context: context),
                                                      hintText:
                                                          "https://google.com",
                                                      focusNode: lienFocus,
                                                      // validator: (value) {
                                                      //   if (value == null ||
                                                      //       value.isEmpty) {
                                                      //     return '';
                                                      //   }
                                                      //   return null;
                                                      // },
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 15,
                                                  ),
                                                  // Immatriculation
                                                  Container(
                                                    margin: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 15),
                                                    child: Text(
                                                      "Immatriculation",
                                                      style: gothicRegular
                                                          .copyWith(
                                                        color: normalText,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 15,
                                                  ),
                                                  Container(
                                                    margin: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 15),
                                                    height: 53,
                                                    constraints:
                                                        const BoxConstraints(
                                                            maxWidth: 250),
                                                    child: Container(
                                                      constraints:
                                                          const BoxConstraints(
                                                              maxWidth: 250),
                                                      child: Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          Image.asset(
                                                            "assets/icons/Emat 1.png",
                                                            height: 48.5,
                                                            fit: BoxFit.fill,
                                                          ),
                                                          Expanded(
                                                            child:
                                                                CustomInputValidatore(
                                                              isradius: true,
                                                              inputFormatters: [
                                                                maskFormatter,
                                                              ],
                                                              controller:
                                                                  immatriculController,
                                                              labelText: null,
                                                              marginContainer:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      bottom: 0,
                                                                      top: 0),
                                                              width: sizeWidth(
                                                                  context:
                                                                      context),
                                                              hintText:
                                                                  "XX - 000 - XX",
                                                              focusNode:
                                                                  immatriculFocus,
                                                              validator:
                                                                  (value) {
                                                                if (value!
                                                                        .isNotEmpty &&
                                                                    value
                                                                            .replaceAll(" ",
                                                                                "")
                                                                            .length !=
                                                                        9) {
                                                                  return '';
                                                                }
                                                                return null;
                                                              },
                                                            ),
                                                          ),
                                                          Image.asset(
                                                            "assets/icons/Emat 2.png",
                                                            height: 48.5,
                                                            fit: BoxFit.fill,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 150,
                                                  ),
                                                ],
                                              ),
                                            )
                                      // Page 2
                                          : Form(
                                              key: _formKey,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  // demand
                                                  const SizedBox(
                                                    height: 50,
                                                  ),
                                                  Container(
                                                    margin: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 15),
                                                    child: Row(
                                                      children: [
                                                        Text(
                                                          "Serez-vous présent lors du contrôle ?",
                                                          style: gothicRegular
                                                              .copyWith(
                                                            color: normalText,
                                                          ),
                                                        ),
                                                        Text(
                                                          "*",
                                                          style: gothicRegular
                                                              .copyWith(
                                                            color: Colors.red,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 15,
                                                  ),
                                                  Container(
                                                    height: 30,
                                                    margin: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 15),
                                                    child: Row(
                                                      children: [
                                                        // checkbox
                                                        Checkbox(
                                                            value: isPresent,
                                                            onChanged: (v) {
                                                              setState(() {
                                                                isPresent =
                                                                    true;
                                                              });
                                                            }),
                                                        // value
                                                        InkWell(
                                                          onTap: () {
                                                            setState(() {
                                                              isPresent = true;
                                                            });
                                                          },
                                                          child: Container(
                                                            margin:
                                                                const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        3),
                                                            child: Text(
                                                              "Oui",
                                                              style:
                                                                  gothicRegular
                                                                      .copyWith(
                                                                color:
                                                                    normalText,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Container(
                                                    height: 30,
                                                    margin: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 15),
                                                    child: Row(
                                                      children: [
                                                        // checkbox
                                                        Checkbox(
                                                            value: !isPresent,
                                                            onChanged: (v) {
                                                              setState(() {
                                                                isPresent =
                                                                    false;
                                                              });
                                                            }),
                                                        // value
                                                        InkWell(
                                                          onTap: () {
                                                            setState(() {
                                                              isPresent = false;
                                                            });
                                                          },
                                                          child: Container(
                                                            margin:
                                                                const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        3),
                                                            child: Text(
                                                              "Non",
                                                              style:
                                                                  gothicRegular
                                                                      .copyWith(
                                                                color:
                                                                    normalText,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),

                                                  const SizedBox(
                                                    height: 15,
                                                  ),
                                                  Divider(
                                                    thickness: 1,
                                                    color: normalText,
                                                  ),
                                                  const SizedBox(
                                                    height: 15,
                                                  ),
                                                  // address
                                                  Container(
                                                    margin: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 15),
                                                    child: InkWell(
                                                      onTap: () async {
                                                        var place = await PlacesAutocomplete.show(
                                                            context: context,
                                                            apiKey: AppConstant
                                                                .API_GOOGLE_MAPS,
                                                            mode: Mode.overlay,
                                                            types: [],
                                                            strictbounds: false,
                                                            language: "fr",
                                                            proxyBaseUrl:
                                                                AppConstant
                                                                    .BASE_ADDRESS_URL,
                                                            components: [],
                                                            onError: (err) {});
                                                        if (place != null) {
                                                          final plist =
                                                              GoogleMapsPlaces(
                                                            apiKey: AppConstant
                                                                .API_GOOGLE_MAPS,
                                                            baseUrl: AppConstant
                                                                .BASE_ADDRESS_URL,
                                                            apiHeaders:
                                                                await const GoogleApiHeaders()
                                                                    .getHeaders(),
                                                          );

                                                          String placeid =
                                                              place.placeId ??
                                                                  "0";

                                                          final detail = await plist
                                                              .getDetailsByPlaceId(
                                                                  placeid);

                                                          final geometry =
                                                              detail.result
                                                                  .geometry!;

                                                          final lat = geometry
                                                              .location.lat;
                                                          final lang = geometry
                                                              .location.lng;
                                                          latLng =
                                                              LatLng(lat, lang);
                                                          controlController
                                                                  .currentPositionLatLng =
                                                              latLng;
                                                          addressController
                                                                  .text =
                                                              place.description
                                                                  .toString();
                                                          setState(() {});
                                                        }
                                                      },
                                                      child: IgnorePointer(
                                                        child:
                                                            CustomInputValidatore(
                                                          controller:
                                                              addressController,
                                                          labelText: null,
                                                          validator: (value) {
                                                            if (value == null ||
                                                                value.isEmpty) {
                                                              return '';
                                                            }
                                                            return null;
                                                          },
                                                          labelWidget: labelInput(
                                                              text:
                                                                  "Adresse du contrôle",
                                                              req: true),
                                                          marginContainer:
                                                              const EdgeInsets
                                                                      .only(
                                                                  bottom: 11),
                                                          width: sizeWidth(
                                                                  context:
                                                                      context) *
                                                              .9,
                                                          inputType:
                                                              TextInputType
                                                                  .text,
                                                          focusNode:
                                                              addressFocus,
                                                        ),
                                                      ),
                                                    ),
                                                  ),

                                                  const SizedBox(
                                                    height: 11,
                                                  ),
                                                  // city
                                                  Container(
                                                    margin: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 15),
                                                    child:
                                                        CustomInputValidatore(
                                                      controller:
                                                          cityController,
                                                      labelText: null,
                                                      labelWidget: labelInput(
                                                        text: "Ville",
                                                        req: true,
                                                      ),
                                                      marginContainer:
                                                          const EdgeInsets.only(
                                                              bottom: 11),
                                                      width: sizeWidth(
                                                              context:
                                                                  context) *
                                                          .9,
                                                      inputType:
                                                          TextInputType.text,
                                                      focusNode: cityFocus,
                                                      validator: (value) {
                                                        if (value == null ||
                                                            value.isEmpty) {
                                                          return '';
                                                        }
                                                        return null;
                                                      },
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 11,
                                                  ),

                                                  // code postal && batiment
                                                  Container(
                                                    margin: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 15),
                                                    child: Row(
                                                      children: [
                                                        Expanded(
                                                          child:
                                                              CustomInputValidatore(
                                                            controller:
                                                                codepostalController,
                                                            labelText: null,
                                                            labelWidget: labelInput(
                                                                text:
                                                                    "Code postal",
                                                                req: true),
                                                            marginContainer:
                                                                const EdgeInsets
                                                                        .only(
                                                                    bottom: 11),
                                                            width: sizeWidth(
                                                                    context:
                                                                        context) *
                                                                .9,
                                                            inputFormatters: [
                                                              codePostalFormatter
                                                            ],
                                                            inputType:
                                                                TextInputType
                                                                    .text,
                                                            focusNode:
                                                                codepostalFocus,
                                                            validator: (value) {
                                                              if (value ==
                                                                      null ||
                                                                  value
                                                                      .isEmpty ||
                                                                  value.length !=
                                                                      5) {
                                                                return '';
                                                              }
                                                              return null;
                                                            },
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 5,
                                                        ),
                                                        Expanded(
                                                          child:
                                                              CustomInputValidatore(
                                                            controller:
                                                                batimentController,
                                                            labelText: null,
                                                            labelWidget: labelInput(
                                                                text:
                                                                    "Bâtiment"),
                                                            marginContainer:
                                                                const EdgeInsets
                                                                        .only(
                                                                    bottom: 11),
                                                            width: sizeWidth(
                                                                    context:
                                                                        context) *
                                                                .9,
                                                            inputType:
                                                                TextInputType
                                                                    .text,
                                                            focusNode:
                                                                batimentFocus,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 15,
                                                  ),
                                                  Container(
                                                    margin: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 15),
                                                    child: SizedBox(
                                                      child:
                                                          CustomInputValidatore(
                                                        maxLines: null,
                                                        minLines: 5,
                                                        controller:
                                                            demandeController,
                                                        labelText:
                                                            "Renseignements supplémentaires",
                                                        hintText:
                                                            "Renseignements supplémentaires ? Exemple : Sur le parking de Leclerc",
                                                        marginContainer:
                                                            const EdgeInsets
                                                                    .only(
                                                                bottom: 11),
                                                        width: sizeWidth(
                                                                context:
                                                                    context) *
                                                            .9,
                                                        inputType: TextInputType
                                                            .multiline,
                                                        focusNode: demandeFocus,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 15,
                                                  ),
                                                ],
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                              // price
                              Divider(
                                thickness: 1,
                                color: normalText,
                              ),

                              Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Row(
                                  children: [
                                    // price
                                    Expanded(
                                      flex: 2,
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 5),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Total :",
                                              style: gothicMediom.copyWith(
                                                fontSize: 16,
                                                color: Colors.black,
                                              ),
                                            ),
                                            Text("150.00€",
                                                style: gothicBold.copyWith(
                                                    color: Colors.black,
                                                    fontSize: 25)),
                                          ],
                                        ),
                                      ),
                                    ),
                                    // btn
                                    Expanded(
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 20),
                                        child: ElevatedButton(
                                          onPressed: () {
                                            if (steps == 0) {
                                              if (!_formKeyfirst.currentState!
                                                  .validate()) {
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
                                                controlController
                                                    .addInfoVehiculeController(
                                                        type_vehicule:
                                                            typeVehicule,
                                                        marque_vehicule:
                                                            marqueVehicule,
                                                        lien_annonce:
                                                            lienController.text
                                                                    .isEmpty
                                                                ? "_"
                                                                : lienController
                                                                    .text,
                                                        immatriculation:
                                                            immatriculController
                                                                    .text
                                                                    .isEmpty
                                                                ? "-"
                                                                : immatriculController
                                                                    .text)
                                                    .then((value) {
                                                  setState(() {
                                                    isLoading = false;
                                                  });
                                                  if (value.isSuccess) {
                                                    setState(() {
                                                      steps = 1;
                                                    });
                                                  } else {
                                                    Get.snackbar(
                                                      maxWidth: 500,
                                                      backgroundColor: blueColor
                                                          .withOpacity(.7),
                                                      "Votre demande n'a pas été enregistrée",
                                                      "Veuillez réessayer",
                                                    );
                                                  }
                                                }).catchError((onError) {
                                                  setState(() {
                                                    isLoading = false;
                                                  });
                                                  Get.snackbar(
                                                    maxWidth: 500,
                                                    backgroundColor: blueColor
                                                        .withOpacity(.7),
                                                    "Votre demande n'a pas été enregistrée",
                                                    "Veuillez réessayer",
                                                  );
                                                });
                                              }
                                            } else {
                                              if (!_formKey.currentState!
                                                  .validate()) {
                                                Get.snackbar(
                                                  maxWidth: 500,
                                                  backgroundColor:
                                                      blueColor.withOpacity(.7),
                                                  "Certains champs sont vides",
                                                  "Veuillez confirmer les champs!",
                                                );
                                              } else {
                                                if (addressController
                                                        .text.isEmpty ||
                                                    cityController
                                                        .text.isEmpty ||
                                                    codepostalController
                                                        .text.isEmpty) {
                                                  Get.snackbar(
                                                    maxWidth: 500,
                                                    backgroundColor: blueColor
                                                        .withOpacity(.7),
                                                    "Certains champs sont vides",
                                                    "Veuillez confirmer les champs!",
                                                  );
                                                } else {
                                                  if (!isPresent) {
                                                    // pup up

                                                    showDialog(
                                                        context: context,
                                                        builder: (context) {
                                                          return AlertDialog(
                                                            shape:
                                                                const RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .all(
                                                                Radius.circular(
                                                                  20.0,
                                                                ),
                                                              ),
                                                            ),
                                                            contentPadding:
                                                                const EdgeInsets
                                                                    .only(
                                                              top: 10.0,
                                                            ),
                                                            title: Text(
                                                              "Attention",
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: gothicBold
                                                                  .copyWith(
                                                                fontSize: 24,
                                                              ),
                                                            ),
                                                            content:
                                                                SingleChildScrollView(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child: Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                children: [
                                                                  Padding(
                                                                    padding:
                                                                        const EdgeInsets.all(
                                                                            8.0),
                                                                    child: Text(
                                                                      "Veuillez vous assurer que le vendeur soit bien présent lors du contrôle.",
                                                                      style: gothicBold
                                                                          .copyWith(),
                                                                    ),
                                                                  ),
                                                                  Padding(
                                                                    padding:
                                                                        const EdgeInsets.all(
                                                                            8.0),
                                                                    child: Text(
                                                                      "Vérifiez:",
                                                                      style: gothicBold
                                                                          .copyWith(),
                                                                    ),
                                                                  ),
                                                                  //
                                                                  Container(
                                                                    margin: const EdgeInsets
                                                                            .symmetric(
                                                                        horizontal:
                                                                            10),
                                                                    child: Row(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .center,
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        const Icon(
                                                                          Icons
                                                                              .circle,
                                                                          size:
                                                                              9,
                                                                        ),
                                                                        Expanded(
                                                                          child:
                                                                              Text(
                                                                            " L'adresse du rendez-vous",
                                                                            style:
                                                                                gothicBold.copyWith(),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  //
                                                                  Container(
                                                                    margin: const EdgeInsets
                                                                            .symmetric(
                                                                        horizontal:
                                                                            10),
                                                                    child: Row(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .center,
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        const Icon(
                                                                          Icons
                                                                              .circle,
                                                                          size:
                                                                              9,
                                                                        ),
                                                                        Expanded(
                                                                          child:
                                                                              Text(
                                                                            " La date et l'heure du contrôle",
                                                                            style:
                                                                                gothicBold.copyWith(),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  //
                                                                  Container(
                                                                    margin: const EdgeInsets
                                                                            .symmetric(
                                                                        horizontal:
                                                                            10),
                                                                    child: Row(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .center,
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        const Icon(
                                                                          Icons
                                                                              .circle,
                                                                          size:
                                                                              9,
                                                                        ),
                                                                        Expanded(
                                                                          child:
                                                                              Text(
                                                                            " La disponibilité du vendeur",
                                                                            style:
                                                                                gothicBold.copyWith(),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  Container(
                                                                    margin: const EdgeInsets
                                                                            .symmetric(
                                                                        horizontal:
                                                                            8,
                                                                        vertical:
                                                                            12),
                                                                    child: Text(
                                                                      "Control-Car ne sera pas responsable si le vendeur ne se présente pas au lieu de rendez-vous.",
                                                                      style: gothicRegular
                                                                          .copyWith(
                                                                        fontSize:
                                                                            12,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Container(
                                                                    alignment:
                                                                        Alignment
                                                                            .center,
                                                                    child: ElevatedButton(
                                                                        onPressed: () {
                                                                          Get.back();
                                                                          setState(
                                                                              () {
                                                                            isLoading =
                                                                                true;
                                                                          });
                                                                          controlController
                                                                              .addInfoPersoVehiculeController(
                                                                            present_ctrl: isPresent
                                                                                ? "True"
                                                                                : "False",
                                                                            demande_particuliere: demandeController.text.isEmpty
                                                                                ? "-"
                                                                                : demandeController.text,
                                                                            addresse:
                                                                                addressController.text,
                                                                            code_postal:
                                                                                codepostalController.text,
                                                                            batiment: batimentController.text.isEmpty
                                                                                ? "-"
                                                                                : batimentController.text,
                                                                            ville:
                                                                                cityController.text,
                                                                            location_x:
                                                                                latLng.latitude.toString(),
                                                                            location_y:
                                                                                latLng.longitude.toString(),
                                                                          )
                                                                              .then((value) {
                                                                            setState(() {
                                                                              isLoading = false;
                                                                            });
                                                                            if (value.isSuccess) {
                                                                              //
                                                                              controlController.facaddress = addressController.text;
                                                                              controlController.faccity = cityController.text;
                                                                              controlController.faccodepostal = codepostalController.text;
                                                                              controlController.facbatiment = batimentController.text;

                                                                              controlController.faclocation_x = latLng.latitude.toString();
                                                                              controlController.faclocation_y = latLng.longitude.toString();

                                                                              //
                                                                              Get.to(() => const DatTimeScreen(), routeName: RouteHelper.getBookRdvDateTimeRoute());
                                                                            } else {
                                                                              Get.snackbar(
                                                                                maxWidth: 500,
                                                                                backgroundColor: blueColor.withOpacity(.7),
                                                                                "Votre demande n'a pas été enregistrée",
                                                                                "Veuillez réessayer",
                                                                              );
                                                                            }
                                                                          }).catchError((onError) {
                                                                            setState(() {
                                                                              isLoading = false;
                                                                            });
                                                                            Get.snackbar(
                                                                              maxWidth: 500,
                                                                              backgroundColor: blueColor.withOpacity(.7),
                                                                              "Votre demande n'a pas été enregistrée",
                                                                              "Veuillez réessayer",
                                                                            );
                                                                          });
                                                                        },
                                                                        style: ButtonStyle(
                                                                          backgroundColor:
                                                                              MaterialStatePropertyAll(blueColor),
                                                                        ),
                                                                        child: Container(
                                                                          margin: const EdgeInsets.symmetric(
                                                                              horizontal: 25,
                                                                              vertical: 1),
                                                                          child:
                                                                              Text(
                                                                            "OK",
                                                                            style:
                                                                                gothicBold.copyWith(color: Colors.white, fontSize: 24),
                                                                          ),
                                                                        )),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                          );
                                                        });
                                                    // end
                                                  } else {
                                                    setState(() {
                                                      isLoading = true;
                                                    });
                                                    controlController
                                                        .addInfoPersoVehiculeController(
                                                      present_ctrl: isPresent
                                                          ? "True"
                                                          : "False",
                                                      demande_particuliere:
                                                          demandeController
                                                                  .text.isEmpty
                                                              ? "-"
                                                              : demandeController
                                                                  .text,
                                                      addresse:
                                                          addressController
                                                              .text,
                                                      code_postal:
                                                          codepostalController
                                                              .text,
                                                      batiment: batimentController
                                                              .text.isEmpty
                                                          ? "-"
                                                          : batimentController
                                                              .text,
                                                      ville:
                                                          cityController.text,
                                                      location_x: latLng
                                                          .latitude
                                                          .toString(),
                                                      location_y: latLng
                                                          .longitude
                                                          .toString(),
                                                    )
                                                        .then((value) {
                                                      setState(() {
                                                        isLoading = false;
                                                      });
                                                      if (value.isSuccess) {
                                                        //
                                                        controlController
                                                                .facaddress =
                                                            addressController
                                                                .text;
                                                        controlController
                                                                .faccity =
                                                            cityController.text;
                                                        controlController
                                                                .faccodepostal =
                                                            codepostalController
                                                                .text;
                                                        controlController
                                                                .facbatiment =
                                                            batimentController
                                                                .text;

                                                        controlController
                                                                .faclocation_x =
                                                            latLng.latitude
                                                                .toString();
                                                        controlController
                                                                .faclocation_y =
                                                            latLng.longitude
                                                                .toString();

                                                        //
                                                        Get.to(
                                                            () =>
                                                                const DatTimeScreen(),
                                                            routeName: RouteHelper
                                                                .getBookRdvDateTimeRoute());
                                                      } else {
                                                        Get.snackbar(
                                                          maxWidth: 500,
                                                          backgroundColor:
                                                              blueColor
                                                                  .withOpacity(
                                                                      .7),
                                                          "Votre demande n'a pas été enregistrée",
                                                          "Veuillez réessayer",
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
                                                        "Votre demande n'a pas été enregistrée",
                                                        "Veuillez réessayer",
                                                      );
                                                    });
                                                  }
                                                }
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
                                            "Suivant",
                                            style: gothicBold.copyWith(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
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
