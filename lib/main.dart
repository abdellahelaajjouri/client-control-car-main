import 'dart:developer';

import 'package:client_control_car/constants/app_constant.dart';
import 'package:client_control_car/constants/constants.dart';
import 'package:client_control_car/constants/notification_service.dart';
import 'package:client_control_car/constants/route_helper.dart';
import 'package:client_control_car/control_repository/api_client.dart';
import 'package:client_control_car/control_repository/auth_repo.dart';
import 'package:client_control_car/control_repository/chat_repo.dart';
import 'package:client_control_car/control_repository/control_repo.dart';
import 'package:client_control_car/control_repository/notification_repo.dart';
import 'package:client_control_car/controllers/auth_controller.dart';
import 'package:client_control_car/controllers/binding_controller.dart';
import 'package:client_control_car/controllers/chat_controller.dart';
import 'package:client_control_car/controllers/control_controller.dart';
import 'package:client_control_car/controllers/notification_controller.dart';
// import 'package:client_control_car/controllers/notification_helper.dart';
import 'package:client_control_car/firebase_options.dart';
import 'package:client_control_car/pages/auth/widgets/custom_input_validator.dart';
import 'package:client_control_car/pages/historys/consulter_rapport_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:shared_preferences/shared_preferences.dart';

// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//     FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  initializeDateFormatting();
  loadController();
  if (!kIsWeb) {
    Stripe.publishableKey = AppConstant.publishableKey;
  }

  NotificationService().initNotification();
  if (!kIsWeb) {
    try {
      // if (GetPlatform.isMobile) {
      // await NotificationHelper.initialize(flutterLocalNotificationsPlugin);
      FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        NotificationService()
            .showNotification(id: 100, title: "nicce  123", body: "hhhh check");

        // NotificationHelper.showNotification(
        //     message, flutterLocalNotificationsPlugin, true);
      });
      // }
    } catch (e) {
      log(e.toString());
    }
  }

  Future.delayed(const Duration(seconds: 60), () {
    AuthController authController = Get.find();
    if (authController.userModel != null ||
        authController.accessUserJWS.toString() != "") {
      final CollectionReference controlRef =
          FirebaseFirestore.instance.collection('control');
      String access = authController.userModel!.access.toString() == "null"
          ? authController.accessUserJWS.toString()
          : authController.userModel!.access.toString();
      controlRef.snapshots().listen((QuerySnapshot snapshot) {
        Map<String, dynamic> payload = Jwt.parseJwt(access);
        if (snapshot.docChanges.isNotEmpty) {
          DocumentChange change = snapshot.docChanges.last;
          if (change.type == DocumentChangeType.added ||
              change.type == DocumentChangeType.modified) {
            if (change.doc["isvue"].toString() == "false" &&
                payload["user_id"].toString() ==
                    change.doc["user"].toString()) {
              controlRef
                  .doc(change.doc.id.toString())
                  .update({"isvue": true}).then((value) => null);
              // Get.defaultDialog();
              getDataControls(
                  id: change.doc.id.toString(),
                  idControl: change.doc["id_control"].toString());
            }
          }
        }
      });
    }
  });

  runApp(const MyApp());
}

// add this

