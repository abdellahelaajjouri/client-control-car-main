import 'dart:math';

import 'package:client_control_car/constants/app_constant.dart';
import 'package:client_control_car/constants/constants.dart';
import 'package:client_control_car/constants/route_helper.dart';
import 'package:client_control_car/controllers/auth_controller.dart';
import 'package:client_control_car/pages/chat/list_last_chat_screen.dart';
import 'package:client_control_car/pages/contact_assistance/contact_assistance_screen.dart';
import 'package:client_control_car/pages/historys/mes_commande_page.dart';
import 'package:client_control_car/pages/info_vehicule/info_vehicule_screen.dart';
import 'package:client_control_car/pages/info_vehicule/widgets/widgets.dart';
import 'package:client_control_car/pages/notification/notification_screen.dart';
import 'package:client_control_car/pages/profil/profil_screen.dart';
import 'package:client_control_car/pages/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DrawerWidget extends StatefulWidget {
  final bool isGet;
  final int countMessage;
  final int countNotification;
  final Function onThen;
  const DrawerWidget(
      {super.key,
      this.isGet = true,
      this.countMessage = 0,
      this.countNotification = 0,
      required this.onThen});

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  // int countNotification = 0;
  // int countMessages = 0;

  double nbrStart = 0;
  TextEditingController commentController = TextEditingController();
  FocusNode commentFocus = FocusNode();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  //

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: GetBuilder<AuthController>(builder: (authController) {
        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: SizedBox(
                  width: sizeWidth(context: context),
                  child: Column(
                    children: [
                      // head
                      if (authController.userModel != null)
                        Container(
                          height: sizeHeight(context: context) * .36,
                          width: double.infinity,
                          color: blueColor,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // image

                              Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 5),
                                child: CustomImageCircle(
                                  image: authController.userModel!.photo
                                      .toString(),
                                  width: 100,
                                  height: 100,
                                  placeholder: "assets/icons/logo_user.png",
                                ),
                              ),
                              // Container(
                              //   margin: const EdgeInsets.symmetric(
                              //       horizontal: 15, vertical: 5),
                              //   child: Image.asset("assets/icons/logo_user.png"),
                              // ),
                              // name
                              Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 4),
                                child: Text(
                                  authController.userModel == null
                                      ? "Nom & Prenom"
                                      : "${authController.userModel!.first_name} ${authController.userModel!.last_name == 'null' ? '' : authController.userModel!.last_name}",
                                  style: gothicBold.copyWith(
                                      color: Colors.white, fontSize: 18),
                                ),
                              ),
                              // phone
                              Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 2),
                                child: Text(
                                  authController.userModel == null
                                      ? ""
                                      : authController.userModel!.phone
                                                  .toString()
                                                  .length ==
                                              9
                                          ? "0${authController.userModel!.phone.toString()}"
                                          : authController.userModel!.phone
                                              .toString(),
                                  style: gothicMediom.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      // menu
                      const SizedBox(
                        height: 30,
                      ),

                      itemMenu(
                          title: "Mon profil",
                          icon: Icons.person,
                          onTap: () {
                            if (!checkIsWeb(context: context)) {
                              Get.back();
                            }
                            Get.to(
                              () => const ProfilScreen(),
                              routeName: RouteHelper.getProfilRoute(),
                            )!
                                .then((value) => widget.onThen);
                          }),

                      itemMenu(
                          title: "Demande de contrôle",
                          icon: Icons.home_filled,
                          iconAssets: "assets/icons/voiture-icon.png",
                          onTap: () {
                            if (!checkIsWeb(context: context)) {
                              Get.back();
                            }
                            Get.to(() => const InfoVehiculeScreen(),
                                    routeName:
                                        RouteHelper.getInfoVehiculeRoute())!
                                .then((value) => widget.onThen);
                          }),
                      itemMenu(
                          title: "Demande de contrôle 2",
                          icon: Icons.home_filled,
                          iconAssets: "assets/icons/voiture-icon.png",
                          onTap: () {
                            if (!checkIsWeb(context: context)) {
                              Get.back();
                            }
                            Get.to(() => const InfoVehiculeScreen(),
                                routeName:
                                RouteHelper.getInfoVehiculeRoute())!
                                .then((value) => widget.onThen);
                          }),
                      itemMenu(
                        title: "Historique / mes commandes",
                        icon: Icons.calendar_month,
                        onTap: () {
                          if (!checkIsWeb(context: context)) {
                            Get.back();
                          }
                          Get.to(() => const MesCommandePage(),
                                  routeName: RouteHelper.getMesCommandeRoute())!
                              .then((value) => widget.onThen);
                        },
                      ),

                      // itemMenu(
                      //     title: "Démarches administratives",
                      //     icon: Icons.account_balance_outlined,
                      //     isArrow: true,
                      //     isShowGriz: authController.isShozGriz,
                      //     onTap: () {
                      //       authController.isShozGriz =
                      //           !authController.isShozGriz;
                      //       authController.update();
                      //     }),
                      // if (authController.isShozGriz)
                      //   Container(
                      //     margin: const EdgeInsets.only(left: 50),
                      //     child: Column(
                      //       children: [
                      //         itemMenu(
                      //           title: "Carte grise",
                      //           icon: Icons.folder_open,
                      //           onTap: () {
                      //             if (!checkIsWeb(context: context)) {
                      //               Get.back();
                      //             }
                      //             Get.to(() => const CarteGriseHomePage(),
                      //                 routeName:
                      //                     RouteHelper.getCarteGriseHomeRoute());
                      //           },
                      //         ),
                      //         itemMenu(
                      //             title: "Assurer mon véhicule",
                      //             onTap: () {},
                      //             icon: Icons.car_crash),
                      //       ],
                      //     ),
                      //   ),

                      itemMenu(
                          title: "Contact / Assistance",
                          icon: Icons.settings,
                          onTap: () {
                            if (!checkIsWeb(context: context)) {
                              Get.back();
                            }
                            Get.to(() => const ContactAssistanceScreen(),
                                    routeName: RouteHelper
                                        .getContactAssistanceRoute())!
                                .then((value) => widget.onThen);
                          }),
                      checkIsWeb(context: context)
                          ? itemMenu(
                              title: "Notifications",
                              isStackNotif: widget.countNotification != 0,
                              icon: Icons.notifications_none,
                              onTap: () {
                                if (!checkIsWeb(context: context)) {
                                  Get.back();
                                }
                                Get.to(() => const NotificationScreen(),
                                        routeName:
                                            RouteHelper.getNotificationRoute())!
                                    .then((value) => widget.onThen);
                              })
                          : Container(),
                      checkIsWeb(context: context)
                          ? itemMenu(
                              title: "Messages",
                              isStackNotif: widget.countMessage != 0,
                              icon: Icons.chat_outlined,
                              onTap: () {
                                if (!checkIsWeb(context: context)) {
                                  Get.back();
                                }
                                Get.to(() => const ListLastChatScreen(),
                                        routeName:
                                            RouteHelper.getListLastChatRoute())!
                                    .then((value) => widget.onThen);
                              })
                          : Container(),
                    ],
                  ),
                ),
              ),
            ),
            // logout
            const SizedBox(
              height: 10,
            ),
            itemMenu(
                title: "Déconnexion",
                icon: Icons.logout,
                onTap: () async {
                  SharedPreferences sharedPreferences =
                      await SharedPreferences.getInstance();
                  sharedPreferences.remove(AppConstant.USER_EMAIL);
                  sharedPreferences.remove(AppConstant.USER_PASSWORD);
                  Get.offAll(
                    () => const SplashScreen(),
                    routeName: RouteHelper.getSplashRoute(),
                  );
                }),
            const SizedBox(
              height: 10,
            ),
          ],
        );
      }),
    );
  }

  Widget itemMenu(
      {required String title,
      required IconData icon,
      String? iconAssets,
      bool isArrow = false,
      Function()? onTap,
      bool isStackNotif = false,
      bool isShowGriz = false}) {
    return ListTile(
      onTap: onTap,
      leading: Stack(
        children: [
          iconAssets == null
              ? Icon(
                  icon,
                  color: Colors.black,
                )
              : SizedBox(
                  width: 24,
                  child: Center(
                    child: Image.asset(
                      iconAssets,
                      color: Colors.black,
                      width: 20,
                    ),
                  ),
                ),
          if (isStackNotif)
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
      title: Text(
        title,
        style: gothicBold.copyWith(
          color: Colors.black,
        ),
      ),
      trailing: isArrow
          ? Transform.rotate(
              angle: isShowGriz ? 90 * pi / 180 : 0,
              child: const Icon(
                Icons.arrow_forward_ios,
                color: Colors.black,
                size: 13,
              ),
            )
          // ? Icon(
          //     isShowGriz ? Icons.arrow_back_ios : Icons.arrow_forward_ios,
          //     color: Colors.black,
          //     size: 13,
          //   )
          : null,
    );
  }
}
