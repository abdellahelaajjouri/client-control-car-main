import 'dart:async';
import 'package:client_control_car/constants/constants.dart';
import 'package:client_control_car/controllers/auth_controller.dart';
import 'package:client_control_car/controllers/control_controller.dart';
import 'package:client_control_car/pages/auth/widgets/custom_input_validator.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:file_picker/file_picker.dart';
import 'package:client_control_car/pages/menu/drawer_widget.dart';
import 'package:client_control_car/pages/menu/menu_bottom.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class DiagnosticVehiculeScreen extends StatefulWidget {
  const DiagnosticVehiculeScreen({Key? key}) : super(key: key);
  @override
  State<DiagnosticVehiculeScreen> createState() => _DiagnosticVehiculeScreenState();
}


class _DiagnosticVehiculeScreenState extends State<DiagnosticVehiculeScreen> {
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
  FocusNode marqueFocus = FocusNode();
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
                              Container(
                                constraints: const BoxConstraints(
                                  maxWidth: 800,
                                ),
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 15),
                                alignment: Alignment.center,
                                child: steps == 0
                                    ?
                                Form(
                                  key: _formKeyfirst,
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                    MainAxisAlignment.start,
                                    children: [
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


                                      // Marque du véhicule
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

                                      Container(
                                        margin: const EdgeInsets.symmetric(horizontal: 15),
                                        child: Stack(
                                          children: [
                                            CustomInputValidatore(
                                              controller: marqueController,
                                              labelText: null,
                                              marginContainer: const EdgeInsets.only(bottom: 0, top: 0),
                                              width: sizeWidth(context: context),
                                              hintText: "Marqurree", // Remove the space after "Marque"
                                              focusNode: marqueFocus,
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





                                      // Lien de l’offre
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
                                              controller: ModeleController,
                                              labelText: null,
                                              marginContainer: const EdgeInsets.only(bottom: 0, top: 0),
                                              width: sizeWidth(context: context),
                                              hintText: "Modèle", // Remove the space after "Marque"
                                              focusNode: ModeleFocus,
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
                                              controller: YearController,
                                              labelText: null,
                                              marginContainer: const EdgeInsets.only(bottom: 0, top: 0),
                                              width: sizeWidth(context: context),
                                              hintText: "Année", // Remove the space after "Marque"
                                              focusNode: YearFocus,
                                              inputFormatters: [
                                                YearFormatter

                                              ],
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
                                              controller: ImmatController,
                                              labelText: null,
                                              marginContainer: const EdgeInsets.only(bottom: 0, top: 0),
                                              width: sizeWidth(context: context),
                                              hintText: "Numéro de matriculation", // Remove the space after "Marque"
                                              focusNode: ImmatFocus,

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
                                              controller: KilomController,
                                              labelText: null,
                                              marginContainer: const EdgeInsets.only(bottom: 0, top: 0),
                                              width: sizeWidth(context: context),
                                              hintText: "Kilomètrage", // Remove the space after "Marque"
                                              focusNode: KilomFocus,

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
                                        height: 2,
                                      ),



                                      // Immatriculation
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
                                              controller: VinController,
                                              labelText: null,
                                              marginContainer: const EdgeInsets.only(bottom: 0, top: 0),
                                              width: sizeWidth(context: context),
                                              hintText: "Numéro de VIN", // Remove the space after "Marque"
                                              focusNode: VinFocus,

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


// ! done
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


                                            const SizedBox(width: 10),


                                            SizedBox(
                                              height: 30,
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                children: [
                                                  Container(
                                                    margin: const EdgeInsets.symmetric(horizontal: 5), // Add margin here
                                                    child: ElevatedButton(
                                                      onPressed: () {
                                                        setState(() {
                                                          isOuiSelected = true;
                                                          isNonSelected = false;
                                                        });
                                                      },
                                                      style: ButtonStyle(
                                                        backgroundColor: MaterialStateProperty.all(isOuiSelected ? Colors.grey[900] : Colors.grey),
                                                      ),
                                                      child: Container(
                                                        margin: const EdgeInsets.symmetric(horizontal: 10),
                                                        child: Text(
                                                          "Oui",
                                                          style: gothicBold.copyWith(fontSize: 18, color: Colors.white),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    margin: const EdgeInsets.symmetric(horizontal: 5), // Add margin here
                                                    child: ElevatedButton(
                                                      onPressed: () {
                                                        setState(() {
                                                          isOuiSelected = false;
                                                          isNonSelected = true;
                                                        });
                                                      },
                                                      style: ButtonStyle(
                                                        backgroundColor: MaterialStateProperty.all(isNonSelected ? Colors.grey[900] : Colors.grey),
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
                                            )
                                          ],

                                        ),

                                      ),
// ! done
                                      Container(
                                        margin: const EdgeInsets.symmetric(vertical: 30),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Container(
                                                height: 150,
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    _openFilePicker(); // Open the file picker when the button is pressed
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
// ! done
                                      Container(
                                        margin: const EdgeInsets
                                            .symmetric(
                                            horizontal: 0),
                                        child: Text(

                                          "Certificat non gage",
                                          style:

                                          gothicBold.copyWith(
                                              fontSize: 18),
                                        ),
                                      ),
// ! done
                                      Container(
                                        margin: const EdgeInsets.symmetric(vertical: 30),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Container(
                                                height: 150,
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    _openFilePicker(); // Open the file picker when the button is pressed
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

                                      Container(
                                        margin: const EdgeInsets.symmetric(vertical: 80),
                                        child: Row(
                                          children: [
                                            const Expanded(
                                              child: Text(
                                                "Contrôle Technique",
                                                style: TextStyle(fontSize: 14),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 30,
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  setState(() {
                                                    isValideChecked = !isValideChecked;
                                                    isInvalideChecked = false;
                                                    isNonChecked = false;
                                                  });
                                                },
                                                style: ButtonStyle(
                                                  backgroundColor: MaterialStateProperty.all(
                                                    isValideChecked ? Colors.grey[900] : Colors.grey,
                                                  ),
                                                ),
                                                child: Container(
                                                  margin: const EdgeInsets.symmetric(horizontal: 10),
                                                  child: const Text(
                                                    "VALIDE",
                                                    style: TextStyle(fontSize: 18, color: Colors.white),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            SizedBox(
                                              height: 30,
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  setState(() {
                                                    isInvalideChecked = !isInvalideChecked;
                                                    isValideChecked = false;
                                                    isNonChecked = false;
                                                  });
                                                },
                                                style: ButtonStyle(
                                                  backgroundColor: MaterialStateProperty.all(
                                                    isInvalideChecked ? Colors.grey[900] : Colors.grey,
                                                  ),
                                                ),
                                                child: Container(
                                                  margin: const EdgeInsets.symmetric(horizontal: 10),
                                                  child: const Text(
                                                    "Invalide",
                                                    style: TextStyle(fontSize: 18, color: Colors.white),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            SizedBox(
                                              height: 30,
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  setState(() {
                                                    isNonChecked = !isNonChecked;
                                                    isValideChecked = false;
                                                    isInvalideChecked = false;
                                                  });
                                                },
                                                style: ButtonStyle(
                                                  backgroundColor: MaterialStateProperty.all(
                                                    isNonChecked ? Colors.grey[900] : Colors.grey,
                                                  ),
                                                ),
                                                child: Container(
                                                  margin: const EdgeInsets.symmetric(horizontal: 10),
                                                  child: const Text(
                                                    "Non",
                                                    style: TextStyle(fontSize: 18, color: Colors.white),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],

                                        ),

                                      ),

                                      Container(
                                        margin: const EdgeInsets.symmetric(vertical: 30),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Container(
                                                height: 150,
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    _openFilePicker(); // Open the file picker when the button is pressed
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
                                        margin: const EdgeInsets.symmetric(horizontal: 0),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                "Carnet d'entretien",
                                                style: gothicBold.copyWith(fontSize: 14),
                                              ),
                                            ),

                                            SizedBox(
                                              height: 30,

                                              child: ElevatedButton(
                                                onPressed: () {
                                                  Get.back();
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
                                                  Get.back();
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
                                      Container(
                                        margin: const EdgeInsets.symmetric(vertical: 30),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Container(
                                                height: 150,
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    _openFilePicker(); // Open the file picker when the button is pressed
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
                                        margin: const EdgeInsets
                                            .symmetric(
                                            horizontal: 0),
                                        child: Text(

                                          "Autre documents ?",
                                          style:

                                          gothicBold.copyWith(
                                              fontSize: 18),
                                        ),
                                      ),

                                      Container(
                                        margin: const EdgeInsets.symmetric(horizontal: 15),
                                        child: SizedBox(
                                          height: 50, // Set your desired height here
                                          child: CustomInputValidatore(
                                            controller: AutreController,
                                            labelText: null,
                                            marginContainer: const EdgeInsets.only(bottom: 0, top: 0),
                                            width: sizeWidth(context: context),
                                            hintText: "Ecriver un commentaire ... *",
                                            focusNode: AutreFocus,
                                          ),
                                        ),
                                      ),


                                      Container(
                                        margin: const EdgeInsets.symmetric(vertical: 30),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Container(

                                                height: 150,
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    _openFilePicker(); // Open the file picker when the button is pressed
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
                                        margin: const EdgeInsets.symmetric(horizontal: 0),
                                        height: 50,
                                        child: Container(
                                          margin: const EdgeInsets.symmetric(horizontal: 0),
                                          height: 50,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                height: 80, // Make sure width and height are equal for a perfect circle
                                                decoration:const  BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.transparent, // Set background color to transparent
                                                ),
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    // Add your button's functionality here
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    elevation: 50, // Remove the shadow
                                                    primary: Colors.blue, // Make button background transparent
                                                    onPrimary: Colors.white, // Text color
                                                  ),
                                                  child:const  Icon(
                                                    Icons.add,
                                                    size: 32,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )










                                    ],
                                  ),
                                )
                                    : Form(
                                  key: _formKey,
                                  child: const Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                    MainAxisAlignment.center,

                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        // price


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
