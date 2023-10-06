import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:client_control_car/constants/constants.dart';
import 'package:client_control_car/controllers/auth_controller.dart';
import 'package:client_control_car/controllers/control_controller.dart';
import 'package:client_control_car/pages/auth/widgets/custom_input_validator.dart';
import 'package:file_picker/file_picker.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:client_control_car/pages/menu/drawer_widget.dart';
import 'package:client_control_car/pages/menu/menu_bottom.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:image_picker/image_picker.dart';

class DiagnosticScreen extends StatefulWidget {
  const DiagnosticScreen({Key? key}) : super(key: key);

  @override
  State<DiagnosticScreen> createState() => _DiagnosticScreenState();
}


class _DiagnosticScreenState extends State<DiagnosticScreen> {
  String? _filePath;

  void _openFilePicker() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        _filePath = result.files.single.path; // Store the selected file path
      });
    }
  }
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  int steps = 0;
  String typeVehicule = "";
  String marqueVehicule = "";

  bool isPresent = true;


  final _formKeyComment = GlobalKey<FormState>();
  TextEditingController commentController = TextEditingController();
  FocusNode commentFocus = FocusNode();
  double nbrStart = 0;

  bool isLoading = true;
  bool isLoadingShow = true;
  bool isErrors = false;
  bool isOuiSelected = false;
  bool isNonSelected = false;

  bool isValideChecked = false;
  bool isInvalideChecked = false;
  bool isNonChecked = false;

  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;




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
              // marqueVehicule = getListMarqueVehiculeByType(
              //         listVehiculeMarque: controlController.listVehiculeMarque,
              //         typeVehicule: typeVehicule)
              //     .first
              //     .id
              //     .toString();
              isErrors = false;
              isLoadingShow = false;
              isLoading = false;
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

    //
  }

  StreamSubscription<QuerySnapshot>? subscription;

  final _formKey = GlobalKey<FormState>();
  final _formKeyfirst = GlobalKey<FormState>();


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
          : AppBar(
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
        child: SizedBox(
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
                          child: MultiStepForm(),
                        )]
                  ),
                  )],
              ),
            );
          }),
        ),
      ),
    );
  }
}


class MultiStepForm extends StatefulWidget {
  @override
  _MultiStepFormState createState() => _MultiStepFormState();
}

