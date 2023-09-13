import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';
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
import 'widgets/image_selection_widget.dart';
import 'package:image_picker/image_picker.dart';import 'dart:convert';

class DiagnosticScreen extends StatefulWidget {
  const DiagnosticScreen({Key? key}) : super(key: key);

  @override
  State<DiagnosticScreen> createState() => _DiagnosticScreenState();
}

class _DiagnosticScreenState extends State<DiagnosticScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  StreamSubscription<QuerySnapshot>? subscription;

  @override
  Widget build(BuildContext context){
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading : InkWell(
            onTap: () {
              scaffoldKey.currentState!.openDrawer();
            },
            child: Image.asset("assets/icons/drawer.png")),
      ),
      body: MultiStepForm(),
      bottomNavigationBar: StreamBuilder<QuerySnapshot>(
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
    );
  }
}

class MultiStepForm extends StatefulWidget {
  @override
  _MultiStepFormState createState() => _MultiStepFormState();
}



class _MultiStepFormState extends State<MultiStepForm> {
  // FORMS
  List<GlobalKey<FormState>> _formKeys = [
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

  TextEditingController step1_marqueController = TextEditingController();
  TextEditingController step1_modeleController = TextEditingController();
  TextEditingController step1_yearController = TextEditingController();
  TextEditingController step1_immatController = TextEditingController();
  TextEditingController step1_kilomController = TextEditingController();
  TextEditingController step1_vinController = TextEditingController();
  TextEditingController step1_certifImmatController = TextEditingController();
  TextEditingController step1_b64CertifImmatController = TextEditingController();
  TextEditingController step1_b64CertifNonGageController = TextEditingController();
  TextEditingController step1_controleTechController = TextEditingController();
  TextEditingController step1_b64ControleTechController = TextEditingController();
  TextEditingController step1_carnetEntretController = TextEditingController();
  TextEditingController step1_b64CarnetEntretController = TextEditingController();
  TextEditingController step1_AutreDocCommentairController = TextEditingController();
  TextEditingController step1_b64AutreDocController = TextEditingController();

  // Step 2



  // Variables
  TextEditingController _field1Controller = TextEditingController();
  TextEditingController _field2Controller = TextEditingController();
  TextEditingController _field3Controller = TextEditingController();
  TextEditingController _field4Controller = TextEditingController();
  TextEditingController _field5Controller = TextEditingController();
  TextEditingController _field6Controller = TextEditingController();
  TextEditingController _field7Controller = TextEditingController();
  TextEditingController _field8Controller = TextEditingController();
  TextEditingController _field9Controller = TextEditingController();
  TextEditingController _field10Controller = TextEditingController();
  TextEditingController _field11Controller = TextEditingController();
  TextEditingController _field12Controller = TextEditingController();
  TextEditingController _field13Controller = TextEditingController();
  TextEditingController _field14Controller = TextEditingController();
  TextEditingController _field15Controller = TextEditingController();
  TextEditingController _field16Controller = TextEditingController();
  TextEditingController _field17Controller = TextEditingController();
  TextEditingController _field18Controller = TextEditingController();
  TextEditingController _field19Controller = TextEditingController();
  int _currentStep = 0;
  List _Data = List.filled(999,"");



  // init
  @override
  void initState() {
    super.initState();
    _getFormData();
  }
  _getFormData() async {
    final prefs = await SharedPreferences.getInstance();
    final Step1 = decodeObject(prefs , 'Step1');

    setState(() {
      step1_marqueController.text = Step1["marque"]  ;
      step1_modeleController.text = Step1["modele"];
      step1_yearController.text = Step1["annee"];
      step1_immatController.text = Step1["kilometrage"];
      step1_kilomController.text = Step1["immatriculation"];
      step1_vinController.text = Step1["numeroVin"];
      step1_b64CertifImmatController.text = Step1["b64CertifImmat"] ;
      step1_b64ControleTechController.text = Step1["b64ControleTech"] ;
      step1_AutreDocCommentairController.text = Step1["AutreDocCommentair"] ;
      step1_b64AutreDocController.text = Step1["b64AutreDoc"];
      step1_b64CertifNonGageController.text = Step1["b64CertifNonGage"] ;
      step1_b64CarnetEntretController.text = Step1["b64CarnetEntret"] ;
    });
  }


  // handle Object str
  decodeObject(prefs, ObjectStr){
    final ObjeStr = prefs.getString(ObjectStr);
    return json.decode(ObjeStr!);
  }
  void encode(prefs, Object , ObjName){
    final ObjsonStr = json.encode(Object);
    prefs.setString(ObjName, ObjsonStr);
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

    List<Step> _steps =  [
      // 1
      Step(
        title: Text('Documents') ,

        content: Form(

          key: _formKeys[_currentStep],
          child: Column(
            children: [
              TextFormField(
                controller: step1_marqueController,
                decoration: InputDecoration(labelText: 'Marque*'),
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
                controller: step1_modeleController,
                decoration: InputDecoration(labelText: 'Modèle*'),
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
                controller: step1_yearController,
                decoration: InputDecoration(labelText: 'Année*'),
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
                controller: step1_immatController,
                decoration: InputDecoration(labelText: 'Kilométrage*'),
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
                controller: step1_kilomController,
                decoration: InputDecoration(labelText: 'Immatriculation*'),
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
                controller: step1_vinController,
                decoration: InputDecoration(labelText: 'Numéro VIN*'),
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
                          step1_certifImmatController.text = "oui";
                          step1["CertifImmat"] = step1_certifImmatController.text;
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
                    SizedBox(width: 10),

                    SizedBox(
                      height: 30,

                      child: ElevatedButton(
                        onPressed: () {
                          step1_certifImmatController.text = "non";
                          step1["CertifImmat"] = step1_certifImmatController.text;
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
                        final ImagePicker _picker = ImagePicker();
                        final XFile? imgFile = await _picker.pickImage(source: ImageSource.gallery);
                        try {
                          if (imgFile != null) {
                            String base64Image = base64Encode(await imgFile.readAsBytes()!);
                            step1_b64CertifImmatController.text = base64Image;
                            step1["b64CertifImmat"] = step1_b64CertifImmatController.text;
                          }
                        } catch (e) {
                          print(e.toString());
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
                      final ImagePicker _picker = ImagePicker();
                      final XFile? imgFile = await _picker.pickImage(source: ImageSource.gallery);
                      try {
                        if (imgFile != null) {
                          String base64Image = base64Encode(await imgFile.readAsBytes()!);
                          step1_b64CertifNonGageController.text = base64Image;
                          step1["b64CertifNonGage"] = step1_b64CertifNonGageController.text;
                        }
                      } catch (e) {
                        print(e.toString());
                      }
                    },
                    child: Text("Importer votre image"),
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
                          step1_controleTechController.text = "valide";
                          step1["controleTech"] = step1_controleTechController.text;
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
                    SizedBox(width: 10),

                    SizedBox(
                      height: 30,

                      child: ElevatedButton(
                        onPressed: () {
                          step1_controleTechController.text = "invalide";
                          step1["controleTech"] = step1_controleTechController.text;
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
                    SizedBox(width: 10),

                    SizedBox(
                      height: 30,

                      child: ElevatedButton(
                        onPressed: () {
                          step1_controleTechController.text = "non";
                          step1["controleTech"] = step1_controleTechController.text;
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
                    final ImagePicker _picker = ImagePicker();
                    final XFile? imgFile = await _picker.pickImage(source: ImageSource.gallery);
                    try {
                      if (imgFile != null) {
                        String base64Image = base64Encode(await imgFile.readAsBytes()!);
                        step1_b64ControleTechController.text = base64Image;
                        step1["b64ControleTech"] = step1_b64ControleTechController.text;
                      }
                    } catch (e) {
                      print(e.toString());
                    }
                  },
                  child: Text("Importer votre image")
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
                          step1_carnetEntretController.text = "oui";
                          step1["carnetEntret"] = step1_carnetEntretController.text;
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
                    SizedBox(width: 10),

                    SizedBox(
                      height: 30,

                      child: ElevatedButton(
                        onPressed: () {
                          step1_carnetEntretController.text = "non";
                          step1["carnetEntret"] = step1_carnetEntretController.text;
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
                      final ImagePicker _picker = ImagePicker();
                      final XFile? imgFile = await _picker.pickImage(source: ImageSource.gallery);
                      try {
                        if (imgFile != null) {
                          String base64Image = base64Encode(await imgFile.readAsBytes()!);
                          step1_b64CarnetEntretController.text = base64Image;
                          step1["b64CarnetEntret"] = step1_b64CarnetEntretController.text;
                        }
                      } catch (e) {
                        print(e.toString());
                      }
                    },
                    child: Text("Importer votre image"),
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
                    controller: step1_AutreDocCommentairController,
                    decoration: InputDecoration(labelText: 'Ecrivez un commentaire...'),
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
                      final ImagePicker _picker = ImagePicker();
                      final XFile? imgFile = await _picker.pickImage(source: ImageSource.gallery);
                      try {
                        if (imgFile != null) {
                          String base64Image = base64Encode(await imgFile.readAsBytes()!);
                          step1_b64AutreDocController.text = base64Image;
                          step1["b64AutreDoc"] = step1_b64AutreDocController.text;
                        }
                      } catch (e) {
                        print(e.toString());
                      }
                    },
                    child: Text("Importer votre image"),
                  )
                ],
              ),
            ],
          ),
        ),
        isActive: _currentStep == 0,
      ),
      // 2
      Step(
        title: Text('Extérieur avant'),
        content: Form(
          key: _formKeys[1],
          child: Column(
            children: [
              TextFormField(
                controller: _field2Controller,
                decoration: InputDecoration(labelText: 'Field 2'),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Field is required';
                  }
                  return null;
                },
                onSaved: (value) {
                  _Data[1] = value!;
                },
              ),
            ],
          ),
        ),
        isActive: _currentStep == 1,
      ),
      // 3
      Step(
        title: Text('Côtés'),
        content: Form(
          key: _formKeys[2],
          child: Column(
            children: [
              TextFormField(
                controller: _field3Controller,
                decoration: InputDecoration(labelText: 'Field 3'),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Field is required';
                  }
                  return null;
                },
                onSaved: (value) {
                  _Data[2] = value!;
                },
              ),
            ],
          ),
        ),
        isActive: _currentStep == 2,
      ),
      // 4
      Step(
        title: Text('Extérieur arrière') ,
        content: Form(
          key: _formKeys[3],
          child: Column(
            children: [
              TextFormField(
                controller: _field4Controller,
                decoration: InputDecoration(labelText: 'Field 1'),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Field is required';
                  }
                  return null;
                },
                onSaved: (value) {
                  _Data[3] = value!;
                },
              ),
            ],
          ),
        ),
        isActive: _currentStep == 3,
      ),
      // 5
      Step(
        title: Text('Toits & avis'),
        content: Form(
          key: _formKeys[4],
          child: Column(
            children: [
              TextFormField(
                controller: _field5Controller,
                decoration: InputDecoration(labelText: 'Field 2'),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Field is required';
                  }
                  return null;
                },
                onSaved: (value) {
                  _Data[4] = value!;
                },
              ),
            ],
          ),
        ),
        isActive: _currentStep == 4,
      ),
      // 6
      Step(
        title: Text('Jantes'),
        content: Form(
          key: _formKeys[5],
          child: Column(

            children: [
              TextFormField(
                controller: _field6Controller,
                decoration: InputDecoration(labelText: 'Field 6'),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Field is required';
                  }
                  return null;
                },
                onSaved: (value) {
                  _Data[5] = value!;
                },
              ),
            ],
          ),
        ),
        isActive: _currentStep == 5,
      ),
      // 7
      Step(
        title: Text('Phare') ,
        content: Form(
          key: _formKeys[6],
          child: Column(
            children: [
              TextFormField(
                controller: _field7Controller,
                decoration: InputDecoration(labelText: 'Field 1'),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Field is required';
                  }
                  return null;
                },
                onSaved: (value) {
                  _Data[6] = value!;
                },
              ),
            ],
          ),
        ),
        isActive: _currentStep == 6,
      ),
      // 8
      Step(
        title: Text('Pneumatique'),
        content: Form(
          key: _formKeys[7],
          child: Column(
            children: [
              TextFormField(
                controller: _field8Controller,
                decoration: InputDecoration(labelText: 'Field 2'),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Field is required';
                  }
                  return null;
                },
                onSaved: (value) {
                  _Data[7] = value!;
                },
              ),
            ],
          ),
        ),
        isActive: _currentStep == 7,
      ),
      // 9
      Step(
        title: Text('Intérieur'),
        content: Form(
          key: _formKeys[8],
          child: Column(
            children: [
              TextFormField(
                controller: _field9Controller,
                decoration: InputDecoration(labelText: 'Field 3'),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Field is required';
                  }
                  return null;
                },
                onSaved: (value) {
                  _Data[8] = value!;
                },
              ),
            ],
          ),
        ),
        isActive: _currentStep == 8,
      ),
      // 10
      Step(
        title: Text('Intérieur avis') ,
        content: Form(
          key: _formKeys[9],
          child: Column(
            children: [
              TextFormField(
                controller: _field10Controller,
                decoration: InputDecoration(labelText: 'Field 1'),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Field is required';
                  }
                  return null;
                },
                onSaved: (value) {
                  _Data[9] = value!;
                },
              ),
            ],
          ),
        ),
        isActive: _currentStep == 9,
      ),
      // 11
      Step(
        title: Text('Électronique'),
        content: Form(
          key: _formKeys[10],
          child: Column(
            children: [
              TextFormField(
                controller: _field11Controller,
                decoration: InputDecoration(labelText: 'Field 2'),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Field is required';
                  }
                  return null;
                },
                onSaved: (value) {
                  _Data[10] = value!;
                },
              ),
            ],
          ),
        ),
        isActive: _currentStep == 10,
      ),
      // 12
      Step(
        title: Text('Moteur'),
        content: Form(
          key: _formKeys[11],
          child: Column(
            children: [
              TextFormField(
                controller: _field12Controller,
                decoration: InputDecoration(labelText: 'Field 3'),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Field is required';
                  }
                  return null;
                },
                onSaved: (value) {
                  _Data[11] = value!;
                },
              ),
            ],
          ),
        ),
        isActive: _currentStep == 11,
      ),
      // 13
      Step(
        title: Text('Roue AVG') ,
        content: Form(
          key: _formKeys[12],
          child: Column(
            children: [
              TextFormField(
                controller: _field13Controller,
                decoration: InputDecoration(labelText: 'Field 1'),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Field is required';
                  }
                  return null;
                },
                onSaved: (value) {
                  _Data[12] = value!;
                },
              ),
            ],
          ),
        ),
        isActive: _currentStep == 12,
      ),
      Step(
        title: Text('Roue AVD'),
        content: Form(
          key: _formKeys[13],
          child: Column(
            children: [
              TextFormField(
                controller: _field14Controller,
                decoration: InputDecoration(labelText: 'Field 2'),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Field is required';
                  }
                  return null;
                },
                onSaved: (value) {
                  _Data[13] = value!;
                },
              ),
            ],
          ),
        ),
        isActive: _currentStep == 13,
      ),
      Step(
        title: Text('Roue ARD'),
        content: Form(
          key: _formKeys[14],
          child: Column(
            children: [
              TextFormField(
                controller: _field15Controller,
                decoration: InputDecoration(labelText: 'Field 3'),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Field is required';
                  }
                  return null;
                },
                onSaved: (value) {
                  _Data[14] = value!;
                },
              ),
            ],
          ),
        ),
        isActive: _currentStep == 14,
      ),
      Step(
        title: Text('Roue ARG') ,
        content: Form(
          key: _formKeys[15],
          child: Column(
            children: [
              TextFormField(
                controller: _field16Controller,
                decoration: InputDecoration(labelText: 'Field 1'),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Field is required';
                  }
                  return null;
                },
                onSaved: (value) {
                  _Data[15] = value!;
                },
              ),
            ],
          ),
        ),
        isActive: _currentStep == 15,
      ),
      Step(
        title: Text('Test Conduite') ,
        content: Form(
          key: _formKeys[16],
          child: Column(
            children: [
              TextFormField(
                controller: _field17Controller,
                decoration: InputDecoration(labelText: 'Field 1'),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Field is required';
                  }
                  return null;
                },
                onSaved: (value) {
                  _Data[16] = value!;
                },
              ),
            ],
          ),
        ),
        isActive: _currentStep == 16,
      ),
      Step(
        title: Text('Avis général') ,
        content: Form(
          key: _formKeys[17],
          child: Column(
            children: [
              TextFormField(
                controller: _field18Controller,
                decoration: InputDecoration(labelText: 'Field 1'),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Field is required';
                  }
                  return null;
                },
                onSaved: (value) {
                  _Data[17] = value!;
                },
              ),
            ],
          ),
        ),
        isActive: _currentStep == 17,
      ),
      Step(
        title: Text('Résultat') ,
        content: Form(
          key: _formKeys[18],
          child: Column(
            children: [
              TextFormField(
                controller: _field19Controller,
                decoration: InputDecoration(labelText: 'Field 1'),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Field is required';
                  }
                  return null;
                },
                onSaved: (value) {
                  _Data[18] = value!;
                },
              ),
            ],
          ),
        ),
        isActive: _currentStep == 18,
      ),
    ];
    return Scaffold(
      appBar: AppBar(
        title: _steps[_currentStep].title,
      ),
      body : _steps[_currentStep].content,
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
