import 'package:client_control_car/constants/constants.dart';
import 'package:client_control_car/constants/route_helper.dart';
import 'package:client_control_car/controllers/auth_controller.dart';
import 'package:client_control_car/controllers/control_controller.dart';
import 'package:client_control_car/pages/book_rdv/forfait_control_screen.dart';
import 'package:client_control_car/pages/book_rdv/functions/functions_date_time.dart';
import 'package:client_control_car/pages/menu/drawer_widget.dart';
import 'package:client_control_car/pages/menu/menu_bottom.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:numberpicker/numberpicker.dart';

class DatTimeScreen extends StatefulWidget {
  const DatTimeScreen({Key? key}) : super(key: key);

  @override
  State<DatTimeScreen> createState() => _DatTimeScreenState();
}

class _DatTimeScreenState extends State<DatTimeScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  String selectedDate = "";
  DateTime dateTime = DateTime.now();
  bool isLoading = false;

  int heurTime = 8;
  int munitTime = 0;

  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  @override
  void initState() {
    super.initState();
    check();
    selectedDate = DateFormat.yMd('fr')
        .format(DateTime.now().add(const Duration(days: 1)));
  }

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
                  )),
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
                                onThen: () {},
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
                      // date
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
                                    "Date du rendez-vous",
                                    style: gothicBold.copyWith(fontSize: 25),
                                  ),
                                ),
                                // date
                                const SizedBox(
                                  height: 15,
                                ),
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  child: Text(
                                    "Sélectionnez un jour",
                                    style: gothicRegular.copyWith(
                                      color: normalText,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                SizedBox(
                                  height: 60,
                                  width: sizeWidth(context: context),
                                  child: ListView(
                                      scrollDirection: Axis.horizontal,
                                      children: [
                                        for (var item in listDate())
                                          InkWell(
                                            onTap: () {
                                              if (selectedDate ==
                                                  DateFormat.yMd('fr')
                                                      .format(item)) {
                                                selectedDate = "";
                                              } else {
                                                selectedDate =
                                                    DateFormat.yMd('fr')
                                                        .format(item);
                                              }
                                              setState(() {});
                                            },
                                            child: Container(
                                              width: 60,
                                              height: 50,
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 5),
                                              decoration: BoxDecoration(
                                                color: selectedDate ==
                                                        DateFormat.yMd('fr')
                                                            .format(item)
                                                    ? blueColor
                                                    : greyColor,
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  // name
                                                  Text(
                                                    DateFormat('EEE', 'fr')
                                                            .format(item)[0]
                                                            .toUpperCase() +
                                                        DateFormat('EEE', 'fr')
                                                            .format(item)
                                                            .substring(1),
                                                    style: gothicBold.copyWith(
                                                        fontSize: 16,
                                                        color: selectedDate ==
                                                                DateFormat.yMd(
                                                                        'fr')
                                                                    .format(
                                                                        item)
                                                            ? Colors.white
                                                            : normalText),
                                                  ),
                                                  // numbers
                                                  Text(
                                                    DateFormat('d', 'fr')
                                                        .format(item),
                                                    style: gothicRegular.copyWith(
                                                        fontSize: 16,
                                                        color: selectedDate ==
                                                                DateFormat.yMd(
                                                                        'fr')
                                                                    .format(
                                                                        item)
                                                            ? Colors.white
                                                            : normalText),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                      ]),
                                ),

                                // time
                                const SizedBox(
                                  height: 15,
                                ),
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  child: Text(
                                    "Sélectionnez une heure",
                                    style: gothicRegular.copyWith(
                                      color: normalText,
                                    ),
                                  ),
                                ),

                                const SizedBox(
                                  height: 15,
                                ),
                                // time
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    NumberPicker(
                                      value: heurTime,
                                      itemWidth: 50,
                                      itemHeight: 50,
                                      minValue: 8,
                                      maxValue: 20,
                                      onChanged: (value) => setState(
                                        () => heurTime = value,
                                      ),
                                      selectedTextStyle: gothicBold.copyWith(
                                        color: normalText,
                                        fontSize: 26,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border.symmetric(
                                          horizontal: BorderSide(
                                              color: normalText, width: 2),
                                        ),
                                      ),
                                    ),
                                    //
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    NumberPicker(
                                      value: munitTime,
                                      itemWidth: 50,
                                      itemHeight: 50,
                                      minValue: 0,
                                      maxValue: 59,
                                      onChanged: (value) => setState(
                                        () => munitTime = value,
                                      ),
                                      selectedTextStyle: gothicBold.copyWith(
                                        color: normalText,
                                        fontSize: 26,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border.symmetric(
                                          horizontal: BorderSide(
                                              color: normalText, width: 2),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                // TimePickerSpinner(
                                //   is24HourMode: true,
                                //   time: dateTime,
                                //   normalTextStyle: gothicMediom.copyWith(
                                //     fontSize: 24,
                                //     color: normalText,
                                //   ),
                                //   highlightedTextStyle: gothicBold.copyWith(
                                //     fontSize: 26,
                                //     color: normalText,
                                //   ),
                                //   spacing: 50,
                                //   itemHeight: 40,
                                //   isForce2Digits: true,
                                //   onTimeChange: (time) {
                                //     setState(() {
                                //       dateTime = time;
                                //     });
                                //   },
                                // ),
                              ],
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
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          children: [
                            // price
                            Expanded(
                              flex: 2,
                              child: Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
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
                                            color: Colors.black, fontSize: 25)),
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
                                    String newDate =
                                        "${selectedDate.split('/')[2]}-${selectedDate.split('/')[1]}-${selectedDate.split('/')[0]}";

                                    ControlController controlController =
                                        Get.find();
                                    setState(() {
                                      isLoading = true;
                                    });
                                    String timming = "";
                                    if (heurTime < 10) {
                                      timming += "0$heurTime";
                                    } else {
                                      timming += heurTime.toString();
                                    }
                                    timming += ":";
                                    if (munitTime < 10) {
                                      timming += "0$munitTime";
                                    } else {
                                      timming += munitTime.toString();
                                    }
                                    timming += ":00";

                                    controlController
                                        .addAddRendezVousController(
                                      date: newDate,
                                      time: timming,
                                    )
                                        .then((value) {
                                      setState(() {
                                        isLoading = false;
                                      });
                                      if (value.isSuccess) {
                                        Get.to(
                                            () => const ForfaitControlScreen(),
                                            routeName: RouteHelper
                                                .getForfaitControlPageRoute());
                                      } else {
                                        Get.snackbar(
                                          maxWidth: 500,
                                          backgroundColor:
                                              blueColor.withOpacity(.7),
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
                                            blueColor.withOpacity(.7),
                                        "Votre demande n'a pas été enregistrée",
                                        "Veuillez réessayer",
                                      );
                                    });

                                    // authController.dateTime = dateTime;
                                    // authController.selectedDate = selectedDate;
                                    // Timer(const Duration(seconds: 3), () {
                                    //   setState(() {
                                    //     isLoading = false;
                                    //   });
                                    //   Get.to(() => const ForfaitControlScreen(),
                                    //       routeName: RouteHelper
                                    //           .getForfaitControlPageRoute());
                                    // });
                                  },
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all(blueColor),
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
          ),
        ),
      ),
    );
  }
}
