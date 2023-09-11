import 'dart:io';

import 'package:client_control_car/constants/constants.dart';
import 'package:client_control_car/constants/route_helper.dart';
import 'package:client_control_car/controllers/chat_controller.dart';
import 'package:client_control_car/controllers/notification_controller.dart';
import 'package:client_control_car/pages/chat/list_last_chat_screen.dart';
import 'package:client_control_car/pages/historys/mes_commande_page.dart';
import 'package:client_control_car/pages/info_vehicule/info_vehicule_screen.dart';
import 'package:client_control_car/pages/notification/notification_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MenuBottom extends StatefulWidget {
  final bool isGet;
  final int countNotification;
  final int countMessages;
  const MenuBottom(
      {super.key,
      this.isGet = true,
      this.countMessages = 0,
      this.countNotification = 0});

  @override
  State<MenuBottom> createState() => _MenuBottomState();
}

class _MenuBottomState extends State<MenuBottom> {
  // bool isPop = false;
  double nbrStart = 0;
  TextEditingController commentController = TextEditingController();
  FocusNode commentFocus = FocusNode();

  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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

  //

  getData() async {
    NotificationControl notificationControl = Get.find();
    ChatController chatController = Get.find();
    try {
      notificationControl.getAllNotificationController().then((value) {
        // countNotifi(listNotifi: notificationControl.listNotification);
      }).catchError((onError) {
        // countNotifi(listNotifi: notificationControl.listNotification);
      });
      //
      chatController.getLastMessagesController().then((value) {
        // countNtMessages(listMessages: chatController.listLastMessages);
      }).catchError((onError) {
        // countNtMessages(listMessages: chatController.listLastMessages);
      });
      //
      // getDataControls();
    } catch (e) {
      // countNotifi(listNotifi: notificationControl.listNotification);
      // countNtMessages(listMessages: chatController.listLastMessages);
    }
  }

  @override
  Widget build(BuildContext context) {
    check();
    return Container(
      height: kIsWeb
          ? 60
          : (Platform.isIOS || Platform.isMacOS)
              ? 70
              : 60,
      width: sizeWidth(context: context),
      color: blueColor,
      padding: EdgeInsets.only(
          bottom: kIsWeb
              ? 7
              : (Platform.isIOS || Platform.isMacOS)
                  ? 15
                  : 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          InkWell(
            onTap: () {
              Get.to(() => const InfoVehiculeScreen(),
                  routeName: RouteHelper.getInfoVehiculeRoute());
              // Get.offAll(() => const HomeMapScreen(),
              //     routeName: RouteHelper.getHomeMapRoute());
            },
            child: Image.asset(
              "assets/icons/voiture-icon.png",
              width: 29,
            ),
          ),
          InkWell(
            onTap: () {
              Get.to(() => const MesCommandePage(),
                  routeName: RouteHelper.getMesCommandeRoute());
            },
            child: const Icon(
              Icons.calendar_month,
              color: Colors.white,
              size: 30,
            ),
          ),
          InkWell(
            onTap: () {
              Get.to(() => const NotificationScreen(),
                  routeName: RouteHelper.getNotificationRoute());
            },
            child: Stack(
              children: [
                const Icon(
                  Icons.notifications_none,
                  color: Colors.white,
                  size: 30,
                ),
                if (widget.countNotification != 0)
                  const Positioned(
                    top: 0,
                    right: 0,
                    child: Icon(
                      Icons.circle,
                      color: Colors.red,
                      size: 10,
                    ),
                  )
              ],
            ),
          ),
          InkWell(
            onTap: () {
              Get.to(() => const ListLastChatScreen(),
                  routeName: RouteHelper.getListLastChatRoute());
            },
            child: Stack(
              children: [
                const Icon(
                  Icons.chat_outlined,
                  color: Colors.white,
                  size: 30,
                ),
                if (widget.countMessages != 0)
                  const Positioned(
                    top: 0,
                    right: 0,
                    child: Icon(
                      Icons.circle,
                      color: Colors.red,
                      size: 10,
                    ),
                  )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
