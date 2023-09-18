import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:client_control_car/constants/constants.dart';
import 'package:client_control_car/controllers/auth_controller.dart';
import 'package:client_control_car/pages/menu/drawer_widget.dart';
import 'package:client_control_car/pages/menu/menu_bottom.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:image_picker/image_picker.dart';
import 'package:client_control_car/controllers/control_controller.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';


class DiagnosticScreen extends StatefulWidget {
  const DiagnosticScreen({Key? key}) : super(key: key);

  @override
  State<DiagnosticScreen> createState() => _DiagnosticScreenState();
}



// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//     FlutterLocalNotificationsPlugin();

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

  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;


  var YearFormatter = MaskTextInputFormatter(
      mask: "####",
      filter: {
        "#": RegExp(r'[0-9]'),
      },
      type: MaskAutoCompletionType.lazy);

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
                                    maxHeight: 99999.0, // Set the maximum height as needed
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
    List<Widget> inkWells = [];
    List<TextEditingController> controllers = [];
    List<Step> steps =  [
      // 1
      Step(
        title: const Text('Documents') ,
        content: Form(
          key: _formKeys[_currentStep],
          child: Column(
            children: [
              TextFormField(
                controller: step1MarqueController,
                decoration: const InputDecoration(labelText: 'Marque*'),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Field is required';
                  }
                  return null;
                },
                onSaved: (value) {
                  step1["marque"] = value!;
                },
              ),
              TextFormField(
                controller: step1ModeleController,
                decoration: const InputDecoration(labelText: 'Modèle*'),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Field is required';
                  }
                  return null;
                },
                onSaved: (value) {
                  step1["modele"] = value!;
                },
              ),
              TextFormField(
                controller: step1YearController,
                decoration: const InputDecoration(labelText: 'Année*'),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Field is required';
                  }
                  return null;
                },
                onSaved: (value) {
                  step1["annee"] = value!;
                },
              ),
              TextFormField(
                controller: step1ImmatController,
                decoration: const InputDecoration(labelText: 'Kilométrage*'),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Field is required';
                  }
                  return null;
                },
                onSaved: (value) {
                  step1["kilometrage"] = value!;
                },
              ),
              TextFormField(
                controller: step1KilomController,
                decoration: const InputDecoration(labelText: 'Immatriculation*'),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Field is required';
                  }
                  return null;
                },
                onSaved: (value) {
                  step1["immatriculation"] = value!;
                },
              ),
              TextFormField(
                controller: step1VinController,
                decoration: const InputDecoration(labelText: 'Numéro VIN*'),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Field is required';
                  }
                  return null;
                },
                onSaved: (value) {
                  step1["numeroVin"] = value!;
                },
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Certificat d'immat",
                        style: gothicBold.copyWith(fontSize: 18),
                      ),
                    ),

                    SizedBox(
                      height: 30,

                      child: ElevatedButton(
                        onPressed: () {
                          step1CertifImmatController.text = "oui";
                          step1["CertifImmat"] = step1CertifImmatController.text;
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Colors.grey),
                        ),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            "OUI",
                            style: gothicBold.copyWith(fontSize: 18, color: Colors.white),
                          ),
                        ),

                      ),

                    ),
                    const SizedBox(width: 10),

                    SizedBox(
                      height: 30,

                      child: ElevatedButton(
                        onPressed: () {
                          step1CertifImmatController.text = "non";
                          step1["CertifImmat"] = step1CertifImmatController.text;
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Colors.grey),
                        ),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            "Non",
                            style: gothicBold.copyWith(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],

                ),

              ),
              InkWell(
                onTap: () async {
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
                child: const Text("Importer votre image"),
              ),
              Column(
                children : [
                  const Text("Certificat non gage",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  InkWell(
                    onTap: () async {
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
                    child: const Text("Importer votre image"),
                  ),
                ],
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Contrôle Technique",
                        style: gothicBold.copyWith(fontSize: 18),
                      ),
                    ),

                    SizedBox(
                      height: 30,

                      child: ElevatedButton(
                        onPressed: () {
                          step1ControleTechController.text = "valide";
                          step1["controleTech"] = step1ControleTechController.text;
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Colors.grey),
                        ),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            "VALIDE",
                            style: gothicBold.copyWith(fontSize: 18, color: Colors.white),
                          ),
                        ),

                      ),

                    ),
                    const SizedBox(width: 10),

                    SizedBox(
                      height: 30,

                      child: ElevatedButton(
                        onPressed: () {
                          step1ControleTechController.text = "invalide";
                          step1["controleTech"] = step1ControleTechController.text;
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Colors.grey),
                        ),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            "INVALIDE",
                            style: gothicBold.copyWith(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    SizedBox(
                      height: 30,

                      child: ElevatedButton(
                        onPressed: () {
                          step1ControleTechController.text = "non";
                          step1["controleTech"] = step1ControleTechController.text;
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Colors.grey),
                        ),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            "Non",
                            style: gothicBold.copyWith(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],

                ),

              ),
              InkWell(
                  onTap: () async {
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
                    }
                  },
                  child: const Text("Importer votre image")
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Carnet d’entretien",
                        style: gothicBold.copyWith(fontSize: 18),
                      ),
                    ),
                    SizedBox(
                      height: 30,

                      child: ElevatedButton(
                        onPressed: () {
                          step1CarnetEntretController.text = "oui";
                          step1["carnetEntret"] = step1CarnetEntretController.text;
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Colors.grey),
                        ),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            "OUI",
                            style: gothicBold.copyWith(fontSize: 18, color: Colors.white),
                          ),
                        ),

                      ),

                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      height: 30,

                      child: ElevatedButton(
                        onPressed: () {
                          step1CarnetEntretController.text = "non";
                          step1["carnetEntret"] = step1CarnetEntretController.text;
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Colors.grey),
                        ),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            "Non",
                            style: gothicBold.copyWith(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children : [
                  const Text("Carnet d’entretien" ,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      )),
                  InkWell(
                    onTap: () async {
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
                    child: const Text("Importer votre image"),
                  )
                ],
              ),
              Column(
                  children : [
                    const Text("Autre documents ?" ,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        )),
                    TextFormField(
                      controller: step1AutreDocCommentairController,
                      decoration: const InputDecoration(labelText: 'Ecrivez un commentaire...'),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Field is required';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        step1["AutreDocCommentair"] = value!;
                      },
                    ),
                    InkWell(
                      onTap: () async {
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
                      child: const Text("Importer votre image"),
                    ),
                  ]
              ),
              DynamicInkWells(),
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

