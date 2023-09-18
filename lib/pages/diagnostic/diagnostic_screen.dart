import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:client_control_car/constants/constants.dart';
import 'package:client_control_car/controllers/auth_controller.dart';
import 'package:client_control_car/controllers/control_controller.dart';
import 'package:client_control_car/pages/auth/widgets/custom_input_validator.dart';
import 'package:file_picker/file_picker.dart';
import 'package:client_control_car/pages/menu/drawer_widget.dart';
import 'package:client_control_car/pages/menu/menu_bottom.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
  TextEditingController lienController = TextEditingController();

  TextEditingController demandeController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController codepostalController = TextEditingController();
  TextEditingController batimentController = TextEditingController();

  TextEditingController marqueController = TextEditingController();
  TextEditingController ModeleController = TextEditingController();
  TextEditingController YearController = TextEditingController();
  TextEditingController ImmatController = TextEditingController();
  TextEditingController KilomController = TextEditingController();
  TextEditingController VinController = TextEditingController();
  TextEditingController AutreController = TextEditingController();


  bool isPresent = true;
  FocusNode lienFocus = FocusNode();

  FocusNode demandeFocus = FocusNode();
  FocusNode addressFocus = FocusNode();
  FocusNode cityFocus = FocusNode();
  FocusNode codepostalFocus = FocusNode();
  FocusNode batimentFocus = FocusNode();




  FocusNode ModeleFocus = FocusNode();
  FocusNode YearFocus = FocusNode();
  FocusNode ImmatFocus = FocusNode();
  FocusNode KilomFocus = FocusNode();
  FocusNode VinFocus = FocusNode();
  FocusNode AutreFocus = FocusNode();

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




  //
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
                          child: SingleChildScrollView(
                            child: Center(
                                child:
                                ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 500.0, // Set the maximum width as needed
                                    maxHeight: 2000.0, // Set the maximum height as needed
                                  ),
                                  child: MultiStepForm(),
                                )

                            ),
                          ),
                        ),
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
    "CertifImmat" : null,
    "b64CertifImmat" : null,
    "b64CertifNonGage" : null,
    "controleTech" : null,
    "b64ControleTech" : null,
    "carnetEntret" : null,
    "b64CarnetEntret" : null,
    "AutreDocCommentair" : null,
    "b64AutreDoc" : null
  };
  TextEditingController step1MarqueController = TextEditingController();
  TextEditingController step1ModeleController = TextEditingController();
  TextEditingController step1YearController = TextEditingController();
  var YearFormatter = MaskTextInputFormatter(
      mask: "####",
      filter: {
        "#": RegExp(r'[0-9]'),
      },
      type: MaskAutoCompletionType.lazy);
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
  bool isOuiSelected = false;
  bool isNonSelected = false;
  int _currentStep = 0;
  List data = List.filled(999,"");
  TextEditingController field2Controller = TextEditingController();
  TextEditingController field3Controller = TextEditingController();
  TextEditingController field4Controller = TextEditingController();
  TextEditingController field5Controller = TextEditingController();
  TextEditingController field6Controller = TextEditingController();
  TextEditingController field7Controller = TextEditingController();
  TextEditingController field8Controller = TextEditingController();
  TextEditingController field9Controller = TextEditingController();
  TextEditingController field10Controller = TextEditingController();
  TextEditingController field11Controller = TextEditingController();
  TextEditingController field12Controller = TextEditingController();
  TextEditingController field13Controller = TextEditingController();
  TextEditingController field14Controller = TextEditingController();
  TextEditingController field15Controller = TextEditingController();
  TextEditingController field16Controller = TextEditingController();
  TextEditingController field17Controller = TextEditingController();
  TextEditingController field18Controller = TextEditingController();
  TextEditingController field19Controller = TextEditingController();
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
      step1B64CertifNonGageController.text = step1["b64CertifNonGage"] ;
      step1B64CarnetEntretController.text = step1["b64CarnetEntret"] ;
    });
  }
  // handle Object str
  decodeObject(prefs, objectStr){
    final objeStr = prefs.getString(objectStr);
    return json.decode(objeStr!);
  }
  void encode(prefs, object , objName){
    final objsonStr = json.encode(Object);
    prefs.setString(objName, objsonStr);
  }
  // Handle Steps
  Future<void> _nextStep() async {
    if (_currentStep == 18) {
      return;
    }
    final isValid = _formKeys[_currentStep].currentState!.validate();
    if (isValid) {
      _formKeys[_currentStep].currentState!.save();
      // Save the form data to Shared Preferences
      final prefs = await SharedPreferences.getInstance();
      if (_currentStep == 0) {
        encode(prefs, step1, 'Step1');
      }
      setState(() {
        _currentStep++;
      });
    }
  }
  void _prevStep() {
    if(_currentStep == 0){
      return ;
    }
    setState(() {
      _currentStep--;
    });
  }
  // Content
  @override
  Widget build(BuildContext context) {
    List<Step> steps =  [
      // 1
      Step(
        title: const Text('Documents') ,
        content: Form(
          key: _formKeys[_currentStep],
          child: Column(
            children: [
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
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Field is required';
                            }
                            return null;
                          },
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
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Field is required';
                            }
                            return null;
                          },
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
              Container(
                    margin: const EdgeInsets.symmetric(horizontal: 15),
                    child: Stack(
                      children: [
                        CustomInputValidatore(
                          controller: step1YearController,
                          labelText: null,
                          marginContainer: const EdgeInsets.only(bottom: 0, top: 0),
                          width: sizeWidth(context: context),
                          hintText: "Année", // Remove the space after "Marque"
                          focusNode: step1YearFocus,
                          inputFormatters: [
                            YearFormatter
                          ],
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Field is required';
                            }
                            return null;
                          },
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
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Field is required';
                            }
                            return null;
                          },
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
                              return 'Field is required';
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
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Field is required';
                            }
                            return null;
                          },
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
                    height: 10,
                  ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Certificat d'immat",
                        style: gothicBold.copyWith(fontSize: 18),
                      ),
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
              TextFormField(
                controller: field2Controller,
                decoration: const InputDecoration(labelText: 'Field 2'),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Field is required';
                  }
                  return null;
                },
                onSaved: (value) {
                  data[1] = value!;
                },
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
              TextFormField(
                controller: field3Controller,
                decoration: const InputDecoration(labelText: 'Field 3'),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Field is required';
                  }
                  return null;
                },
                onSaved: (value) {
                  data[2] = value!;
                },
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
              TextFormField(
                controller: field4Controller,
                decoration: const InputDecoration(labelText: 'Field 1'),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Field is required';
                  }
                  return null;
                },
                onSaved: (value) {
                  data[3] = value!;
                },
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
              TextFormField(
                controller: field5Controller,
                decoration: const InputDecoration(labelText: 'Field 2'),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Field is required';
                  }
                  return null;
                },
                onSaved: (value) {
                  data[4] = value!;
                },
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
              TextFormField(
                controller: field6Controller,
                decoration: const InputDecoration(labelText: 'Field 6'),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Field is required';
                  }
                  return null;
                },
                onSaved: (value) {
                  data[5] = value!;
                },
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
              TextFormField(
                controller: field7Controller,
                decoration: const InputDecoration(labelText: 'Field 1'),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Field is required';
                  }
                  return null;
                },
                onSaved: (value) {
                  data[6] = value!;
                },
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
              TextFormField(
                controller: field8Controller,
                decoration: const InputDecoration(labelText: 'Field 2'),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Field is required';
                  }
                  return null;
                },
                onSaved: (value) {
                  data[7] = value!;
                },
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
              TextFormField(
                controller: field9Controller,
                decoration: const InputDecoration(labelText: 'Field 3'),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Field is required';
                  }
                  return null;
                },
                onSaved: (value) {
                  data[8] = value!;
                },
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
              TextFormField(
                controller: field10Controller,
                decoration: const InputDecoration(labelText: 'Field 1'),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Field is required';
                  }
                  return null;
                },
                onSaved: (value) {
                  data[9] = value!;
                },
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
              TextFormField(
                controller: field11Controller,
                decoration: const InputDecoration(labelText: 'Field 2'),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Field is required';
                  }
                  return null;
                },
                onSaved: (value) {
                  data[10] = value!;
                },
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
              TextFormField(
                controller: field12Controller,
                decoration: const InputDecoration(labelText: 'Field 3'),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Field is required';
                  }
                  return null;
                },
                onSaved: (value) {
                  data[11] = value!;
                },
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
              TextFormField(
                controller: field13Controller,
                decoration: const InputDecoration(labelText: 'Field 1'),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Field is required';
                  }
                  return null;
                },
                onSaved: (value) {
                  data[12] = value!;
                },
              ),
            ],
          ),
        ),
        isActive: _currentStep == 12,
      ),
      Step(
        title: const Text('Roue AVD'),
        content: Form(
          key: _formKeys[13],
          child: Column(
            children: [
              TextFormField(
                controller: field14Controller,
                decoration: const InputDecoration(labelText: 'Field 2'),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Field is required';
                  }
                  return null;
                },
                onSaved: (value) {
                  data[13] = value!;
                },
              ),
            ],
          ),
        ),
        isActive: _currentStep == 13,
      ),
      Step(
        title: const Text('Roue ARD'),
        content: Form(
          key: _formKeys[14],
          child: Column(
            children: [
              TextFormField(
                controller: field15Controller,
                decoration: const InputDecoration(labelText: 'Field 3'),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Field is required';
                  }
                  return null;
                },
                onSaved: (value) {
                  data[14] = value!;
                },
              ),
            ],
          ),
        ),
        isActive: _currentStep == 14,
      ),
      Step(
        title: const Text('Roue ARG') ,
        content: Form(
          key: _formKeys[15],
          child: Column(
            children: [
              TextFormField(
                controller: field16Controller,
                decoration: const InputDecoration(labelText: 'Field 1'),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Field is required';
                  }
                  return null;
                },
                onSaved: (value) {
                  data[15] = value!;
                },
              ),
            ],
          ),
        ),
        isActive: _currentStep == 15,
      ),
      Step(
        title: const Text('Test Conduite') ,
        content: Form(
          key: _formKeys[16],
          child: Column(
            children: [
              TextFormField(
                controller: field17Controller,
                decoration: const InputDecoration(labelText: 'Field 1'),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Field is required';
                  }
                  return null;
                },
                onSaved: (value) {
                  data[16] = value!;
                },
              ),
            ],
          ),
        ),
        isActive: _currentStep == 16,
      ),
      Step(
        title: const Text('Avis général') ,
        content: Form(
          key: _formKeys[17],
          child: Column(
            children: [
              TextFormField(
                controller: field18Controller,
                decoration: const InputDecoration(labelText: 'Field 1'),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Field is required';
                  }
                  return null;
                },
                onSaved: (value) {
                  data[17] = value!;
                },
              ),
            ],
          ),
        ),
        isActive: _currentStep == 17,
      ),
      Step(
        title: const Text('Résultat') ,
        content: Form(
          key: _formKeys[18],
          child: Column(
            children: [
              TextFormField(
                controller: field19Controller,
                decoration: const InputDecoration(labelText: 'Field 1'),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Field is required';
                  }
                  return null;
                },
                onSaved: (value) {
                  data[18] = value!;
                },
              ),
            ],
          ),
        ),
        isActive: _currentStep == 18,
      ),
    ];
    return Scaffold(
        body : steps[_currentStep].content,
        persistentFooterButtons : [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.black,
              padding: const EdgeInsets.all(16.0),
              textStyle: const TextStyle(fontSize: 20),
            ),
            onPressed: () => _prevStep(),
            child: const Text('Previous'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.black,
              padding: const EdgeInsets.all(16.0),
              textStyle: const TextStyle(fontSize: 20),
            ),
            onPressed: () => _nextStep(),
            child: const Text('Suivant'),
          ),
        ]
    );
  }

}

class DynamicInkWells extends StatefulWidget {
  @override
  _DynamicInkWellsState createState() => _DynamicInkWellsState();
}

class _DynamicInkWellsState extends State<DynamicInkWells> {
  List<Widget> inkWells = [];
  List<TextEditingController> controllers = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Column(
          children: inkWells,
        ),
        ElevatedButton(
          onPressed: () {
            _addInkWell();
          },
          child: Text('Add InkWell'),
        ),
      ],
    );
  }

  void _addInkWell() {
    final TextEditingController controller = TextEditingController();
    controllers.add(controller);
    inkWells.add(
      InkWell(
        onTap: () async {
          final ImagePicker picker = ImagePicker();
          final XFile? imgFile =
          await picker.pickImage(source: ImageSource.gallery);
          try {
            if (imgFile != null) {
              String base64Image =
              base64Encode(await imgFile.readAsBytes());
              controller.text = base64Image;
            }
          } catch (e) {
            print(e.toString());
          }
        },
        child: Text("Importer votre image"),
      ),
    );
    setState(() {});
  }
}