class _MultiStepFormState extends State<MultiStepForm> {
  // FORMS
  final  List<GlobalKey<FormState>>_formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
  ];
  // Step 1
  Map<String, dynamic> step1 = {
    'marque': null,
    'modele': null,
    "annee" : null,
    "kilometrage" : null,
    "immatriculation" : null,
    "numeroVin" : null ,
    "CertifImmat" : "non",
    "b64CertifImmat" : null,
    "b64CertifNonGage" : null,
    "controleTech" : "non",
    "b64ControleTech" : null,
    "carnetEntret" : "oui",
    "b64CarnetEntret" : null,
    "AutreDocCommentair" : null,
    "b64AutreDoc" : null
  };
  TextEditingController step1MarqueController = TextEditingController();
  TextEditingController step1ModeleController = TextEditingController();
  TextEditingController step1YearController = TextEditingController();
  TextEditingController step1ImmatController = TextEditingController();
  TextEditingController step1KilomController = TextEditingController();
  TextEditingController step1VinController = TextEditingController();
  TextEditingController step1CertifImmatController = TextEditingController();
  TextEditingController step1B64CertifImmatController = TextEditingController();
  TextEditingController step1B64CertifNonGageController = TextEditingController();
  TextEditingController step1ControleTechController = TextEditingController();
  TextEditingController step1B64ControleTechController = TextEditingController();
  TextEditingController step1CarnetEntretController = TextEditingController();
  TextEditingController step1B64CarnetEntretController = TextEditingController();
  TextEditingController step1AutreDocCommentairController = TextEditingController();
  TextEditingController step1B64AutreDocController = TextEditingController();
  FocusNode step1MarqueFocus = FocusNode();
  FocusNode step1ModeleFocus = FocusNode();
  FocusNode step1YearFocus = FocusNode();
  FocusNode step1ImmatFocus = FocusNode();
  FocusNode step1KilomFocus = FocusNode();
  FocusNode step1VinFocus = FocusNode();
  FocusNode step1AutreDocCommentairFocus = FocusNode();
  bool isOuiSelected = false;
  bool isNonSelected = false;
  bool isValideChecked = false;
  bool isInvalideChecked = false;
  bool isNonChecked = false;
  bool isOuiSelected1 = false;
  bool isNonSelected1 = false;
  // Step 2
  Map<String, dynamic> step2 = {
    "essuieGlaceAvantStatuts" : null,
    "pareBriseStatuts":null,
    "pareBriseComment":null,
    "pareBriseImage":null,
    "faceAvantStatuts":null,
    "faceAvantComment":null,
    "faceAvantImage":null,
    "avantDroitStatuts":null,
    "avantDroitComment":null,
    "avantDroitImage":null,
    "avantGaucheStatuts":null,
    "avantGaucheComment":null,
    "avantGaucheImage":null,
  };
  // Step 2 Controller
  TextEditingController step2_essuieGlaceAvantStatutsController = TextEditingController();
  TextEditingController step2_pareBriseStatutsController = TextEditingController();
  TextEditingController step2_pareBriseCommentController = TextEditingController();
  TextEditingController step2_pareBriseImageController = TextEditingController();
  TextEditingController step2_faceAvantStatutsController = TextEditingController();
  TextEditingController step2_faceAvantCommentController = TextEditingController();
  TextEditingController step2_faceAvantImageController = TextEditingController();
  TextEditingController step2_avantDroitStatutsController = TextEditingController();
  TextEditingController step2_avantDroitCommentController = TextEditingController();
  TextEditingController step2_avantDroitImageController = TextEditingController();
  TextEditingController step2_avantGaucheStatutsController = TextEditingController();
  TextEditingController step2_avantGaucheCommentController = TextEditingController();
  TextEditingController step2_avantGaucheImageController = TextEditingController();
  bool isOuiSelected2 = false;
  bool isNonSelected2 = false;
  bool isNonChecked2 = false;
  bool isValideChecked2 = false;
  bool isInvalideChecked2 = false;
  FocusNode step2_pareBriseCommentFocus = FocusNode();
  FocusNode step2_faceAvantCommentFocus = FocusNode();
  FocusNode step2_avantDroitCommentFocus = FocusNode();
  FocusNode step2_avantGaucheCommentFocus = FocusNode();
  bool isInvalideChecked3 = false;
  bool isValideChecked3 = false;
  bool isNonChecked3 = false;
  bool isValideChecked4 = false;
  bool isInvalideChecked4 = false;
  bool isNonChecked4 = false;
  bool isNonChecked5 = false;
  bool isValideChecked5 = false;
  bool isInvalideChecked5 = false;
  // Step 3
  Map<String, dynamic> step3 = {
    "coteDroitStatuts" : null,
    "coteDroitComment":null,
    "coteDroitImage":null,
    "baseCaisseDroitStatuts":null,
    "baseCaisseDroitComment":null,
    "baseCaisseDroitImage":null,
    "coteGaucheStatuts":null,
    "coteGaucheComment":null,
    "coteGaucheImage":null,
    "baseCaisseGaucheStatuts":null,
    "baseCaisseGaucheComment":null,
    "baseCaisseGaucheImage":null,
  };

  // Step 3 Controller

  TextEditingController step3_coteDroitStatutsController = TextEditingController();
  TextEditingController step3_coteDroitCommentController = TextEditingController();
  TextEditingController step3_coteDroitImageController = TextEditingController();
  TextEditingController step3_baseCaisseDroitStatutsController = TextEditingController();
  TextEditingController step3_baseCaisseDroitCommentController = TextEditingController();
  TextEditingController step3_baseCaisseDroitImageController = TextEditingController();
  TextEditingController step3_coteGaucheStatutsController = TextEditingController();
  TextEditingController step3_coteGaucheCommentController = TextEditingController();
  TextEditingController step3_coteGaucheImageController = TextEditingController();
  TextEditingController step3_baseCaisseGaucheStatutsController = TextEditingController();
  TextEditingController step3_baseCaisseGaucheCommentController = TextEditingController();
  TextEditingController step3_baseCaisseGaucheImageController = TextEditingController();
  FocusNode step3_coteDroitCommentFocus = FocusNode();
  FocusNode step3_baseCaisseDroitCommentFocus = FocusNode();
  FocusNode step3_coteGaucheCommentFocus = FocusNode();
  FocusNode step3_baseCaisseGaucheCommentFocus = FocusNode();
  bool isInvalideChecked6 = false;
  bool isValideChecked6 = false;
  bool isNonChecked6 = false;
  bool isInvalideChecked7 = false;
  bool isValideChecked7 = false;
  bool isNonChecked7 = false;
  bool isInvalideChecked8 = false;
  bool isValideChecked8 = false;
  bool isNonChecked8 = false;
  bool isInvalideChecked9 = false;
  bool isValideChecked9 = false;
  bool isNonChecked9 = false;
  // Step 4
  Map<String, dynamic> step4 = {
    "essuieGlaceArriereStatuts" : null,
    "faceArriereStatuts":null,
    "faceArriereComment":null,
    "faceArriereImage":null,
    "arriereDroitStatuts":null,
    "arriereDroitComment":null,
    "arriereDroitImage":null,
    "arriereGaucheStatuts":null,
    "arriereGaucheComment":null,
    "arriereGaucheImage":null,
  };
  TextEditingController step4_essuieGlaceArriereStatutsController = TextEditingController();
  TextEditingController step4_faceArriereStatutsController = TextEditingController();
  TextEditingController step4_faceArriereCommentController = TextEditingController();
  TextEditingController step4_faceArriereImageController = TextEditingController();
  TextEditingController step4_arriereDroitStatutsController = TextEditingController();
  TextEditingController step4_arriereDroitCommentController = TextEditingController();
  TextEditingController step4_arriereDroitImageController = TextEditingController();
  TextEditingController step4_arriereGaucheStatutsController = TextEditingController();
  TextEditingController step4_arriereGaucheCommentController = TextEditingController();
  TextEditingController step4_arriereGaucheImageController = TextEditingController();
  FocusNode step4_faceArriereCommentFocus = FocusNode();
  FocusNode step4_arriereDroitCommentFocus = FocusNode();
  FocusNode step4_arriereGaucheCommentFocus = FocusNode();
  bool isInvalideChecked10 = false;
  bool isValideChecked10 = false;
  bool isNonChecked10 = false;
  bool isInvalideChecked11 = false;
  bool isValideChecked11 = false;
  bool isNonChecked11 = false;
  bool isInvalideChecked12 = false;
  bool isValideChecked12 = false;
  bool isNonChecked12 = false;
  bool isOuiSelected3 = false;
  bool isNonSelected3 = false;
  // Step 5
  Map<String, dynamic> step5 = {
    "toitStatuts" : null,
    "toitComment":null,
    "toitImage":null,
    "avisEtatVehiculeComment":null,
    "photoSuplementaire1" : null,
    "photoSuplementaire2" : null ,
    "conformeAnnonceStatuts_1":null,
  };
  TextEditingController step5_toitStatutsController = TextEditingController();
  TextEditingController step5_toitCommentController = TextEditingController();
  TextEditingController step5_toitImageController = TextEditingController();
  TextEditingController step5_avisEtatVehiculeCommentController = TextEditingController();
  TextEditingController step5_photoSuplementaire1Controller = TextEditingController();
  TextEditingController step5_photoSuplementaire2Controller = TextEditingController();
  TextEditingController step5_conformeAnnonceStatuts_1Controller = TextEditingController();
  FocusNode step5_toitCommentFocus = FocusNode();
  FocusNode step5_avisEtatVehiculeCommentFocus = FocusNode();
  bool isNonChecked13 = false;
  bool isValideChecked13 = false;
  bool isInvalideChecked13 = false;
  bool isOuiSelected4 = false;
  bool isNonSelected4 = false;
  // Step 6
  Map<String, dynamic> step6 = {
    "janteAvantDroitStatuts" : null,
    "janteAvantDroitComment":null,
    "janteAvantDroitImage":null,
    "janteAvantGaucheStatuts" : null,
    "janteAvantGaucheComment":null,
    "janteAvantGaucheImage":null,
    "janteArriereGaucheStatuts" : null,
    "janteArriereGaucheComment":null,
    "janteArriereGaucheImage":null,
    "janteArriereDroitStatuts" : null,
    "janteArriereDroitComment":null,
    "janteArriereDroitImage":null,
    "roueSecoursStatut":null,
  };
  TextEditingController step6_janteAvantDroitStatutsController = TextEditingController();
  TextEditingController step6_janteAvantDroitCommentController = TextEditingController();
  TextEditingController step6_janteAvantDroitImageController = TextEditingController();
  TextEditingController step6_janteAvantGaucheStatutsController = TextEditingController();
  TextEditingController step6_janteAvantGaucheCommentController = TextEditingController();
  TextEditingController step6_janteAvantGaucheImageController = TextEditingController();
  TextEditingController step6_janteArriereGaucheStatutsController = TextEditingController();
  TextEditingController step6_janteArriereGaucheCommentController = TextEditingController();
  TextEditingController step6_janteArriereGaucheImageController = TextEditingController();
  TextEditingController step6_janteArriereDroitStatutsController = TextEditingController();
  TextEditingController step6_janteArriereDroitCommentController = TextEditingController();
  TextEditingController step6_janteArriereDroitImageController = TextEditingController();
  TextEditingController step6_roueSecoursStatutController = TextEditingController();
  FocusNode step6_janteAvantDroitCommentFocus = FocusNode();
  FocusNode step6_janteAvantGaucheCommentFocus = FocusNode();
  FocusNode step6_janteArriereGaucheCommentFocus = FocusNode();
  FocusNode step6_janteArriereDroitCommentFocus = FocusNode();
  bool isNonChecked14 = false;
  bool isValideChecked14 = false;
  bool isInvalideChecked14 = false;
  bool isNonChecked15 = false;
  bool isValideChecked15 = false;
  bool isInvalideChecked15 = false;
  bool isNonChecked16 = false;
  bool isValideChecked16 = false;
  bool isInvalideChecked16 = false;
  bool isNonChecked17 = false;
  bool isValideChecked17 = false;
  bool isInvalideChecked17 = false;
  bool isOuiSelected5 = false;
  bool isNonSelected5 = false;
  // Step 7
  Map<String, dynamic> step7 = {
    "phareAvantGaucheStatuts" : null,
    "phareAvantGaucheComment":null,
    "phareAvantGaucheImage":null,
    "ampouleAvantGaucheStatuts" : null,
    "clignotantAvantGaucheStatuts":null,
    "phareAvantDroitStatuts":null,
    "phareAvantDroitComment":null,
    "phareAvantDroitImage" : null,
    "ampouleAvantDroitStatuts":null,
    "clignotantAvantDroitStatuts":null,
    "phareArriereDroitStatuts" : null,
    "phareArriereDroitComment":null,
    "phareArriereDroitImage":null,
    "ampouleArriereDroitStatuts":null,
    "clignotantArriereDroitStatuts":null,
    "phareArriereGaucheStatuts" : null,
    "phareArriereGaucheComment":null,
    "phareArriereGaucheImage":null,
    "ampouleArriereGaucheStatuts":null,
    "clignotantArriereGaucheStatuts":null,
  };
  TextEditingController step7_phareAvantGaucheStatutsController = TextEditingController();
  TextEditingController step7_phareAvantGaucheCommentController = TextEditingController();
  TextEditingController step7_phareAvantGaucheImageController = TextEditingController();
  TextEditingController step7_ampouleAvantGaucheStatutsController = TextEditingController();
  TextEditingController step7_clignotantAvantGaucheStatutsController = TextEditingController();
  TextEditingController step7_phareAvantDroitStatutsController = TextEditingController();
  TextEditingController step7_phareAvantDroitCommentController = TextEditingController();
  TextEditingController step7_phareAvantDroitImageController = TextEditingController();
  TextEditingController step7_ampouleAvantDroitStatutsController = TextEditingController();
  TextEditingController step7_clignotantAvantDroitStatutsController = TextEditingController();
  TextEditingController step7_phareArriereDroitStatutsController = TextEditingController();
  TextEditingController step7_phareArriereDroitCommentController = TextEditingController();
  TextEditingController step7_phareArriereDroitImageController = TextEditingController();
  TextEditingController step7_ampouleArriereDroitStatutsController = TextEditingController();
  TextEditingController step7_clignotantArriereDroitStatutsController = TextEditingController();
  TextEditingController step7_phareArriereGaucheStatutsController = TextEditingController();
  TextEditingController step7_phareArriereGaucheCommentController = TextEditingController();
  TextEditingController step7_phareArriereGaucheImageController = TextEditingController();
  TextEditingController step7_ampouleArriereGaucheStatutsController = TextEditingController();
  TextEditingController step7_clignotantArriereGaucheStatutsController = TextEditingController();
  bool isValideChecked18 = false;
  bool isInvalideChecked18 = false;
  bool isNonChecked18 = false;
  FocusNode step7_phareAvantGaucheCommentFocus = FocusNode();
  bool isOuiSelected6 = false;
  bool isNonSelected6 = false;
  bool isOuiSelected7 = false;
  bool isNonSelected7 = false;
  bool isValideChecked19 = false;
  bool isInvalideChecked19 = false;
  bool isNonChecked19 = false;
  FocusNode step7_phareAvantDroitCommentFocus = FocusNode();
  bool isOuiSelected8 = false;
  bool isNonSelected8 = false;
  bool isOuiSelected9 = false;
  bool isNonSelected9 = false;
  bool isValideChecked20 = false;
  bool isInvalideChecked20 = false;
  bool isNonChecked20 = false;
  FocusNode step7_phareArriereDroitCommentFocus = FocusNode();
  bool isOuiSelected10 = false;
  bool isNonSelected10 = false;
  bool isOuiSelected11 = false;
  bool isNonSelected11 = false;
  bool isValideChecked21 = false;
  bool isInvalideChecked21 = false;
  bool isNonChecked21 = false;
  FocusNode step7_phareArriereGaucheCommentFocus = FocusNode();
  bool isOuiSelected12 = false;
  bool isNonSelected12 = false;
  bool isOuiSelected13 = false;
  bool isNonSelected13 = false;
  // Step 8
  Map<String, dynamic> step8 = {
    "pneuAvantDroit" : "correct",
    "pneuAvantGauche":"correct",
    "pneuArriereDroit":"correct",
    "pneuArriereGauche":"correct",
  };
  TextEditingController step8_pneuAvantDroitController = TextEditingController();
  TextEditingController step8_pneuAvantGaucheController = TextEditingController();
  TextEditingController step8_pneuArriereDroitController = TextEditingController();
  TextEditingController step8_pneuArriereGaucheController = TextEditingController();
  // Step 9
  Map<String, dynamic> step9 = {
    "apparenceGeneraleStatuts" : null,
    "siegeAvantGaucheComment":null,
    "siegeAvantGaucheImage":null,
    "siegeAvantDroitComment":null,
    "siegeAvantDroitImage":null,
    "banquetteArriereComment":null,
    "banquetteArriereImage":null,
    "autrePhotosComment":null,
    "autrePhotosImage":null,
    "tableauBordComment":null,
    "tableauBordImage_1":null,
    "tableauBordImage_2":null
  };
  TextEditingController step9_apparenceGeneraleStatutsController = TextEditingController();
  TextEditingController step9_siegeAvantGaucheCommentController = TextEditingController();
  TextEditingController step9_siegeAvantGaucheImageController = TextEditingController();
  TextEditingController step9_siegeAvantDroitCommentController = TextEditingController();
  TextEditingController step9_siegeAvantDroitImageController = TextEditingController();
  TextEditingController step9_banquetteArriereCommentController = TextEditingController();
  TextEditingController step9_banquetteArriereImageController = TextEditingController();
  TextEditingController step9_autrePhotosCommentController = TextEditingController();
  TextEditingController step9_autrePhotosImageController = TextEditingController();
  TextEditingController step9_tableauBordCommentController = TextEditingController();
  TextEditingController step9_tableauBordImage_1Controller = TextEditingController();
  TextEditingController step9_tableauBordImage_2Controller = TextEditingController();
  bool isValideChecked22 = false;
  bool isInvalideChecked22 = false;
  bool isNonChecked22 = false;
  FocusNode step9_siegeAvantGaucheCommentFocus = FocusNode();
  FocusNode step9_siegeAvantDroitCommentFocus = FocusNode();
  FocusNode step9_banquetteArriereCommentFocus = FocusNode();
  FocusNode step9_autrePhotosCommentFocus = FocusNode();
  FocusNode step9_tableauBordCommentFocus = FocusNode();
  // Step 10
  Map<String, dynamic> step10 = {
    "interieurAvisComment" : null,
    "interieurAvisImage":null,
    "interieurAvisImage1" : null,
    "conformeAnnonceStatuts_2":null,
  };
  TextEditingController step10_interieurAvisCommentController = TextEditingController();
  FocusNode step10_interieurAvisCommentFocus = FocusNode();
  TextEditingController step10_interieurAvisImageController = TextEditingController();
  TextEditingController step10_interieurAvisImage1Controller = TextEditingController();
  TextEditingController step10_conformeAnnonceStatuts_2Controller = TextEditingController();
  bool isOuiSelected14 = false;
  bool isNonSelected14 = false;
  // Step 11
  Map<String, dynamic> step11 = {
    "presenceCompteurStatuts" : null,
    "compteurImage_1":null,
    "compteurImage_2":null,
    "airbagStatuts":null,
    "ceinturesStatuts":null,
    "vitresStatuts":null,
    "reglageRetroviseursStatuts":null,
    "enceinteVéhiculesStatuts":null,
    "panneauPortesStatuts":null,
    "panneauCoffreStatuts":null,
    "conformeAnnonceStatuts_3":null,
  };
  TextEditingController step11_presenceCompteurStatutsController = TextEditingController();
  TextEditingController step11_compteurImage_1Controller = TextEditingController();
  TextEditingController step11_compteurImage_2Controller = TextEditingController();
  TextEditingController step11_airbagStatutsController = TextEditingController();
  TextEditingController step11_ceinturesStatutsController = TextEditingController();
  TextEditingController step11_vitresStatutsController = TextEditingController();
  TextEditingController step11_reglageRetroviseursStatutsController = TextEditingController();
  TextEditingController step11_enceinteVehiculesStatutsController = TextEditingController();
  TextEditingController step11_panneauPortesStatutsController = TextEditingController();
  TextEditingController step11_panneauCoffreStatutsController = TextEditingController();
  TextEditingController step11_conformeAnnonceStatuts_3Controller = TextEditingController();
  bool isOuiSelected15 = false;
  bool isNonSelected15 = false;
  bool isOuiSelected16 = false;
  bool isNonSelected16 = false;
  bool isOuiSelected17 = false;
  bool isNonSelected17 = false;
  bool isOuiSelected18 = false;
  bool isNonSelected18 = false;
  bool isOuiSelected19 = false;
  bool isNonSelected19 = false;
  bool isOuiSelected20 = false;
  bool isNonSelected20 = false;
  bool isInvalideChecked23 = false;
  bool isValideChecked23 = false;
  bool isNonChecked23 = false;
  bool isValideChecked24 = false;
  bool isInvalideChecked24 = false;
  bool isNonChecked24 = false;
  bool isOuiSelected25 = false;
  bool isNonSelected25 = false;
  // Step 12
  Map<String, dynamic> step12 = {
    "propreteMoteurStatuts" : null,
    "propreteMoteurImage":null,
    "niveauEauStatuts":null,
    "niveauEauImage":null,
    "niveauHuileStatuts":null,
    "transmissionStatuts":null,
    "avisMoteurComment":null,
    "avisMoteurImage":null,
    "conformeAnnonceStatuts_4":null,
  };
  TextEditingController step12_propreteMoteurStatutsController = TextEditingController();
  TextEditingController step12_propreteMoteurImageController = TextEditingController();
  TextEditingController step12_niveauEauStatutsController = TextEditingController();
  TextEditingController step12_niveauEauImageController = TextEditingController();
  TextEditingController step12_niveauHuileStatutsController = TextEditingController();
  TextEditingController step12_transmissionStatutsController = TextEditingController();
  TextEditingController step12_avisMoteurCommentController = TextEditingController();
  TextEditingController step12_avisMoteurImageController = TextEditingController();
  TextEditingController step12_conformeAnnonceStatuts_4Controller = TextEditingController();
  bool isValideChecked25 = false;
  bool isInvalideChecked25 = false;
  bool isNonChecked25 = false;
  bool isValideChecked26 = false;
  bool isInvalideChecked26 = false;
  bool isNonChecked26 = false;
  bool isValideChecked27 = false;
  bool isInvalideChecked27 = false;
  bool isNonChecked27 = false;
  bool isValideChecked28 = false;
  bool isInvalideChecked28 = false;
  bool isNonChecked28 = false;
  FocusNode step12_avisMoteurCommentFocus = FocusNode();
  bool isOuiSelected21 = false;
  bool isNonSelected21 = false;
  // Step 13
  Map<String, dynamic> step13 = {
    "roueAvantGaucheLeveImage" : null,
    "rotuleTriangleGaucheStatuts":null,
    "rotuleTriangleGaucheImage":null,
    "rotuleBarreStableGaucheStatuts":null,
    "rotuleBarreStableGaucheImage":null,
    "rotuleBilleteDirectionGaucheStatuts":null,
    "rotuleBilleteDirectionGaucheImage":null,
    "roulementGaucheStatuts":null,
    "roulementGaucheImage":null,
    "suspensionGaucheStatuts":null,
    "suspensionGaucheImage":null,
    "disqueGaucheStatuts":null,
    "disqueGaucheImage":null,
    "plaquetteGaucheStatuts":null,
    "plaquetteGaucheImage":null,
    "cardanGaucheStatuts":null,
    "cardanGaucheImage":null,
  };
  TextEditingController step13_roueAvantGaucheLeveImageController = TextEditingController();
  TextEditingController step13_rotuleTriangleGaucheStatutsController = TextEditingController();
  TextEditingController step13_rotuleTriangleGaucheImageController = TextEditingController();
  TextEditingController step13_rotuleBarreStableGaucheStatutsController = TextEditingController();
  TextEditingController step13_rotuleBarreStableGaucheImageController = TextEditingController();
  TextEditingController step13_rotuleBilleteDirectionGaucheStatutsController = TextEditingController();
  TextEditingController step13_rotuleBilleteDirectionGaucheImageController = TextEditingController();
  TextEditingController step13_roulementGaucheStatutsController = TextEditingController();
  TextEditingController step13_roulementGaucheImageController = TextEditingController();
  TextEditingController step13_suspensionGaucheStatutsController = TextEditingController();
  TextEditingController step13_suspensionGaucheImageController = TextEditingController();
  TextEditingController step13_disqueGaucheStatutsController = TextEditingController();
  TextEditingController step13_disqueGaucheImageController = TextEditingController();
  TextEditingController step13_plaquetteGaucheStatutsController = TextEditingController();
  TextEditingController step13_plaquetteGaucheImageController = TextEditingController();
  TextEditingController step13_cardanGaucheStatutsController = TextEditingController();
  TextEditingController step13_cardanGaucheImageController = TextEditingController();
  bool isValideChecked29 = false;
  bool isInvalideChecked29 = false;
  bool isNonChecked29 = false;
  bool isValideChecked30 = false;
  bool isInvalideChecked30 = false;
  bool isNonChecked30 = false;
  bool isValideChecked31 = false;
  bool isInvalideChecked31 = false;
  bool isNonChecked31 = false;
  bool isValideChecked32 = false;
  bool isInvalideChecked32 = false;
  bool isNonChecked32 = false;
  bool isValideChecked33 = false;
  bool isInvalideChecked33 = false;
  bool isNonChecked33 = false;
  bool isValideChecked34 = false;
  bool isInvalideChecked34 = false;
  bool isNonChecked34 = false;
  bool isValideChecked35 = false;
  bool isInvalideChecked35 = false;
  bool isNonChecked35 = false;
  bool isValideChecked36 = false;
  bool isInvalideChecked36 = false;
  bool isNonChecked36 = false;
  bool isValideChecked37 = false;
  bool isInvalideChecked37 = false;
  bool isNonChecked37 = false;
  // Step 14
  Map<String, dynamic> step14 = {
    "roueAvantDroitLeveImage" : null,
    "rotuleTriangleDroitStatuts":null,
    "rotuleTriangleDroitImage":null,
    "rotuleBarreStableDroitStatuts":null,
    "rotuleBarreStableDroitImage":null,
    "rotuleBilleteDirectionDroitStatuts":null,
    "rotuleBilleteDirectionDroitImage":null,
    "roulementDroitStatuts":null,
    "roulementDroitImage":null,
    "suspensionDroitStatuts":null,
    "suspensionDroitImage":null,
    "disqueDroitStatuts":null,
    "disqueDroitImage":null,
    "plaquetteDroitStatuts":null,
    "plaquetteDroitImage":null,
    "cardanDroitStatuts":null,
    "cardanDroitImage":null,
  };
  TextEditingController step14_roueAvantDroitLeveImageController = TextEditingController();
  TextEditingController step14_rotuleTriangleDroitStatutsController = TextEditingController();
  TextEditingController step14_rotuleTriangleDroitImageController = TextEditingController();
  TextEditingController step14_rotuleBarreStableDroitStatutsController = TextEditingController();
  TextEditingController step14_rotuleBarreStableDroitImageController = TextEditingController();
  TextEditingController step14_rotuleBilleteDirectionDroitStatutsController = TextEditingController();
  TextEditingController step14_rotuleBilleteDirectionDroitImageController = TextEditingController();
  TextEditingController step14_roulementDroitStatutsController = TextEditingController();
  TextEditingController step14_roulementDroitImageController = TextEditingController();
  TextEditingController step14_suspensionDroitStatutsController = TextEditingController();
  TextEditingController step14_suspensionDroitImageController = TextEditingController();
  TextEditingController step14_disqueDroitStatutsController = TextEditingController();
  TextEditingController step14_disqueDroitImageController = TextEditingController();
  TextEditingController step14_plaquetteDroitStatutsController = TextEditingController();
  TextEditingController step14_plaquetteDroitImageController = TextEditingController();
  TextEditingController step14_cardanDroitStatutsController = TextEditingController();
  TextEditingController step14_cardanDroitImageController = TextEditingController();
  bool isInvalideChecked38 = false;
  bool isValideChecked38 = false;
  bool isNonChecked38 = false;
  bool isValideChecked39 = false;
  bool isInvalideChecked39 = false;
  bool isNonChecked39 = false;
  bool isValideChecked40 = false;
  bool isInvalideChecked40 = false;
  bool isNonChecked40 = false;
  bool isValideChecked41 = false;
  bool isInvalideChecked41 = false;
  bool isNonChecked41 = false;
  bool isValideChecked42 = false;
  bool isInvalideChecked42 = false;
  bool isNonChecked42 = false;
  bool isValideChecked45 = false;
  bool isInvalideChecked45 = false;
  bool isNonChecked45 = false;
  bool isValideChecked46 = false;
  bool isInvalideChecked46 = false;
  bool isNonChecked46 = false;
  // Step 16
  Map<String, dynamic> step16 = {
    "roueArriereGaucheLeveImage" : null,
    "roulementArriereGaucheStatut":null,
    "roulementArriereGaucheImage":null,
    "suspensionArriereGaucheStatuts":null,
    "suspensionArriereGaucheImage":null,
    "disqueArriereGaucheStatuts":null,
    "disqueArriereGaucheImage":null,
    "plaquetteArriereGaucheStatuts":null,
    "plaquetteArriereGaucheImage":null,
  };

  TextEditingController step16_roueArriereGaucheLeveImageController = TextEditingController();
  TextEditingController step16_roulementArriereGaucheStatutController = TextEditingController();
  TextEditingController step16_roulementArriereGaucheImageController = TextEditingController();
  TextEditingController step16_suspensionArriereGaucheStatutsController = TextEditingController();
  TextEditingController step16_suspensionArriereGaucheImageController = TextEditingController();
  TextEditingController step16_disqueArriereGaucheStatutsController = TextEditingController();
  TextEditingController step16_disqueArriereGaucheImageController = TextEditingController();
  TextEditingController step16_plaquetteArriereGaucheStatutsController = TextEditingController();
  TextEditingController step16_plaquetteArriereGaucheImageController = TextEditingController();
  bool isValideChecked47 = false;
  bool isInvalideChecked47 = false;
  bool isNonChecked47 = false;
  bool isValideChecked48 = false;
  bool isInvalideChecked48 = false;
  bool isNonChecked48 = false;
  bool isValideChecked49 = false;
  bool isInvalideChecked49 = false;
  bool isNonChecked49 = false;
  bool isValideChecked50 = false;
  bool isInvalideChecked50 = false;
  bool isNonChecked50 = false;
  // Step 17
  Map<String, dynamic> step17 = {
    "claquementBruitStatuts" : null,
    "directionStatuts":null,
    "fumeEchapement":null,
    "conformeAnnonceStatuts_4":null,
  };
  TextEditingController step17_claquementBruitStatutsController = TextEditingController();
  TextEditingController step17_directionStatutsController = TextEditingController();
  TextEditingController step17_fumeEchapementController = TextEditingController();
  TextEditingController step17_conformeAnnonceStatuts_4Controller = TextEditingController();
  bool isOuiSelected22 = false;
  bool isNonSelected22 = false;
  bool isValideChecked51 = false;
  bool isInvalideChecked51 = false;
  bool isNonChecked51 = false;
  bool isValideChecked52 = false;
  bool isInvalideChecked52 = false;
  bool isNonChecked52 = false;
  bool isOuiSelected23 = false;
  bool isNonSelected23 = false;
  // Step 18
  Map<String, dynamic> step18 = {
    "avisEtatVehiculeGlobaleImage":null,
  };
  TextEditingController step18_avisEtatVehiculeGlobaleImageController = TextEditingController();
  FocusNode step18_avisEtatVehiculeGlobaleImageFocus = FocusNode();
  // Step 15
  Map<String, dynamic> step15 = {
    "roueArriereDroitLeveImage" : null,
    "roulementArriereDroitStatut":null,
    "roulementArriereDroitImage":null,
    "suspensionArriereDroitStatuts":null,
    "suspensionArriereDroitImage":null,
    "disqueArriereDroitStatuts":null,
    "disqueArriereDroitImage":null,
    "plaquetteArriereDroitStatuts":null,
    "plaquetteArriereDroitImage":null,
  };
  TextEditingController step15_roueArriereDroitLeveImageController = TextEditingController();
  TextEditingController step15_roulementArriereDroitStatutController = TextEditingController();
  TextEditingController step15_roulementArriereDroitImageController = TextEditingController();
  TextEditingController step15_suspensionArriereDroitStatutsController = TextEditingController();
  TextEditingController step15_suspensionArriereDroitImageController = TextEditingController();
  TextEditingController step15_disqueArriereDroitStatutsController = TextEditingController();
  TextEditingController step15_disqueArriereDroitImageController = TextEditingController();
  TextEditingController step15_plaquetteArriereDroitStatutsController = TextEditingController();
  TextEditingController step15_plaquetteArriereDroitImageController = TextEditingController();
  bool isValideChecked53 = false;
  bool isInvalideChecked53 = false;
  bool isNonChecked53 = false;
  bool isValideChecked54 = false;
  bool isInvalideChecked54 = false;
  bool isNonChecked54 = false;
  bool isValideChecked55 = false;
  bool isInvalideChecked55 = false;
  bool isNonChecked55 = false;
  bool isValideChecked56 = false;
  bool isInvalideChecked56 = false;
  bool isNonChecked56 = false;
  Map<String, dynamic> step19 = {
    "achatVehiculStatut" : null
  };
  TextEditingController step19_achatVehiculStatutController = TextEditingController();

  double _currentSlider1Value = 6;
  double _currentSlider2Value = 6;
  double _currentSlider3Value = 6;
  double _currentSlider4Value = 6;
  // all
  int _currentStep = 0;
  // init
  @override
  void initState() {
    super.initState();
    _getFormData();
  }
  _getFormData() async {
    final prefs = await SharedPreferences.getInstance();
    final step1 = decodeObject(prefs , 'Step1');

    setState(() {
      step1MarqueController.text = step1["marque"]  ;
      step1ModeleController.text = step1["modele"];
      step1YearController.text = step1["annee"];
      step1ImmatController.text = step1["kilometrage"];
      step1KilomController.text = step1["immatriculation"];
      step1VinController.text = step1["numeroVin"];
      step1B64CertifImmatController.text = step1["b64CertifImmat"] ;
      step1B64ControleTechController.text = step1["b64ControleTech"] ;
      step1AutreDocCommentairController.text = step1["AutreDocCommentair"] ;
      step1B64AutreDocController.text = step1["b64AutreDoc"];
      step1B64CertifNonGageController.text = step1["b64CertifNonGage"];
      step1B64CarnetEntretController.text = step1["b64CarnetEntret"] ;
    });
  }
  // handle Object str
  decodeObject(prefs, objectStr){
    final objeStr = prefs.getString(objectStr);
    return json.decode(objeStr!);
  }
  void encode(SharedPreferences prefs, Object object, String objName) {
    final objsonStr = json.encode(object);
    prefs.setString(objName, objsonStr);
  }
  // Handle Steps
  Future<void> _nextStep() async {
    if (_currentStep == 18) {
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    if (_currentStep == 0) {
      if(step1MarqueController.text != "" && step1ModeleController.text != "" && step1YearController.text != "" && step1ImmatController.text != "" && step1KilomController.text != "" && step1VinController.text != "" && step1CertifImmatController.text != "" && step1B64CertifNonGageController.text != "" && step1AutreDocCommentairController.text != ""){
        encode(prefs, step1, 'Step1');
      }else{
        showValidationError(context);
        return ;
      }
    }
    if (_currentStep == 1) {
      showEtap2PopUp(context);
      if(step2_pareBriseCommentController.text != "" && step2_pareBriseImageController.text != "" && step2_faceAvantCommentController.text != "" && step2_faceAvantImageController.text != "" && step2_avantDroitCommentController.text != "" && step2_avantDroitImageController.text != "" && step2_avantGaucheCommentController.text != "" && step2_avantGaucheImageController.text != ""){
        encode(prefs, step2, 'Step2');
      }else{
        showValidationError(context);
        return ;
      }
    }
    if (_currentStep == 2) {
      showEtap2PopUp(context);
      if(step3_coteDroitCommentController.text != "" && step3_coteDroitImageController.text != "" && step3_baseCaisseDroitCommentController.text != "" && step3_baseCaisseDroitImageController.text != "" && step3_coteGaucheCommentController.text != "" && step3_coteGaucheImageController.text != "" && step3_baseCaisseGaucheCommentController.text != "" && step3_baseCaisseGaucheImageController.text != ""){
        encode(prefs, step3, 'Step3');
      }else{
        showValidationError(context);
        return ;
      }
    }
    if (_currentStep == 3) {
      if(step4_faceArriereCommentController.text != "" && step4_faceArriereImageController.text != "" && step4_arriereDroitCommentController.text != "" && step4_arriereDroitImageController.text != "" && step4_arriereGaucheCommentController.text != "" && step4_arriereGaucheImageController.text != ""){
        encode(prefs, step5, 'Step5');
      }else{
        showValidationError(context);
        return ;
      }
    }
    if (_currentStep == 4) {
      if(step5_toitCommentController.text != "" && step5_toitImageController.text != "" ){
        encode(prefs, step5, 'Step5');
      }else{
        showValidationError(context);
        return ;
      }
    }
    if (_currentStep == 5) {
      if(step6_janteAvantDroitCommentController.text != "" && step6_janteAvantDroitImageController.text != "" && step6_janteAvantGaucheImageController.text != "" && step6_janteAvantGaucheCommentController.text != "" && step6_janteArriereGaucheCommentController.text != "" && step6_janteArriereGaucheImageController.text != "" && step6_janteArriereDroitCommentController.text != "" && step6_janteArriereDroitImageController.text != "" ){
        encode(prefs, step6, 'Step6');
      }else{
        showValidationError(context);
        return ;
      }
    }
    if (_currentStep == 6) {
      if(step7_phareAvantGaucheCommentController.text != "" && step7_phareAvantGaucheImageController.text != "" && step7_phareAvantDroitCommentController.text != "" && step7_phareAvantDroitImageController.text != "" && step7_phareArriereDroitCommentController.text != "" && step7_phareArriereDroitImageController.text != "" && step7_phareArriereGaucheCommentController.text != "" && step7_phareArriereGaucheImageController.text != "" ){
        encode(prefs, step6, 'Step6');
      }else{
        showValidationError(context);
        return ;
      }
    }
    if (_currentStep == 7) {
        encode(prefs, step8, 'Step8');
    }
    if (_currentStep == 8) {
      if(step9_siegeAvantGaucheCommentController.text != "" && step9_siegeAvantGaucheImageController.text != "" && step9_siegeAvantDroitCommentController.text != "" && step9_siegeAvantDroitImageController.text != "" && step9_banquetteArriereCommentController.text != "" && step9_banquetteArriereImageController.text != "" && step9_autrePhotosCommentController.text != "" && step9_autrePhotosImageController.text != "" && step9_tableauBordCommentController.text != "" && step9_tableauBordImage_1Controller.text != "" ){
        encode(prefs, step9, 'Step9');
      }else{
        showValidationError(context);
        return ;
      }
    }
    if (_currentStep == 9) {
      if(step10_interieurAvisCommentController.text != ""){
        encode(prefs, step10, 'Step10');
      }else{
        showValidationError(context);
        return ;
      }
    }
    if (_currentStep == 10) {
      if(step11_compteurImage_1Controller.text != ""){
        encode(prefs, step11, 'Step11');
      }else{
        showValidationError(context);
        return ;
      }
    }
    if (_currentStep == 11) {
      if(step12_propreteMoteurImageController.text != "" && step12_niveauEauImageController.text != "" ){
        encode(prefs, step12, 'Step12');
      }else{
        showValidationError(context);
        return ;
      }
    }
    if (_currentStep == 12) {
      if(step13_roulementGaucheImageController.text != ""){
        encode(prefs, step13, 'Step13');
      }else{
        showValidationError(context);
        return ;
      }
    }
    if (_currentStep == 13) {
      if(step14_roueAvantDroitLeveImageController.text != ""){
        encode(prefs, step14, 'Step14');
      }else{
        showValidationError(context);
        return ;
      }
    }
    if (_currentStep == 14) {
      if(step15_roueArriereDroitLeveImageController.text != ""){
        encode(prefs, step15, 'Step15');
      }else{
        showValidationError(context);
        return ;
      }
    }
    if (_currentStep == 15) {
      if(step16_roueArriereGaucheLeveImageController.text != ""){
        encode(prefs, step16, 'Step16');
      }else{
        showValidationError(context);
        return ;
      }
    }
    if (_currentStep == 16) {
      encode(prefs, step17, 'Step17');
    }
    if (_currentStep == 17) {
      if(step18_avisEtatVehiculeGlobaleImageController.text != ""){
        encode(prefs, step18, 'Step18');
      }else{
        showValidationError(context);
        return ;
      }
    }

    setState(() {
      _currentStep++;
    });
  }
  void _prevStep() {
    if(_currentStep == 0){
      return ;
    }
    setState(() {
      _currentStep--;
    });
  }
  void showValidationError(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
            content : const SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Center(
                    child : Text('VEUILLEZ REMPLIR TOUT LES CHAMPS OBLIGATOIRES' , style : TextStyle(
                        fontSize : 20 ,
                        color : Colors.red
                    )),
                  ),
                ],
              ),
            ),

        );
      },
    );
  }
  void showCommentPopUp(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title : const Text("ATTENTION!" , style : TextStyle(
            fontSize : 14 ,
           )),
          content : const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Soyez le plus précis possible dans votre explication'),
                Text("Merci de veiller  à ne pas faire de fautes d'ortographes et de pas écrire en abréger" ),
              ],
            ),
          ),
          actions: <Widget>[
            Center (
              child : TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
            ),

          ],

        );
      },
    );
  }
  void showDeFavorablePopUp(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title : const Text("ATTENTION!" , style : TextStyle(
            fontSize : 14 ,
          )),
          content : const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('ETES-VOUS SUR DE DECLARER LE VEHICULE COMME DEFAVORABLE' , style : TextStyle(
                    fontSize : 22,
                )),
                Text("Merci de veiller  à ne pas faire de fautes d'ortographes et de pas écrire en abréger"  , style : TextStyle(
                  fontSize : 12,
                )),
              ],
            ),
          ),
          actions: <Widget>[

                TextButton(
                onPressed: () => Navigator.pop(context, 'Cancel'),
            child: const Text('Cancel'),
            ),
            TextButton(
            onPressed: () => {
              step19_achatVehiculStatutController.text = "defavorable",
              step19["achatVehiculStatut"] = step19_achatVehiculStatutController.text
            },
            child: const Text('OK'))
          ],

        );
      },
    );
  }
  void showFavorablePopUp(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title : const Text("ATTENTION!" , style : TextStyle(
            fontSize : 14 ,
          )),
          content : const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('ETES-VOUS SUR DE DECLARER LE VEHICULE COMME FAVORABLE' , style : TextStyle(
                  fontSize : 22,
                )),
                Text("Merci de veiller  à ne pas faire de fautes d'ortographes et de pas écrire en abréger"  , style : TextStyle(
                  fontSize : 12,
                )),
              ],
            ),
          ),
          actions: <Widget>[

            TextButton(
              onPressed: () => Navigator.pop(context, 'Cancel'),
              child: const Text('Cancel'),
            ),
            TextButton(
                onPressed: () => {
                  step19_achatVehiculStatutController.text = "favorable",
                  step19["achatVehiculStatut"] = step19_achatVehiculStatutController.text
                },
                child: const Text('OK'))
          ],

        );
      },
    );
  }
  void showEtap2PopUp(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title : const Text(""),
          content : const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Expliquez pourquoi le résultat est mauvais ou moyen en commentaire' , style : TextStyle(
                  fontSize : 22,
                )),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(

                  onPressed: () => Navigator.pop(context, 'Cancel'),

                child: const Text('OK'))
          ],

        );
      },
    );
  }
  // Content
  @override
  Widget build(BuildContext context) {
    List<Step> steps =  [
      // 1
      Step(
        title: const Text('') ,
        content: Form(
          key: _formKeys[_currentStep],
          child: Column(
            children: [
              // title
              Center(
                child: Container(
                  width: 250,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.all(20.0),
                      textStyle: const TextStyle(fontSize: 24 , color: Colors.white ),
                    ),
                    onPressed: () =>{},
                    child: const Text('DOCUMENTS' , style: TextStyle(color: Colors.white),),
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              // Progress bar
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 15), // Add margin here
                          child: Text(
                            "Etape 1/18",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 15), // Add margin here
                          child: Text(
                            "Diagnostic",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Center(
                child: Container(
                  width: 800.0, // Adjust the width as needed
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: LinearPercentIndicator(

                      animation: true,
                      backgroundColor: Colors.black,
                      animationDuration: 1000,
                      lineHeight: 10.0,
                      percent: 0.09,
                      barRadius: const Radius.circular(16),
                      //linearStrokeCap: LinearStrokeCap.butt,
                      progressColor: Colors.blue,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              // marque
              Container(
                      margin: const EdgeInsets.symmetric(horizontal: 15),
                    child : Stack(
                      children: [
                        CustomInputValidatore(
                          controller: step1MarqueController,
                          labelText: null,
                          marginContainer: const EdgeInsets.only(bottom: 0, top: 0),
                          width: sizeWidth(context: context),
                          hintText: "Marque", // Remove the space after "Marque"
                          focusNode: step1MarqueFocus,
                          onChanged: (value) {
                            step1["marque"] = value!;
                          },
                        ),
                        const Positioned(
                          right: 10, // Adjust the position of the asterisk as needed
                          bottom: 15, // Adjust the position of the asterisk as needed
                          child: Text(
                            "*",
                            style: TextStyle(
                              color: Colors.red, // Set the color of the asterisk to red
                            ),
                          ),
                        ),
                      ],
                    )
                  ),
              Container(
                margin: const EdgeInsets
                    .symmetric(
                    horizontal: 15),

              ),
              const SizedBox(
                height: 10,
              ),
              // model
              Container(
                    margin: const EdgeInsets.symmetric(horizontal: 15),
                    child: Stack(
                      children: [
                        CustomInputValidatore(
                          controller: step1ModeleController,
                          labelText: null,
                          marginContainer: const EdgeInsets.only(bottom: 0, top: 0),
                          width: sizeWidth(context: context),
                          hintText: "Modèle", // Remove the space after "Marque"
                          focusNode: step1ModeleFocus,
                          onChanged: (value) {
                            step1["modele"] = value!;
                          },
                        ),
                        const Positioned(
                          right: 10, // Adjust the position of the asterisk as needed
                          bottom: 15, // Adjust the position of the asterisk as needed
                          child: Text(
                            "*",
                            style: TextStyle(
                              color: Colors.red, // Set the color of the asterisk to red
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              const SizedBox(
                height: 10,
              ),
              // anne
              Container(
                    margin: const EdgeInsets.symmetric(horizontal: 15),
                    child: Stack(
                      children: [
                        CustomInputValidatore(
                          controller: step1YearController,
                          labelText: null,
                          marginContainer: const EdgeInsets.only(bottom: 0, top: 0),
                          width: sizeWidth(context: context),
                          hintText: "Année", 
                          focusNode: step1YearFocus,
                          onChanged: (value) {
                            step1["annee"] = value!;
                          },
                        ),
                        const Positioned(
                          right: 10, // Adjust the position of the asterisk as needed
                          bottom: 15, // Adjust the position of the asterisk as needed
                          child: Text(
                            "*",
                            style: TextStyle(
                              color: Colors.red, // Set the color of the asterisk to red
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              const SizedBox(
                height: 10,
              ),
              // matriculation
              Container(
                    margin: const EdgeInsets.symmetric(horizontal: 15),
                    child: Stack(
                      children: [
                        CustomInputValidatore(
                          controller: step1ImmatController,
                          labelText: null,
                          marginContainer: const EdgeInsets.only(bottom: 0, top: 0),
                          width: sizeWidth(context: context),
                          hintText: "Numéro de matriculation", // Remove the space after "Marque"
                          focusNode: step1ImmatFocus,
                          onChanged: (value) {
                            step1["immatriculation"] = value!;
                          },
                        ),
                        const Positioned(
                          right: 10, // Adjust the position of the asterisk as needed
                          bottom: 15, // Adjust the position of the asterisk as needed
                          child: Text(
                            "*",
                            style: TextStyle(
                              color: Colors.red, // Set the color of the asterisk to red
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              const SizedBox(
                height: 10,
              ),
              // Kilomètrage
              Container(
                    margin: const EdgeInsets.symmetric(horizontal: 15),
                    child: Stack(
                      children: [
                        CustomInputValidatore(
                          controller: step1KilomController,
                          labelText: null,
                          marginContainer: const EdgeInsets.only(bottom: 0, top: 0),
                          width: sizeWidth(context: context),
                          hintText: "Kilomètrage", // Remove the space after "Marque"
                          focusNode: step1KilomFocus,
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Champ requis';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            step1["kilometrage"] = value!;
                          },
                        ),
                        const Positioned(
                          right: 10, // Adjust the position of the asterisk as needed
                          bottom: 15, // Adjust the position of the asterisk as needed
                          child: Text(
                            "*",
                            style: TextStyle(
                              color: Colors.red, // Set the color of the asterisk to red
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              Container(
                margin: const EdgeInsets
                    .symmetric(
                    horizontal: 15),
              ),
              const SizedBox(
                    height: 10,
                  ),
              // VIN
              Container(
                    margin: const EdgeInsets.symmetric(horizontal: 15),
                    child: Stack(
                      children: [
                        CustomInputValidatore(
                          controller: step1VinController,
                          labelText: null,
                          marginContainer: const EdgeInsets.only(bottom: 0, top: 0),
                          width: sizeWidth(context: context),
                          hintText: "Numéro de VIN", // Remove the space after "Marque"
                          focusNode: step1VinFocus,
                          onChanged: (value) {
                            step1["numeroVin"] = value!;
                          },
                        ),
                        const Positioned(
                          right: 10, // Adjust the position of the asterisk as needed
                          bottom: 15, // Adjust the position of the asterisk as needed
                          child: Text(
                            "*",
                            style: TextStyle(
                              color: Colors.red, // Set the color of the asterisk to red
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              const SizedBox(
                    height: 80,
                  ),
              // Certificat d'immat
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children : [
                          Text(
                            "Certificat d'immatriculation",
                            style: gothicBold.copyWith(fontSize: 18),
                          ),
                        ]
                      )
                    ),
                    SizedBox(width: 10),
                    SizedBox(
                      height: 30,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 70, // Set the width here
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  isOuiSelected = true;
                                  isNonSelected = false;
                                });
                                step1CertifImmatController.text = "oui";
                                step1["CertifImmat"] = step1CertifImmatController.text;
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    isOuiSelected ? Colors.grey[900] : Colors.grey),
                              ),
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: Text(
                                  "Oui",
                                  style: gothicBold.copyWith(
                                      fontSize: 12, color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: 80, // Set the width here
                            margin: const EdgeInsets.symmetric(horizontal: 0),
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  isOuiSelected = false;
                                  isNonSelected = true;
                                });
                                step1CertifImmatController.text = "non";
                                step1["CertifImmat"] = step1CertifImmatController.text;
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    isNonSelected ? Colors.grey[900] : Colors.grey),
                              ),
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: Text(
                                  "Non",
                                  style: gothicBold.copyWith(
                                      fontSize: 12, color: Colors.white),
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
              Container(
                margin: const EdgeInsets.symmetric(vertical: 30 , horizontal: 15),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 150,
                        child: ElevatedButton(
                          onPressed: () async {
                            final ImagePicker picker = ImagePicker();
                            final XFile? imgFile = await picker.pickImage(source: ImageSource.gallery);
                            try {
                              if (imgFile != null) {
                                String base64Image = base64Encode(await imgFile.readAsBytes()!);
                            step1B64CertifImmatController.text = base64Image;
                            step1["b64CertifImmat"] = step1B64CertifImmatController.text;
                            }
                            } catch (e) {
                            // print(e.toString());
                            }
                          },
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload,
                                size: 36,
                                color: Colors.black,
                              ),
                              SizedBox(height: 10),
                              Text(
                                "Importer votre photo",
                                style: TextStyle(fontSize: 18, color: Colors.black),
                              ),

                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Certificat non gage
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Certificat non gage",
                        style:
                        gothicBold.copyWith(
                            fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 30 , horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        height: 150,
                        child: ElevatedButton(
                          onPressed: () async{
                            final ImagePicker picker = ImagePicker();
                            final XFile? imgFile = await picker.pickImage(source: ImageSource.gallery);
                            try {
                              if (imgFile != null) {
                                String base64Image = base64Encode(await imgFile.readAsBytes()!);
                            step1B64CertifNonGageController.text = base64Image;
                            step1["b64CertifNonGage"] = step1B64CertifNonGageController.text;
                            }
                            } catch (e) {
                            // print(e.toString());
                            }
                          },
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload,
                                size: 36,
                                color: Colors.black,
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Importer votre photo",
                                    style: TextStyle(fontSize: 18, color: Colors.black),
                                  ),
                                  Text(
                                    "  *",
                                    style: TextStyle(fontSize: 18, color: Colors.red),
                                  ),
                                ],
                              )

                            ],
                          ),
                        ),
                      ),
                    ),
                    // Add the second element here
                  ],
                ),
              ),
              // Contrôle Technique
              Container(
                margin: const EdgeInsets.symmetric(horizontal:15),
                child: Row(
                  children: [
                    SizedBox(
                      child: Row(
                        children : [
                          Text(
                            "Contrôle Technique",
                            style: gothicBold.copyWith(fontSize: 18),
                          ),
                        ]
                      )
                    ),
                    SizedBox(width: 5),
                    SizedBox(
                      height: 30,
                      child : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 90, // Set the width here
                            margin: const EdgeInsets.symmetric(horizontal: 0),
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  isValideChecked = !isValideChecked;
                                  isInvalideChecked = false;
                                  isNonChecked = false;
                                });
                                step1ControleTechController.text = "valid";
                                step1["controleTech"] = step1ControleTechController.text;
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                  isValideChecked ? Colors.grey[900] : Colors.grey,
                                ),
                              ),
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child:  Text(
                                  "VALIDE",
                                  style: gothicBold.copyWith(
                                      fontSize: 12, color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: 100, // Set the width here
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  isInvalideChecked = !isInvalideChecked;
                                  isValideChecked = false;
                                  isNonChecked = false;
                                });
                                step1ControleTechController.text = "invalid";
                                step1["controleTech"] = step1ControleTechController.text;
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                  isInvalideChecked ? Colors.grey[900] : Colors.grey,
                                ),
                              ),
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child:  Text(
                                  "Invalide",
                                  style: gothicBold.copyWith(
                                      fontSize: 12, color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: 80, // Set the width here
                            margin: const EdgeInsets.symmetric(horizontal: 0),
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  isNonChecked = !isNonChecked;
                                  isValideChecked = false;
                                  isInvalideChecked = false;
                                });
                                step1ControleTechController.text = "non";
                                step1["controleTech"] = step1ControleTechController.text;
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                  isNonChecked ? Colors.grey[900] : Colors.grey,
                                ),
                              ),
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child:  Text(
                                  "Non",
                                  style: gothicBold.copyWith(
                                      fontSize: 12, color: Colors.white),
                                ),
                              ),
                            ),
                          )
                        ],
                      )
                    )
                ]),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15 , vertical: 30 ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 150,
                        child: ElevatedButton(
                          onPressed: () async {
                            final ImagePicker picker = ImagePicker();
                            final XFile? imgFile = await picker.pickImage(source: ImageSource.gallery);
                            try {
                              if (imgFile != null) {
                                String base64Image = base64Encode(await imgFile.readAsBytes()!);
                            step1B64ControleTechController.text = base64Image;
                            step1["b64ControleTech"] = step1B64ControleTechController.text;
                            }
                            } catch (e) {
                            // print(e.toString());
                            } // Open the file picker when the button is pressed
                          },
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload, // Add your upload icon here
                                size: 36,
                                color: Colors.black,
                              ),
                              SizedBox(height: 10), // Add some spacing between icon and text
                              Text(
                                "Importer votre photo",
                                style: TextStyle(fontSize: 18, color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Carnet d’entretien
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                      children : [
                        Text(
                          "Carnet d’entretien",
                          style: gothicBold.copyWith(fontSize: 18),
                        ),
                      ]
                    )
                    ),

                    SizedBox(width: 10),

                    SizedBox(
                      height: 30,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 70, // Set the width here
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  isOuiSelected1 = true;
                                  isNonSelected1 = false;
                                });
                                step1CarnetEntretController.text = "oui";
                                step1["carnetEntret"] = step1CarnetEntretController.text;
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    isOuiSelected1 ? Colors.grey[900] : Colors.grey),
                              ),
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: Text(
                                  "Oui",
                                  style: gothicBold.copyWith(
                                      fontSize: 12, color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: 80, // Set the width here
                            margin: const EdgeInsets.symmetric(horizontal: 0),
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  isOuiSelected1 = false;
                                  isNonSelected1 = true;
                                });
                                step1CarnetEntretController.text = "non";
                                step1["carnetEntret"] = step1CarnetEntretController.text;
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    isNonSelected1 ? Colors.grey[900] : Colors.grey),
                              ),
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: Text(
                                  "Non",
                                  style: gothicBold.copyWith(
                                      fontSize: 12, color: Colors.white),
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
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15 , vertical: 30 ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 150,
                        child: ElevatedButton(
                          onPressed: () async {
                            final ImagePicker picker = ImagePicker();
                            final XFile? imgFile = await picker.pickImage(source: ImageSource.gallery);
                            try {
                              if (imgFile != null) {
                                String base64Image = base64Encode(await imgFile.readAsBytes()!);
                            step1B64CarnetEntretController.text = base64Image;
                            step1["b64CarnetEntret"] = step1B64CarnetEntretController.text;
                            }
                            } catch (e) {
                            // print(e.toString());
                            }
                          },
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload, // Add your upload icon here
                                size: 36,
                                color: Colors.black,
                              ),
                              SizedBox(height: 10), // Add some spacing between icon and text
                              Text(
                                "Importer votre photo",
                                style: TextStyle(fontSize: 18, color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Autre documents ?
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Autre documents ?",
                        style:
                        gothicBold.copyWith(
                            fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15),
                child: SizedBox(
                  height: 50, // Set your desired height here
                  child: CustomInputValidatore(
                    controller: step1AutreDocCommentairController,
                    labelText: null,
                    onChanged: (value) {
                      step1["AutreDocCommentair"] = value!;
                    },
                    marginContainer: const EdgeInsets.only(bottom: 0, top: 0),
                    width: sizeWidth(context: context),
                    hintText: "Ecriver un commentaire ... *",
                    focusNode: step1AutreDocCommentairFocus,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15 , vertical: 30 ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(

                        height: 150,
                        child: ElevatedButton(
                          onPressed: () async {
                            final ImagePicker picker = ImagePicker();
                            final XFile? imgFile = await picker.pickImage(source: ImageSource.gallery);
                            try {
                              if (imgFile != null) {
                                String base64Image = base64Encode(await imgFile.readAsBytes()!);
                                step1B64AutreDocController.text = base64Image;
                                step1["b64AutreDoc"] = step1B64AutreDocController.text;
                              }
                            } catch (e) {
                              // print(e.toString());
                            }
                          },
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload, // Add your upload icon here
                                size: 36,
                                color: Colors.black,
                              ),
                              SizedBox(height: 10), // Add some spacing between icon and text
                              Text(
                                "Importer votre photo",
                                style: TextStyle(fontSize: 18, color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        isActive: _currentStep == 0,
      ),
      // 2
      Step(
        title: const Text('Extérieur avant'),
        content: Form(
          key: _formKeys[1],
          child: Column(
            children: [
              // title
              Center(
                child: Container(
                  width: 250,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.all(20.0),
                      textStyle: const TextStyle(fontSize: 24 , color: Colors.white ),
                    ),
                    onPressed: () =>{},
                    child: const Text('Extérieur avant' , style: TextStyle(color: Colors.white),),
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              // Progress bar
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 15), // Add margin here
                          child: Text(
                            "Etape 2/18",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 15), // Add margin here
                          child: Text(
                            "Diagnostic",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Center(
                child: Container(
                  width: 800.0, // Adjust the width as needed
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: LinearPercentIndicator(

                      animation: true,
                      backgroundColor: Colors.black,
                      animationDuration: 1000,
                      lineHeight: 10.0,
                      percent: 0.10,
                      barRadius: const Radius.circular(16),
                      //linearStrokeCap: LinearStrokeCap.butt,
                      progressColor: Colors.blue,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              // Essuie Glace Avant
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15 ,vertical: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      child: Text(
                        "Essuie Glace Avant",
                        style: gothicBold.copyWith(fontSize: 18),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 120, // Set the width here
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  isOuiSelected2 = true;
                                  isNonSelected2 = false;
                                });
                                step2_essuieGlaceAvantStatutsController.text = "mauvais";
                                step2["essuieGlaceAvantStatuts"] = step2_essuieGlaceAvantStatutsController.text;
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    isOuiSelected2 ? Colors.grey[900] : Colors.grey),
                              ),
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: Text(
                                  "MAUVAIS",
                                  style: gothicBold.copyWith(
                                      fontSize: 12, color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: 80, // Set the width here
                            margin: const EdgeInsets.symmetric(horizontal: 0),
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  isOuiSelected2 = false;
                                  isNonSelected2 = true;
                                });
                                step2_essuieGlaceAvantStatutsController.text = "bon";
                                step2["essuieGlaceAvantStatuts"] = step2_essuieGlaceAvantStatutsController.text;
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    isNonSelected2 ? Colors.grey[900] : Colors.grey),
                              ),
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: Text(
                                  "BON",
                                  style: gothicBold.copyWith(
                                      fontSize: 12, color: Colors.white),
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
              // Pare Brise
              Container(
                margin: const EdgeInsets.symmetric(horizontal:15),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        child: Text(
                          "Pare Brise",
                          style: gothicBold.copyWith(fontSize: 18),
                        ),
                      ),
                      SizedBox(
                          height: 30,
                          child : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 120, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isValideChecked2 = !isValideChecked2;
                                      isInvalideChecked2 = false;
                                      isNonChecked2 = false;
                                    });
                                    step2_pareBriseStatutsController.text = "mauvais";
                                    step2["pareBriseStatuts"] = step2_pareBriseStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isValideChecked2 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "MAUVAIS",
                                      style: gothicBold.copyWith(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 100, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 5),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isInvalideChecked2 = !isInvalideChecked2;
                                      isValideChecked2 = false;
                                      isNonChecked2 = false;
                                    });
                                    step2_pareBriseStatutsController.text = "moyen";
                                    step2["pareBriseStatuts"] = step2_pareBriseStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isInvalideChecked2 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "MOYEN",
                                      style: gothicBold.copyWith(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 80, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isNonChecked2 = !isNonChecked2;
                                      isValideChecked2 = false;
                                      isInvalideChecked2 = false;
                                    });
                                    step2_pareBriseStatutsController.text = "bon";
                                    step2["pareBriseStatuts"] = step2_pareBriseStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isNonChecked2 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "BON",
                                      style: gothicBold.copyWith(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )
                      )
                    ]),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15 , vertical: 15),
                child: SizedBox(
                  height: 50, // Set your desired height here
                  child: CustomInputValidatore(
                    controller: step2_pareBriseCommentController,
                    labelText: null,
                    onChanged: (value) {
                      step2["pareBriseComment"] = value!;
                    },
                    marginContainer: const EdgeInsets.only(bottom: 0, top: 0),
                    width: sizeWidth(context: context),
                    hintText: "Ecriver un commentaire ... *",
                    focusNode: step2_pareBriseCommentFocus,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 15 , horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        height: 150,
                        child: ElevatedButton(
                          onPressed: () async{
                            final ImagePicker picker = ImagePicker();
                            final XFile? imgFile = await picker.pickImage(source: ImageSource.gallery);
                            try {
                              if (imgFile != null) {
                                String base64Image = base64Encode(await imgFile.readAsBytes()!);
                                step2_pareBriseImageController.text = base64Image;
                                step2["pareBriseImage"] = step2_pareBriseImageController.text;
                              }
                            } catch (e) {
                              // print(e.toString());
                            }
                          },
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload,
                                size: 36,
                                color: Colors.black,
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Importer votre photo",
                                    style: TextStyle(fontSize: 18, color: Colors.black),
                                  ),
                                  Text(
                                    "  *",
                                    style: TextStyle(fontSize: 18, color: Colors.red),
                                  ),
                                ],
                              )

                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15,

                    ),
                  ],
                ),
              ),
              // Face Avant
              Container(
                margin: const EdgeInsets.symmetric(horizontal:15),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        child: Text(
                          "Face Avant",
                          style: gothicBold.copyWith(fontSize: 18),
                        ),
                      ),

                      SizedBox(
                          height: 30,
                          child : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 120, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isValideChecked3 = !isValideChecked3;
                                      isInvalideChecked3 = false;
                                      isNonChecked3 = false;
                                    });
                                    step2_faceAvantStatutsController.text = "mauvais";
                                    step2["faceAvantStatuts"] = step2_faceAvantStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isValideChecked3 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "MAUVAIS",
                                      style: gothicBold.copyWith(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 100, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 5),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isInvalideChecked3 = !isInvalideChecked3;
                                      isValideChecked3 = false;
                                      isNonChecked3 = false;
                                    });
                                    step2_faceAvantStatutsController.text = "moyen";
                                    step2["faceAvantStatuts"] = step2_faceAvantStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isInvalideChecked3 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "MOYEN",
                                      style: gothicBold.copyWith(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 80, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isNonChecked3 = !isNonChecked3;
                                      isValideChecked3 = false;
                                      isInvalideChecked3 = false;
                                    });
                                    step2_faceAvantStatutsController.text = "bon";
                                    step2["faceAvantStatuts"] = step2_faceAvantStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isNonChecked3 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "BON",
                                      style: gothicBold.copyWith(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )
                      )
                    ]),

              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15 , vertical: 15),
                child: SizedBox(
                  height: 50, // Set your desired height here
                  child: CustomInputValidatore(
                    controller: step2_faceAvantCommentController,
                    labelText: null,
                    onChanged: (value) {
                      step2["faceAvantComment"] = value!;
                    },
                    marginContainer: const EdgeInsets.only(bottom: 0, top: 0),
                    width: sizeWidth(context: context),
                    hintText: "Ecriver un commentaire ... *",
                    focusNode: step2_faceAvantCommentFocus,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 15 , horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        height: 150,
                        width : 300 ,
                        child: ElevatedButton(
                          onPressed: () async{
                            final ImagePicker picker = ImagePicker();
                            final XFile? imgFile = await picker.pickImage(source: ImageSource.gallery);
                            try {
                              if (imgFile != null) {
                                String base64Image = base64Encode(await imgFile.readAsBytes()!);
                                step2_faceAvantImageController.text = base64Image;
                                step2["faceAvantImage"] = step2_faceAvantImageController.text;
                              }
                            } catch (e) {
                              // print(e.toString());
                            }
                          },
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload,
                                size: 36,
                                color: Colors.black,
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Importer votre photo",
                                    style: TextStyle(fontSize: 18, color: Colors.black),
                                  ),
                                  Text(
                                    "  *",
                                    style: TextStyle(fontSize: 18, color: Colors.red),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                        padding: const EdgeInsets.all(10.0),
                        child : Image.asset("assets/images/face_avant.png")
                    ),
                  ],
                ),
              ),
              // 3/4 Avant Droit
              Container(
                margin: const EdgeInsets.symmetric(horizontal:15),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        child: Text(
                          "3/4 Avant Droit",
                          style: gothicBold.copyWith(fontSize: 18),
                        ),
                      ),
                      SizedBox(
                          height: 30,
                          child : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 120, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isValideChecked4 = !isValideChecked4;
                                      isInvalideChecked4 = false;
                                      isNonChecked4 = false;
                                    });
                                    step2_avantDroitStatutsController.text = "mauvais";
                                    step2["avantDroitStatuts"] = step2_avantDroitStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isValideChecked4 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "MAUVAIS",
                                      style: gothicBold.copyWith(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 100, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 5),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isInvalideChecked4 = !isInvalideChecked4;
                                      isValideChecked4 = false;
                                      isNonChecked4 = false;
                                    });
                                    step2_avantDroitStatutsController.text = "moyen";
                                    step2["avantDroitStatuts"] = step2_avantDroitStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isInvalideChecked4 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "MOYEN",
                                      style: gothicBold.copyWith(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 80, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isNonChecked4 = !isNonChecked4;
                                      isValideChecked4 = false;
                                      isInvalideChecked4 = false;
                                    });
                                    step2_avantDroitStatutsController.text = "bon";
                                    step2["avantDroitStatuts"] = step2_avantDroitStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isNonChecked4 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "BON",
                                      style: gothicBold.copyWith(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )
                      )
                    ]),

              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15 , vertical: 15),
                child: SizedBox(
                  height: 50, // Set your desired height here
                  child: CustomInputValidatore(
                    controller: step2_avantDroitCommentController,
                    labelText: null,

                    onChanged: (value) {
                      step2["avantDroitComment"] = value!;
                    },
                    marginContainer: const EdgeInsets.only(bottom: 0, top: 0),
                    width: sizeWidth(context: context),
                    hintText: "Ecriver un commentaire ...  *",
                    focusNode: step2_avantDroitCommentFocus,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 15 , horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        height: 150,
                        child: ElevatedButton(
                          onPressed: () async{
                            final ImagePicker picker = ImagePicker();
                            final XFile? imgFile = await picker.pickImage(source: ImageSource.gallery);
                            try {
                              if (imgFile != null) {
                                String base64Image = base64Encode(await imgFile.readAsBytes()!);
                                step2_avantDroitImageController.text = base64Image;
                                step2["avantDroitImage"] = step2_avantDroitImageController.text;
                              }
                            } catch (e) {
                              // print(e.toString());
                            }
                          },
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload,
                                size: 36,
                                color: Colors.black,
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Importer votre photo",
                                    style: TextStyle(fontSize: 18, color: Colors.black),
                                  ),
                                  Text(
                                    "  *",
                                    style: TextStyle(fontSize: 18, color: Colors.red),
                                  ),
                                ],
                              )

                            ],
                          ),
                        ),
                      ),
                    ),

                    Container(
                      padding: const EdgeInsets.all(10.0),
                      child : Image.asset("assets/images/avant_droit.png"),
                    ),

                  ],
                ),
              ),
              // 3/4 Avant Gauche
              Container(
                margin: const EdgeInsets.symmetric(horizontal:15),

                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        child: Text(
                          "3/4 Avant Gauche",
                          style: gothicBold.copyWith(fontSize: 18),
                        ),
                      ),

                      SizedBox(
                          height: 30,
                          child : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 105,                         margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isValideChecked5 = !isValideChecked5;
                                      isInvalideChecked5 = false;
                                      isNonChecked5 = false;
                                    });
                                    step2_avantGaucheStatutsController.text = "mauvais";
                                    step2["avantGaucheStatuts"] = step2_avantGaucheStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isValideChecked5 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "MAUVAIS",
                                      style: gothicBold.copyWith(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 95, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 5),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isInvalideChecked5 = !isInvalideChecked5;
                                      isValideChecked5 = false;
                                      isNonChecked5 = false;
                                    });
                                    step2_avantGaucheStatutsController.text = "moyen";
                                    step2["avantGaucheStatuts"] = step2_avantGaucheStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isInvalideChecked5 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "MOYEN",
                                      style: gothicBold.copyWith(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 80, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isNonChecked5 = !isNonChecked5;
                                      isValideChecked5 = false;
                                      isInvalideChecked5 = false;
                                    });
                                    step2_avantGaucheStatutsController.text = "bon";
                                    step2["avantGaucheStatuts"] = step2_avantGaucheStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isNonChecked5 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "BON",
                                      style: gothicBold.copyWith(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )
                      )
                    ]),

              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15 , vertical: 15),
                child: SizedBox(
                  height: 50, // Set your desired height here
                  child: CustomInputValidatore(
                    controller: step2_avantGaucheCommentController,
                    labelText: null,

                    onChanged: (value) {
                      step2["avantGaucheComment"] = value!;
                    },
                    marginContainer: const EdgeInsets.only(bottom: 0, top: 0),
                    width: sizeWidth(context: context),
                    hintText: "Ecriver un commentaire ... *",
                    focusNode: step2_avantGaucheCommentFocus,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 15 , horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        height: 150,
                        child: ElevatedButton(
                          onPressed: () async{
                            final ImagePicker picker = ImagePicker();
                            final XFile? imgFile = await picker.pickImage(source: ImageSource.gallery);
                            try {
                              if (imgFile != null) {
                                String base64Image = base64Encode(await imgFile.readAsBytes()!);
                                step2_avantGaucheImageController.text = base64Image;
                                step2["avantGaucheImage"] = step2_avantGaucheImageController.text;
                              }
                            } catch (e) {
                              // print(e.toString());
                            }
                          },
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload,
                                size: 36,
                                color: Colors.black,
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Importer votre photo",
                                    style: TextStyle(fontSize: 18, color: Colors.black),
                                  ),
                                  Text(
                                    "  *",
                                    style: TextStyle(fontSize: 18, color: Colors.red),
                                  ),
                                ],
                              )

                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(10.0),
                        child : Image.asset("assets/images/avant_gauche.png"),
                      ),

                  ],
                ),
              ),
            ],
          ),
        ),
        isActive: _currentStep == 1,
      ),
      // 3
      Step(
        title: const Text('Côtés'),
        content: Form(
          key: _formKeys[2],
          child: Column(
            children: [
              // title
              Center(
                child: Container(
                  width: 250,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.all(20.0),
                      textStyle: const TextStyle(fontSize: 24 , color: Colors.white ),
                    ),
                    onPressed: () =>{},
                    child: const Text('Côtés' , style: TextStyle(color: Colors.white),),
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              // Progress bar
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 15), // Add margin here
                          child: Text(
                            "Etape 3/18",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 15), // Add margin here
                          child: Text(
                            "Diagnostic",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Center(
                child: Container(
                  width: 800.0, // Adjust the width as needed
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: LinearPercentIndicator(

                      animation: true,
                      backgroundColor: Colors.black,
                      animationDuration: 1000,
                      lineHeight: 10.0,
                      percent: 0.15,
                      barRadius: const Radius.circular(16),
                      //linearStrokeCap: LinearStrokeCap.butt,
                      progressColor: Colors.blue,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              // Coté droit
              Container(
                margin: const EdgeInsets.symmetric(horizontal:15),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        child: Text(
                          "Coté droit",
                          style: gothicBold.copyWith(fontSize: 18),
                        ),
                      ),
                      SizedBox(
                          height: 30,
                          child : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 120, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isValideChecked6 = !isValideChecked6;
                                      isInvalideChecked6 = false;
                                      isNonChecked6 = false;
                                    });
                                    step3_coteDroitStatutsController.text = "mauvais";
                                    step3["coteDroitStatuts"] = step3_coteDroitStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isValideChecked6 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "MAUVAIS",
                                      style: gothicBold.copyWith(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 100, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 5),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isInvalideChecked6 = !isInvalideChecked6;
                                      isValideChecked6 = false;
                                      isNonChecked6 = false;
                                    });
                                    step3_coteDroitStatutsController.text = "moyen";
                                    step3["coteDroitStatuts"] = step3_coteDroitStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isInvalideChecked6 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "MOYEN",
                                      style: gothicBold.copyWith(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 80, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isNonChecked6 = !isNonChecked6;
                                      isValideChecked6 = false;
                                      isInvalideChecked6 = false;
                                    });
                                    step3_coteDroitStatutsController.text = "bon";
                                    step3["coteDroitStatuts"] = step3_coteDroitStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isNonChecked6 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "BON",
                                      style: gothicBold.copyWith(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )
                      )
                    ]),

              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15 , vertical: 15),
                child: SizedBox(
                  height: 50, // Set your desired height here
                  child: CustomInputValidatore(
                    controller: step3_coteDroitCommentController,
                    labelText: null,

                    onChanged: (value) {
                      step3["coteDroitComment"] = value!;
                    },
                    marginContainer: const EdgeInsets.only(bottom: 0, top: 0),
                    width: sizeWidth(context: context),
                    hintText: "Ecriver un commentaire ... *",
                    focusNode: step3_coteDroitCommentFocus,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 15 , horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        height: 150,
                        child: ElevatedButton(
                          onPressed: () async{
                            final ImagePicker picker = ImagePicker();
                            final XFile? imgFile = await picker.pickImage(source: ImageSource.gallery);
                            try {
                              if (imgFile != null) {
                                String base64Image = base64Encode(await imgFile.readAsBytes()!);
                                step3_coteDroitImageController.text = base64Image;
                                step3["coteDroitImage"] = step3_coteDroitImageController.text;
                              }
                            } catch (e) {
                              // print(e.toString());
                            }
                          },
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload,
                                size: 36,
                                color: Colors.black,
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Importer votre photo",
                                    style: TextStyle(fontSize: 18, color: Colors.black),
                                  ),
                                  Text(
                                    "  *",
                                    style: TextStyle(fontSize: 18, color: Colors.red),
                                  ),
                                ],
                              )

                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(10.0),
                        child : Image.asset("assets/images/coteDroit.png"),
                      ),
                  ],
                ),
              ),
              // Bas de caisse Droit
              Container(
                margin: const EdgeInsets.symmetric(horizontal:15),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(

                        child: Text(
                          "Bas de caisse Droit",
                          style: gothicBold.copyWith(fontSize: 15),
                        ),
                      ),

                      SizedBox(
                          height: 30,
                          child : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 120, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isValideChecked7 = !isValideChecked7;
                                      isInvalideChecked7 = false;
                                      isNonChecked7 = false;
                                    });
                                    step3_baseCaisseDroitStatutsController.text = "mauvais";
                                    step3["baseCaisseDroitStatuts"] = step3_baseCaisseDroitStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isValideChecked7 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "MAUVAIS",
                                      style: gothicBold.copyWith(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 100, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 5),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isInvalideChecked7 = !isInvalideChecked7;
                                      isValideChecked7 = false;
                                      isNonChecked7 = false;
                                    });
                                    step3_baseCaisseDroitStatutsController.text = "moyen";
                                    step3["baseCaisseDroitStatuts"] = step3_baseCaisseDroitStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isInvalideChecked7 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "MOYEN",
                                      style: gothicBold.copyWith(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 80, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isNonChecked7 = !isNonChecked7;
                                      isValideChecked7 = false;
                                      isInvalideChecked7 = false;
                                    });
                                    step3_baseCaisseDroitStatutsController.text = "bon";
                                    step3["baseCaisseDroitStatuts"] = step3_baseCaisseDroitStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isNonChecked7 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "BON",
                                      style: gothicBold.copyWith(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )
                      )
                    ]),

              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15 , vertical: 15),
                child: SizedBox(
                  height: 50, // Set your desired height here
                  child: CustomInputValidatore(
                    controller: step3_baseCaisseDroitCommentController,
                    labelText: null,
                    onChanged: (value) {
                      step3["baseCaisseDroitComment"] = value!;
                    },
                    marginContainer: const EdgeInsets.only(bottom: 0, top: 0),
                    width: sizeWidth(context: context),
                    hintText: "Ecriver un commentaire ... *",
                    focusNode: step3_baseCaisseDroitCommentFocus,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 15 , horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        height: 150,
                        child: ElevatedButton(
                          onPressed: () async{
                            final ImagePicker picker = ImagePicker();
                            final XFile? imgFile = await picker.pickImage(source: ImageSource.gallery);
                            try {
                              if (imgFile != null) {
                                String base64Image = base64Encode(await imgFile.readAsBytes()!);
                                step3_baseCaisseDroitImageController.text = base64Image;
                                step3["baseCaisseDroitImage"] = step3_baseCaisseDroitImageController.text;
                              }
                            } catch (e) {
                              // print(e.toString());
                            }
                          },
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload,
                                size: 36,
                                color: Colors.black,
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Importer votre photo",
                                    style: TextStyle(fontSize: 18, color: Colors.black),
                                  ),
                                  Text(
                                    "  *",
                                    style: TextStyle(fontSize: 18, color: Colors.red),
                                  ),
                                ],
                              )

                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(10.0),
                        child : Image.asset("assets/images/basCaisseDroit.png"),
                      ),

                  ],
                ),
              ),
              // Côté gauche
              Container(
                margin: const EdgeInsets.symmetric(horizontal:15),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        child: Text(
                          "Côté gauche",
                          style: gothicBold.copyWith(fontSize: 18),
                        ),
                      ),

                      SizedBox(
                          height: 30,
                          child : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 120, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isValideChecked8 = !isValideChecked8;
                                      isInvalideChecked8 = false;
                                      isNonChecked8 = false;
                                    });
                                    step3_coteGaucheStatutsController.text = "mauvais";
                                    step3["coteGaucheStatuts"] = step3_coteGaucheStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isValideChecked8 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "MAUVAIS",
                                      style: gothicBold.copyWith(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 100, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 5),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isInvalideChecked8 = !isInvalideChecked8;
                                      isValideChecked8 = false;
                                      isNonChecked8 = false;
                                    });
                                    step3_coteGaucheStatutsController.text = "moyen";
                                    step3["coteGaucheStatuts"] = step3_coteGaucheStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isInvalideChecked8 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "MOYEN",
                                      style: gothicBold.copyWith(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 80, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isNonChecked8 = !isNonChecked8;
                                      isValideChecked8 = false;
                                      isInvalideChecked8 = false;
                                    });
                                    step3_coteGaucheStatutsController.text = "bon";
                                    step3["coteGaucheStatuts"] = step3_coteGaucheStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isNonChecked8 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "BON",
                                      style: gothicBold.copyWith(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )
                      )
                    ]),

              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15 , vertical: 15),
                child: SizedBox(
                  height: 50, // Set your desired height here
                  child: CustomInputValidatore(
                    controller: step3_coteGaucheCommentController,
                    labelText: null,

                    onChanged: (value) {
                      step3["coteGaucheComment"] = value!;
                    },
                    marginContainer: const EdgeInsets.only(bottom: 0, top: 0),
                    width: sizeWidth(context: context),
                    hintText: "Ecriver un commentaire ... *",
                    focusNode: step3_coteGaucheCommentFocus,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 15 , horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        height: 150,
                        child: ElevatedButton(
                          onPressed: () async{
                            final ImagePicker picker = ImagePicker();
                            final XFile? imgFile = await picker.pickImage(source: ImageSource.gallery);
                            try {
                              if (imgFile != null) {
                                String base64Image = base64Encode(await imgFile.readAsBytes()!);
                                step3_coteGaucheImageController.text = base64Image;
                                step3["coteGaucheImage"] = step3_coteGaucheImageController.text;
                              }
                            } catch (e) {
                              // print(e.toString());
                            }
                          },
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload,
                                size: 36,
                                color: Colors.black,
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Importer votre photo",
                                    style: TextStyle(fontSize: 18, color: Colors.black),
                                  ),
                                  Text(
                                    "  *",
                                    style: TextStyle(fontSize: 18, color: Colors.red),
                                  ),
                                ],
                              )

                            ],
                          ),
                        ),
                      ),
                    ),
                      Container(
                        padding: const EdgeInsets.all(10.0),
                        child : Image.asset("assets/images/coteGauche.png"),
                    ),
                  ],
                ),
              ),
              // Bas de caisse Gauche
              Container(
                margin: const EdgeInsets.symmetric(horizontal:15),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        child: Text(
                          "Bas de caisse Gauche",
                          style: gothicBold.copyWith(fontSize: 14),
                        ),
                      ),

                      SizedBox(
                          height: 30,
                          child : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 120, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isValideChecked9 = !isValideChecked9;
                                      isInvalideChecked9 = false;
                                      isNonChecked9 = false;
                                    });
                                    step3_baseCaisseGaucheStatutsController.text = "mauvais";
                                    step3["baseCaisseGaucheStatuts"] = step3_baseCaisseGaucheStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isValideChecked9 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "MAUVAIS",
                                      style: gothicBold.copyWith(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 100, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 5),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isInvalideChecked9 = !isInvalideChecked9;
                                      isValideChecked9 = false;
                                      isNonChecked9 = false;
                                    });
                                    step3_baseCaisseGaucheStatutsController.text = "moyen";
                                    step3["baseCaisseGaucheStatuts"] = step3_baseCaisseGaucheStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isInvalideChecked9 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "MOYEN",
                                      style: gothicBold.copyWith(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 80, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isNonChecked9 = !isNonChecked9;
                                      isValideChecked9 = false;
                                      isInvalideChecked9 = false;
                                    });
                                    step3_baseCaisseGaucheStatutsController.text = "bon";
                                    step3["baseCaisseGaucheStatuts"] = step3_baseCaisseGaucheStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isNonChecked9 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "BON",
                                      style: gothicBold.copyWith(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )
                      )
                    ]),

              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15 , vertical: 15),
                child: SizedBox(
                  height: 50, // Set your desired height here
                  child: CustomInputValidatore(
                    controller: step3_baseCaisseGaucheCommentController,
                    labelText: null,
                    onChanged: (value) {
                      step3["baseCaisseGaucheComment"] = value!;
                    },
                    marginContainer: const EdgeInsets.only(bottom: 0, top: 0),
                    width: sizeWidth(context: context),
                    hintText: "Ecriver un commentaire ... *",
                    focusNode: step3_baseCaisseGaucheCommentFocus,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 15 , horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        height: 150,
                        child: ElevatedButton(
                          onPressed: () async{
                            final ImagePicker picker = ImagePicker();
                            final XFile? imgFile = await picker.pickImage(source: ImageSource.gallery);
                            try {
                              if (imgFile != null) {
                                String base64Image = base64Encode(await imgFile.readAsBytes()!);
                                step3_baseCaisseGaucheImageController.text = base64Image;
                                step3["baseCaisseGaucheImage"] = step3_baseCaisseGaucheImageController.text;
                              }
                            } catch (e) {
                              // print(e.toString());
                            }
                          },
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload,
                                size: 36,
                                color: Colors.black,
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Importer votre photo",
                                    style: TextStyle(fontSize: 18, color: Colors.black),
                                  ),
                                  Text(
                                    "  *",
                                    style: TextStyle(fontSize: 18, color: Colors.red),
                                  ),
                                ],
                              )

                            ],
                          ),
                        ),
                      ),
                    ),
                     Container(
                       padding: const EdgeInsets.all(10.0),
                        child : Image.asset("assets/images/BasCaisseGauche.png"),
                      ),

                  ],
                ),
              ),
            ],
          ),
        ),
        isActive: _currentStep == 2,
      ),
      // 4
      Step(
        title: const Text('Extérieur arrière') ,
        content: Form(
          key: _formKeys[3],
          child: Column(
            children: [
              // title
              Center(
                child: Container(
                  width: 250,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.all(20.0),
                      textStyle: const TextStyle(fontSize: 24 , color: Colors.white ),
                    ),
                    onPressed: () =>{},
                    child: const Text('Extérieur arrière' , style: TextStyle(color: Colors.white),),
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              // Progress bar
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 15), // Add margin here
                          child: Text(
                            "Etape 4/18",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 15), // Add margin here
                          child: Text(
                            "Diagnostic",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Center(
                child: Container(
                  width: 800.0, // Adjust the width as needed
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: LinearPercentIndicator(

                      animation: true,
                      backgroundColor: Colors.black,
                      animationDuration: 1000,
                      lineHeight: 10.0,
                      percent: 0.17,
                      barRadius: const Radius.circular(16),
                      //linearStrokeCap: LinearStrokeCap.butt,
                      progressColor: Colors.blue,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              // Essuie Glace Arrière
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15 ,vertical: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      child: Text(
                        "Essuie Glace Arrière",
                        style: gothicBold.copyWith(fontSize: 18),
                      ),
                    ),

                    SizedBox(
                      height: 30,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 120, // Set the width here
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  isOuiSelected3 = true;
                                  isNonSelected3 = false;
                                });
                                step4_essuieGlaceArriereStatutsController.text = "mauvais";
                                step4["essuieGlaceArriereStatuts"] = step4_essuieGlaceArriereStatutsController.text;
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    isOuiSelected3 ? Colors.grey[900] : Colors.grey),
                              ),
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: Text(
                                  "MAUVAIS",
                                  style: gothicBold.copyWith(
                                      fontSize: 12, color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: 80, // Set the width here
                            margin: const EdgeInsets.symmetric(horizontal: 0),
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  isOuiSelected3 = false;
                                  isNonSelected3 = true;
                                });
                                step4_essuieGlaceArriereStatutsController.text = "bon";
                                step4["essuieGlaceArriereStatuts"] = step4_essuieGlaceArriereStatutsController.text;
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    isNonSelected3 ? Colors.grey[900] : Colors.grey),
                              ),
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: Text(
                                  "BON",
                                  style: gothicBold.copyWith(
                                      fontSize: 12, color: Colors.white),
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
              // Face Arrière
              Container(
                margin: const EdgeInsets.symmetric(horizontal:15),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        child: Text(
                          "Face Arrière",
                          style: gothicBold.copyWith(fontSize: 18),
                        ),
                      ),

                      SizedBox(
                          height: 30,
                          child : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 120, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isValideChecked10 = !isValideChecked10;
                                      isInvalideChecked10 = false;
                                      isNonChecked10 = false;
                                    });
                                    step4_faceArriereStatutsController.text = "mauvais";
                                    step4["faceArriereStatuts"] = step4_faceArriereStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isValideChecked10 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "MAUVAIS",
                                      style: gothicBold.copyWith(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 100, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 5),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isInvalideChecked10 = !isInvalideChecked10;
                                      isValideChecked10 = false;
                                      isNonChecked10 = false;
                                    });
                                    step4_faceArriereStatutsController.text = "moyen";
                                    step4["faceArriereStatuts"] = step4_faceArriereStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isInvalideChecked10 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "MOYEN",
                                      style: gothicBold.copyWith(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 80, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isNonChecked10 = !isNonChecked10;
                                      isValideChecked10 = false;
                                      isInvalideChecked10 = false;
                                    });
                                    step4_faceArriereStatutsController.text = "bon";
                                    step4["faceArriereStatuts"] = step4_faceArriereStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isNonChecked10 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "BON",
                                      style: gothicBold.copyWith(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )
                      )
                    ]),

              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15 , vertical: 15),
                child: SizedBox(
                  height: 50, // Set your desired height here
                  child: CustomInputValidatore(
                    controller: step4_faceArriereCommentController,
                    labelText: null,
                    
                    onChanged: (value) {
                      step4["faceArriereComment"] = value!;
                    },
                    marginContainer: const EdgeInsets.only(bottom: 0, top: 0),
                    width: sizeWidth(context: context),
                    hintText: "Ecriver un commentaire ... *",
                    focusNode: step4_faceArriereCommentFocus,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 15 , horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        height: 150,
                        child: ElevatedButton(
                          onPressed: () async{
                            final ImagePicker picker = ImagePicker();
                            final XFile? imgFile = await picker.pickImage(source: ImageSource.gallery);
                            try {
                              if (imgFile != null) {
                                String base64Image = base64Encode(await imgFile.readAsBytes()!);
                                step4_faceArriereImageController.text = base64Image;
                                step4["faceArriereImage"] = step4_faceArriereImageController.text;
                              }
                            } catch (e) {
                              // print(e.toString());
                            }
                          },
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload,
                                size: 36,
                                color: Colors.black,
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Importer votre photo",
                                    style: TextStyle(fontSize: 18, color: Colors.black),
                                  ),
                                  Text(
                                    "  *",
                                    style: TextStyle(fontSize: 18, color: Colors.red),
                                  ),
                                ],
                              )

                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(10.0),
                        child : Image.asset("assets/images/faceArrière.png"),
                    ),
                  ],
                ),
              ),
              // 3/4 Arrière Droit
              Container(
                margin: const EdgeInsets.symmetric(horizontal:15),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        child: Text(
                          "3/4 Arrière Droit",
                          style: gothicBold.copyWith(fontSize: 18),
                        ),
                      ),

                      SizedBox(
                          height: 30,
                          child : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 120, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isValideChecked11 = !isValideChecked11;
                                      isInvalideChecked11 = false;
                                      isNonChecked11 = false;
                                    });
                                    step4_arriereDroitStatutsController.text = "mauvais";
                                    step4["arriereDroitStatuts"] = step4_arriereDroitStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isValideChecked11 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "MAUVAIS",
                                      style: gothicBold.copyWith(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 100, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 5),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isInvalideChecked11 = !isInvalideChecked11;
                                      isValideChecked11 = false;
                                      isNonChecked11 = false;
                                    });
                                    step4_arriereDroitStatutsController.text = "moyen";
                                    step4["arriereDroitStatuts"] = step4_arriereDroitStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isInvalideChecked11 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "MOYEN",
                                      style: gothicBold.copyWith(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 80, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isNonChecked11 = !isNonChecked11;
                                      isValideChecked11 = false;
                                      isInvalideChecked11 = false;
                                    });
                                    step4_arriereDroitStatutsController.text = "bon";
                                    step4["arriereDroitStatuts"] = step4_arriereDroitStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isNonChecked11 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "BON",
                                      style: gothicBold.copyWith(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )
                      )
                    ]),

              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15 , vertical: 15),
                child: SizedBox(
                  height: 50, // Set your desired height here
                  child: CustomInputValidatore(
                    controller: step4_arriereDroitCommentController,
                    labelText: null,
                    
                    onChanged: (value) {
                      step4["arriereDroitComment"] = value!;
                    },
                    marginContainer: const EdgeInsets.only(bottom: 0, top: 0),
                    width: sizeWidth(context: context),
                    hintText: "Ecriver un commentaire ... *",
                    focusNode: step4_arriereDroitCommentFocus,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 15 , horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        height: 150,
                        child: ElevatedButton(
                          onPressed: () async{
                            final ImagePicker picker = ImagePicker();
                            final XFile? imgFile = await picker.pickImage(source: ImageSource.gallery);
                            try {
                              if (imgFile != null) {
                                String base64Image = base64Encode(await imgFile.readAsBytes()!);
                                step4_arriereDroitImageController.text = base64Image;
                                step4["arriereDroitImage"] = step4_arriereDroitImageController.text;
                              }
                            } catch (e) {
                              // print(e.toString());
                            }
                          },
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload,
                                size: 36,
                                color: Colors.black,
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Importer votre photo",
                                    style: TextStyle(fontSize: 18, color: Colors.black),
                                  ),
                                  Text(
                                    "  *",
                                    style: TextStyle(fontSize: 18, color: Colors.red),
                                  ),
                                ],
                              )

                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(10.0),
                        child : Image.asset("assets/images/arriereDroit.jpg"),
                    ),
                  ],
                ),
              ),
              // 3/4 Arrière Gauche
              Container(
                margin: const EdgeInsets.symmetric(horizontal:15),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        child: Text(
                          "3/4 Arrière Gauche",
                          style: gothicBold.copyWith(fontSize: 16),
                        ),
                      ),

                      SizedBox(
                          height: 30,
                          child : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 120, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isValideChecked12 = !isValideChecked12;
                                      isInvalideChecked12 = false;
                                      isNonChecked12 = false;
                                    });
                                    step4_arriereGaucheStatutsController.text = "mauvais";
                                    step4["arriereGaucheStatuts"] = step4_arriereGaucheStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isValideChecked12 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "MAUVAIS",
                                      style: gothicBold.copyWith(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 100, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 5),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isInvalideChecked12 = !isInvalideChecked12;
                                      isValideChecked12 = false;
                                      isNonChecked12 = false;
                                    });
                                    step4_arriereGaucheStatutsController.text = "moyen";
                                    step4["arriereGaucheStatuts"] = step4_arriereGaucheStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isInvalideChecked12 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "MOYEN",
                                      style: gothicBold.copyWith(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 80, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isNonChecked12 = !isNonChecked12;
                                      isValideChecked12 = false;
                                      isInvalideChecked12 = false;
                                    });
                                    step4_arriereGaucheStatutsController.text = "bon";
                                    step4["arriereGaucheStatuts"] = step4_arriereGaucheStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isNonChecked12 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "BON",
                                      style: gothicBold.copyWith(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )
                      )
                    ]),

              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15 , vertical: 15),
                child: SizedBox(
                  height: 50, // Set your desired height here
                  child: CustomInputValidatore(
                    controller: step4_arriereGaucheCommentController,
                    labelText: null,
                    
                    onChanged: (value) {
                      step4["arriereGaucheComment"] = value!;
                    },
                    marginContainer: const EdgeInsets.only(bottom: 0, top: 0),
                    width: sizeWidth(context: context),
                    hintText: "Ecriver un commentaire ... *",
                    focusNode: step4_arriereGaucheCommentFocus,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 15 , horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        height: 150,
                        child: ElevatedButton(
                          onPressed: () async{
                            final ImagePicker picker = ImagePicker();
                            final XFile? imgFile = await picker.pickImage(source: ImageSource.gallery);
                            try {
                              if (imgFile != null) {
                                String base64Image = base64Encode(await imgFile.readAsBytes()!);
                                step4_arriereGaucheImageController.text = base64Image;
                                step4["arriereGaucheImage"] = step4_arriereGaucheImageController.text;
                              }
                            } catch (e) {
                              // print(e.toString());
                            }
                          },
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload,
                                size: 36,
                                color: Colors.black,
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Importer votre photo",
                                    style: TextStyle(fontSize: 18, color: Colors.black),
                                  ),
                                  Text(
                                    "  *",
                                    style: TextStyle(fontSize: 18, color: Colors.red),
                                  ),
                                ],
                              )

                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(10.0),
                        child : Image.asset("assets/images/arriereDroit.jpg"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        isActive: _currentStep == 3,
      ),
      // 5
      Step(
        title: const Text('Toits & avis'),
        content: Form(
          key: _formKeys[4],
          child: Column(
            children: [
              // title
              Center(
                child: Container(
                  width: 250,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.all(20.0),
                      textStyle: const TextStyle(fontSize: 24 , color: Colors.white ),
                    ),
                    onPressed: () =>{},
                    child: const Text('Toits & avis' , style: TextStyle(color: Colors.white),),
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              // Progress bar
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 15), // Add margin here
                          child: Text(
                            "Etape 5/18",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 15), // Add margin here
                          child: Text(
                            "Diagnostic",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Center(
                child: Container(
                  width: 800.0, // Adjust the width as needed
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: LinearPercentIndicator(

                      animation: true,
                      backgroundColor: Colors.black,
                      animationDuration: 1000,
                      lineHeight: 10.0,
                      percent: 0.19,
                      barRadius: const Radius.circular(16),
                      //linearStrokeCap: LinearStrokeCap.butt,
                      progressColor: Colors.blue,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              // Toit
              Container(
                margin: const EdgeInsets.symmetric(horizontal:15),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        child: Text(
                          "Toit",
                          style: gothicBold.copyWith(fontSize: 18),
                        ),
                      ),

                      SizedBox(
                          height: 30,
                          child : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 120, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isValideChecked13 = !isValideChecked13;
                                      isInvalideChecked13 = false;
                                      isNonChecked13 = false;
                                    });
                                    step5_toitStatutsController.text = "mauvais";
                                    step5["toitStatuts"] = step5_toitStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isValideChecked13 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "MAUVAIS",
                                      style: gothicBold.copyWith(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 100, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 5),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isInvalideChecked13 = !isInvalideChecked13;
                                      isValideChecked13 = false;
                                      isNonChecked13 = false;
                                    });
                                    step5_toitStatutsController.text = "moyen";
                                    step5["toitStatuts"] = step5_toitStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isInvalideChecked13 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "MOYEN",
                                      style: gothicBold.copyWith(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 80, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isNonChecked13 = !isNonChecked13;
                                      isValideChecked13 = false;
                                      isInvalideChecked13 = false;
                                    });
                                    step5_toitStatutsController.text = "bon";
                                    step5["toitStatuts"] = step5_toitStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isNonChecked13 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "BON",
                                      style: gothicBold.copyWith(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )
                      )
                    ]),

              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15 , vertical: 15),
                child: SizedBox(
                  height: 50, // Set your desired height here
                  child: CustomInputValidatore(
                    controller: step5_toitCommentController,
                    labelText: null,
                    
                    onChanged: (value) {
                      step5["toitComment"] = value!;
                    },
                    marginContainer: const EdgeInsets.only(bottom: 0, top: 0),
                    width: sizeWidth(context: context),
                    hintText: "Ecriver un commentaire ... *",
                    focusNode: step5_toitCommentFocus,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 15 , horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        height: 150,
                        child: ElevatedButton(
                          onPressed: () async{
                            final ImagePicker picker = ImagePicker();
                            final XFile? imgFile = await picker.pickImage(source: ImageSource.gallery);
                            try {
                              if (imgFile != null) {
                                String base64Image = base64Encode(await imgFile.readAsBytes()!);
                                step5_toitImageController.text = base64Image;
                                step5["toitImage"] = step5_toitImageController.text;
                              }
                            } catch (e) {
                              // print(e.toString());
                            }
                          },
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload,
                                size: 36,
                                color: Colors.black,
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Importer votre photo",
                                    style: TextStyle(fontSize: 18, color: Colors.black),
                                  ),
                                  Text(
                                    "  *",
                                    style: TextStyle(fontSize: 18, color: Colors.red),
                                  ),
                                ],
                              )

                            ],
                          ),
                        ),
                      ),
                    ),
                    // Add the second element here
                  ],
                ),
              ),
              // AVIS sur l’état de l’extérieur du véhicule ?
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "AVIS sur l’état de l’extérieur du véhicule ?",
                        style:
                        gothicBold.copyWith(
                            fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Carrosserie, traces, chocs, peinture...",
                        style:
                        gothicBold.copyWith(
                            fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15 , vertical: 15),
                child: SizedBox(
                  height: 50, // Set your desired height here
                  child: CustomInputValidatore(
                    controller: step5_avisEtatVehiculeCommentController,
                    labelText: null,
                    
                    onChanged: (value) {
                      step5["avisEtatVehiculeComment"] = value!;
                    },
                    marginContainer: const EdgeInsets.only(bottom: 0, top: 0),
                    width: sizeWidth(context: context),
                    hintText: "Ecriver un commentaire ...",
                    focusNode: step5_avisEtatVehiculeCommentFocus,
                  ),
                ),
              ),
              // Phots Supplémentaires
              Container(
                margin: const EdgeInsets.symmetric(horizontal:15),
                child: SizedBox(
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Photos Supplémentaires",
                          style:
                          gothicBold.copyWith(
                              fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 15 , horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        height: 150,
                        child: ElevatedButton(
                          onPressed: () async{
                            final ImagePicker picker = ImagePicker();
                            final XFile? imgFile = await picker.pickImage(source: ImageSource.gallery);
                            try {
                              if (imgFile != null) {
                                String base64Image = base64Encode(await imgFile.readAsBytes()!);
                                step5_photoSuplementaire1Controller.text = base64Image;
                                step5["photoSuplementaire1"] = step5_photoSuplementaire1Controller.text;
                              }
                            } catch (e) {
                              // print(e.toString());
                            }
                          },
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload,
                                size: 36,
                                color: Colors.black,
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Importer votre photo",
                                    style: TextStyle(fontSize: 18, color: Colors.black),
                                  )
                                ],
                              )

                            ],
                          ),
                        ),
                      ),
                    ),
                    // Add the second element here
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 15 , horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        height: 150,
                        child: ElevatedButton(
                          onPressed: () async{
                            final ImagePicker picker = ImagePicker();
                            final XFile? imgFile = await picker.pickImage(source: ImageSource.gallery);
                            try {
                              if (imgFile != null) {
                                String base64Image = base64Encode(await imgFile.readAsBytes()!);
                                step5_photoSuplementaire2Controller.text = base64Image;
                                step5["photoSuplementaire2"] = step5_photoSuplementaire2Controller.text;
                              }
                            } catch (e) {
                              // print(e.toString());
                            }
                          },
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload,
                                size: 36,
                                color: Colors.black,
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Importer votre photo",
                                    style: TextStyle(fontSize: 18, color: Colors.black),
                                  )
                                ],
                              )

                            ],
                          ),
                        ),
                      ),
                    ),
                    // Add the second element here
                  ],
                ),
              ),
              // Conform à l'annonce
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15 ,vertical: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      child: Text(
                        "Conforme à l’annonce ?",
                        style: gothicBold.copyWith(fontSize: 18),
                      ),
                    ),

                    SizedBox(
                      height: 30,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 120, // Set the width here
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  isOuiSelected4 = true;
                                  isNonSelected4 = false;
                                });
                                step5_conformeAnnonceStatuts_1Controller.text = "non";
                                step5["conformeAnnonceStatuts_1"] = step5_conformeAnnonceStatuts_1Controller.text;
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    isOuiSelected4 ? Colors.grey[900] : Colors.grey),
                              ),
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: Text(
                                  "MAUVAIS",
                                  style: gothicBold.copyWith(
                                      fontSize: 12, color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: 80, // Set the width here
                            margin: const EdgeInsets.symmetric(horizontal: 0),
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  isOuiSelected4 = false;
                                  isNonSelected4 = true;
                                });
                                step5_conformeAnnonceStatuts_1Controller.text = "bon";
                                step5["conformeAnnonceStatuts_1"] = step5_conformeAnnonceStatuts_1Controller.text;
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    isNonSelected4 ? Colors.grey[900] : Colors.grey),
                              ),
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: Text(
                                  "BON",
                                  style: gothicBold.copyWith(
                                      fontSize: 12, color: Colors.white),
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
        ),
        isActive: _currentStep == 4,
      ),
      // 6
      Step(
        title: const Text('Jantes'),
        content: Form(
          key: _formKeys[5],
          child: Column(

            children: [
              // title
              Center(
                child: Container(
                  width: 250,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.all(20.0),
                      textStyle: const TextStyle(fontSize: 24 , color: Colors.white ),
                    ),
                    onPressed: () =>{},
                    child: const Text('Jantes' , style: TextStyle(color: Colors.white),),
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              // Progress bar
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 15), // Add margin here
                          child: Text(
                            "Etape 6/18",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 15), // Add margin here
                          child: Text(
                            "Diagnostic",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Center(
                child: Container(
                  width: 800.0, // Adjust the width as needed
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: LinearPercentIndicator(

                      animation: true,
                      backgroundColor: Colors.black,
                      animationDuration: 1000,
                      lineHeight: 10.0,
                      percent: 0.25,
                      barRadius: const Radius.circular(16),
                      //linearStrokeCap: LinearStrokeCap.butt,
                      progressColor: Colors.blue,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              // Jante Avant Droit
              Container(
                margin: const EdgeInsets.symmetric(horizontal:15),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        child: Text(
                          "Jante Avant Droit",
                          style: gothicBold.copyWith(fontSize: 18),
                        ),
                      ),

                      SizedBox(
                          height: 30,
                          child : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 120, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isValideChecked14 = !isValideChecked14;
                                      isInvalideChecked14 = false;
                                      isNonChecked14 = false;
                                    });
                                    step6_janteAvantDroitStatutsController.text = "mauvais";
                                    step6["janteAvantDroitStatuts"] = step6_janteAvantDroitStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isValideChecked14 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "MAUVAIS",
                                      style: gothicBold.copyWith(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 100, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 5),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isInvalideChecked14 = !isInvalideChecked14;
                                      isValideChecked14 = false;
                                      isNonChecked14 = false;
                                    });
                                    step6_janteAvantDroitStatutsController.text = "moyen";
                                    step6["janteAvantDroitStatuts"] = step6_janteAvantDroitStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isInvalideChecked14 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "MOYEN",
                                      style: gothicBold.copyWith(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 80, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isNonChecked14 = !isNonChecked14;
                                      isValideChecked14 = false;
                                      isInvalideChecked14 = false;
                                    });
                                    step6_janteAvantDroitStatutsController.text = "bon";
                                    step6["janteAvantDroitStatuts"] = step6_janteAvantDroitStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isNonChecked14 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "BON",
                                      style: gothicBold.copyWith(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )
                      )
                    ]),

              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15 , vertical: 15),
                child: SizedBox(
                  height: 50, // Set your desired height here
                  child: CustomInputValidatore(
                    controller: step6_janteAvantDroitCommentController,
                    labelText: null,
                    
                    onChanged: (value) {
                      step6["janteAvantDroitComment"] = value!;
                    },
                    marginContainer: const EdgeInsets.only(bottom: 0, top: 0),
                    width: sizeWidth(context: context),
                    hintText: "Ecriver un commentaire ... *",
                    focusNode: step6_janteAvantDroitCommentFocus,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 15 , horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        height: 150,
                        child: ElevatedButton(
                          onPressed: () async{
                            final ImagePicker picker = ImagePicker();
                            final XFile? imgFile = await picker.pickImage(source: ImageSource.gallery);
                            try {
                              if (imgFile != null) {
                                String base64Image = base64Encode(await imgFile.readAsBytes()!);
                                step6_janteAvantDroitImageController.text = base64Image;
                                step6["janteAvantDroitImage"] = step6_janteAvantDroitImageController.text;
                              }
                            } catch (e) {
                              // print(e.toString());
                            }
                          },
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload,
                                size: 36,
                                color: Colors.black,
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Importer votre photo",
                                    style: TextStyle(fontSize: 18, color: Colors.black),
                                  ),
                                  Text(
                                    "  *",
                                    style: TextStyle(fontSize: 18, color: Colors.red),
                                  ),
                                ],
                              )

                            ],
                          ),
                        ),
                      ),
                    ),
                    // Add the second element here
                  ],
                ),
              ),
              // Jante Avant Gauche
              Container(
                margin: const EdgeInsets.symmetric(horizontal:15),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        child: Text(
                          "Jante Avant Gauche",
                          style: gothicBold.copyWith(fontSize: 14),
                        ),
                      ),

                      SizedBox(
                          height: 30,
                          child : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 120, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isValideChecked15 = !isValideChecked15;
                                      isInvalideChecked15 = false;
                                      isNonChecked15 = false;
                                    });
                                    step6_janteAvantGaucheStatutsController.text = "mauvais";
                                    step6["janteAvantGaucheStatuts"] = step6_janteAvantGaucheStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isValideChecked15 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "MAUVAIS",
                                      style: gothicBold.copyWith(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 100, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 5),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isInvalideChecked15 = !isInvalideChecked15;
                                      isValideChecked15 = false;
                                      isNonChecked15 = false;
                                    });
                                    step6_janteAvantGaucheStatutsController.text = "moyen";
                                    step6["janteAvantGaucheStatuts"] = step6_janteAvantGaucheStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isInvalideChecked15 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "MOYEN",
                                      style: gothicBold.copyWith(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 80, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isNonChecked15 = !isNonChecked15;
                                      isValideChecked15 = false;
                                      isInvalideChecked15 = false;
                                    });
                                    step6_janteAvantGaucheStatutsController.text = "bon";
                                    step6["janteAvantGaucheStatuts"] = step6_janteAvantGaucheStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isNonChecked15 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "BON",
                                      style: gothicBold.copyWith(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )
                      )
                    ]),

              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15 , vertical: 15),
                child: SizedBox(
                  height: 50, // Set your desired height here
                  child: CustomInputValidatore(
                    controller: step6_janteAvantGaucheCommentController,
                    labelText: null,
                    
                    onChanged: (value) {
                      step6["janteAvantGaucheComment"] = value!;
                    },
                    marginContainer: const EdgeInsets.only(bottom: 0, top: 0),
                    width: sizeWidth(context: context),
                    hintText: "Ecriver un commentaire ... *",
                    focusNode: step6_janteAvantGaucheCommentFocus,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 15 , horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        height: 150,
                        child: ElevatedButton(
                          onPressed: () async{
                            final ImagePicker picker = ImagePicker();
                            final XFile? imgFile = await picker.pickImage(source: ImageSource.gallery);
                            try {
                              if (imgFile != null) {
                                String base64Image = base64Encode(await imgFile.readAsBytes()!);
                                step6_janteAvantGaucheImageController.text = base64Image;
                                step6["janteAvantGaucheImage"] = step6_janteAvantGaucheImageController.text;
                              }
                            } catch (e) {
                              // print(e.toString());
                            }
                          },
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload,
                                size: 36,
                                color: Colors.black,
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Importer votre photo",
                                    style: TextStyle(fontSize: 18, color: Colors.black),
                                  ),
                                  Text(
                                    "  *",
                                    style: TextStyle(fontSize: 18, color: Colors.red),
                                  ),
                                ],
                              )

                            ],
                          ),
                        ),
                      ),
                    ),
                    // Add the second element here
                  ],
                ),
              ),
              // Jante Arrière Gauche
              Container(
                margin: const EdgeInsets.symmetric(horizontal:15),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        child: Text(
                          "Jante Arrière Gauche",
                          style: gothicBold.copyWith(fontSize: 14),
                        ),
                      ),

                      SizedBox(
                          height: 30,
                          child : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 120, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isValideChecked16 = !isValideChecked16;
                                      isInvalideChecked16 = false;
                                      isNonChecked16 = false;
                                    });
                                    step6_janteArriereGaucheStatutsController.text = "mauvais";
                                    step6["janteArriereGaucheStatuts"] = step6_janteArriereGaucheStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isValideChecked16 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "MAUVAIS",
                                      style: gothicBold.copyWith(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 100, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 5),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isInvalideChecked16 = !isInvalideChecked16;
                                      isValideChecked16 = false;
                                      isNonChecked16 = false;
                                    });
                                    step6_janteArriereGaucheStatutsController.text = "moyen";
                                    step6["janteArriereGaucheStatuts"] = step6_janteArriereGaucheStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isInvalideChecked16 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "MOYEN",
                                      style: gothicBold.copyWith(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 80, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isNonChecked16 = !isNonChecked16;
                                      isValideChecked16 = false;
                                      isInvalideChecked16 = false;
                                    });
                                    step6_janteArriereGaucheStatutsController.text = "bon";
                                    step6["janteArriereGaucheStatuts"] = step6_janteArriereGaucheStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isNonChecked16 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "BON",
                                      style: gothicBold.copyWith(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )
                      )
                    ]),

              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15 , vertical: 15),
                child: SizedBox(
                  height: 50, // Set your desired height here
                  child: CustomInputValidatore(
                    controller: step6_janteArriereGaucheCommentController,
                    labelText: null,
                    onChanged: (value) {
                      step6["step6_janteArriereGaucheComment"] = value!;
                    },
                    marginContainer: const EdgeInsets.only(bottom: 0, top: 0),
                    width: sizeWidth(context: context),
                    hintText: "Ecriver un commentaire ... *",
                    focusNode: step6_janteArriereGaucheCommentFocus,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 15 , horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        height: 150,
                        child: ElevatedButton(
                          onPressed: () async{
                            final ImagePicker picker = ImagePicker();
                            final XFile? imgFile = await picker.pickImage(source: ImageSource.gallery);
                            try {
                              if (imgFile != null) {
                                String base64Image = base64Encode(await imgFile.readAsBytes()!);
                                step6_janteArriereGaucheImageController.text = base64Image;
                                step6["janteArriereGaucheImage"] = step6_janteArriereGaucheImageController.text;
                              }
                            } catch (e) {
                              // print(e.toString());
                            }
                          },
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload,
                                size: 36,
                                color: Colors.black,
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Importer votre photo",
                                    style: TextStyle(fontSize: 18, color: Colors.black),
                                  ),
                                  Text(
                                    "  *",
                                    style: TextStyle(fontSize: 18, color: Colors.red),
                                  ),
                                ],
                              )

                            ],
                          ),
                        ),
                      ),
                    ),
                    // Add the second element here
                  ],
                ),
              ),
              // Jante Arrière Droit
              Container(
                margin: const EdgeInsets.symmetric(horizontal:15),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        child: Text(
                          "Jante Arrière Droit",
                          style: gothicBold.copyWith(fontSize: 14),
                        ),
                      ),

                      SizedBox(
                          height: 30,
                          child : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 120, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isValideChecked17 = !isValideChecked17;
                                      isInvalideChecked17 = false;
                                      isNonChecked17 = false;
                                    });
                                    step6_janteArriereDroitStatutsController.text = "mauvais";
                                    step6["janteArriereDroitStatuts"] = step6_janteArriereDroitStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isValideChecked17 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "MAUVAIS",
                                      style: gothicBold.copyWith(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 100, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 5),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isInvalideChecked17 = !isInvalideChecked17;
                                      isValideChecked17 = false;
                                      isNonChecked17 = false;
                                    });
                                    step6_janteArriereDroitStatutsController.text = "moyen";
                                    step6["janteArriereDroitStatuts"] = step6_janteArriereDroitStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isInvalideChecked17 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "MOYEN",
                                      style: gothicBold.copyWith(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 80, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isNonChecked17 = !isNonChecked17;
                                      isValideChecked17 = false;
                                      isInvalideChecked17 = false;
                                    });
                                    step6_janteArriereDroitStatutsController.text = "bon";
                                    step6["janteArriereDroitStatuts"] = step6_janteArriereDroitStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isNonChecked17 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "BON",
                                      style: gothicBold.copyWith(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )
                      )
                    ]),

              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15 , vertical: 15),
                child: SizedBox(
                  height: 50, // Set your desired height here
                  child: CustomInputValidatore(
                    controller: step6_janteArriereDroitCommentController,
                    labelText: null,
                    
                    onChanged: (value) {
                      step6["janteArriereDroitComment"] = value!;
                    },
                    marginContainer: const EdgeInsets.only(bottom: 0, top: 0),
                    width: sizeWidth(context: context),
                    hintText: "Ecriver un commentaire ... *",
                    focusNode: step6_janteArriereDroitCommentFocus,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 15 , horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        height: 150,
                        child: ElevatedButton(
                          onPressed: () async{
                            final ImagePicker picker = ImagePicker();
                            final XFile? imgFile = await picker.pickImage(source: ImageSource.gallery);
                            try {
                              if (imgFile != null) {
                                String base64Image = base64Encode(await imgFile.readAsBytes()!);
                                step6_janteArriereDroitImageController.text = base64Image;
                                step6["janteArriereDroitImage"] = step6_janteArriereDroitImageController.text;
                              }
                            } catch (e) {
                              // print(e.toString());
                            }
                          },
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload,
                                size: 36,
                                color: Colors.black,
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Importer votre photo",
                                    style: TextStyle(fontSize: 18, color: Colors.black),
                                  ),
                                  Text(
                                    "  *",
                                    style: TextStyle(fontSize: 18, color: Colors.red),
                                  ),
                                ],
                              )

                            ],
                          ),
                        ),
                      ),
                    ),
                    // Add the second element here
                  ],
                ),
              ),
              // Roue de secours
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15 ,vertical: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      child: Text(
                        "Roue de secours",
                        style: gothicBold.copyWith(fontSize: 18),
                      ),
                    ),

                    SizedBox(
                      height: 30,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 120, // Set the width here
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  isOuiSelected5 = true;
                                  isNonSelected5 = false;
                                });
                                step6_roueSecoursStatutController.text = "oui";
                                step5["roueSecoursStatut"] = step6_roueSecoursStatutController.text;
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    isOuiSelected5 ? Colors.grey[900] : Colors.grey),
                              ),
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: Text(
                                  "OUI",
                                  style: gothicBold.copyWith(
                                      fontSize: 12, color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: 80, // Set the width here
                            margin: const EdgeInsets.symmetric(horizontal: 0),
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  isOuiSelected5 = false;
                                  isNonSelected5 = true;
                                });
                                step6_roueSecoursStatutController.text = "non";
                                step5["roueSecoursStatut"] = step6_roueSecoursStatutController.text;
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    isNonSelected5 ? Colors.grey[900] : Colors.grey),
                              ),
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: Text(
                                  "NON",
                                  style: gothicBold.copyWith(
                                      fontSize: 12, color: Colors.white),
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
        ),
        isActive: _currentStep == 5,
      ),
      // 7
      Step(
        title: const Text('Phare') ,
        content: Form(
          key: _formKeys[6],
          child: Column(
            children: [
              // title
              Center(
                child: Container(
                  width: 250,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.all(20.0),
                      textStyle: const TextStyle(fontSize: 24 , color: Colors.white ),
                    ),
                    onPressed: () =>{},
                    child: const Text('Phare' , style: TextStyle(color: Colors.white),),
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              // Progress bar
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 15), // Add margin here
                          child: Text(
                            "Etape 7/18",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 15), // Add margin here
                          child: Text(
                            "Diagnostic",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Center(
                child: Container(
                  width: 800.0, // Adjust the width as needed
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: LinearPercentIndicator(

                      animation: true,
                      backgroundColor: Colors.black,
                      animationDuration: 1000,
                      lineHeight: 10.0,
                      percent: 0.28,
                      barRadius: const Radius.circular(16),
                      //linearStrokeCap: LinearStrokeCap.butt,
                      progressColor: Colors.blue,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              // Phare Avant Gauche
              Container(
                margin: const EdgeInsets.symmetric(horizontal:15),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        child: Text(
                          "Phare Avant Gauche",
                          style: gothicBold.copyWith(fontSize: 14),
                        ),
                      ),

                      SizedBox(
                          height: 30,
                          child : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 120, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isValideChecked18 = !isValideChecked18;
                                      isInvalideChecked18 = false;
                                      isNonChecked18 = false;
                                    });
                                    step7_phareAvantGaucheStatutsController.text = "mauvais";
                                    step7["phareAvantGaucheStatuts"] = step7_phareAvantGaucheStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isValideChecked18 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "MAUVAIS",
                                      style: gothicBold.copyWith(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 100, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 5),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isInvalideChecked18 = !isInvalideChecked18;
                                      isValideChecked18 = false;
                                      isNonChecked18 = false;
                                    });
                                    step7_phareAvantGaucheStatutsController.text = "moyen";
                                    step7["phareAvantGaucheStatuts"] = step7_phareAvantGaucheStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isInvalideChecked18 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "MOYEN",
                                      style: gothicBold.copyWith(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 80, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isNonChecked18 = !isNonChecked18;
                                      isValideChecked18 = false;
                                      isInvalideChecked18 = false;
                                    });
                                    step7_phareAvantGaucheStatutsController.text = "bon";
                                    step7["phareAvantGaucheStatuts"] = step7_phareAvantGaucheStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isNonChecked18 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "BON",
                                      style: gothicBold.copyWith(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )
                      )
                    ]),

              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15 , vertical: 15),
                child: SizedBox(
                  height: 50, // Set your desired height here
                  child: CustomInputValidatore(
                    controller: step7_phareAvantGaucheCommentController,
                    labelText: null,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Field is required';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      step7["phareAvantGaucheComment"] = value!;
                    },
                    marginContainer: const EdgeInsets.only(bottom: 0, top: 0),
                    width: sizeWidth(context: context),
                    hintText: "Ecriver un commentaire ... *",
                    focusNode: step7_phareAvantGaucheCommentFocus,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 15 , horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        height: 150,
                        child: ElevatedButton(
                          onPressed: () async{
                            final ImagePicker picker = ImagePicker();
                            final XFile? imgFile = await picker.pickImage(source: ImageSource.gallery);
                            try {
                              if (imgFile != null) {
                                String base64Image = base64Encode(await imgFile.readAsBytes()!);
                                step7_phareAvantGaucheImageController.text = base64Image;
                                step7["phareAvantGaucheImage"] = step7_phareAvantGaucheImageController.text;
                              }
                            } catch (e) {
                              // print(e.toString());
                            }
                          },
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload,
                                size: 36,
                                color: Colors.black,
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Importer votre photo",
                                    style: TextStyle(fontSize: 18, color: Colors.black),
                                  ),
                                  Text(
                                    "  *",
                                    style: TextStyle(fontSize: 18, color: Colors.red),
                                  ),
                                ],
                              )

                            ],
                          ),
                        ),
                      ),
                    ),
                    // Add the second element here
                  ],
                ),
              ),
              // Ampoule Avant Gauche
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15 ,vertical: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      child: Text(
                        "Ampoule Avant Gauche",
                        style: gothicBold.copyWith(fontSize: 14),
                      ),
                    ),

                    SizedBox(
                      height: 30,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 120, // Set the width here
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  isOuiSelected6 = true;
                                  isNonSelected6 = false;
                                });
                                step7_ampouleAvantGaucheStatutsController.text = "fonctionnel";
                                step7["ampouleAvantGaucheStatuts"] = step7_ampouleAvantGaucheStatutsController.text;
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    isOuiSelected6 ? Colors.grey[900] : Colors.grey),
                              ),
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: Text(
                                  "FONCTIONNEL",
                                  style: gothicBold.copyWith(
                                      fontSize: 10, color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: 150, // Set the width here
                            margin: const EdgeInsets.symmetric(horizontal: 0),
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  isOuiSelected6 = false;
                                  isNonSelected6 = true;
                                });
                                step7_ampouleAvantGaucheStatutsController.text = "non fonctionnel";
                                step7["ampouleAvantGaucheStatuts"] = step7_ampouleAvantGaucheStatutsController.text;
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    isNonSelected6 ? Colors.grey[900] : Colors.grey),
                              ),
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: Text(
                                  "NON FONCTIONNEL",
                                  style: gothicBold.copyWith(
                                      fontSize: 10, color: Colors.white),
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
              // Clignotant Avant Gauche
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15 ,vertical: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      child: Text(
                        "Clignotant Avant Gauche",
                        style: gothicBold.copyWith(fontSize: 14),
                      ),
                    ),

                    SizedBox(
                      height: 30,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 120, // Set the width here
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  isOuiSelected7 = true;
                                  isNonSelected7 = false;
                                });
                                step7_clignotantAvantGaucheStatutsController.text = "fonctionnel";
                                step7["clignotantAvantGaucheStatuts"] = step7_clignotantAvantGaucheStatutsController.text;
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    isOuiSelected7 ? Colors.grey[900] : Colors.grey),
                              ),
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: Text(
                                  "FONCTIONNEL",
                                  style: gothicBold.copyWith(
                                      fontSize: 10, color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: 150, // Set the width here
                            margin: const EdgeInsets.symmetric(horizontal: 0),
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  isOuiSelected7 = false;
                                  isNonSelected7 = true;
                                });
                                step7_clignotantAvantGaucheStatutsController.text = "non fonctionnel";
                                step7["clignotantAvantGaucheStatuts"] = step7_clignotantAvantGaucheStatutsController.text;
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    isNonSelected7 ? Colors.grey[900] : Colors.grey),
                              ),
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: Text(
                                  "NON FONCTIONNEL",
                                  style: gothicBold.copyWith(
                                      fontSize: 10, color: Colors.white),
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
              // Phare Avant Droit
              Container(
                margin: const EdgeInsets.symmetric(horizontal:15),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        child: Text(
                          "Phare Avant Droit",
                          style: gothicBold.copyWith(fontSize: 18),
                        ),
                      ),

                      SizedBox(
                          height: 30,
                          child : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 120, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isValideChecked19 = !isValideChecked19;
                                      isInvalideChecked19 = false;
                                      isNonChecked19 = false;
                                    });
                                    step7_phareAvantDroitStatutsController.text = "mauvais";
                                    step7["phareAvantDroitStatuts"] = step7_phareAvantDroitStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isValideChecked19 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "MAUVAIS",
                                      style: gothicBold.copyWith(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 100, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 5),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isInvalideChecked19 = !isInvalideChecked19;
                                      isValideChecked19 = false;
                                      isNonChecked19 = false;
                                    });
                                    step7_phareAvantDroitStatutsController.text = "moyen";
                                    step7["phareAvantDroitStatuts"] = step7_phareAvantDroitStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isInvalideChecked19 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "MOYEN",
                                      style: gothicBold.copyWith(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 80, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isNonChecked19 = !isNonChecked19;
                                      isValideChecked19 = false;
                                      isInvalideChecked19 = false;
                                    });
                                    step7_phareAvantDroitStatutsController.text = "bon";
                                    step7["phareAvantDroitStatuts"] = step7_phareAvantDroitStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isNonChecked19 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "BON",
                                      style: gothicBold.copyWith(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )
                      )
                    ]),

              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15 , vertical: 15),
                child: SizedBox(
                  height: 50,
                  child: CustomInputValidatore(
                    controller: step7_phareAvantDroitCommentController,
                    labelText: null,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Field is required';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      step7["phareAvantDroitComment"] = value!;
                    },
                    marginContainer: const EdgeInsets.only(bottom: 0, top: 0),
                    width: sizeWidth(context: context),
                    hintText: "Ecriver un commentaire ... *",
                    focusNode: step7_phareAvantDroitCommentFocus,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 15 , horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        height: 150,
                        child: ElevatedButton(
                          onPressed: () async{
                            final ImagePicker picker = ImagePicker();
                            final XFile? imgFile = await picker.pickImage(source: ImageSource.gallery);
                            try {
                              if (imgFile != null) {
                                String base64Image = base64Encode(await imgFile.readAsBytes()!);
                                step7_phareAvantDroitImageController.text = base64Image;
                                step7["phareAvantDroitImage"] = step7_phareAvantDroitImageController.text;
                              }
                            } catch (e) {
                              // print(e.toString());
                            }
                          },
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload,
                                size: 36,
                                color: Colors.black,
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Importer votre photo",
                                    style: TextStyle(fontSize: 18, color: Colors.black),
                                  ),
                                  Text(
                                    "  *",
                                    style: TextStyle(fontSize: 18, color: Colors.red),
                                  ),
                                ],
                              )

                            ],
                          ),
                        ),
                      ),
                    ),
                    // Add the second element here
                  ],
                ),
              ),
              // Ampoule Avant Droit
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15 ,vertical: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      child: Text(
                        "Ampoule Avant Droit",
                        style: gothicBold.copyWith(fontSize: 18),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 120, // Set the width here
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  isOuiSelected8 = true;
                                  isNonSelected8 = false;
                                });
                                step7_ampouleAvantDroitStatutsController.text = "fonctionnel";
                                step7["ampouleAvantDroitStatuts"] = step7_ampouleAvantDroitStatutsController.text;
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    isOuiSelected8 ? Colors.grey[900] : Colors.grey),
                              ),
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: Text(
                                  "FONCTIONNEL",
                                  style: gothicBold.copyWith(
                                      fontSize: 10, color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: 150,
                            margin: const EdgeInsets.symmetric(horizontal: 0),
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  isOuiSelected8 = false;
                                  isNonSelected8 = true;
                                });
                                step7_ampouleAvantDroitStatutsController.text = "non fonctionnel";
                                step7["ampouleAvantDroitStatuts"] = step7_ampouleAvantDroitStatutsController.text;
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    isNonSelected8 ? Colors.grey[900] : Colors.grey),
                              ),
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: Text(
                                  "NON FONCTIONNEL",
                                  style: gothicBold.copyWith(
                                      fontSize: 10, color: Colors.white),
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
              // Clignotant Avant Droit
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15 ,vertical: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      child: Text(
                        "Clignotant Avant Droit",
                        style: gothicBold.copyWith(fontSize: 14),
                      ),
                    ),

                    SizedBox(
                      height: 30,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 120, // Set the width here
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  isOuiSelected9 = true;
                                  isNonSelected9 = false;
                                });
                                step7_clignotantAvantDroitStatutsController.text = "fonctionnel";
                                step7["clignotantAvantDroitStatuts"] = step7_clignotantAvantDroitStatutsController.text;
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    isOuiSelected9 ? Colors.grey[900] : Colors.grey),
                              ),
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: Text(
                                  "FONCTIONNEL",
                                  style: gothicBold.copyWith(
                                      fontSize: 10, color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: 150, // Set the width here
                            margin: const EdgeInsets.symmetric(horizontal: 0),
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  isOuiSelected9 = false;
                                  isNonSelected9 = true;
                                });
                                step7_clignotantAvantDroitStatutsController.text = "non fonctionnel";
                                step7["clignotantAvantDroitStatuts"] = step7_clignotantAvantDroitStatutsController.text;
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    isNonSelected9 ? Colors.grey[900] : Colors.grey),
                              ),
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: Text(
                                  "NON FONCTIONNEL",
                                  style: gothicBold.copyWith(
                                      fontSize: 10, color: Colors.white),
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
              // Phare Arrière Droit
              Container(
                margin: const EdgeInsets.symmetric(horizontal:15),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        child: Text(
                          "Phare Arrière Droit",
                          style: gothicBold.copyWith(fontSize: 14),
                        ),
                      ),

                      SizedBox(
                          height: 30,
                          child : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 120, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isValideChecked20 = !isValideChecked20;
                                      isInvalideChecked20 = false;
                                      isNonChecked20 = false;
                                    });
                                    step7_phareArriereDroitStatutsController.text = "mauvais";
                                    step7["phareArriereDroitStatuts"] = step7_phareArriereDroitStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isValideChecked20 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "MAUVAIS",
                                      style: gothicBold.copyWith(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 100, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 5),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isInvalideChecked20 = !isInvalideChecked20;
                                      isValideChecked20 = false;
                                      isNonChecked20 = false;
                                    });
                                    step7_phareArriereDroitStatutsController.text = "moyen";
                                    step7["phareArriereDroitStatuts"] = step7_phareArriereDroitStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isInvalideChecked20 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "MOYEN",
                                      style: gothicBold.copyWith(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 80, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isNonChecked20 = !isNonChecked20;
                                      isValideChecked20 = false;
                                      isInvalideChecked20 = false;
                                    });
                                    step7_phareArriereDroitStatutsController.text = "bon";
                                    step7["phareArriereDroitStatuts"] = step7_phareArriereDroitStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isNonChecked20 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "BON",
                                      style: gothicBold.copyWith(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )
                      )
                    ]),

              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15 , vertical: 15),
                child: SizedBox(
                  height: 50, // Set your desired height here
                  child: CustomInputValidatore(
                    controller: step7_phareArriereDroitCommentController,
                    labelText: null,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Field is required';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      step7["phareArriereDroitComment"] = value!;
                    },
                    marginContainer: const EdgeInsets.only(bottom: 0, top: 0),
                    width: sizeWidth(context: context),
                    hintText: "Ecriver un commentaire ... *",
                    focusNode: step7_phareArriereDroitCommentFocus,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 15 , horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        height: 150,
                        child: ElevatedButton(
                          onPressed: () async{
                            final ImagePicker picker = ImagePicker();
                            final XFile? imgFile = await picker.pickImage(source: ImageSource.gallery);
                            try {
                              if (imgFile != null) {
                                String base64Image = base64Encode(await imgFile.readAsBytes()!);
                                step7_phareArriereDroitImageController.text = base64Image;
                                step7["phareArriereDroitImage"] = step7_phareArriereDroitImageController.text;
                              }
                            } catch (e) {
                              // print(e.toString());
                            }
                          },
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload,
                                size: 36,
                                color: Colors.black,
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Importer votre photo",
                                    style: TextStyle(fontSize: 18, color: Colors.black),
                                  ),
                                  Text(
                                    "  *",
                                    style: TextStyle(fontSize: 18, color: Colors.red),
                                  ),
                                ],
                              )

                            ],
                          ),
                        ),
                      ),
                    ),
                    // Add the second element here
                  ],
                ),
              ),
              // Ampoule Arrière Droit
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15 ,vertical: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      child: Text(
                        "Ampoule Arrière Droit",
                        style: gothicBold.copyWith(fontSize: 14),
                      ),
                    ),

                    SizedBox(
                      height: 30,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 120, // Set the width here
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  isOuiSelected10 = true;
                                  isNonSelected10 = false;
                                });
                                step7_ampouleArriereDroitStatutsController.text = "fonctionnel";
                                step7["ampouleArriereDroitStatuts"] = step7_ampouleArriereDroitStatutsController.text;
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    isOuiSelected10 ? Colors.grey[900] : Colors.grey),
                              ),
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: Text(
                                  "FONCTIONNEL",
                                  style: gothicBold.copyWith(
                                      fontSize: 10, color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: 150, // Set the width here
                            margin: const EdgeInsets.symmetric(horizontal: 0),
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  isOuiSelected10 = false;
                                  isNonSelected10 = true;
                                });
                                step7_ampouleArriereDroitStatutsController.text = "non fonctionnel";
                                step7["ampouleArriereDroitStatuts"] = step7_ampouleArriereDroitStatutsController.text;
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    isNonSelected10 ? Colors.grey[900] : Colors.grey),
                              ),
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: Text(
                                  "NON FONCTIONNEL",
                                  style: gothicBold.copyWith(
                                      fontSize: 10, color: Colors.white),
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
              // Clignotant Arrière Droit
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15 ,vertical: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      child: Text(
                        "Clignotant Arrière Droit",
                        style: gothicBold.copyWith(fontSize: 14),
                      ),
                    ),

                    SizedBox(
                      height: 30,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 120, // Set the width here
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  isOuiSelected11 = true;
                                  isNonSelected11 = false;
                                });
                                step7_clignotantArriereDroitStatutsController.text = "fonctionnel";
                                step7["phareArriereGaucheStatuts"] = step7_clignotantArriereDroitStatutsController.text;
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    isOuiSelected11 ? Colors.grey[900] : Colors.grey),
                              ),
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: Text(
                                  "FONCTIONNEL",
                                  style: gothicBold.copyWith(
                                      fontSize: 10, color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: 150, // Set the width here
                            margin: const EdgeInsets.symmetric(horizontal: 0),
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  isOuiSelected11 = false;
                                  isNonSelected11 = true;
                                });
                                step7_clignotantArriereDroitStatutsController.text = "non fonctionnel";
                                step7["phareArriereGaucheStatuts"] = step7_clignotantArriereDroitStatutsController.text;
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    isNonSelected11 ? Colors.grey[900] : Colors.grey),
                              ),
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: Text(
                                  "NON FONCTIONNEL",
                                  style: gothicBold.copyWith(
                                      fontSize: 10, color: Colors.white),
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
              // Phare Arrière Gauche
              Container(
                margin: const EdgeInsets.symmetric(horizontal:15),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        child: Text(
                          "Phare Arrière Gauche",
                          style: gothicBold.copyWith(fontSize: 14),
                        ),
                      ),

                      SizedBox(
                          height: 30,
                          child : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 120, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isValideChecked21 = !isValideChecked21;
                                      isInvalideChecked21 = false;
                                      isNonChecked21 = false;
                                    });
                                    step7_phareArriereGaucheStatutsController.text = "mauvais";
                                    step7["phareArriereGaucheStatuts"] = step7_phareArriereGaucheStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isValideChecked21 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "MAUVAIS",
                                      style: gothicBold.copyWith(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 100, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 5),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isInvalideChecked21 = !isInvalideChecked20;
                                      isValideChecked21 = false;
                                      isNonChecked21 = false;
                                    });
                                    step7_phareArriereGaucheStatutsController.text = "moyen";
                                    step7["phareArriereGaucheStatuts"] = step7_phareArriereGaucheStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isInvalideChecked21 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "MOYEN",
                                      style: gothicBold.copyWith(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 80, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isNonChecked21 = !isNonChecked21;
                                      isValideChecked21 = false;
                                      isInvalideChecked21 = false;
                                    });
                                    step7_phareArriereGaucheStatutsController.text = "bon";
                                    step7["phareArriereGaucheStatuts"] = step7_phareArriereGaucheStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isNonChecked21 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "BON",
                                      style: gothicBold.copyWith(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )
                      )
                    ]),

              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15 , vertical: 15),
                child: SizedBox(
                  height: 50, // Set your desired height here
                  child: CustomInputValidatore(
                    controller: step7_phareArriereGaucheCommentController,
                    labelText: null,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Field is required';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      step7["phareArriereGaucheComment"] = value!;
                    },
                    marginContainer: const EdgeInsets.only(bottom: 0, top: 0),
                    width: sizeWidth(context: context),
                    hintText: "Ecriver un commentaire ... *",
                    focusNode: step7_phareArriereGaucheCommentFocus,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 15 , horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        height: 150,
                        child: ElevatedButton(
                          onPressed: () async{
                            final ImagePicker picker = ImagePicker();
                            final XFile? imgFile = await picker.pickImage(source: ImageSource.gallery);
                            try {
                              if (imgFile != null) {
                                String base64Image = base64Encode(await imgFile.readAsBytes()!);
                                step7_phareArriereGaucheImageController.text = base64Image;
                                step7["phareArriereGaucheImage"] = step7_phareArriereGaucheImageController.text;
                              }
                            } catch (e) {
                              // print(e.toString());
                            }
                          },
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload,
                                size: 36,
                                color: Colors.black,
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Importer votre photo",
                                    style: TextStyle(fontSize: 18, color: Colors.black),
                                  ),
                                  Text(
                                    "  *",
                                    style: TextStyle(fontSize: 18, color: Colors.red),
                                  ),
                                ],
                              )

                            ],
                          ),
                        ),
                      ),
                    ),
                    // Add the second element here
                  ],
                ),
              ),
              // Ampoule Arrière Gauche
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15 ,vertical: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      child: Text(
                        "Ampoule Arrière Gauche",
                        style: gothicBold.copyWith(fontSize: 14),
                      ),
                    ),

                    SizedBox(
                      height: 30,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 120, // Set the width here
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  isOuiSelected12 = true;
                                  isNonSelected12 = false;
                                });
                                step7_ampouleArriereGaucheStatutsController.text = "fonctionnel";
                                step7["ampouleArriereGaucheStatuts"] = step7_ampouleArriereGaucheStatutsController.text;
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    isOuiSelected12 ? Colors.grey[900] : Colors.grey),
                              ),
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: Text(
                                  "FONCTIONNEL",
                                  style: gothicBold.copyWith(
                                      fontSize: 10, color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: 150, // Set the width here
                            margin: const EdgeInsets.symmetric(horizontal: 0),
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  isOuiSelected12 = false;
                                  isNonSelected12 = true;
                                });
                                step7_ampouleArriereGaucheStatutsController.text = "non fonctionnel";
                                step7["ampouleArriereGaucheStatuts"] = step7_ampouleArriereGaucheStatutsController.text;
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    isNonSelected12 ? Colors.grey[900] : Colors.grey),
                              ),
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: Text(
                                  "NON FONCTIONNEL",
                                  style: gothicBold.copyWith(
                                      fontSize: 10, color: Colors.white),
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
              // Clignotant Arrière Gauche
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15 ,vertical: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      child: Text(
                        "Clignotant Arrière Gauche",
                        style: gothicBold.copyWith(fontSize: 14),
                      ),
                    ),

                    SizedBox(
                      height: 30,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 120, // Set the width here
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  isOuiSelected13 = true;
                                  isNonSelected13 = false;
                                });
                                step7_clignotantArriereGaucheStatutsController.text = "fonctionnel";
                                step7["clignotantArriereGaucheStatuts"] = step7_clignotantArriereGaucheStatutsController.text;
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    isOuiSelected13 ? Colors.grey[900] : Colors.grey),
                              ),
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: Text(
                                  "FONCTIONNEL",
                                  style: gothicBold.copyWith(
                                      fontSize: 10, color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: 150, // Set the width here
                            margin: const EdgeInsets.symmetric(horizontal: 0),
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  isOuiSelected13 = false;
                                  isNonSelected13 = true;
                                });
                                step7_clignotantArriereGaucheStatutsController.text = "non fonctionnel";
                                step7["clignotantArriereGaucheStatuts"] = step7_clignotantArriereGaucheStatutsController.text;
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    isNonSelected13 ? Colors.grey[900] : Colors.grey),
                              ),
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: Text(
                                  "NON FONCTIONNEL",
                                  style: gothicBold.copyWith(
                                      fontSize: 10, color: Colors.white),
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
        ),
        isActive: _currentStep == 6,
      ),
      // 8
      Step(
        title: const Text('Pneumatique'),
        content: Form(
          key: _formKeys[7],
          child: Column(
            children: [
              // title
              Center(
                child: Container(
                  width: 250,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.all(20.0),
                      textStyle: const TextStyle(fontSize: 24 , color: Colors.white ),
                    ),
                    onPressed: () =>{},
                    child: const Text('Pneumatique' , style: TextStyle(color: Colors.white)),
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              // Progress bar
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 15), // Add margin here
                          child: Text(
                            "Etape 8/18",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 15), // Add margin here
                          child: Text(
                            "Diagnostic",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Center(
                child: Container(
                  width: 800.0, // Adjust the width as needed
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: LinearPercentIndicator(

                      animation: true,
                      backgroundColor: Colors.black,
                      animationDuration: 1000,
                      lineHeight: 10.0,
                      percent: 0.30,
                      barRadius: const Radius.circular(16),
                      //linearStrokeCap: LinearStrokeCap.butt,
                      progressColor: Colors.blue,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              // Pneu Avant Droit
              const SizedBox(
                height: 15,
              ),
              Center(
                child : Column(
                    children : [
                      const Text("Pneu Avant Droit",
                          style : TextStyle(
                            fontSize : 25,
                          ),
                      ),
                      Slider(
                        value: _currentSlider1Value,
                        max: 9,
                        activeColor : Colors.grey,
                        inactiveColor : Colors.grey[300],
                        divisions: 3,
                        label: _currentSlider1Value.round().toString(),
                        onChanged: (double value) {
                          setState(() {
                            _currentSlider1Value = value;
                          });
                          if (_currentSlider1Value == 0){
                            step8_pneuAvantDroitController.text = "mort";
                            step8["pneuAvantDroit"] = step8_pneuAvantDroitController.text;
                          }
                          if (_currentSlider1Value == 3){
                            step8_pneuAvantDroitController.text = "usé";
                            step8["pneuAvantDroit"] = step8_pneuAvantDroitController.text;
                          }
                          if (_currentSlider1Value == 6){
                            step8_pneuAvantDroitController.text = "correct";
                            step8["pneuAvantDroit"] = step8_pneuAvantDroitController.text;
                          }
                          if (_currentSlider1Value == 9){
                            step8_pneuAvantDroitController.text = "neuf";
                            step8["pneuAvantDroit"] = step8_pneuAvantDroitController.text;
                          }
                        },
                      ),
                      const Row(
                          mainAxisAlignment : MainAxisAlignment.spaceBetween,
                          children : [
                            Text("MORT"),
                            Text("USÉ"),
                            Text("CORRECT"),
                            Text("NEUF"),
                          ]
                      )
                    ]
                )
              ),
              // Pneu Avant Gauche
              const SizedBox(
                height: 15,
              ),
              Center(
                  child : Column(
                      children : [
                        const Text("Pneu Avant Gauche",
                          style : TextStyle(
                            fontSize : 25,
                          ),
                        ),
                        Slider(
                          value: _currentSlider2Value,
                          max: 9,
                          activeColor : Colors.grey,
                          inactiveColor : Colors.grey[300],
                          divisions: 3,
                          label: _currentSlider2Value.round().toString(),
                          onChanged: (double value) {
                            setState(() {
                              _currentSlider2Value = value;
                            });
                            if (_currentSlider2Value == 0){
                              step8_pneuAvantGaucheController.text = "mort";
                              step8["pneuAvantGauche"] = step8_pneuAvantGaucheController.text;
                            }
                            if (_currentSlider2Value == 3){
                              step8_pneuAvantGaucheController.text = "usé";
                              step8["pneuAvantGauche"] = step8_pneuAvantGaucheController.text;
                            }
                            if (_currentSlider2Value == 6){
                              step8_pneuAvantGaucheController.text = "correct";
                              step8["pneuAvantGauche"] = step8_pneuAvantGaucheController.text;
                            }
                            if (_currentSlider2Value == 9){
                              step8_pneuAvantGaucheController.text = "neuf";
                              step8["pneuAvantGauche"] = step8_pneuAvantGaucheController.text;
                            }
                          },
                        ),
                        const Row(
                            mainAxisAlignment : MainAxisAlignment.spaceBetween,
                            children : [
                              Text("MORT"),
                              Text("USÉ"),
                              Text("CORRECT"),
                              Text("NEUF"),
                            ]
                        )
                      ]
                  )
              ),
              // Pneu Arrière Droit
              const SizedBox(
                height: 15,
              ),
              Center(
                  child : Column(
                      children : [
                        const Text("Pneu Arrière Droit",
                          style : TextStyle(
                            fontSize : 25,
                          ),
                        ),
                        Slider(
                          value: _currentSlider3Value,
                          max: 9,
                          activeColor : Colors.grey,
                          inactiveColor : Colors.grey[300],
                          divisions: 3,
                          label: _currentSlider3Value.round().toString(),
                          onChanged: (double value) {
                            setState(() {
                              _currentSlider3Value = value;
                            });
                            if (_currentSlider3Value == 0){
                              step8_pneuArriereDroitController.text = "mort";
                              step8["pneuArriereDroit"] = step8_pneuArriereDroitController.text;
                            }
                            if (_currentSlider3Value == 3){
                              step8_pneuArriereDroitController.text = "usé";
                              step8["pneuArriereDroit"] = step8_pneuArriereDroitController.text;
                            }
                            if (_currentSlider3Value == 6){
                              step8_pneuArriereDroitController.text = "correct";
                              step8["pneuArriereDroit"] = step8_pneuArriereDroitController.text;
                            }
                            if (_currentSlider3Value == 9){
                              step8_pneuArriereDroitController.text = "neuf";
                              step8["pneuArriereDroit"] = step8_pneuArriereDroitController.text;
                            }
                          },
                        ),
                        const Row(
                            mainAxisAlignment : MainAxisAlignment.spaceBetween,
                            children : [
                              Text("MORT"),
                              Text("USÉ"),
                              Text("CORRECT"),
                              Text("NEUF"),
                            ]
                        )
                      ]
                  )
              ),
              // Pneu Arrière Gauche
              const SizedBox(
                height: 15,
              ),
              Center(
                  child : Column(
                      children : [
                        const Text("Pneu Arrière Gauche",
                          style : TextStyle(
                            fontSize : 25,
                          ),
                        ),
                        Slider(
                          value: _currentSlider4Value,
                          max: 9,
                          activeColor : Colors.grey,
                          inactiveColor : Colors.grey[300],
                          divisions: 3,
                          label: _currentSlider4Value.round().toString(),
                          onChanged: (double value) {
                            setState(() {
                              _currentSlider4Value = value;
                            });
                            if (_currentSlider4Value == 0){
                              step8_pneuArriereGaucheController.text = "mort";
                              step8["pneuArriereGauche"] = step8_pneuArriereGaucheController.text;
                            }
                            if (_currentSlider4Value == 3){
                              step8_pneuArriereGaucheController.text = "usé";
                              step8["pneuArriereGauche"] = step8_pneuArriereGaucheController.text;
                            }
                            if (_currentSlider4Value == 6){
                              step8_pneuArriereGaucheController.text = "correct";
                              step8["pneuArriereGauche"] = step8_pneuArriereGaucheController.text;
                            }
                            if (_currentSlider4Value == 9){
                              step8_pneuArriereGaucheController.text = "neuf";
                              step8["pneuArriereGauche"] = step8_pneuArriereGaucheController.text;
                            }
                          },
                        ),
                        const Row(
                            mainAxisAlignment : MainAxisAlignment.spaceBetween,
                            children : [
                              Text("MORT"),
                              Text("USÉ"),
                              Text("CORRECT"),
                              Text("NEUF"),
                            ]
                        )
                      ]
                  )
              ),
            ],
          ),
        ),
        isActive: _currentStep == 7,
      ),
      // 9
      Step(
        title: const Text('Intérieur'),
        content: Form(
          key: _formKeys[8],
          child: Column(
            children: [
              // title
              Center(
                child: Container(
                  width: 250,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.all(20.0),
                      textStyle: const TextStyle(fontSize: 24 , color: Colors.white ),
                    ),
                    onPressed: () =>{},
                    child: const Text('Intérieur' , style: TextStyle(color: Colors.white),),
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              // Progress bar
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 15), // Add margin here
                          child: Text(
                            "Etape 9/18",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 15), // Add margin here
                          child: Text(
                            "Diagnostic",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Center(
                child: Container(
                  width: 800.0, // Adjust the width as needed
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: LinearPercentIndicator(

                      animation: true,
                      backgroundColor: Colors.black,
                      animationDuration: 1000,
                      lineHeight: 10.0,
                      percent: 0.32,
                      barRadius: const Radius.circular(16),
                      //linearStrokeCap: LinearStrokeCap.butt,
                      progressColor: Colors.blue,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              // Apparence Géneral
              const SizedBox(
                height: 30,
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal:15),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(

                        child: Text(
                          "Apparence Géneral",
                          style: gothicBold.copyWith(fontSize: 15),
                        ),
                      ),

                      SizedBox(
                          height: 30,
                          child : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 115, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isValideChecked22 = !isValideChecked22;
                                      isInvalideChecked22 = false;
                                      isNonChecked22 = false;
                                    });
                                    step9_apparenceGeneraleStatutsController.text = "mauvais";
                                    step9["apparenceGeneraleStatuts"] = step9_apparenceGeneraleStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isValideChecked22 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "MAUVAIS",
                                      style: gothicBold.copyWith(
                                          fontSize: 10, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 95, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 5),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isInvalideChecked22 = !isInvalideChecked22;
                                      isValideChecked22 = false;
                                      isNonChecked22 = false;
                                    });
                                    step9_apparenceGeneraleStatutsController.text = "moyen";
                                    step9["apparenceGeneraleStatuts"] = step9_apparenceGeneraleStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isInvalideChecked22 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "MOYEN",
                                      style: gothicBold.copyWith(
                                          fontSize: 10, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 75, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isNonChecked22 = !isNonChecked22;
                                      isValideChecked22 = false;
                                      isInvalideChecked22 = false;
                                    });
                                    step9_apparenceGeneraleStatutsController.text = "bon";
                                    step9["apparenceGeneraleStatuts"] = step9_apparenceGeneraleStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isNonChecked22 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "BON",
                                      style: gothicBold.copyWith(
                                          fontSize: 10, color: Colors.white),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )
                      )
                    ]),

              ),
              const SizedBox(
                height: 60,
              ),
              // Siège Avant Gauch (ceinture bouclé)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Siège Avant Gauch (ceinture bouclé)",
                        style:
                        gothicBold.copyWith(
                            fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15),
                child: SizedBox(
                  height: 50, // Set your desired height here
                  child: CustomInputValidatore(
                    controller: step9_siegeAvantGaucheCommentController,
                    labelText: null,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Field is required';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      step9["siegeAvantGaucheComment"] = value!;
                    },
                    marginContainer: const EdgeInsets.only(bottom: 0, top: 0),
                    width: sizeWidth(context: context),
                    hintText: "Ecriver un commentaire ... *",
                    focusNode: step9_siegeAvantGaucheCommentFocus,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15 , vertical: 30 ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(

                        height: 150,
                        child: ElevatedButton(
                          onPressed: () async {
                            final ImagePicker picker = ImagePicker();
                            final XFile? imgFile = await picker.pickImage(source: ImageSource.gallery);
                            try {
                              if (imgFile != null) {
                                String base64Image = base64Encode(await imgFile.readAsBytes()!);
                                step9_siegeAvantGaucheImageController.text = base64Image;
                                step9["siegeAvantGaucheImage"] = step9_siegeAvantGaucheImageController.text;
                              }
                            } catch (e) {
                              // print(e.toString());
                            }
                          },
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload, // Add your upload icon here
                                size: 36,
                                color: Colors.black,
                              ),
                              SizedBox(height: 10), // Add some spacing between icon and text


                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Importer votre photo",
                                    style: TextStyle(fontSize: 18, color: Colors.black),
                                  ),
                                  Text(
                                    "  *",
                                    style: TextStyle(fontSize: 18, color: Colors.red),
                                  ),
                                ],
                              )


                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Siège Avant Droit (ceinture bouclé)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Siège Avant Droit (ceinture bouclé)",
                        style:
                        gothicBold.copyWith(
                            fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15),
                child: SizedBox(
                  height: 50, // Set your desired height here
                  child: CustomInputValidatore(
                    controller: step9_siegeAvantDroitCommentController,
                    labelText: null,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Field is required';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      step9["siegeAvantDroitComment"] = value!;
                    },
                    marginContainer: const EdgeInsets.only(bottom: 0, top: 0),
                    width: sizeWidth(context: context),
                    hintText: "Ecriver un commentaire ... *",
                    focusNode: step9_siegeAvantDroitCommentFocus,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15 , vertical: 30 ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(

                        height: 150,
                        child: ElevatedButton(
                          onPressed: () async {
                            final ImagePicker picker = ImagePicker();
                            final XFile? imgFile = await picker.pickImage(source: ImageSource.gallery);
                            try {
                              if (imgFile != null) {
                                String base64Image = base64Encode(await imgFile.readAsBytes()!);
                                step9_siegeAvantDroitImageController.text = base64Image;
                                step9["siegeAvantDroitImage"] = step9_siegeAvantDroitImageController.text;
                              }
                            } catch (e) {
                              // print(e.toString());
                            }
                          },
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload, // Add your upload icon here
                                size: 36,
                                color: Colors.black,
                              ),
                              SizedBox(height: 10), // Add some spacing between icon and text

                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Importer votre photo",
                                    style: TextStyle(fontSize: 18, color: Colors.black),
                                  ),
                                  Text(
                                    "  *",
                                    style: TextStyle(fontSize: 18, color: Colors.red),
                                  ),
                                ],
                              )

                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Banquette Arrière (ceintures bouclés)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Banquette Arrière (ceintures bouclés)",
                        style:
                        gothicBold.copyWith(
                            fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15),
                child: SizedBox(
                  height: 50, // Set your desired height here
                  child: CustomInputValidatore(
                    controller: step9_banquetteArriereCommentController,
                    labelText: null,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Field is required';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      step9["banquetteArriereComment"] = value!;
                    },
                    marginContainer: const EdgeInsets.only(bottom: 0, top: 0),
                    width: sizeWidth(context: context),
                    hintText: "Ecriver un commentaire ... *",
                    focusNode: step9_banquetteArriereCommentFocus,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15 , vertical: 30 ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(

                        height: 150,
                        child: ElevatedButton(
                          onPressed: () async {
                            final ImagePicker picker = ImagePicker();
                            final XFile? imgFile = await picker.pickImage(source: ImageSource.gallery);
                            try {
                              if (imgFile != null) {
                                String base64Image = base64Encode(await imgFile.readAsBytes()!);
                                step9_banquetteArriereImageController.text = base64Image;
                                step9["banquetteArriereImage"] = step9_banquetteArriereImageController.text;
                              }
                            } catch (e) {
                              // print(e.toString());
                            }
                          },
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload, // Add your upload icon here
                                size: 36,
                                color: Colors.black,
                              ),
                              SizedBox(height: 10), // Add some spacing between icon and text
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Importer votre photo",
                                    style: TextStyle(fontSize: 18, color: Colors.black),
                                  ),
                                  Text(
                                    "  *",
                                    style: TextStyle(fontSize: 18, color: Colors.red),
                                  ),
                                ],
                              )

                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Autres photos (7 place ou +)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Autres photos (7 place ou +)",
                        style:
                        gothicBold.copyWith(
                            fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15),
                child: SizedBox(
                  height: 50, // Set your desired height here
                  child: CustomInputValidatore(
                    controller: step9_autrePhotosCommentController,
                    labelText: null,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Field is required';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      step9["autrePhotosComment"] = value!;
                    },
                    marginContainer: const EdgeInsets.only(bottom: 0, top: 0),
                    width: sizeWidth(context: context),
                    hintText: "Ecriver un commentaire ... *",
                    focusNode: step9_autrePhotosCommentFocus,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15 , vertical: 30 ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(

                        height: 150,
                        child: ElevatedButton(
                          onPressed: () async {
                            final ImagePicker picker = ImagePicker();
                            final XFile? imgFile = await picker.pickImage(source: ImageSource.gallery);
                            try {
                              if (imgFile != null) {
                                String base64Image = base64Encode(await imgFile.readAsBytes()!);
                                step9_autrePhotosImageController.text = base64Image;
                                step9["autrePhotosImage"] = step9_autrePhotosImageController.text;
                              }
                            } catch (e) {
                              // print(e.toString());
                            }
                          },
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload, // Add your upload icon here
                                size: 36,
                                color: Colors.black,
                              ),
                              SizedBox(height: 10), // Add some spacing between icon and text
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Importer votre photo",
                                    style: TextStyle(fontSize: 18, color: Colors.black),
                                  ),
                                  Text(
                                    "  *",
                                    style: TextStyle(fontSize: 18, color: Colors.red),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Tableau de bord
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Tableau de bord",
                        style:
                        gothicBold.copyWith(
                            fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15),
                child: SizedBox(
                  height: 50, // Set your desired height here
                  child: CustomInputValidatore(
                    controller: step9_tableauBordCommentController,
                    labelText: null,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Field is required';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      step9["tableauBordComment"] = value!;
                    },
                    marginContainer: const EdgeInsets.only(bottom: 0, top: 0),
                    width: sizeWidth(context: context),
                    hintText: "Ecriver un commentaire ... *",
                    focusNode: step9_tableauBordCommentFocus,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15 , vertical: 30 ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(

                        height: 150,
                        child: ElevatedButton(
                          onPressed: () async {
                            final ImagePicker picker = ImagePicker();
                            final XFile? imgFile = await picker.pickImage(source: ImageSource.gallery);
                            try {
                              if (imgFile != null) {
                                String base64Image = base64Encode(await imgFile.readAsBytes()!);
                                step9_tableauBordImage_1Controller.text = base64Image;
                                step9["tableauBordImage_1"] = step9_tableauBordImage_1Controller.text;
                              }
                            } catch (e) {
                              // print(e.toString());
                            }
                          },
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload, // Add your upload icon here
                                size: 36,
                                color: Colors.black,
                              ),
                              SizedBox(height: 10), // Add some spacing between icon and text

                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Importer votre photo",
                                    style: TextStyle(fontSize: 18, color: Colors.black),
                                  ),
                                  Text(
                                    "  *",
                                    style: TextStyle(fontSize: 18, color: Colors.red),
                                  ),
                                ],
                              )

                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15 , vertical: 30 ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(

                        height: 150,
                        child: ElevatedButton(
                          onPressed: () async {
                            final ImagePicker picker = ImagePicker();
                            final XFile? imgFile = await picker.pickImage(source: ImageSource.gallery);
                            try {
                              if (imgFile != null) {
                                String base64Image = base64Encode(await imgFile.readAsBytes()!);
                                step9_tableauBordImage_2Controller.text = base64Image;
                                step9["tableauBordImage_2"] = step9_tableauBordImage_2Controller.text;
                              }
                            } catch (e) {
                              // print(e.toString());
                            }
                          },
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload, // Add your upload icon here
                                size: 36,
                                color: Colors.black,
                              ),
                              SizedBox(height: 10), // Add some spacing between icon and text
                              Text(
                                "Importer votre photo",
                                style: TextStyle(fontSize: 18, color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        isActive: _currentStep == 8,
      ),
      // 10
      Step(
        title: const Text('Intérieur avis') ,
        content: Form(
          key: _formKeys[9],
          child: Column(
            children: [
              // title
              Center(
                child: Container(
                  width: 250,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.all(20.0),
                      textStyle: const TextStyle(fontSize: 24 , color: Colors.white ),
                    ),
                    onPressed: () =>{},
                    child: const Text('Intérieur avis' , style: TextStyle(color: Colors.white),),
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              // Progress bar
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 15), // Add margin here
                          child: Text(
                            "Etape 10/18",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 15), // Add margin here
                          child: Text(
                            "Diagnostic",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Center(
                child: Container(
                  width: 800.0, // Adjust the width as needed
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: LinearPercentIndicator(

                      animation: true,
                      backgroundColor: Colors.black,
                      animationDuration: 1000,
                      lineHeight: 10.0,
                      percent: 0.35,
                      barRadius: const Radius.circular(16),
                      //linearStrokeCap: LinearStrokeCap.butt,
                      progressColor: Colors.blue,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              // Commentaire Général
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Commentaire Général sur l'interieur ?",
                        style:
                        gothicBold.copyWith(
                            fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "sièges, tableau de bord, usres,défauts,trous...",
                        style:
                        gothicBold.copyWith(
                            fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15 , vertical : 15),
                child: SizedBox(
                  height: 50, // Set your desired height here
                  child: CustomInputValidatore(
                    controller: step10_interieurAvisCommentController,
                    labelText: null,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Field is required';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      step10["interieurAvisComment"] = value!;
                    },
                    marginContainer: const EdgeInsets.only(bottom: 0, top: 0),
                    width: sizeWidth(context: context),
                    hintText: "Ecriver un commentaire ... *",
                    focusNode: step10_interieurAvisCommentFocus,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15 , vertical: 30 ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(

                        height: 150,
                        child: ElevatedButton(
                          onPressed: () async {
                            final ImagePicker picker = ImagePicker();
                            final XFile? imgFile = await picker.pickImage(source: ImageSource.gallery);
                            try {
                              if (imgFile != null) {
                                String base64Image = base64Encode(await imgFile.readAsBytes()!);
                                step10_interieurAvisImageController.text = base64Image;
                                step10["interieurAvisImage"] = step10_interieurAvisImageController.text;
                              }
                            } catch (e) {
                              // print(e.toString());
                            }
                          },
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload, // Add your upload icon here
                                size: 36,
                                color: Colors.black,
                              ),
                              SizedBox(height: 10), // Add some spacing between icon and text
                              Text(
                                "Importer votre photo",
                                style: TextStyle(fontSize: 18, color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15 , vertical: 30 ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(

                        height: 150,
                        child: ElevatedButton(
                          onPressed: () async {
                            final ImagePicker picker = ImagePicker();
                            final XFile? imgFile = await picker.pickImage(source: ImageSource.gallery);
                            try {
                              if (imgFile != null) {
                                String base64Image = base64Encode(await imgFile.readAsBytes()!);
                                step10_interieurAvisImageController.text = base64Image;
                                step10["interieurAvisImage1"] = step10_interieurAvisImage1Controller.text;
                              }
                            } catch (e) {
                              // print(e.toString());
                            }
                          },
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload, // Add your upload icon here
                                size: 36,
                                color: Colors.black,
                              ),
                              SizedBox(height: 10), // Add some spacing between icon and text
                              Text(
                                "Importer votre photo",
                                style: TextStyle(fontSize: 18, color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Conforme à l'annonce
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15 ,vertical: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      child: Text(
                        "Conforme à l'annonce",
                        style: gothicBold.copyWith(fontSize: 18),
                      ),
                    ),

                    SizedBox(
                      height: 30,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 100, // Set the width here
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  isOuiSelected14 = true;
                                  isNonSelected14 = false;
                                });
                                step10_conformeAnnonceStatuts_2Controller.text = "oui";
                                step10["conformeAnnonceStatuts_2"] = step10_conformeAnnonceStatuts_2Controller.text;
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    isOuiSelected14 ? Colors.grey[900] : Colors.grey),
                              ),
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: Text(
                                  "OUI",
                                  style: gothicBold.copyWith(
                                      fontSize: 12, color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: 80, // Set the width here
                            margin: const EdgeInsets.symmetric(horizontal: 0),
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  isOuiSelected14 = false;
                                  isNonSelected14 = true;
                                });
                                step10_conformeAnnonceStatuts_2Controller.text = "non";
                                step10["conformeAnnonceStatuts_2"] = step10_conformeAnnonceStatuts_2Controller.text;
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    isNonSelected14 ? Colors.grey[900] : Colors.grey),
                              ),
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: Text(
                                  "NON",
                                  style: gothicBold.copyWith(
                                      fontSize: 12, color: Colors.white),
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
        ),
        isActive: _currentStep == 9,
      ),
      // 11
      Step(
        title: const Text('Électronique'),
        content: Form(
          key: _formKeys[10],
          child: Column(
            children: [
              // title
              Center(
                child: Container(
                  width: 250,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.all(20.0),
                      textStyle: const TextStyle(fontSize: 24 , color: Colors.white ),
                    ),
                    onPressed: () =>{},
                    child: const Text('Électronique' , style: TextStyle(color: Colors.white),),
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              // Progress bar
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 15), // Add margin here
                          child: Text(
                            "Etape 11/18",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 15), // Add margin here
                          child: Text(
                            "Diagnostic",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Center(
                child: Container(
                  width: 800.0, // Adjust the width as needed
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: LinearPercentIndicator(

                      animation: true,
                      backgroundColor: Colors.black,
                      animationDuration: 1000,
                      lineHeight: 10.0,
                      percent: 0.50,
                      barRadius: const Radius.circular(16),
                      //linearStrokeCap: LinearStrokeCap.butt,
                      progressColor: Colors.blue,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              // Présence de voyant compteur
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15 ,vertical: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      child: Text(
                        "Présence de voyant compteur",
                        style: gothicBold.copyWith(fontSize: 18),
                      ),
                    ),

                    SizedBox(
                      height: 30,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 100, // Set the width here
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  isOuiSelected15 = true;
                                  isNonSelected15 = false;
                                });
                                step11_presenceCompteurStatutsController.text = "oui";
                                step11["presenceCompteurStatuts"] = step11_presenceCompteurStatutsController.text;
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    isOuiSelected15 ? Colors.grey[900] : Colors.grey),
                              ),
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: Text(
                                  "OUI",
                                  style: gothicBold.copyWith(
                                      fontSize: 12, color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: 80, // Set the width here
                            margin: const EdgeInsets.symmetric(horizontal: 0),
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  isOuiSelected15 = false;
                                  isNonSelected15 = true;
                                });
                                step11_presenceCompteurStatutsController.text = "non";
                                step11["presenceCompteurStatuts"] = step11_presenceCompteurStatutsController.text;
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    isNonSelected15 ? Colors.grey[900] : Colors.grey),
                              ),
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: Text(
                                  "NON",
                                  style: gothicBold.copyWith(
                                      fontSize: 12, color: Colors.white),
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
              // Compteur (moteur allumé)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Compteur (moteur allumé)",
                        style:
                        gothicBold.copyWith(
                            fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15 , vertical:0 ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(

                        height: 150,
                        child: ElevatedButton(
                          onPressed: () async {
                            final ImagePicker picker = ImagePicker();
                            final XFile? imgFile = await picker.pickImage(source: ImageSource.gallery);
                            try {
                              if (imgFile != null) {
                                String base64Image = base64Encode(await imgFile.readAsBytes()!);
                                step11_compteurImage_1Controller.text = base64Image;
                                step11["compteurImage_1"] = step11_compteurImage_1Controller.text;
                              }
                            } catch (e) {
                              // print(e.toString());
                            }
                          },
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload, // Add your upload icon here
                                size: 36,
                                color: Colors.black,
                              ),
                              SizedBox(height: 10), // Add some spacing between icon and text
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Importer votre photo",
                                    style: TextStyle(fontSize: 18, color: Colors.black),
                                  ),
                                  Text(
                                    "  *",
                                    style: TextStyle(fontSize: 18, color: Colors.red),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15 , vertical: 30 ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(

                        height: 150,
                        child: ElevatedButton(
                          onPressed: () async {
                            final ImagePicker picker = ImagePicker();
                            final XFile? imgFile = await picker.pickImage(source: ImageSource.gallery);
                            try {
                              if (imgFile != null) {
                                String base64Image = base64Encode(await imgFile.readAsBytes()!);
                                step11_compteurImage_2Controller.text = base64Image;
                                step11["compteurImage_2"] = step11_compteurImage_2Controller.text;
                              }
                            } catch (e) {
                              // print(e.toString());
                            }
                          },
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload, // Add your upload icon here
                                size: 36,
                                color: Colors.black,
                              ),
                              SizedBox(height: 10), // Add some spacing between icon and text
                              Text(
                                "Importer votre photo",
                                style: TextStyle(fontSize: 18, color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Airbags
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15 ,vertical: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      child: Text(
                        "Airbags",
                        style: gothicBold.copyWith(fontSize: 18),
                      ),
                    ),

                    SizedBox(
                      height: 30,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 150, // Set the width here
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  isOuiSelected16 = true;
                                  isNonSelected16 = false;
                                });
                                step11_airbagStatutsController.text = "fonctionnel";
                                step11["airbagStatuts"] = step11_airbagStatutsController.text;
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    isOuiSelected16 ? Colors.grey[900] : Colors.grey),
                              ),
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: Text(
                                  "FONCTIONNEL",
                                  style: gothicBold.copyWith(
                                      fontSize: 12, color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: 170, // Set the width here
                            margin: const EdgeInsets.symmetric(horizontal: 0),
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  isOuiSelected16 = false;
                                  isNonSelected16 = true;
                                });
                                step11_airbagStatutsController.text = "non fonctionnel";
                                step11["airbagStatuts"] = step11_airbagStatutsController.text;
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    isNonSelected16 ? Colors.grey[900] : Colors.grey),
                              ),
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: Text(
                                  "NON FONCTIONNEL",
                                  style: gothicBold.copyWith(
                                      fontSize: 12, color: Colors.white),
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
              // Ceintures
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15 ,vertical: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      child: Text(
                        "Ceintures",
                        style: gothicBold.copyWith(fontSize: 18),
                      ),
                    ),

                    SizedBox(
                      height: 30,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 150, // Set the width here
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  isOuiSelected17 = true;
                                  isNonSelected17 = false;
                                });
                                step11_ceinturesStatutsController.text = "fonctionnel";
                                step11["ceinturesStatuts"] = step11_ceinturesStatutsController.text;
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    isOuiSelected17 ? Colors.grey[900] : Colors.grey),
                              ),
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: Text(
                                  "FONCTIONNEL",
                                  style: gothicBold.copyWith(
                                      fontSize: 12, color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: 170, // Set the width here
                            margin: const EdgeInsets.symmetric(horizontal: 0),
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  isOuiSelected17 = false;
                                  isNonSelected17 = true;
                                });
                                step11_ceinturesStatutsController.text = "non fonctionnel";
                                step11["ceinturesStatuts"] = step11_ceinturesStatutsController.text;
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    isNonSelected17 ? Colors.grey[900] : Colors.grey),
                              ),
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: Text(
                                  "NON FONCTIONNEL",
                                  style: gothicBold.copyWith(
                                      fontSize: 12, color: Colors.white),
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
              // Vitres
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15 ,vertical: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      child: Text(
                        "Vitres",
                        style: gothicBold.copyWith(fontSize: 18),
                      ),
                    ),

                    SizedBox(
                      height: 30,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 150, // Set the width here
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  isOuiSelected18 = true;
                                  isNonSelected18 = false;
                                });
                                step11_vitresStatutsController.text = "fonctionnel";
                                step11["vitresStatuts"] = step11_vitresStatutsController.text;
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    isOuiSelected18 ? Colors.grey[900] : Colors.grey),
                              ),
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: Text(
                                  "FONCTIONNEL",
                                  style: gothicBold.copyWith(
                                      fontSize: 12, color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: 170, // Set the width here
                            margin: const EdgeInsets.symmetric(horizontal: 0),
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  isOuiSelected18 = false;
                                  isNonSelected18 = true;
                                });
                                step11_vitresStatutsController.text = "non fonctionnel";
                                step11["vitresStatuts"] = step11_vitresStatutsController.text;
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    isNonSelected18 ? Colors.grey[900] : Colors.grey),
                              ),
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: Text(
                                  "NON FONCTIONNEL",
                                  style: gothicBold.copyWith(
                                      fontSize: 12, color: Colors.white),
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
              // Réglage des rétroviseurs
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15 ,vertical: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      child: Text(
                        "Réglage des rétroviseurs",
                        style: gothicBold.copyWith(fontSize: 14),
                      ),
                    ),

                    SizedBox(
                      height: 30,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 120, // Set the width here
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  isOuiSelected19 = true;
                                  isNonSelected19 = false;
                                });
                                step11_reglageRetroviseursStatutsController.text = "fonctionnel";
                                step11["reglageRetroviseursStatuts"] = step11_reglageRetroviseursStatutsController.text;
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    isOuiSelected19 ? Colors.grey[900] : Colors.grey),
                              ),
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: Text(
                                  "FONCTIONNEL",
                                  style: gothicBold.copyWith(
                                      fontSize: 10, color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: 150, // Set the width here
                            margin: const EdgeInsets.symmetric(horizontal: 0),
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  isOuiSelected19 = false;
                                  isNonSelected19 = true;
                                });
                                step11_reglageRetroviseursStatutsController.text = "non fonctionnel";
                                step11["reglageRetroviseursStatuts"] = step11_reglageRetroviseursStatutsController.text;
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    isNonSelected19 ? Colors.grey[900] : Colors.grey),
                              ),
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: Text(
                                  "NON FONCTIONNEL",
                                  style: gothicBold.copyWith(
                                      fontSize: 10, color: Colors.white),
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
              // Enceints Véhicules
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15 ,vertical: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      child: Text(
                        "Enceints Véhicules",
                        style: gothicBold.copyWith(fontSize: 14),
                      ),
                    ),

                    SizedBox(
                      height: 30,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 120, // Set the width here
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  isOuiSelected20 = true;
                                  isNonSelected20 = false;
                                });
                                step11_enceinteVehiculesStatutsController.text = "fonctionnel";
                                step11["enceinteVéhiculesStatuts"] = step11_enceinteVehiculesStatutsController.text;
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    isOuiSelected20 ? Colors.grey[900] : Colors.grey),
                              ),
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: Text(
                                  "FONCTIONNEL",
                                  style: gothicBold.copyWith(
                                      fontSize: 10, color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: 150, // Set the width here
                            margin: const EdgeInsets.symmetric(horizontal: 0),
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  isOuiSelected20 = false;
                                  isNonSelected20 = true;
                                });
                                step11_enceinteVehiculesStatutsController.text = "non fonctionnel";
                                step11["enceinteVéhiculesStatuts"] = step11_enceinteVehiculesStatutsController.text;
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    isNonSelected20 ? Colors.grey[900] : Colors.grey),
                              ),
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: Text(
                                  "NON FONCTIONNEL",
                                  style: gothicBold.copyWith(
                                      fontSize: 10, color: Colors.white),
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
              // Panneaux de Portes
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15 ,vertical: 15),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        child: Text(
                          "Panneaux de Portes ",
                          style: gothicBold.copyWith(fontSize: 14),
                        ),
                      ),

                      SizedBox(
                          height: 30,
                          child : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 115, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isValideChecked23 = !isValideChecked23;
                                      isInvalideChecked23 = false;
                                      isNonChecked23 = false;
                                    });
                                    step11_panneauPortesStatutsController.text = "mauvais";
                                    step11["panneauPortesStatuts"] = step11_panneauPortesStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isValideChecked23 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "MAUVAIS",
                                      style: gothicBold.copyWith(
                                          fontSize: 10, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 95, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 5),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isInvalideChecked23 = !isInvalideChecked23;
                                      isValideChecked23 = false;
                                      isNonChecked23 = false;
                                    });
                                    step11_panneauPortesStatutsController.text = "moyen";
                                    step11["panneauPortesStatuts"] = step11_panneauPortesStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isInvalideChecked23 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "MOYEN",
                                      style: gothicBold.copyWith(
                                          fontSize: 10, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 75, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isNonChecked23 = !isNonChecked23;
                                      isValideChecked23 = false;
                                      isInvalideChecked23 = false;
                                    });
                                    step11_panneauPortesStatutsController.text = "bon";
                                    step11["panneauPortesStatuts"] = step11_panneauPortesStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isNonChecked23 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "BON",
                                      style: gothicBold.copyWith(
                                          fontSize: 10, color: Colors.white),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )
                      )
                    ]),

              ),
              // Panneau de Coffre
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15 ,vertical: 15),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        child: Text(
                          "Panneau de Coffre",
                          style: gothicBold.copyWith(fontSize: 14),
                        ),
                      ),

                      SizedBox(
                          height: 30,
                          child : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 115, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isValideChecked24 = !isValideChecked24;
                                      isInvalideChecked24 = false;
                                      isNonChecked24 = false;
                                    });
                                    step11_panneauCoffreStatutsController.text = "mauvais";
                                    step11["panneauCoffreStatuts"] = step11_panneauCoffreStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isValideChecked24 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "MAUVAIS",
                                      style: gothicBold.copyWith(
                                          fontSize: 10, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 95, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 5),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isInvalideChecked24 = !isInvalideChecked24;
                                      isValideChecked24 = false;
                                      isNonChecked24 = false;
                                    });
                                    step11_panneauCoffreStatutsController.text = "moyen";
                                    step11["panneauCoffreStatuts"] = step11_panneauCoffreStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isInvalideChecked24 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "MOYEN",
                                      style: gothicBold.copyWith(
                                          fontSize: 10, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 75, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isNonChecked24 = !isNonChecked24;
                                      isValideChecked24 = false;
                                      isInvalideChecked24 = false;
                                    });
                                    step11_panneauCoffreStatutsController.text = "bon";
                                    step11["panneauCoffreStatuts"] = step11_panneauCoffreStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isNonChecked24 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "BON",
                                      style: gothicBold.copyWith(
                                          fontSize: 10, color: Colors.white),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )
                      )
                    ]),

              ),
              // Conforme à l'annoce
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15 ,vertical: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      child: Text(
                        "Enceints Véhicules",
                        style: gothicBold.copyWith(fontSize: 18),
                      ),
                    ),

                    SizedBox(
                      height: 30,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 100, // Set the width here
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  isOuiSelected25 = true;
                                  isNonSelected25 = false;
                                });
                                step11_conformeAnnonceStatuts_3Controller.text = "oui";
                                step11["conformeAnnonceStatuts_3"] = step11_conformeAnnonceStatuts_3Controller.text;
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    isOuiSelected25 ? Colors.grey[900] : Colors.grey),
                              ),
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: Text(
                                  "OUI",
                                  style: gothicBold.copyWith(
                                      fontSize: 12, color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: 100, // Set the width here
                            margin: const EdgeInsets.symmetric(horizontal: 0),
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  isOuiSelected25 = false;
                                  isNonSelected25 = true;
                                });
                                step11_conformeAnnonceStatuts_3Controller.text = "non";
                                step11["conformeAnnonceStatuts_3"] = step11_conformeAnnonceStatuts_3Controller.text;
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    isNonSelected25 ? Colors.grey[900] : Colors.grey),
                              ),
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: Text(
                                  "NON",
                                  style: gothicBold.copyWith(
                                      fontSize: 12, color: Colors.white),
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
        ),
        isActive: _currentStep == 10,
      ),
      // 12
      Step(
        title: const Text('Moteur'),
        content: Form(
          key: _formKeys[11],
          child: Column(
            children: [
              // title
              Center(
                child: Container(
                  width: 250,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.all(20.0),
                      textStyle: const TextStyle(fontSize: 24 , color: Colors.white ),
                    ),
                    onPressed: () =>{},
                    child: const Text('Moteur' , style: TextStyle(color: Colors.white),),
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              // Progress bar
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 15), // Add margin here
                          child: Text(
                            "Etape 12/18",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 15), // Add margin here
                          child: Text(
                            "Diagnostic",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Center(
                child: Container(
                  width: 800.0, // Adjust the width as needed
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: LinearPercentIndicator(

                      animation: true,
                      backgroundColor: Colors.black,
                      animationDuration: 1000,
                      lineHeight: 10.0,
                      percent: 0.55,
                      barRadius: const Radius.circular(16),
                      //linearStrokeCap: LinearStrokeCap.butt,
                      progressColor: Colors.blue,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              // Propreté du moteur
              Container(
                margin: const EdgeInsets.symmetric(horizontal:15),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        child: Text(
                          "Propreté du moteur",
                          style: gothicBold.copyWith(fontSize: 18),
                        ),
                      ),

                      SizedBox(
                          height: 30,
                          child : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 115, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isValideChecked25 = !isValideChecked25;
                                      isInvalideChecked25 = false;
                                      isNonChecked25 = false;
                                    });
                                    step12_propreteMoteurStatutsController.text = "mauvais";
                                    step12["propreteMoteurStatuts"] = step12_propreteMoteurStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isValideChecked25 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "MAUVAIS",
                                      style: gothicBold.copyWith(
                                          fontSize: 10, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 95, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 5),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isInvalideChecked25 = !isInvalideChecked25;
                                      isValideChecked25 = false;
                                      isNonChecked25 = false;
                                    });
                                    step12_propreteMoteurStatutsController.text = "moyen";
                                    step12["propreteMoteurStatuts"] = step12_propreteMoteurStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isInvalideChecked25 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "MOYEN",
                                      style: gothicBold.copyWith(
                                          fontSize: 10, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 75, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isNonChecked25 = !isNonChecked25;
                                      isValideChecked25 = false;
                                      isInvalideChecked25 = false;
                                    });
                                    step12_propreteMoteurStatutsController.text = "bon";
                                    step12["propreteMoteurStatuts"] = step12_propreteMoteurStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isNonChecked25 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "BON",
                                      style: gothicBold.copyWith(
                                          fontSize: 10, color: Colors.white),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )
                      )
                    ]),

              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 15 , horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        height: 150,
                        child: ElevatedButton(
                          onPressed: () async{
                            final ImagePicker picker = ImagePicker();
                            final XFile? imgFile = await picker.pickImage(source: ImageSource.gallery);
                            try {
                              if (imgFile != null) {
                                String base64Image = base64Encode(await imgFile.readAsBytes()!);
                                step12_propreteMoteurImageController.text = base64Image;
                                step12["propreteMoteurImage"] = step12_propreteMoteurImageController.text;
                              }
                            } catch (e) {
                              // print(e.toString());
                            }
                          },
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload,
                                size: 36,
                                color: Colors.black,
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Importer votre photo",
                                    style: TextStyle(fontSize: 18, color: Colors.black),
                                  ),
                                  Text(
                                    "  *",
                                    style: TextStyle(fontSize: 18, color: Colors.red),
                                  ),
                                ],
                              )

                            ],
                          ),
                        ),
                      ),
                    ),
                    // Add the second element here
                  ],
                ),
              ),
              // Niveau d'eau
              Container(
                margin: const EdgeInsets.symmetric(horizontal:15),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        child: Text(
                          "Niveau d'eau ",
                          style: gothicBold.copyWith(fontSize: 18),
                        ),
                      ),

                      SizedBox(
                          height: 30,
                          child : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 120, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isValideChecked26 = !isValideChecked26;
                                      isInvalideChecked26 = false;
                                      isNonChecked26 = false;
                                    });
                                    step12_niveauEauStatutsController.text = "mauvais";
                                    step12["niveauEauStatuts"] = step12_niveauEauStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isValideChecked26 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "MAUVAIS",
                                      style: gothicBold.copyWith(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 100, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 5),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isInvalideChecked26 = !isInvalideChecked26;
                                      isValideChecked26 = false;
                                      isNonChecked26 = false;
                                    });
                                    step12_niveauEauStatutsController.text = "moyen";
                                    step12["niveauEauStatuts"] = step12_niveauEauStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isInvalideChecked26 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "MOYEN",
                                      style: gothicBold.copyWith(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 80, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isNonChecked26 = !isNonChecked26;
                                      isValideChecked26 = false;
                                      isInvalideChecked26 = false;
                                    });
                                    step12_niveauEauStatutsController.text = "bon";
                                    step12["niveauEauStatuts"] = step12_niveauEauStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isNonChecked26 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "BON",
                                      style: gothicBold.copyWith(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )
                      )
                    ]),

              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 15 , horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        height: 150,
                        child: ElevatedButton(
                          onPressed: () async{
                            final ImagePicker picker = ImagePicker();
                            final XFile? imgFile = await picker.pickImage(source: ImageSource.gallery);
                            try {
                              if (imgFile != null) {
                                String base64Image = base64Encode(await imgFile.readAsBytes()!);
                                step12_niveauEauImageController.text = base64Image;
                                step7["niveauEauImage"] = step12_niveauEauImageController.text;
                              }
                            } catch (e) {
                              // print(e.toString());
                            }
                          },
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload,
                                size: 36,
                                color: Colors.black,
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Importer votre photo",
                                    style: TextStyle(fontSize: 18, color: Colors.black),
                                  ),
                                  Text(
                                    "  *",
                                    style: TextStyle(fontSize: 18, color: Colors.red),
                                  ),
                                ],
                              )

                            ],
                          ),
                        ),
                      ),
                    ),
                    // Add the second element here
                  ],
                ),
              ),
              // Niveau d'huile
              Container(
                margin: const EdgeInsets.symmetric(horizontal:15,vertical:15),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        child: Text(
                          "Niveau d'huile ",
                          style: gothicBold.copyWith(fontSize: 18),
                        ),
                      ),

                      SizedBox(
                          height: 30,
                          child : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 120, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isValideChecked27 = !isValideChecked27;
                                      isInvalideChecked27 = false;
                                      isNonChecked27 = false;
                                    });
                                    step12_niveauHuileStatutsController.text = "mauvais";
                                    step12["niveauHuileStatuts"] = step12_niveauHuileStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isValideChecked27 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "MAUVAIS",
                                      style: gothicBold.copyWith(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 100, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 5),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isInvalideChecked27 = !isInvalideChecked27;
                                      isValideChecked27 = false;
                                      isNonChecked27 = false;
                                    });
                                    step12_niveauHuileStatutsController.text = "moyen";
                                    step12["niveauHuileStatuts"] = step12_niveauHuileStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isInvalideChecked27 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "MOYEN",
                                      style: gothicBold.copyWith(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 80, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isNonChecked27 = !isNonChecked27;
                                      isValideChecked27 = false;
                                      isInvalideChecked27 = false;
                                    });
                                    step12_niveauHuileStatutsController.text = "bon";
                                    step12["niveauHuileStatuts"] = step12_niveauHuileStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isNonChecked27 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "BON",
                                      style: gothicBold.copyWith(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )
                      )
                    ]),

              ),
              // Transmission (cardon)
              Container(
                margin: const EdgeInsets.symmetric(horizontal:15),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        child: Text(
                          "Transmission (cardon)",
                          style: gothicBold.copyWith(fontSize: 15),
                        ),
                      ),

                      SizedBox(
                          height: 30,
                          child : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 115, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isValideChecked28 = !isValideChecked28;
                                      isInvalideChecked28 = false;
                                      isNonChecked28 = false;
                                    });
                                    step12_transmissionStatutsController.text = "mauvais";
                                    step12["transmissionStatuts"] = step12_transmissionStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isValideChecked28 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "MAUVAIS",
                                      style: gothicBold.copyWith(
                                          fontSize: 10, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 95, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 5),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isInvalideChecked28 = !isInvalideChecked27;
                                      isValideChecked28 = false;
                                      isNonChecked28= false;
                                    });
                                    step12_transmissionStatutsController.text = "moyen";
                                    step12["transmissionStatuts"] = step12_transmissionStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isInvalideChecked28 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "MOYEN",
                                      style: gothicBold.copyWith(
                                          fontSize: 10, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 75, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isNonChecked28 = !isNonChecked28;
                                      isValideChecked28 = false;
                                      isInvalideChecked28 = false;
                                    });
                                    step12_transmissionStatutsController.text = "bon";
                                    step12["transmissionStatuts"] = step12_transmissionStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isNonChecked28 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "BON",
                                      style: gothicBold.copyWith(
                                          fontSize: 10, color: Colors.white),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )
                      )
                    ]),

              ),
              const SizedBox(
                height: 60,
              ),
              // Avis sur l'etat du moteur
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Avis sur l'etat du moteur ?",
                        style:
                        gothicBold.copyWith(
                            fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "propreté,état,niveaux...",
                        style:
                        gothicBold.copyWith(
                            fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15 , vertical : 15),
                child: SizedBox(
                  height: 50, // Set your desired height here
                  child: CustomInputValidatore(
                    controller: step12_avisMoteurCommentController,
                    labelText: null,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Field is required';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      step12["avisMoteurComment"] = value!;
                    },
                    marginContainer: const EdgeInsets.only(bottom: 0, top: 0),
                    width: sizeWidth(context: context),
                    hintText: "Ecriver un commentaire ... *",
                    focusNode: step12_avisMoteurCommentFocus,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15 , vertical: 30 ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(

                        height: 150,
                        child: ElevatedButton(
                          onPressed: () async {
                            final ImagePicker picker = ImagePicker();
                            final XFile? imgFile = await picker.pickImage(source: ImageSource.gallery);
                            try {
                              if (imgFile != null) {
                                String base64Image = base64Encode(await imgFile.readAsBytes()!);
                                step12_avisMoteurImageController.text = base64Image;
                                step10["avisMoteurImage"] = step12_avisMoteurImageController.text;
                              }
                            } catch (e) {
                              // print(e.toString());
                            }
                          },
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload, // Add your upload icon here
                                size: 36,
                                color: Colors.black,
                              ),
                              SizedBox(height: 10), // Add some spacing between icon and text
                              Text(
                                "Importer votre photo",
                                style: TextStyle(fontSize: 18, color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Conforme à l'annonce
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15 ,vertical: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      child: Text(
                        "Conforme à l'annonce",
                        style: gothicBold.copyWith(fontSize: 18),
                      ),
                    ),

                    SizedBox(
                      height: 100,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 100, // Set the width here
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  isOuiSelected21 = true;
                                  isNonSelected21 = false;
                                });
                                step12_conformeAnnonceStatuts_4Controller.text = "oui";
                                step10["conformeAnnonceStatuts_4"] = step12_conformeAnnonceStatuts_4Controller.text;
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    isOuiSelected21 ? Colors.grey[900] : Colors.grey),
                              ),
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: Text(
                                  "OUI",
                                  style: gothicBold.copyWith(
                                      fontSize: 12, color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: 100, // Set the width here
                            margin: const EdgeInsets.symmetric(horizontal: 0),
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  isOuiSelected21 = false;
                                  isNonSelected21 = true;
                                });
                                step12_conformeAnnonceStatuts_4Controller.text = "non";
                                step10["conformeAnnonceStatuts_4"] = step12_conformeAnnonceStatuts_4Controller.text;
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    isNonSelected21 ? Colors.grey[900] : Colors.grey),
                              ),
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: Text(
                                  "NON",
                                  style: gothicBold.copyWith(
                                      fontSize: 12, color: Colors.white),
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
        ),
        isActive: _currentStep == 11,
      ),
      // 13
      Step(
        title: const Text('Roue AVG') ,
        content: Form(
          key: _formKeys[12],
          child: Column(
            children: [
              // title
              Center(
                child: Container(
                  width: 250,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.all(20.0),
                      textStyle: const TextStyle(fontSize: 24 , color: Colors.white ),
                    ),
                    onPressed: () =>{},
                    child: const Text('Roue AVG' , style: TextStyle(color: Colors.white),),
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              // Progress bar
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 15), // Add margin here
                          child: Text(
                            "Etape 13/18",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 15), // Add margin here
                          child: Text(
                            "Diagnostic",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Center(
                child: Container(
                  width: 800.0, // Adjust the width as needed
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: LinearPercentIndicator(

                      animation: true,
                      backgroundColor: Colors.black,
                      animationDuration: 1000,
                      lineHeight: 10.0,
                      percent: 0.59,
                      barRadius: const Radius.circular(16),
                      //linearStrokeCap: LinearStrokeCap.butt,
                      progressColor: Colors.blue,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              // Roue Avant Gauche Levée
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Roue Avant Gauche Levée",
                        style:
                        gothicBold.copyWith(
                            fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15 , vertical: 30 ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 150,
                        child: ElevatedButton(
                          onPressed: () async {
                            final ImagePicker picker = ImagePicker();
                            final XFile? imgFile = await picker.pickImage(source: ImageSource.gallery);
                            try {
                              if (imgFile != null) {
                                String base64Image = base64Encode(await imgFile.readAsBytes()!);
                                step13_roueAvantGaucheLeveImageController.text = base64Image;
                                step13["roueAvantGaucheLeveImage"] = step13_roueAvantGaucheLeveImageController.text;
                              }
                            } catch (e) {
                              // print(e.toString());
                            }
                          },
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload, // Add your upload icon here
                                size: 36,
                                color: Colors.black,
                              ),
                              SizedBox(height: 10), // Add some spacing between icon and text
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Importer votre photo",
                                    style: TextStyle(fontSize: 18, color: Colors.black),
                                  ),
                                  Text(
                                    "  *",
                                    style: TextStyle(fontSize: 18, color: Colors.red),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Rotule Triangle G
              Container(
                margin: const EdgeInsets.symmetric(horizontal:15),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        child: Text(
                          "Rotule Triangle G",
                          style: gothicBold.copyWith(fontSize: 18),
                        ),
                      ),

                      SizedBox(
                          height: 30,
                          child : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 120, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isValideChecked29 = !isValideChecked29;
                                      isInvalideChecked29 = false;
                                      isNonChecked29 = false;
                                    });
                                    step13_rotuleTriangleGaucheStatutsController.text = "mauvais";
                                    step13["rotuleTriangleGaucheStatuts"] = step13_rotuleTriangleGaucheStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isValideChecked29 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "MAUVAIS",
                                      style: gothicBold.copyWith(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 100, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 5),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isInvalideChecked29 = !isInvalideChecked29;
                                      isValideChecked29 = false;
                                      isNonChecked29 = false;
                                    });
                                    step13_rotuleTriangleGaucheStatutsController.text = "moyen";
                                    step13["rotuleTriangleGaucheStatuts"] = step13_rotuleTriangleGaucheStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isInvalideChecked29 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "MOYEN",
                                      style: gothicBold.copyWith(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 80, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isNonChecked29 = !isNonChecked29;
                                      isValideChecked29 = false;
                                      isInvalideChecked29 = false;
                                    });
                                    step13_rotuleTriangleGaucheStatutsController.text = "bon";
                                    step13["rotuleTriangleGaucheStatuts"] = step13_rotuleTriangleGaucheStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isNonChecked29 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "BON",
                                      style: gothicBold.copyWith(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )
                      )
                    ]),

              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 15 , horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        height: 150,
                        child: ElevatedButton(
                          onPressed: () async{
                            final ImagePicker picker = ImagePicker();
                            final XFile? imgFile = await picker.pickImage(source: ImageSource.gallery);
                            try {
                              if (imgFile != null) {
                                String base64Image = base64Encode(await imgFile.readAsBytes()!);
                                step13_rotuleTriangleGaucheImageController.text = base64Image;
                                step13["rotuleTriangleGaucheImage"] = step13_rotuleTriangleGaucheImageController.text;
                              }
                            } catch (e) {
                              // print(e.toString());
                            }
                          },
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload,
                                size: 36,
                                color: Colors.black,
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Importer votre photo",
                                    style: TextStyle(fontSize: 18, color: Colors.black),
                                  ),

                                ],
                              )

                            ],
                          ),
                        ),
                      ),
                    ),
                    // Add the second element here
                  ],
                ),
              ),
              // Routule Barre Dir. G
              Container(
                margin: const EdgeInsets.symmetric(horizontal:15),
                child: Row(
                    children: [
                      SizedBox(
                        child: Text(
                          "Routule Barre Stable Dir. G",
                          style: gothicBold.copyWith(fontSize: 15),
                        ),
                      ),

                      SizedBox(
                          height: 30,
                          child : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 100, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isValideChecked30 = !isValideChecked30;
                                      isInvalideChecked30 = false;
                                      isNonChecked30 = false;
                                    });
                                    step13_rotuleBarreStableGaucheStatutsController.text = "mauvais";
                                    step13["rotuleBarreStableGaucheStatuts"] = step13_rotuleBarreStableGaucheStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isValideChecked30 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "MAUVAIS",
                                      style: gothicBold.copyWith(
                                          fontSize: 10, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 90, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 5),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isInvalideChecked30 = !isInvalideChecked30;
                                      isValideChecked30 = false;
                                      isNonChecked30 = false;
                                    });
                                    step13_rotuleBarreStableGaucheStatutsController.text = "moyen";
                                    step13["rotuleBarreStableGaucheStatuts"] = step13_rotuleBarreStableGaucheStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isInvalideChecked30 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "MOYEN",
                                      style: gothicBold.copyWith(
                                          fontSize: 10, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 70, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isNonChecked30 = !isNonChecked30;
                                      isValideChecked30 = false;
                                      isInvalideChecked30 = false;
                                    });
                                    step13_rotuleBarreStableGaucheStatutsController.text = "bon";
                                    step13["rotuleBarreStableGaucheStatuts"] = step13_rotuleBarreStableGaucheStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isNonChecked30 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "BON",
                                      style: gothicBold.copyWith(
                                          fontSize: 10, color: Colors.white),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )
                      )
                    ]),

              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 15 , horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        height: 150,
                        child: ElevatedButton(
                          onPressed: () async{
                            final ImagePicker picker = ImagePicker();
                            final XFile? imgFile = await picker.pickImage(source: ImageSource.gallery);
                            try {
                              if (imgFile != null) {
                                String base64Image = base64Encode(await imgFile.readAsBytes()!);
                                step13_rotuleBarreStableGaucheImageController.text = base64Image;
                                step13["rotuleBarreStableGaucheImage"] = step13_rotuleBarreStableGaucheImageController.text;
                              }
                            } catch (e) {
                              // print(e.toString());
                            }
                          },
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload,
                                size: 36,
                                color: Colors.black,
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Importer votre photo",
                                    style: TextStyle(fontSize: 18, color: Colors.black),
                                  ),
                                ],
                              )

                            ],
                          ),
                        ),
                      ),
                    ),
                    // Add the second element here
                  ],
                ),
              ),
              // Rotule Bielette Dir. G
              Container(
                margin: const EdgeInsets.symmetric(horizontal:15),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        child: Text(
                          "Rotule Bielette Dir. G",
                          style: gothicBold.copyWith(fontSize: 15),
                        ),
                      ),

                      SizedBox(
                          height: 30,
                          child : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 115, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isValideChecked31 = !isValideChecked31;
                                      isInvalideChecked31 = false;
                                      isNonChecked31 = false;
                                    });
                                    step13_rotuleBilleteDirectionGaucheStatutsController.text = "mauvais";
                                    step13["rotuleBilleteDirectionGaucheStatuts"] = step13_rotuleBilleteDirectionGaucheStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isValideChecked31 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "MAUVAIS",
                                      style: gothicBold.copyWith(
                                          fontSize: 10, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 95, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 5),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isInvalideChecked31 = !isInvalideChecked31;
                                      isValideChecked31 = false;
                                      isNonChecked31 = false;
                                    });
                                    step13_rotuleBilleteDirectionGaucheStatutsController.text = "moyen";
                                    step13["rotuleBilleteDirectionGaucheStatuts"] = step13_rotuleBilleteDirectionGaucheStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isInvalideChecked31 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "MOYEN",
                                      style: gothicBold.copyWith(
                                          fontSize: 10, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 75, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isNonChecked31 = !isNonChecked31;
                                      isValideChecked31 = false;
                                      isInvalideChecked31 = false;
                                    });
                                    step13_rotuleBilleteDirectionGaucheStatutsController.text = "bon";
                                    step13["rotuleBilleteDirectionGaucheStatuts"] = step13_rotuleBilleteDirectionGaucheStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isNonChecked31 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "BON",
                                      style: gothicBold.copyWith(
                                          fontSize: 10, color: Colors.white),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )
                      )
                    ]),

              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 15 , horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        height: 150,
                        child: ElevatedButton(
                          onPressed: () async{
                            final ImagePicker picker = ImagePicker();
                            final XFile? imgFile = await picker.pickImage(source: ImageSource.gallery);
                            try {
                              if (imgFile != null) {
                                String base64Image = base64Encode(await imgFile.readAsBytes()!);
                                step13_rotuleBilleteDirectionGaucheImageController.text = base64Image;
                                step13["roulementGaucheStatuts"] = step13_rotuleBilleteDirectionGaucheImageController.text;
                              }
                            } catch (e) {
                              // print(e.toString());
                            }
                          },
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload,
                                size: 36,
                                color: Colors.black,
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Importer votre photo",
                                    style: TextStyle(fontSize: 18, color: Colors.black),
                                  ),

                                ],
                              )

                            ],
                          ),
                        ),
                      ),
                    ),
                    // Add the second element here
                  ],
                ),
              ),
              // Roulement G
              Container(
                margin: const EdgeInsets.symmetric(horizontal:15),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        child: Text(
                          "Roulement G",
                          style: gothicBold.copyWith(fontSize: 18),
                        ),
                      ),

                      SizedBox(
                          height: 30,
                          child : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 120, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isValideChecked36 = !isValideChecked36;
                                      isInvalideChecked36 = false;
                                      isNonChecked36 = false;
                                    });
                                    step13_roulementGaucheStatutsController.text = "mauvais";
                                    step13["roulementGaucheStatuts"] = step13_roulementGaucheStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isValideChecked36 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "MAUVAIS",
                                      style: gothicBold.copyWith(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 100, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 5),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isInvalideChecked36 = !isInvalideChecked36;
                                      isValideChecked36 = false;
                                      isNonChecked36 = false;
                                    });
                                    step13_roulementGaucheStatutsController.text = "moyen";
                                    step13["roulementGaucheStatuts"] = step13_roulementGaucheStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isInvalideChecked36 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "MOYEN",
                                      style: gothicBold.copyWith(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 80, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isNonChecked36 = !isNonChecked36;
                                      isValideChecked36 = false;
                                      isInvalideChecked36 = false;
                                    });
                                    step13_roulementGaucheStatutsController.text = "bon";
                                    step13["roulementGaucheStatuts"] = step13_roulementGaucheStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isNonChecked36 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "BON",
                                      style: gothicBold.copyWith(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )
                      )
                    ]),

              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 15 , horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        height: 150,
                        child: ElevatedButton(
                          onPressed: () async{
                            final ImagePicker picker = ImagePicker();
                            final XFile? imgFile = await picker.pickImage(source: ImageSource.gallery);
                            try {
                              if (imgFile != null) {
                                String base64Image = base64Encode(await imgFile.readAsBytes()!);
                                step13_roulementGaucheImageController.text = base64Image;
                                step13["roulementGaucheImage"] = step13_roulementGaucheImageController.text;
                              }
                            } catch (e) {
                              // print(e.toString());
                            }
                          },
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload,
                                size: 36,
                                color: Colors.black,
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Importer votre photo",
                                    style: TextStyle(fontSize: 18, color: Colors.black),
                                  ),

                                ],
                              )

                            ],
                          ),
                        ),
                      ),
                    ),
                    // Add the second element here
                  ],
                ),
              ),
              // Suspension G
              Container(
                margin: const EdgeInsets.symmetric(horizontal:15),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        child: Text(
                          "Suspension G",
                          style: gothicBold.copyWith(fontSize: 18),
                        ),
                      ),

                      SizedBox(
                          height: 30,
                          child : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 120, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isValideChecked32 = !isValideChecked32;
                                      isInvalideChecked32 = false;
                                      isNonChecked32 = false;
                                    });
                                    step13_suspensionGaucheStatutsController.text = "mauvais";
                                    step13["suspensionGaucheStatuts"] = step13_suspensionGaucheStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isValideChecked32 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "MAUVAIS",
                                      style: gothicBold.copyWith(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 100, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 5),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isInvalideChecked32 = !isInvalideChecked32;
                                      isValideChecked32 = false;
                                      isNonChecked32 = false;
                                    });
                                    step13_suspensionGaucheStatutsController.text = "moyen";
                                    step13["suspensionGaucheStatuts"] = step13_suspensionGaucheStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isInvalideChecked32 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "MOYEN",
                                      style: gothicBold.copyWith(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 80, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isNonChecked32 = !isNonChecked32;
                                      isValideChecked32 = false;
                                      isInvalideChecked32 = false;
                                    });
                                    step13_suspensionGaucheStatutsController.text = "bon";
                                    step13["suspensionGaucheStatuts"] = step13_suspensionGaucheStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isNonChecked32 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "BON",
                                      style: gothicBold.copyWith(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )
                      )
                    ]),

              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 15 , horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        height: 150,
                        child: ElevatedButton(
                          onPressed: () async{
                            final ImagePicker picker = ImagePicker();
                            final XFile? imgFile = await picker.pickImage(source: ImageSource.gallery);
                            try {
                              if (imgFile != null) {
                                String base64Image = base64Encode(await imgFile.readAsBytes()!);
                                step13_suspensionGaucheImageController.text = base64Image;
                                step13["suspensionGaucheImage"] = step13_suspensionGaucheImageController.text;
                              }
                            } catch (e) {
                              // print(e.toString());
                            }
                          },
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload,
                                size: 36,
                                color: Colors.black,
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Importer votre photo",
                                    style: TextStyle(fontSize: 18, color: Colors.black),
                                  ),

                                ],
                              )

                            ],
                          ),
                        ),
                      ),
                    ),
                    // Add the second element here
                  ],
                ),
              ),
              // Disque G
              Container(
                margin: const EdgeInsets.symmetric(horizontal:15),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        child: Text(
                          "Disque G",
                          style: gothicBold.copyWith(fontSize: 18),
                        ),
                      ),

                      SizedBox(
                          height: 30,
                          child : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 120, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isValideChecked33 = !isValideChecked33;
                                      isInvalideChecked33 = false;
                                      isNonChecked33 = false;
                                    });
                                    step13_disqueGaucheStatutsController.text = "mauvais";
                                    step13["disqueGaucheStatuts"] = step13_disqueGaucheStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isValideChecked33 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "MAUVAIS",
                                      style: gothicBold.copyWith(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 100, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 5),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isInvalideChecked33 = !isInvalideChecked33;
                                      isValideChecked33 = false;
                                      isNonChecked33 = false;
                                    });
                                    step13_disqueGaucheStatutsController.text = "moyen";
                                    step13["disqueGaucheStatuts"] = step13_disqueGaucheStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isInvalideChecked33 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "MOYEN",
                                      style: gothicBold.copyWith(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 80, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isNonChecked33 = !isNonChecked33;
                                      isValideChecked33 = false;
                                      isInvalideChecked33 = false;
                                    });
                                    step13_rotuleTriangleGaucheStatutsController.text = "bon";
                                    step13["disqueGaucheStatuts"] = step13_disqueGaucheStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isNonChecked33 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "BON",
                                      style: gothicBold.copyWith(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )
                      )
                    ]),

              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 15 , horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        height: 150,
                        child: ElevatedButton(
                          onPressed: () async{
                            final ImagePicker picker = ImagePicker();
                            final XFile? imgFile = await picker.pickImage(source: ImageSource.gallery);
                            try {
                              if (imgFile != null) {
                                String base64Image = base64Encode(await imgFile.readAsBytes()!);
                                step13_disqueGaucheImageController.text = base64Image;
                                step13["disqueGaucheImage"] = step13_disqueGaucheImageController.text;
                              }
                            } catch (e) {
                              // print(e.toString());
                            }
                          },
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload,
                                size: 36,
                                color: Colors.black,
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Importer votre photo",
                                    style: TextStyle(fontSize: 18, color: Colors.black),
                                  ),

                                ],
                              )

                            ],
                          ),
                        ),
                      ),
                    ),
                    // Add the second element here
                  ],
                ),
              ),
              // Plaquette G
              Container(
                margin: const EdgeInsets.symmetric(horizontal:15),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        child: Text(
                          "Plaquette G",
                          style: gothicBold.copyWith(fontSize: 18),
                        ),
                      ),

                      SizedBox(
                          height: 30,
                          child : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 120, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isValideChecked34 = !isValideChecked34;
                                      isInvalideChecked34 = false;
                                      isNonChecked34 = false;
                                    });
                                    step13_plaquetteGaucheStatutsController.text = "mauvais";
                                    step13["plaquetteGaucheStatuts"] = step13_plaquetteGaucheStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isValideChecked34 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "MAUVAIS",
                                      style: gothicBold.copyWith(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 100, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 5),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isInvalideChecked34 = !isInvalideChecked34;
                                      isValideChecked34 = false;
                                      isNonChecked34 = false;
                                    });
                                    step13_plaquetteGaucheStatutsController.text = "moyen";
                                    step13["plaquetteGaucheStatuts"] = step13_plaquetteGaucheStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isInvalideChecked34 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "MOYEN",
                                      style: gothicBold.copyWith(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 80, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isNonChecked34 = !isNonChecked34;
                                      isValideChecked34 = false;
                                      isInvalideChecked34 = false;
                                    });
                                    step13_plaquetteGaucheStatutsController.text = "bon";
                                    step13["plaquetteGaucheStatuts"] = step13_plaquetteGaucheStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isNonChecked34 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "BON",
                                      style: gothicBold.copyWith(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )
                      )
                    ]),

              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 15 , horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        height: 150,
                        child: ElevatedButton(
                          onPressed: () async{
                            final ImagePicker picker = ImagePicker();
                            final XFile? imgFile = await picker.pickImage(source: ImageSource.gallery);
                            try {
                              if (imgFile != null) {
                                String base64Image = base64Encode(await imgFile.readAsBytes()!);
                                step13_plaquetteGaucheImageController.text = base64Image;
                                step13["plaquetteGaucheImage"] = step13_plaquetteGaucheImageController.text;
                              }
                            } catch (e) {
                              // print(e.toString());
                            }
                          },
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload,
                                size: 36,
                                color: Colors.black,
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Importer votre photo",
                                    style: TextStyle(fontSize: 18, color: Colors.black),
                                  ),

                                ],
                              )

                            ],
                          ),
                        ),
                      ),
                    ),
                    // Add the second element here
                  ],
                ),
              ),
              // Cardan G
              Container(
                margin: const EdgeInsets.symmetric(horizontal:15),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        child: Text(
                          "Cardan G",
                          style: gothicBold.copyWith(fontSize: 18),
                        ),
                      ),

                      SizedBox(
                          height: 30,
                          child : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 120, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isValideChecked35 = !isValideChecked35;
                                      isInvalideChecked35 = false;
                                      isNonChecked35 = false;
                                    });
                                    step13_cardanGaucheStatutsController.text = "mauvais";
                                    step13["cardanGaucheStatuts"] = step13_cardanGaucheStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isValideChecked35 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "MAUVAIS",
                                      style: gothicBold.copyWith(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 100, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 5),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isInvalideChecked35 = !isInvalideChecked35;
                                      isValideChecked35 = false;
                                      isNonChecked35 = false;
                                    });
                                    step13_cardanGaucheStatutsController.text = "moyen";
                                    step13["cardanGaucheStatuts"] = step13_cardanGaucheStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isInvalideChecked35 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "MOYEN",
                                      style: gothicBold.copyWith(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 80, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isNonChecked35 = !isNonChecked35;
                                      isValideChecked35 = false;
                                      isInvalideChecked35 = false;
                                    });
                                    step13_cardanGaucheStatutsController.text = "bon";
                                    step13["cardanGaucheStatuts"] = step13_cardanGaucheStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isNonChecked35 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "BON",
                                      style: gothicBold.copyWith(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )
                      )
                    ]),

              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 15 , horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        height: 150,
                        child: ElevatedButton(
                          onPressed: () async{
                            final ImagePicker picker = ImagePicker();
                            final XFile? imgFile = await picker.pickImage(source: ImageSource.gallery);
                            try {
                              if (imgFile != null) {
                                String base64Image = base64Encode(await imgFile.readAsBytes()!);
                                step13_cardanGaucheImageController.text = base64Image;
                                step12["cardanGaucheImage"] = step13_cardanGaucheImageController.text;
                              }
                            } catch (e) {
                              // print(e.toString());
                            }
                          },
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload,
                                size: 36,
                                color: Colors.black,
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Importer votre photo",
                                    style: TextStyle(fontSize: 18, color: Colors.black),
                                  ),

                                ],
                              )

                            ],
                          ),
                        ),
                      ),
                    ),
                    // Add the second element here
                  ],
                ),
              ),
            ],
          ),
        ),
        isActive: _currentStep == 12,
      ),
      // 14
      Step(
        title: const Text('Roue AVD'),
        content: Form(
          key: _formKeys[13],
          child: Column(
            children: [
              // title
              Center(
                child: Container(
                  width: 250,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.all(20.0),
                      textStyle: const TextStyle(fontSize: 24 , color: Colors.white ),
                    ),
                    onPressed: () =>{},
                    child: const Text('Roue AVD' , style: TextStyle(color: Colors.white),),
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              // Progress bar
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 15), // Add margin here
                          child: Text(
                            "Etape 14/18",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 15), // Add margin here
                          child: Text(
                            "Diagnostic",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Center(
                child: Container(
                  width: 800.0, // Adjust the width as needed
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: LinearPercentIndicator(

                      animation: true,
                      backgroundColor: Colors.black,
                      animationDuration: 1000,
                      lineHeight: 10.0,
                      percent: 0.62,
                      barRadius: const Radius.circular(16),
                      //linearStrokeCap: LinearStrokeCap.butt,
                      progressColor: Colors.blue,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              // Roue Avant Droite Levée
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Roue Avant Droite Levée",
                        style:
                        gothicBold.copyWith(
                            fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15 , vertical: 30 ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 150,
                        child: ElevatedButton(
                          onPressed: () async {
                            final ImagePicker picker = ImagePicker();
                            final XFile? imgFile = await picker.pickImage(source: ImageSource.gallery);
                            try {
                              if (imgFile != null) {
                                String base64Image = base64Encode(await imgFile.readAsBytes()!);
                                step14_roueAvantDroitLeveImageController.text = base64Image;
                                step14["roueAvantDroitLeveImage"] = step14_roueAvantDroitLeveImageController.text;
                              }
                            } catch (e) {
                              // print(e.toString());
                            }
                          },
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload, // Add your upload icon here
                                size: 36,
                                color: Colors.black,
                              ),
                              SizedBox(height: 10), // Add some spacing between icon and text
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Importer votre photo",
                                    style: TextStyle(fontSize: 18, color: Colors.black),
                                  ),
                                  Text(
                                    "  *",
                                    style: TextStyle(fontSize: 18, color: Colors.red),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Rotule Triangle D
              Container(
                margin: const EdgeInsets.symmetric(horizontal:15),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        child: Text(
                          "Rotule Triangle D",
                          style: gothicBold.copyWith(fontSize: 15),
                        ),
                      ),

                      SizedBox(
                          height: 30,
                          child : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 115, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isValideChecked37 = !isValideChecked37;
                                      isInvalideChecked37 = false;
                                      isNonChecked37 = false;
                                    });
                                    step14_rotuleTriangleDroitStatutsController.text = "mauvais";
                                    step13["rotuleTriangleDroitStatuts"] = step14_rotuleTriangleDroitStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isValideChecked37 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "MAUVAIS",
                                      style: gothicBold.copyWith(
                                          fontSize: 10, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 95, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 5),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isInvalideChecked37 = !isInvalideChecked37;
                                      isValideChecked37 = false;
                                      isNonChecked37 = false;
                                    });
                                    step14_rotuleTriangleDroitStatutsController.text = "moyen";
                                    step13["rotuleTriangleDroitStatuts"] = step14_rotuleTriangleDroitStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isInvalideChecked37 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "MOYEN",
                                      style: gothicBold.copyWith(
                                          fontSize: 10, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 75, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isNonChecked37 = !isNonChecked37;
                                      isValideChecked37 = false;
                                      isInvalideChecked37 = false;
                                    });
                                    step14_rotuleTriangleDroitStatutsController.text = "bon";
                                    step13["rotuleTriangleDroitStatuts"] = step14_rotuleTriangleDroitStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isNonChecked37 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "BON",
                                      style: gothicBold.copyWith(
                                          fontSize: 10, color: Colors.white),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )
                      )
                    ]),

              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 15 , horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        height: 150,
                        child: ElevatedButton(
                          onPressed: () async{
                            final ImagePicker picker = ImagePicker();
                            final XFile? imgFile = await picker.pickImage(source: ImageSource.gallery);
                            try {
                              if (imgFile != null) {
                                String base64Image = base64Encode(await imgFile.readAsBytes()!);
                                step14_rotuleTriangleDroitImageController.text = base64Image;
                                step14["rotuleTriangleDroitImage"] = step14_rotuleTriangleDroitImageController.text;
                              }
                            } catch (e) {
                              // print(e.toString());
                            }
                          },
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload,
                                size: 36,
                                color: Colors.black,
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Importer votre photo",
                                    style: TextStyle(fontSize: 18, color: Colors.black),
                                  ),

                                ],
                              )

                            ],
                          ),
                        ),
                      ),
                    ),
                    // Add the second element here
                  ],
                ),
              ),
              // Routule Barre Dir. D
              Container(
                margin: const EdgeInsets.symmetric(horizontal:15),
                child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        child: Text(
                          "Routule Barre Dir. D",
                          style: gothicBold.copyWith(fontSize: 15),
                        ),
                      ),

                      SizedBox(
                          height: 30,
                          child : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 115, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isValideChecked38 = !isValideChecked38;
                                      isInvalideChecked38 = false;
                                      isNonChecked38 = false;
                                    });
                                    step14_rotuleBarreStableDroitStatutsController.text = "mauvais";
                                    step14["rotuleBarreStableDroitStatuts"] = step14_rotuleBarreStableDroitStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isValideChecked38 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "MAUVAIS",
                                      style: gothicBold.copyWith(
                                          fontSize: 10, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 95, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 5),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isInvalideChecked38 = !isInvalideChecked30;
                                      isValideChecked38 = false;
                                      isNonChecked38 = false;
                                    });
                                    step14_rotuleBarreStableDroitStatutsController.text = "moyen";
                                    step14["rotuleBarreStableDroitStatuts"] = step14_rotuleBarreStableDroitStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isInvalideChecked38 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "MOYEN",
                                      style: gothicBold.copyWith(
                                          fontSize: 10, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 75, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isNonChecked38 = !isNonChecked38;
                                      isValideChecked38 = false;
                                      isInvalideChecked38 = false;
                                    });
                                    step14_rotuleBarreStableDroitStatutsController.text = "bon";
                                    step14["rotuleBarreStableDroitStatuts"] = step14_rotuleBarreStableDroitStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isNonChecked38 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "BON",
                                      style: gothicBold.copyWith(
                                          fontSize: 10, color: Colors.white),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )
                      )
                    ]),

              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 15 , horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        height: 150,
                        child: ElevatedButton(
                          onPressed: () async{
                            final ImagePicker picker = ImagePicker();
                            final XFile? imgFile = await picker.pickImage(source: ImageSource.gallery);
                            try {
                              if (imgFile != null) {
                                String base64Image = base64Encode(await imgFile.readAsBytes()!);
                                step14_rotuleBarreStableDroitImageController.text = base64Image;
                                step14["rotuleBarreStableDroitImage"] = step14_rotuleBarreStableDroitImageController.text;
                              }
                            } catch (e) {
                              // print(e.toString());
                            }
                          },
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload,
                                size: 36,
                                color: Colors.black,
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Importer votre photo",
                                    style: TextStyle(fontSize: 18, color: Colors.black),
                                  ),
                                  Text(
                                    "  *",
                                    style: TextStyle(fontSize: 18, color: Colors.red),
                                  ),
                                ],
                              )

                            ],
                          ),
                        ),
                      ),
                    ),
                    // Add the second element here
                  ],
                ),
              ),
              // Routule Bielette Dir. D
              Container(
                margin: const EdgeInsets.symmetric(horizontal:15),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        child: Text(
                          "Routule Bielette Dir. D",
                           style: gothicBold.copyWith(fontSize: 15),
                        ),
                      ),

                      SizedBox(
                          height: 30,
                          child : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 115, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isValideChecked39 = !isValideChecked39;
                                      isInvalideChecked39 = false;
                                      isNonChecked39 = false;
                                    });
                                    step14_rotuleBilleteDirectionDroitStatutsController.text = "mauvais";
                                    step14["rotuleBilleteDirectionDroitStatuts"] = step14_rotuleBilleteDirectionDroitStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isValideChecked39 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "MAUVAIS",
                                      style: gothicBold.copyWith(
                                          fontSize: 10, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 95, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 5),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isInvalideChecked39 = !isInvalideChecked39;
                                      isValideChecked39 = false;
                                      isNonChecked39 = false;
                                    });
                                    step14_rotuleBilleteDirectionDroitStatutsController.text = "moyen";
                                    step14["rotuleBilleteDirectionDroitStatuts"] = step14_rotuleBilleteDirectionDroitStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isInvalideChecked39 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "MOYEN",
                                      style: gothicBold.copyWith(
                                          fontSize: 10, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 75, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isNonChecked39 = !isNonChecked39;
                                      isValideChecked39 = false;
                                      isInvalideChecked39 = false;
                                    });
                                    step14_rotuleBilleteDirectionDroitStatutsController.text = "bon";
                                    step14["rotuleBilleteDirectionDroitStatuts"] = step14_rotuleBilleteDirectionDroitStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isNonChecked39 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "BON",
                                      style: gothicBold.copyWith(
                                          fontSize: 10, color: Colors.white),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )
                      )
                    ]),

              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 15 , horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        height: 150,
                        child: ElevatedButton(
                          onPressed: () async{
                            final ImagePicker picker = ImagePicker();
                            final XFile? imgFile = await picker.pickImage(source: ImageSource.gallery);
                            try {
                              if (imgFile != null) {
                                String base64Image = base64Encode(await imgFile.readAsBytes()!);
                                step14_rotuleBarreStableDroitImageController.text = base64Image;
                                step14["rotuleBilleteDirectionDroitImage"] = step14_rotuleBarreStableDroitImageController.text;
                              }
                            } catch (e) {
                              // print(e.toString());
                            }
                          },
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload,
                                size: 36,
                                color: Colors.black,
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Importer votre photo",
                                    style: TextStyle(fontSize: 18, color: Colors.black),
                                  ),
                                  Text(
                                    "  *",
                                    style: TextStyle(fontSize: 18, color: Colors.red),
                                  ),
                                ],
                              )

                            ],
                          ),
                        ),
                      ),
                    ),
                    // Add the second element here
                  ],
                ),
              ),
              // Roulement D
              Container(
                margin: const EdgeInsets.symmetric(horizontal:15),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        child: Text(
                          "Roulement D",
                          style: gothicBold.copyWith(fontSize: 18),
                        ),
                      ),

                      SizedBox(
                          height: 30,
                          child : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 120, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isValideChecked40 = !isValideChecked40;
                                      isInvalideChecked40 = false;
                                      isNonChecked40 = false;
                                    });
                                    step14_roulementDroitStatutsController.text = "mauvais";
                                    step14["rotuleBilleteDirectionDroitStatuts"] = step14_roulementDroitStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isValideChecked40 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "MAUVAIS",
                                      style: gothicBold.copyWith(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 100, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 5),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isInvalideChecked40 = !isInvalideChecked40;
                                      isValideChecked40 = false;
                                      isNonChecked40 = false;
                                    });
                                    step14_roulementDroitStatutsController.text = "moyen";
                                    step14["rotuleBilleteDirectionDroitStatuts"] = step14_roulementDroitStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isInvalideChecked40 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "MOYEN",
                                      style: gothicBold.copyWith(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 80, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isNonChecked40 = !isNonChecked40;
                                      isValideChecked40 = false;
                                      isInvalideChecked40 = false;
                                    });
                                    step14_roulementDroitStatutsController.text = "bon";
                                    step14["rotuleBilleteDirectionDroitStatuts"] = step14_roulementDroitStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isNonChecked40 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "BON",
                                      style: gothicBold.copyWith(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )
                      )
                    ]),

              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 15 , horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        height: 150,
                        child: ElevatedButton(
                          onPressed: () async{
                            final ImagePicker picker = ImagePicker();
                            final XFile? imgFile = await picker.pickImage(source: ImageSource.gallery);
                            try {
                              if (imgFile != null) {
                                String base64Image = base64Encode(await imgFile.readAsBytes()!);
                                step14_roulementDroitStatutsController.text = base64Image;
                                step14["roulementDroitImage"] = step14_roulementDroitStatutsController.text;
                              }
                            } catch (e) {
                              // print(e.toString());
                            }
                          },
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload,
                                size: 36,
                                color: Colors.black,
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Importer votre photo",
                                    style: TextStyle(fontSize: 18, color: Colors.black),
                                  ),
                                  Text(
                                    "  *",
                                    style: TextStyle(fontSize: 18, color: Colors.red),
                                  ),
                                ],
                              )

                            ],
                          ),
                        ),
                      ),
                    ),
                    // Add the second element here
                  ],
                ),
              ),
              // Suspension D
              Container(
                margin: const EdgeInsets.symmetric(horizontal:15),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        child: Text(
                          "Suspension D",
                          style: gothicBold.copyWith(fontSize: 18),
                        ),
                      ),

                      SizedBox(
                          height: 30,
                          child : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 120, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isValideChecked41 = !isValideChecked41;
                                      isInvalideChecked41 = false;
                                      isNonChecked41 = false;
                                    });
                                    step14_suspensionDroitStatutsController.text = "mauvais";
                                    step14["suspensionDroitStatuts"] = step14_suspensionDroitStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isValideChecked41 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "MAUVAIS",
                                      style: gothicBold.copyWith(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 100, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 5),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isInvalideChecked41 = !isInvalideChecked41;
                                      isValideChecked41 = false;
                                      isNonChecked41 = false;
                                    });
                                    step14_suspensionDroitStatutsController.text = "moyen";
                                    step14["suspensionDroitStatuts"] = step14_suspensionDroitStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isInvalideChecked41 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "MOYEN",
                                      style: gothicBold.copyWith(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 80, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isNonChecked41 = !isNonChecked41;
                                      isValideChecked41 = false;
                                      isInvalideChecked41 = false;
                                    });
                                    step14_suspensionDroitStatutsController.text = "bon";
                                    step14["suspensionDroitStatuts"] = step14_suspensionDroitStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isNonChecked41 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "BON",
                                      style: gothicBold.copyWith(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )
                      )
                    ]),

              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 15 , horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        height: 150,
                        child: ElevatedButton(
                          onPressed: () async{
                            final ImagePicker picker = ImagePicker();
                            final XFile? imgFile = await picker.pickImage(source: ImageSource.gallery);
                            try {
                              if (imgFile != null) {
                                String base64Image = base64Encode(await imgFile.readAsBytes()!);
                                step14_suspensionDroitImageController.text = base64Image;
                                step13["suspensionDroitImage"] = step14_suspensionDroitImageController.text;
                              }
                            } catch (e) {
                              // print(e.toString());
                            }
                          },
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload,
                                size: 36,
                                color: Colors.black,
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Importer votre photo",
                                    style: TextStyle(fontSize: 18, color: Colors.black),
                                  ),
                                  Text(
                                    "  *",
                                    style: TextStyle(fontSize: 18, color: Colors.red),
                                  ),
                                ],
                              )

                            ],
                          ),
                        ),
                      ),
                    ),
                    // Add the second element here
                  ],
                ),
              ),
              // Disque D
              Container(
                margin: const EdgeInsets.symmetric(horizontal:15),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        child: Text(
                          "Disque D",
                          style: gothicBold.copyWith(fontSize: 18),
                        ),
                      ),

                      SizedBox(
                          height: 30,
                          child : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 120, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isValideChecked42 = !isValideChecked42;
                                      isInvalideChecked42 = false;
                                      isNonChecked42 = false;
                                    });
                                    step14_disqueDroitStatutsController.text = "mauvais";
                                    step14["disqueDroitStatuts"] = step14_disqueDroitStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isValideChecked42 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "MAUVAIS",
                                      style: gothicBold.copyWith(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 100, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 5),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isInvalideChecked42 = !isInvalideChecked42;
                                      isValideChecked42 = false;
                                      isNonChecked42 = false;
                                    });
                                    step14_disqueDroitStatutsController.text = "moyen";
                                    step14["disqueDroitStatuts"] = step14_disqueDroitStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isInvalideChecked42 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "MOYEN",
                                      style: gothicBold.copyWith(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 80, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isNonChecked42 = !isNonChecked42;
                                      isValideChecked42 = false;
                                      isInvalideChecked42 = false;
                                    });
                                    step14_disqueDroitStatutsController.text = "bon";
                                    step14["disqueDroitStatuts"] = step14_disqueDroitStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isNonChecked42 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "BON",
                                      style: gothicBold.copyWith(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )
                      )
                    ]),

              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 15 , horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        height: 150,
                        child: ElevatedButton(
                          onPressed: () async{
                            final ImagePicker picker = ImagePicker();
                            final XFile? imgFile = await picker.pickImage(source: ImageSource.gallery);
                            try {
                              if (imgFile != null) {
                                String base64Image = base64Encode(await imgFile.readAsBytes()!);
                                step14_disqueDroitImageController.text = base64Image;
                                step13["bool "] = step14_disqueDroitImageController.text;
                              }
                            } catch (e) {
                              // print(e.toString());
                            }
                          },
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload,
                                size: 36,
                                color: Colors.black,
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Importer votre photo",
                                    style: TextStyle(fontSize: 18, color: Colors.black),
                                  ),
                                  Text(
                                    "  *",
                                    style: TextStyle(fontSize: 18, color: Colors.red),
                                  ),
                                ],
                              )

                            ],
                          ),
                        ),
                      ),
                    ),
                    // Add the second element here
                  ],
                ),
              ),
              // Plaquette D
              Container(
                margin: const EdgeInsets.symmetric(horizontal:15),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        child: Text(
                          "Plaquette D",
                          style: gothicBold.copyWith(fontSize: 18),
                        ),
                      ),

                      SizedBox(
                          height: 30,
                          child : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 120, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isValideChecked45 = !isValideChecked45;
                                      isInvalideChecked45 = false;
                                      isNonChecked45 = false;
                                    });
                                    step14_plaquetteDroitStatutsController.text = "mauvais";
                                    step14["plaquetteDroitStatuts"] = step14_plaquetteDroitStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isValideChecked45 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "MAUVAIS",
                                      style: gothicBold.copyWith(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 100, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 5),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isInvalideChecked45 = !isInvalideChecked45;
                                      isValideChecked45 = false;
                                      isNonChecked45 = false;
                                    });
                                    step14_plaquetteDroitStatutsController.text = "moyen";
                                    step14["plaquetteDroitStatuts"] = step14_plaquetteDroitStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isInvalideChecked45 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "MOYEN",
                                      style: gothicBold.copyWith(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 80, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isNonChecked45 = !isNonChecked45;
                                      isValideChecked45 = false;
                                      isInvalideChecked45 = false;
                                    });
                                    step14_plaquetteDroitStatutsController.text = "bon";
                                    step14["plaquetteDroitStatuts"] = step14_plaquetteDroitStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isNonChecked45 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "BON",
                                      style: gothicBold.copyWith(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )
                      )
                    ]),

              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 15 , horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        height: 150,
                        child: ElevatedButton(
                          onPressed: () async{
                            final ImagePicker picker = ImagePicker();
                            final XFile? imgFile = await picker.pickImage(source: ImageSource.gallery);
                            try {
                              if (imgFile != null) {
                                String base64Image = base64Encode(await imgFile.readAsBytes()!);
                                step14_plaquetteDroitImageController.text = base64Image;
                                step14["plaquetteDroitImage"] = step14_plaquetteDroitImageController.text;
                              }
                            } catch (e) {
                              // print(e.toString());
                            }
                          },
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload,
                                size: 36,
                                color: Colors.black,
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Importer votre photo",
                                    style: TextStyle(fontSize: 18, color: Colors.black),
                                  ),
                                  Text(
                                    "  *",
                                    style: TextStyle(fontSize: 18, color: Colors.red),
                                  ),
                                ],
                              )

                            ],
                          ),
                        ),
                      ),
                    ),
                    // Add the second element here
                  ],
                ),
              ),
              // Cardan D
              Container(
                margin: const EdgeInsets.symmetric(horizontal:15),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        child: Text(
                          "Cardan D",
                          style: gothicBold.copyWith(fontSize: 18),
                        ),
                      ),

                      SizedBox(
                          height: 30,
                          child : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 120, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isValideChecked46 = !isValideChecked46;
                                      isInvalideChecked46 = false;
                                      isNonChecked46 = false;
                                    });
                                    step14_cardanDroitStatutsController.text = "mauvais";
                                    step14["cardanDroitStatuts"] = step14_cardanDroitStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isValideChecked46 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "MAUVAIS",
                                      style: gothicBold.copyWith(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 100, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 5),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isInvalideChecked46 = !isInvalideChecked46;
                                      isValideChecked46 = false;
                                      isNonChecked46 = false;
                                    });
                                    step14_cardanDroitStatutsController.text = "moyen";
                                    step14["cardanDroitStatuts"] = step14_cardanDroitStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isInvalideChecked46 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "MOYEN",
                                      style: gothicBold.copyWith(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 80, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isNonChecked46 = !isNonChecked46;
                                      isValideChecked46 = false;
                                      isInvalideChecked46 = false;
                                    });
                                    step14_cardanDroitStatutsController.text = "bon";
                                    step14["cardanDroitStatuts"] = step14_cardanDroitStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isNonChecked46 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "BON",
                                      style: gothicBold.copyWith(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )
                      )
                    ]),

              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 15 , horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        height: 150,
                        child: ElevatedButton(
                          onPressed: () async{
                            final ImagePicker picker = ImagePicker();
                            final XFile? imgFile = await picker.pickImage(source: ImageSource.gallery);
                            try {
                              if (imgFile != null) {
                                String base64Image = base64Encode(await imgFile.readAsBytes()!);
                                step14_cardanDroitImageController.text = base64Image;
                                step12["cardanDroitImage"] = step14_cardanDroitImageController.text;
                              }
                            } catch (e) {
                              // print(e.toString());
                            }
                          },
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload,
                                size: 36,
                                color: Colors.black,
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Importer votre photo",
                                    style: TextStyle(fontSize: 18, color: Colors.black),
                                  ),
                                  Text(
                                    "  *",
                                    style: TextStyle(fontSize: 18, color: Colors.red),
                                  ),
                                ],
                              )

                            ],
                          ),
                        ),
                      ),
                    ),
                    // Add the second element here
                  ],
                ),
              ),
            ],
          ),
        ),
        isActive: _currentStep == 13,
      ),
      // 15
      Step(
        title: const Text('Roue ARD'),
        content: Form(
          key: _formKeys[14],
          child: Column(
            children: [
              // title
              Center(
                child: Container(
                  width: 250,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.all(20.0),
                      textStyle: const TextStyle(fontSize: 24 , color: Colors.white ),
                    ),
                    onPressed: () =>{},
                    child: const Text('Roue ARD' , style: TextStyle(color: Colors.white),),
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              // Progress bar
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 15), // Add margin here
                          child: Text(
                            "Etape 15/18",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 15), // Add margin here
                          child: Text(
                            "Diagnostic",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Center(
                child: Container(
                  width: 800.0, // Adjust the width as needed
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: LinearPercentIndicator(

                      animation: true,
                      backgroundColor: Colors.black,
                      animationDuration: 1000,
                      lineHeight: 10.0,
                      percent: 0.72,
                      barRadius: const Radius.circular(16),
                      //linearStrokeCap: LinearStrokeCap.butt,
                      progressColor: Colors.blue,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              //  Roue Arrière Droite Levée
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Roue Arrière Droite Levée",
                        style:
                        gothicBold.copyWith(
                            fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15 , vertical: 30 ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 150,
                        child: ElevatedButton(
                          onPressed: () async {
                            final ImagePicker picker = ImagePicker();
                            final XFile? imgFile = await picker.pickImage(source: ImageSource.gallery);
                            try {
                              if (imgFile != null) {
                                String base64Image = base64Encode(await imgFile.readAsBytes()!);
                                step15_roueArriereDroitLeveImageController.text = base64Image;
                                step15["roueArriereDroitLeveImage"] = step15_roueArriereDroitLeveImageController.text;
                              }
                            } catch (e) {
                              // print(e.toString());
                            }
                          },
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload, // Add your upload icon here
                                size: 36,
                                color: Colors.black,
                              ),
                              SizedBox(height: 10), // Add some spacing between icon and text
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Importer votre photo",
                                    style: TextStyle(fontSize: 18, color: Colors.black),
                                  ),
                                  Text(
                                    "  *",
                                    style: TextStyle(fontSize: 18, color: Colors.red),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Roulement Arrière D
              Container(
                margin: const EdgeInsets.symmetric(horizontal:15),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        child: Text(
                          "Roulement Arrière D",
                          style: gothicBold.copyWith(fontSize: 15),
                        ),
                      ),

                      SizedBox(
                          height: 30,
                          child : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 115, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isValideChecked53 = !isValideChecked53;
                                      isInvalideChecked53 = false;
                                      isNonChecked53 = false;
                                    });
                                    step15_roulementArriereDroitStatutController.text = "mauvais";
                                    step15["roulementArriereDroitStatut"] = step15_roulementArriereDroitStatutController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isValideChecked53 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "MAUVAIS",
                                      style: gothicBold.copyWith(
                                          fontSize: 10, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 95, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 5),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isInvalideChecked53 = !isInvalideChecked53;
                                      isValideChecked53 = false;
                                      isNonChecked53 = false;
                                    });
                                    step15_roulementArriereDroitStatutController.text = "moyen";
                                    step15["roulementArriereDroitStatut"] = step15_roulementArriereDroitStatutController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isInvalideChecked53 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "MOYEN",
                                      style: gothicBold.copyWith(
                                          fontSize: 10, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 75, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isNonChecked53 = !isNonChecked53;
                                      isValideChecked53 = false;
                                      isInvalideChecked53 = false;
                                    });
                                    step15_roulementArriereDroitStatutController.text = "bon";
                                    step15["roulementArriereDroitStatut"] = step15_roulementArriereDroitStatutController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isNonChecked53 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "BON",
                                      style: gothicBold.copyWith(
                                          fontSize: 10, color: Colors.white),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )
                      )
                    ]),

              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 15 , horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        height: 150,
                        child: ElevatedButton(
                          onPressed: () async{
                            final ImagePicker picker = ImagePicker();
                            final XFile? imgFile = await picker.pickImage(source: ImageSource.gallery);
                            try {
                              if (imgFile != null) {
                                String base64Image = base64Encode(await imgFile.readAsBytes()!);
                                step15_roulementArriereDroitImageController.text = base64Image;
                                step15["roulementArriereDroitImage"] = step15_roulementArriereDroitImageController.text;
                              }
                            } catch (e) {
                              // print(e.toString());
                            }
                          },
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload,
                                size: 36,
                                color: Colors.black,
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Importer votre photo",
                                    style: TextStyle(fontSize: 18, color: Colors.black),
                                  ),

                                ],
                              )

                            ],
                          ),
                        ),
                      ),
                    ),
                    // Add the second element here
                  ],
                ),
              ),
              // Suspension Arrière D
              Container(
                margin: const EdgeInsets.symmetric(horizontal:15),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        child: Text(
                          "Suspension Arrière D",
                          style: gothicBold.copyWith(fontSize: 15),
                        ),
                      ),

                      SizedBox(
                          height: 30,
                          child : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 115, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isValideChecked54 = !isValideChecked54;
                                      isInvalideChecked54 = false;
                                      isNonChecked54 = false;
                                    });
                                    step15_suspensionArriereDroitStatutsController.text = "mauvais";
                                    step15["suspensionArriereDroitStatuts"] = step15_suspensionArriereDroitStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isValideChecked54 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "MAUVAIS",
                                      style: gothicBold.copyWith(
                                          fontSize: 10, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 95, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 5),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isInvalideChecked54 = !isInvalideChecked54;
                                      isValideChecked54 = false;
                                      isNonChecked54 = false;
                                    });
                                    step15_suspensionArriereDroitStatutsController.text = "moyen";
                                    step15["suspensionArriereDroitStatuts"] = step15_suspensionArriereDroitStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isInvalideChecked54 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "MOYEN",
                                      style: gothicBold.copyWith(
                                          fontSize: 10, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 75, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isNonChecked54 = !isNonChecked54;
                                      isValideChecked54 = false;
                                      isInvalideChecked54 = false;
                                    });
                                    step15_suspensionArriereDroitStatutsController.text = "bon";
                                    step15["suspensionArriereDroitStatuts"] = step15_suspensionArriereDroitStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isNonChecked54 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "BON",
                                      style: gothicBold.copyWith(
                                          fontSize: 10, color: Colors.white),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )
                      )
                    ]),

              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 15 , horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        height: 150,
                        child: ElevatedButton(
                          onPressed: () async{
                            final ImagePicker picker = ImagePicker();
                            final XFile? imgFile = await picker.pickImage(source: ImageSource.gallery);
                            try {
                              if (imgFile != null) {
                                String base64Image = base64Encode(await imgFile.readAsBytes()!);
                                step15_suspensionArriereDroitImageController.text = base64Image;
                                step15["suspensionArriereDroitImage"] = step15_suspensionArriereDroitImageController.text;
                              }
                            } catch (e) {
                              // print(e.toString());
                            }
                          },
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload,
                                size: 36,
                                color: Colors.black,
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Importer votre photo",
                                    style: TextStyle(fontSize: 18, color: Colors.black),
                                  ),

                                ],
                              )

                            ],
                          ),
                        ),
                      ),
                    ),
                    // Add the second element here
                  ],
                ),
              ),
              // Disque Arrière D
              Container(
                margin: const EdgeInsets.symmetric(horizontal:15),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        child: Text(
                          "Disque Arrière D",
                          style: gothicBold.copyWith(fontSize: 18),
                        ),
                      ),

                      SizedBox(
                          height: 30,
                          child : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 120, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isValideChecked55 = !isValideChecked55;
                                      isInvalideChecked55 = false;
                                      isNonChecked55 = false;
                                    });
                                    step15_disqueArriereDroitStatutsController.text = "mauvais";
                                    step15["disqueArriereDroitStatuts"] = step15_disqueArriereDroitStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isValideChecked55 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "MAUVAIS",
                                      style: gothicBold.copyWith(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 100, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 5),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isInvalideChecked55 = !isInvalideChecked55;
                                      isValideChecked55 = false;
                                      isNonChecked55 = false;
                                    });
                                    step15_disqueArriereDroitStatutsController.text = "moyen";
                                    step15["disqueArriereDroitStatuts"] = step15_disqueArriereDroitStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isInvalideChecked55 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "MOYEN",
                                      style: gothicBold.copyWith(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 80, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isNonChecked55 = !isNonChecked55;
                                      isValideChecked55 = false;
                                      isInvalideChecked55 = false;
                                    });
                                    step15_disqueArriereDroitStatutsController.text = "bon";
                                    step15["disqueArriereDroitStatuts"] = step15_disqueArriereDroitStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isNonChecked55 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "BON",
                                      style: gothicBold.copyWith(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )
                      )
                    ]),

              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 15 , horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        height: 150,
                        child: ElevatedButton(
                          onPressed: () async{
                            final ImagePicker picker = ImagePicker();
                            final XFile? imgFile = await picker.pickImage(source: ImageSource.gallery);
                            try {
                              if (imgFile != null) {
                                String base64Image = base64Encode(await imgFile.readAsBytes()!);
                                step15_disqueArriereDroitImageController.text = base64Image;
                                step15["disqueArriereDroitImage"] = step15_disqueArriereDroitImageController.text;
                              }
                            } catch (e) {
                              // print(e.toString());
                            }
                          },
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload,
                                size: 36,
                                color: Colors.black,
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Importer votre photo",
                                    style: TextStyle(fontSize: 18, color: Colors.black),
                                  ),

                                ],
                              )

                            ],
                          ),
                        ),
                      ),
                    ),
                    // Add the second element here
                  ],
                ),
              ),
              // Plaquette Arrière D
              Container(
                margin: const EdgeInsets.symmetric(horizontal:15),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        child: Text(
                          "Plaquette Arrière D",
                          style: gothicBold.copyWith(fontSize: 15),
                        ),
                      ),

                      SizedBox(
                          height: 30,
                          child : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 115, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isValideChecked56 = !isValideChecked56;
                                      isInvalideChecked56 = false;
                                      isNonChecked56 = false;
                                    });
                                    step15_plaquetteArriereDroitStatutsController.text = "mauvais";
                                    step15["plaquetteArriereDroitStatuts"] = step15_plaquetteArriereDroitStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isValideChecked56 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "MAUVAIS",
                                      style: gothicBold.copyWith(
                                          fontSize: 10, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 95, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 5),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isInvalideChecked56 = !isInvalideChecked56;
                                      isValideChecked56 = false;
                                      isNonChecked56 = false;
                                    });
                                    step15_plaquetteArriereDroitStatutsController.text = "moyen";
                                    step15["plaquetteArriereDroitStatuts"] = step15_plaquetteArriereDroitStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isInvalideChecked56 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "MOYEN",
                                      style: gothicBold.copyWith(
                                          fontSize: 10, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 75, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isNonChecked56 = !isNonChecked56;
                                      isValideChecked56 = false;
                                      isInvalideChecked56 = false;
                                    });
                                    step15_plaquetteArriereDroitStatutsController.text = "bon";
                                    step15["plaquetteArriereDroitStatuts"] = step15_plaquetteArriereDroitStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isNonChecked56 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "BON",
                                      style: gothicBold.copyWith(
                                          fontSize: 10, color: Colors.white),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )
                      )
                    ]),

              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 15 , horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        height: 150,
                        child: ElevatedButton(
                          onPressed: () async{
                            final ImagePicker picker = ImagePicker();
                            final XFile? imgFile = await picker.pickImage(source: ImageSource.gallery);
                            try {
                              if (imgFile != null) {
                                String base64Image = base64Encode(await imgFile.readAsBytes()!);
                                step15_disqueArriereDroitImageController.text = base64Image;
                                step15["disqueArriereDroitImage"] = step15_disqueArriereDroitImageController.text;
                              }
                            } catch (e) {
                              // print(e.toString());
                            }
                          },
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload,
                                size: 36,
                                color: Colors.black,
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Importer votre photo",
                                    style: TextStyle(fontSize: 18, color: Colors.black),
                                  ),

                                ],
                              )

                            ],
                          ),
                        ),
                      ),
                    ),
                    // Add the second element here
                  ],
                ),
              ),
            ],
          ),
        ),
        isActive: _currentStep == 14,
      ),
      // 16
      Step(
        title: const Text('Roue ARG') ,
        content: Form(
          key: _formKeys[15],
          child: Column(
            children: [
              // title
              Center(
                child: Container(
                  width: 250,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.all(20.0),
                      textStyle: const TextStyle(fontSize: 24 , color: Colors.white ),
                    ),
                    onPressed: () =>{},
                    child: const Text('Roue ARG' , style: TextStyle(color: Colors.white),),
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              // Progress bar
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 15), // Add margin here
                          child: Text(
                            "Etape 16/18",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 15), // Add margin here
                          child: Text(
                            "Diagnostic",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Center(
                child: Container(
                  width: 800.0, // Adjust the width as needed
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: LinearPercentIndicator(

                      animation: true,
                      backgroundColor: Colors.black,
                      animationDuration: 1000,
                      lineHeight: 10.0,
                      percent: 0.75,
                      barRadius: const Radius.circular(16),
                      //linearStrokeCap: LinearStrokeCap.butt,
                      progressColor: Colors.blue,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              // Roue Arrère Gauche Levée
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Roue Arrère Gauche Levée",
                        style:
                        gothicBold.copyWith(
                            fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15 , vertical: 30 ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 150,
                        child: ElevatedButton(
                          onPressed: () async {
                            final ImagePicker picker = ImagePicker();
                            final XFile? imgFile = await picker.pickImage(source: ImageSource.gallery);
                            try {
                              if (imgFile != null) {
                                String base64Image = base64Encode(await imgFile.readAsBytes()!);
                                step16_roueArriereGaucheLeveImageController.text = base64Image;
                                step16["roueArriereGaucheLeveImage"] = step16_roueArriereGaucheLeveImageController.text;
                              }
                            } catch (e) {
                              // print(e.toString());
                            }
                          },
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload, // Add your upload icon here
                                size: 36,
                                color: Colors.black,
                              ),
                              SizedBox(height: 10), // Add some spacing between icon and text
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Importer votre photo",
                                    style: TextStyle(fontSize: 18, color: Colors.black),
                                  ),
                                  Text(
                                    "  *",
                                    style: TextStyle(fontSize: 18, color: Colors.red),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Roulement Arrière G
              Container(
                margin: const EdgeInsets.symmetric(horizontal:15),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        child: Text(
                          "Roulement Arrière G",
                          style: gothicBold.copyWith(fontSize: 15),
                        ),
                      ),

                      SizedBox(
                          height: 30,
                          child : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 115, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isValideChecked47 = !isValideChecked47;
                                      isInvalideChecked47 = false;
                                      isNonChecked47 = false;
                                    });
                                    step16_roueArriereGaucheLeveImageController.text = "mauvais";
                                    step16["roulementArriereGaucheStatut"] = step16_roueArriereGaucheLeveImageController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isValideChecked47 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "MAUVAIS",
                                      style: gothicBold.copyWith(
                                          fontSize: 10, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 95, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 5),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isInvalideChecked47 = !isInvalideChecked47;
                                      isValideChecked47 = false;
                                      isNonChecked47 = false;
                                    });
                                    step16_roueArriereGaucheLeveImageController.text = "moyen";
                                    step16["roulementArriereGaucheStatut"] = step16_roueArriereGaucheLeveImageController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isInvalideChecked47 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "MOYEN",
                                      style: gothicBold.copyWith(
                                          fontSize: 10, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 75, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isNonChecked47 = !isNonChecked47;
                                      isValideChecked47 = false;
                                      isInvalideChecked47 = false;
                                    });
                                    step16_roueArriereGaucheLeveImageController.text = "bon";
                                    step16["roulementArriereGaucheStatut"] = step16_roueArriereGaucheLeveImageController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isNonChecked47 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "BON",
                                      style: gothicBold.copyWith(
                                          fontSize: 10, color: Colors.white),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )
                      )
                    ]),

              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 15 , horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        height: 150,
                        child: ElevatedButton(
                          onPressed: () async{
                            final ImagePicker picker = ImagePicker();
                            final XFile? imgFile = await picker.pickImage(source: ImageSource.gallery);
                            try {
                              if (imgFile != null) {
                                String base64Image = base64Encode(await imgFile.readAsBytes()!);
                                step16_roulementArriereGaucheImageController.text = base64Image;
                                step16["roulementArriereGaucheImage"] = step16_roulementArriereGaucheImageController.text;
                              }
                            } catch (e) {
                              // print(e.toString());
                            }
                          },
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload,
                                size: 36,
                                color: Colors.black,
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Importer votre photo",
                                    style: TextStyle(fontSize: 18, color: Colors.black),
                                  ),

                                ],
                              )

                            ],
                          ),
                        ),
                      ),
                    ),
                    // Add the second element here
                  ],
                ),
              ),
              // Suspension Arrière G
              Container(
                margin: const EdgeInsets.symmetric(horizontal:15),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        child: Text(
                          "Suspension Arrière G",
                          style: gothicBold.copyWith(fontSize: 15),
                        ),
                      ),

                      SizedBox(
                          height: 30,
                          child : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 115, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isValideChecked48 = !isValideChecked48;
                                      isInvalideChecked48 = false;
                                      isNonChecked48 = false;
                                    });
                                    step16_suspensionArriereGaucheStatutsController.text = "mauvais";
                                    step16["suspensionArriereGaucheStatuts"] = step16_suspensionArriereGaucheStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isValideChecked48 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "MAUVAIS",
                                      style: gothicBold.copyWith(
                                          fontSize: 10, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 95, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 5),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isInvalideChecked48 = !isInvalideChecked48;
                                      isValideChecked48 = false;
                                      isNonChecked48 = false;
                                    });
                                    step16_suspensionArriereGaucheStatutsController.text = "moyen";
                                    step16["suspensionArriereGaucheStatuts"] = step16_suspensionArriereGaucheStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isInvalideChecked48 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "MOYEN",
                                      style: gothicBold.copyWith(
                                          fontSize: 10, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 75, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isNonChecked48 = !isNonChecked48;
                                      isValideChecked48 = false;
                                      isInvalideChecked48 = false;
                                    });
                                    step16_suspensionArriereGaucheStatutsController.text = "bon";
                                    step16["suspensionArriereGaucheStatuts"] = step16_suspensionArriereGaucheStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isNonChecked48 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "BON",
                                      style: gothicBold.copyWith(
                                          fontSize: 10, color: Colors.white),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )
                      )
                    ]),

              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 15 , horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        height: 150,
                        child: ElevatedButton(
                          onPressed: () async{
                            final ImagePicker picker = ImagePicker();
                            final XFile? imgFile = await picker.pickImage(source: ImageSource.gallery);
                            try {
                              if (imgFile != null) {
                                String base64Image = base64Encode(await imgFile.readAsBytes()!);
                                step16_suspensionArriereGaucheImageController.text = base64Image;
                                step16["suspensionArriereGaucheImage"] = step16_suspensionArriereGaucheImageController.text;
                              }
                            } catch (e) {
                              // print(e.toString());
                            }
                          },
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload,
                                size: 36,
                                color: Colors.black,
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Importer votre photo",
                                    style: TextStyle(fontSize: 18, color: Colors.black),
                                  ),

                                ],
                              )

                            ],
                          ),
                        ),
                      ),
                    ),
                    // Add the second element here
                  ],
                ),
              ),
              // Disque Arrière G
              Container(
                margin: const EdgeInsets.symmetric(horizontal:15),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        child: Text(
                          "Disque Arrière G",
                          style: gothicBold.copyWith(fontSize: 18),
                        ),
                      ),

                      SizedBox(
                          height: 30,
                          child : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 120, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isValideChecked49 = !isValideChecked49;
                                      isInvalideChecked49 = false;
                                      isNonChecked49 = false;
                                    });
                                    step16_disqueArriereGaucheStatutsController.text = "mauvais";
                                    step16["disqueArriereGaucheStatuts"] = step16_disqueArriereGaucheStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isValideChecked49 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "MAUVAIS",
                                      style: gothicBold.copyWith(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 100, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 5),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isInvalideChecked49 = !isInvalideChecked49;
                                      isValideChecked49 = false;
                                      isNonChecked49 = false;
                                    });
                                    step16_disqueArriereGaucheStatutsController.text = "moyen";
                                    step16["disqueArriereGaucheStatuts"] = step16_disqueArriereGaucheStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isInvalideChecked49 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "MOYEN",
                                      style: gothicBold.copyWith(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 80, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isNonChecked49 = !isNonChecked49;
                                      isValideChecked49 = false;
                                      isInvalideChecked49 = false;
                                    });
                                    step16_disqueArriereGaucheStatutsController.text = "bon";
                                    step16["disqueArriereGaucheStatuts"] = step16_disqueArriereGaucheStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isNonChecked49 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "BON",
                                      style: gothicBold.copyWith(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )
                      )
                    ]),

              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 15 , horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        height: 150,
                        child: ElevatedButton(
                          onPressed: () async{
                            final ImagePicker picker = ImagePicker();
                            final XFile? imgFile = await picker.pickImage(source: ImageSource.gallery);
                            try {
                              if (imgFile != null) {
                                String base64Image = base64Encode(await imgFile.readAsBytes()!);
                                step16_disqueArriereGaucheImageController.text = base64Image;
                                step16["disqueArriereGaucheImage"] = step16_disqueArriereGaucheImageController.text;
                              }
                            } catch (e) {
                              // print(e.toString());
                            }
                          },
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload,
                                size: 36,
                                color: Colors.black,
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Importer votre photo",
                                    style: TextStyle(fontSize: 18, color: Colors.black),
                                  ),

                                ],
                              )

                            ],
                          ),
                        ),
                      ),
                    ),
                    // Add the second element here
                  ],
                ),
              ),
              // Plaquette Arrière G
              Container(
                margin: const EdgeInsets.symmetric(horizontal:15),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        child: Text(
                          "Plaquette Arrière G",
                          style: gothicBold.copyWith(fontSize: 15),
                        ),
                      ),

                      SizedBox(
                          height: 30,
                          child : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 115, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isValideChecked50 = !isValideChecked50;
                                      isInvalideChecked50 = false;
                                      isNonChecked50 = false;
                                    });
                                    step16_plaquetteArriereGaucheStatutsController.text = "mauvais";
                                    step16["plaquetteArriereGaucheStatuts"] = step16_plaquetteArriereGaucheStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isValideChecked50 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "MAUVAIS",
                                      style: gothicBold.copyWith(
                                          fontSize: 10, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 95, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 5),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isInvalideChecked50 = !isInvalideChecked50;
                                      isValideChecked50 = false;
                                      isNonChecked50 = false;
                                    });
                                    step16_plaquetteArriereGaucheStatutsController.text = "moyen";
                                    step16["plaquetteArriereGaucheStatuts"] = step16_plaquetteArriereGaucheStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isInvalideChecked50 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "MOYEN",
                                      style: gothicBold.copyWith(
                                          fontSize: 10, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 75, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isNonChecked50 = !isNonChecked50;
                                      isValideChecked50 = false;
                                      isInvalideChecked50 = false;
                                    });
                                    step16_plaquetteArriereGaucheStatutsController.text = "bon";
                                    step16["plaquetteArriereGaucheStatuts"] = step16_plaquetteArriereGaucheStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isNonChecked50 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "BON",
                                      style: gothicBold.copyWith(
                                          fontSize: 10, color: Colors.white),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )
                      )
                    ]),

              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 15 , horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        height: 150,
                        child: ElevatedButton(
                          onPressed: () async{
                            final ImagePicker picker = ImagePicker();
                            final XFile? imgFile = await picker.pickImage(source: ImageSource.gallery);
                            try {
                              if (imgFile != null) {
                                String base64Image = base64Encode(await imgFile.readAsBytes()!);
                                step16_plaquetteArriereGaucheImageController.text = base64Image;
                                step16["plaquetteArriereGaucheImage"] = step16_plaquetteArriereGaucheImageController.text;
                              }
                            } catch (e) {
                              // print(e.toString());
                            }
                          },
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload,
                                size: 36,
                                color: Colors.black,
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Importer votre photo",
                                    style: TextStyle(fontSize: 18, color: Colors.black),
                                  ),

                                ],
                              )

                            ],
                          ),
                        ),
                      ),
                    ),
                    // Add the second element here
                  ],
                ),
              ),
            ],
          ),
        ),
        isActive: _currentStep == 15,
      ),
      // 17
      Step(
        title: const Text('Test Conduite') ,
        content: Form(
          key: _formKeys[16],
          child: Column(
            children: [
              // title
              Center(
                child: Container(
                  width: 250,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.all(20.0),
                      textStyle: const TextStyle(fontSize: 24 , color: Colors.white ),
                    ),
                    onPressed: () =>{},
                    child: const Text('Test Conduite' , style: TextStyle(color: Colors.white),),
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              // Progress bar
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 15), // Add margin here
                          child: Text(
                            "Etape 17/18",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 15), // Add margin here
                          child: Text(
                            "Diagnostic",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Center(
                child: Container(
                  width: 800.0, // Adjust the width as needed
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: LinearPercentIndicator(

                      animation: true,
                      backgroundColor: Colors.black,
                      animationDuration: 1000,
                      lineHeight: 10.0,
                      percent: 0.80,
                      barRadius: const Radius.circular(16),
                      //linearStrokeCap: LinearStrokeCap.butt,
                      progressColor: Colors.blue,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              // claquemnet ou Buit Innaproprié?
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15 ,vertical: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      child: Text(
                        "claquemnet ou Buit Innaproprié?",
                        style: gothicBold.copyWith(fontSize: 15),
                      ),
                    ),

                    SizedBox(
                      height: 30,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 95, // Set the width here
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  isOuiSelected22 = true;
                                  isNonSelected22 = false;
                                });
                                step17_claquementBruitStatutsController.text = "oui";
                                step17["claquementBruitStatuts"] = step17_claquementBruitStatutsController.text;
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    isOuiSelected22 ? Colors.grey[900] : Colors.grey),
                              ),
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: Text(
                                  "OUI",
                                  style: gothicBold.copyWith(
                                      fontSize: 10, color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: 95, // Set the width here
                            margin: const EdgeInsets.symmetric(horizontal: 0),
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  isOuiSelected22 = false;
                                  isNonSelected22 = true;
                                });
                                step17_claquementBruitStatutsController.text = "non";
                                step17["claquementBruitStatuts"] = step17_claquementBruitStatutsController.text;
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    isNonSelected22 ? Colors.grey[900] : Colors.grey),
                              ),
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: Text(
                                  "NON",
                                  style: gothicBold.copyWith(
                                      fontSize: 10, color: Colors.white),
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
              // Direction
              Container(
                margin: const EdgeInsets.symmetric(horizontal:15 , vertical : 15),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        child: Text(
                          "Direction",
                          style: gothicBold.copyWith(fontSize: 18),
                        ),
                      ),

                      SizedBox(
                          height: 30,
                          child : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 120, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isValideChecked51 = !isValideChecked51;
                                      isInvalideChecked51 = false;
                                      isNonChecked51 = false;
                                    });
                                    step17_directionStatutsController.text = "mauvais";
                                    step17["directionStatuts"] = step17_directionStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isValideChecked51 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "MAUVAIS",
                                      style: gothicBold.copyWith(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 100, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 5),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isInvalideChecked51 = !isInvalideChecked51;
                                      isValideChecked51 = false;
                                      isNonChecked51 = false;
                                    });
                                    step17_directionStatutsController.text = "moyen";
                                    step17["directionStatuts"] = step17_directionStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isInvalideChecked51 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "MOYEN",
                                      style: gothicBold.copyWith(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 80, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isNonChecked51 = !isNonChecked51;
                                      isValideChecked51 = false;
                                      isInvalideChecked51 = false;
                                    });
                                    step17_directionStatutsController.text = "bon";
                                    step17["directionStatuts"] = step17_directionStatutsController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isNonChecked51 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "BON",
                                      style: gothicBold.copyWith(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )
                      )
                    ]),

              ),
              // Fumée Echappement
              Container(
                margin: const EdgeInsets.symmetric(horizontal:15 ,vertical: 15),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        child: Text(
                          "Fumée Echappement",
                          style: gothicBold.copyWith(fontSize: 15),
                        ),
                      ),

                      SizedBox(
                          height: 30,
                          child : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 115, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isValideChecked52 = !isValideChecked52;
                                      isInvalideChecked52 = false;
                                      isNonChecked52 = false;
                                    });
                                    step17_fumeEchapementController.text = "mauvais";
                                    step17["fumeEchapement"] = step17_fumeEchapementController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isValideChecked52 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "MAUVAIS",
                                      style: gothicBold.copyWith(
                                          fontSize: 10, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 95, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 5),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isInvalideChecked52 = !isInvalideChecked52;
                                      isValideChecked52 = false;
                                      isNonChecked52 = false;
                                    });
                                    step17_fumeEchapementController.text = "moyen";
                                    step17["fumeEchapement"] = step17_fumeEchapementController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isInvalideChecked52 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "MOYEN",
                                      style: gothicBold.copyWith(
                                          fontSize: 10, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 75, // Set the width here
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isNonChecked52 = !isNonChecked52;
                                      isValideChecked52 = false;
                                      isInvalideChecked52 = false;
                                    });
                                    step17_fumeEchapementController.text = "bon";
                                    step17["fumeEchapement"] = step17_fumeEchapementController.text;
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isNonChecked52 ? Colors.grey[900] : Colors.grey,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    child:  Text(
                                      "BON",
                                      style: gothicBold.copyWith(
                                          fontSize: 10, color: Colors.white),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )
                      )
                    ]),

              ),
              // Conforme à l'annoce
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15 ,vertical: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    SizedBox(
                      child: Text(
                        "Conforme à l'annoce",
                        style: gothicBold.copyWith(fontSize: 18),
                      ),
                    ),

                    SizedBox(
                      height: 30,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 100, // Set the width here
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  isOuiSelected23 = true;
                                  isNonSelected23 = false;
                                });
                                step17_conformeAnnonceStatuts_4Controller.text = "oui";
                                step17["conformeAnnonceStatuts_4"] = step17_conformeAnnonceStatuts_4Controller.text;
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    isOuiSelected23 ? Colors.grey[900] : Colors.grey),
                              ),
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: Text(
                                  "OUI",
                                  style: gothicBold.copyWith(
                                      fontSize: 12, color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: 100, // Set the width here
                            margin: const EdgeInsets.symmetric(horizontal: 0),
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  isOuiSelected23 = false;
                                  isNonSelected23 = true;
                                });
                                step17_conformeAnnonceStatuts_4Controller.text = "non";
                                step17["conformeAnnonceStatuts_4"] = step17_conformeAnnonceStatuts_4Controller.text;
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    isNonSelected23 ? Colors.grey[900] : Colors.grey),
                              ),
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 0),
                                child: Text(
                                  "NON",
                                  style: gothicBold.copyWith(
                                      fontSize: 12, color: Colors.white),
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
        ),
        isActive: _currentStep == 16,
      ),
      // 18
      Step(
        title: const Text('Avis général') ,
        content: Form(
          key: _formKeys[17],
          child: Column(
            children: [
              // title
              Center(
                child: Container(
                  width: 250,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.all(20.0),
                      textStyle: const TextStyle(fontSize: 24 , color: Colors.white ),
                    ),
                    onPressed: () =>{},
                    child: const Text('Avis général' , style: TextStyle(color: Colors.white),),
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              // Progress bar
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 15), // Add margin here
                          child: Text(
                            "Etape 18/18",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 15), // Add margin here
                          child: Text(
                            "Diagnostic",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Center(
                child: Container(
                  width: 800.0, // Adjust the width as needed
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: LinearPercentIndicator(

                      animation: true,
                      backgroundColor: Colors.black,
                      animationDuration: 1000,
                      lineHeight: 10.0,
                      percent: 0.93,
                      barRadius: const Radius.circular(16),
                      //linearStrokeCap: LinearStrokeCap.butt,
                      progressColor: Colors.blue,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              // Avis sur l’état global du véhicule ?
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Avis sur l’état global du véhicule ?",
                        style:
                        gothicBold.copyWith(
                            fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Est-ce une bonne affaire ? extérieur, intérieur, électronique, problème à signaler, bruit, etc",
                        style:
                        gothicBold.copyWith(
                            fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15 , vertical : 15),
                child: SizedBox(
                  height: 80, // Set your desired height here
                  child: CustomInputValidatore(
                    controller: step18_avisEtatVehiculeGlobaleImageController,
                    labelText: null,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Field is required';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      step18["avisEtatVehiculeGlobaleImage"] = value!;
                    },
                    marginContainer: const EdgeInsets.only(bottom: 0, top: 0),
                    width: sizeWidth(context: context),
                    hintText: "Votre avis... *",
                    focusNode: step18_avisEtatVehiculeGlobaleImageFocus,
                  ),
                ),
              ),
            ],
          ),
        ),
        isActive: _currentStep == 17,
      ),
      // 19
      Step(
        title: const Text('Résultat') ,
        content: Form(
          key: _formKeys[18],
          child: Column(
            children: [
              // title
              Center(
                child: Container(
                  width: 250,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.all(20.0),
                      textStyle: const TextStyle(fontSize: 24 , color: Colors.white ),
                    ),
                    onPressed: () =>{},
                    child: const Text('Résultat' , style: TextStyle(color: Colors.white),),
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              // Progress bar
              Center(
                child: Container(
                  width: 800.0, // Adjust the width as needed
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: LinearPercentIndicator(
                      animation: true,
                      backgroundColor: Colors.black,
                      animationDuration: 1000,
                      lineHeight: 10.0,
                      percent: 1,
                      barRadius: const Radius.circular(16),
                      progressColor: Colors.blue,
                    ),
                  ),
                ),
              ),
              // L’achat du véhicule est-il
              // favorable ou défavorable ?
              const SizedBox(
                height:50,
              ),
              Center(
                child: Text(
                  "L’achat du véhicule est-il",
                  style:
                  gothicBold.copyWith(
                      fontSize: 25),
                ),
              ),
              Center(
                child: Text(
                  "favorable ou défavorable ?",
                  style:
                  gothicBold.copyWith(
                      fontSize: 25),
                ),
              ),
              //  Buttons
              const SizedBox(
                height: 100,
              ),
              Center(
                    child: TextButton(
                      style: TextButton.styleFrom(
                          padding: const EdgeInsets.all(25),
                          textStyle: const TextStyle(fontSize: 40 ),
                          backgroundColor : Colors.green
                      ),
                      onPressed: () => {
                        showFavorablePopUp(context),

                      },
                      child: const Text('FAVORABLE' , style: TextStyle(color: Colors.white )),
                    ),
              ),
              const SizedBox(
                height: 100,
              ),
              Center(
                child: TextButton(
                  style: TextButton.styleFrom(
                      padding: const EdgeInsets.all(25),
                      textStyle: const TextStyle(fontSize: 40 ),
                      backgroundColor : Colors.black
                  ),
                  onPressed: () => {
                    showDeFavorablePopUp(context)
                  },
                  child: const Text('DEFAVORABLE' , style: TextStyle(color: Colors.white )),
                ),
              )
            ],
          ),
        ),
        isActive: _currentStep == 18,
      ),
    ];
    return Scaffold(
        body : SingleChildScrollView(child:steps[_currentStep].content),
        persistentFooterButtons : [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.all(16.0),
                  textStyle: const TextStyle(fontSize: 20 , color: Colors.white ),
                ),
                onPressed: () => _prevStep(),
                child: const Text('Previous' , style: TextStyle(color: Colors.white),),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.all(16.0),
                  textStyle: const TextStyle(fontSize: 20 , color: Colors.white),
                ),
                onPressed: () => _nextStep(),
                child: const Text('Suivant', style: TextStyle(color: Colors.white),),
              ),
            ],
          )
        ]
    );
  }

}