getDataControls({required String id, required String idControl}) async {
  //
  double nbrStart = 0;
  final formKeyComment = GlobalKey<FormState>();
  TextEditingController commentController = TextEditingController();
  FocusNode commentFocus = FocusNode();
  //
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
                  height: Get.height * .6,
                  decoration: const BoxDecoration(color: Colors.white),
                  child: Form(
                    key: formKeyComment,
                    child: SingleChildScrollView(
                      child: SizedBox(
                        width: Get.width,
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
                                itemPadding:
                                    const EdgeInsets.symmetric(horizontal: 4.0),
                                itemBuilder: (context, _) => Icon(
                                  Icons.star,
                                  color: blueColor,
                                ),
                                onRatingUpdate: (rating) {
                                  nbrStart = rating;
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
                                width: Get.width,
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
                              width: Get.size.width * .8,
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
                                      // setState(() {
                                      // isLoading = true;
                                      // });
                                      ControlController controlController =
                                          Get.find();
                                      controlController
                                          .addreviewController(
                                              control: controlController
                                                  .controlModel!.id
                                                  .toString(),
                                              comment:
                                                  commentController.text.isEmpty
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
                                          // getData();
                                        } else {
                                          // setState(() {
                                          //   isLoading = false;
                                          // });
                                          if (value.message
                                              .toLowerCase()
                                              .contains(
                                                  "deja exist".toLowerCase())) {
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
                                        // setState(() {
                                        //   isLoading = false;
                                        // });
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
                                        borderRadius: BorderRadius.circular(0),
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
                              width: Get.size.width * .8,
                              child: ElevatedButton(
                                  onPressed: () {
                                    // start pass
                                    Get.back();
                                    // setState(() {
                                    //   isLoading = true;
                                    // });
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
                                        // getData();
                                        passControlFini();
                                      } else {
                                        // setState(() {
                                        //   isLoading = false;
                                        // });
                                        Get.snackbar(
                                          maxWidth: 500,
                                          backgroundColor:
                                              blueColor.withOpacity(.7),
                                          "Votre demande n'a pas été enregistrée",
                                          "Veuillez réessayer",
                                        );
                                      }
                                    }).catchError((onerror) {
                                      // setState(() {
                                      //   isLoading = false;
                                      // });
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
                                        MaterialStateProperty.all(Colors.white),
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
                                    "Passer",
                                    style: gothicBold.copyWith(
                                        color: Colors.black),
                                  )),
                            ),
                            //
                            SizedBox(
                              width: Get.size.width * .8,
                              child: ElevatedButton(
                                onPressed: () {
                                  Get.dialog(Scaffold(
                                    // appBar: AppBar(),
                                    floatingActionButton: FloatingActionButton(
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
                                  style:
                                      gothicBold.copyWith(color: Colors.white),
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
        height: Get.size.width * .5,
        decoration: const BoxDecoration(color: Colors.white),
        child: SingleChildScrollView(
          child: SizedBox(
            width: Get.size.width,
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
                    style:
                        gothicBold.copyWith(fontSize: 16, color: Colors.black),
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
                    style:
                        gothicMediom.copyWith(fontSize: 14, color: normalText),
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

// end add this

Future<dynamic> myBackgroundMessageHandler(RemoteMessage message) async {
  NotificationService()
      .showNotification(id: 100, title: "nicce ", body: "hhhh check");

  // NotificationHelper.showNotification(
  //     message, flutterLocalNotificationsPlugin, true);
  // var androidInitialize = new AndroidInitializationSettings('notification_icon');
  // var iOSInitialize = new IOSInitializationSettings();
  // var initializationsSettings = new InitializationSettings(android: androidInitialize, iOS: iOSInitialize);
  // FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  // flutterLocalNotificationsPlugin.initialize(initializationsSettings);
  // NotificationHelper.showNotification(message, flutterLocalNotificationsPlugin, true);
}

void loadController() async {
  final sharedPreferences = await SharedPreferences.getInstance();

  Get.put(
    sharedPreferences,
    permanent: true,
  );

  Get.put(
    ApiClient(
      appBaseUrl: AppConstant.BASE_URL,
      sharedPreferences: Get.find(),
    ),
    permanent: true,
  );

  // Repository
  Get.put(
    AuthRepo(
      apiClient: Get.find(),
      sharedPreferences: Get.find(),
    ),
    permanent: true,
  );

  Get.put(
    ControlRepo(
      apiClient: Get.find(),
      sharedPreferences: Get.find(),
    ),
    permanent: true,
  );
  Get.put(
    ChatRepo(
      apiClient: Get.find(),
      sharedPreferences: Get.find(),
    ),
    permanent: true,
  );

  Get.put(
    NotificationRepo(
      apiClient: Get.find(),
      sharedPreferences: Get.find(),
    ),
    permanent: true,
  );
  // Controller
  Get.put(
    AuthController(
      authRepo: Get.find(),
    ),
    permanent: true,
  );

  Get.put(
    ControlController(
      controlRepo: Get.find(),
    ),
    permanent: true,
  );

  Get.put(
    ChatController(
      chatRepo: Get.find(),
    ),
    permanent: true,
  );

  Get.put(
    NotificationControl(
      notificationRepo: Get.find(),
    ),
    permanent: true,
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppConstant.APP_NAME,
      // theme: ThemeData(useMaterial3: true),
      debugShowCheckedModeBanner: false,
      initialRoute: RouteHelper.getSplashRoute(),
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: "Century Gothic",
        useMaterial3: true,
      ),
      getPages: RouteHelper.routes,
      initialBinding: BindingController(),
      locale: const Locale("fr"),
      // home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}
