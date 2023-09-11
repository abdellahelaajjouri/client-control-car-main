import 'dart:io';

import 'package:client_control_car/constants/constants.dart';
import 'package:client_control_car/constants/route_helper.dart';
import 'package:client_control_car/pages/auth/login_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DemoScreen extends StatefulWidget {
  const DemoScreen({Key? key}) : super(key: key);

  @override
  State<DemoScreen> createState() => _DemoScreenState();
}

class _DemoScreenState extends State<DemoScreen> {
  int indexDemo = 0;
  List<DemoModel> listDemo = [
    DemoModel(
        title: "Sélectionnez un véhicule",
        content:
            "Vous pouvez sélectionner jusqu'à 5 véhicule, pour vous, vos amis et de votre famille.",
        image: "assets/images/Groupe 68.png"),
    DemoModel(
        title: "Choisissez un forfait",
        content:
            "Pour chaque voiture, sélectionnez un forfaits puis joignez vos informations.",
        image: "assets/images/Groupe 72.png"),
    DemoModel(
        title: "Relax et soyez notifiés",
        content:
            "Nos professionnels font le travail pour vous. Vous serez averti dès que le travail est terminé !",
        image: "assets/images/Groupe 108.png"),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            color: blueColor,
            width: sizeWidth(context: context),
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            child: Container(
              padding: EdgeInsets.only(
                  top: kIsWeb
                      ? 30
                      : (Platform.isIOS || Platform.isMacOS)
                          ? 50
                          : 30),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(
                    maxWidth: 700,
                  ),
                  height: 60,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Image.asset(
                          "assets/icons/logo-horiz-cntrolcar.png",
                        ),
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      InkWell(
                        onTap: () {
                          Get.to(
                            () => const LoginScreen(),
                            routeName: RouteHelper.getLoginRoute(),
                          );
                        },
                        child: Image.asset(
                          "assets/icons/lauch-page-pro-03.png",
                          height: 50,
                          width: 50,
                          color: Colors.white,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          // head

          // content
          Expanded(
            child: SingleChildScrollView(
              child: Center(
                // width: sizeWidth(context: context),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: Column(
                    children: [
                      // title
                      Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 15),
                        child: Text(
                          "ACHETER UN VÉHICULE EN TOUTE SÉRÉNITÉ".toUpperCase(),
                          style: gothicBold.copyWith(
                              color: blueColor, fontSize: 16),
                        ),
                      ),
                      // content
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 15),
                        child: Text(
                          "Faites vous accompagner ou envoyer un technicien, vérifier l’état du véhicule directement chez le vendeur (Particulier ou Garage). AVANT L'ACHAT DU VEHICULE",
                          style: gothicBold.copyWith(fontSize: 12),
                        ),
                      ),
                      const SizedBox(
                        height: 13,
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 15),
                        child: Text(
                          "Nos techniciens vous envoi un rapport complet du véhicule et confirme s’il est conforme à l’annonce de la vente, à la fin du rendez-vous!",
                          style: gothicBold.copyWith(fontSize: 12),
                        ),
                      ),
                      // title
                      Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 15),
                        width: sizeWidth(context: context),
                        child: Text(
                          "COMMENT ÇA MARCHE ?".toUpperCase(),
                          textAlign: TextAlign.start,
                          style: gothicBold.copyWith(
                              color: blueColor, fontSize: 16),
                        ),
                      ),
                      // content
                      stepContent(
                        image:
                            "assets/icons/launchpage-inscription-client-05.jpg",
                        title: "ÉTAPE 1".toUpperCase(),
                        content:
                            "Trouver la voiture que vous souhaitez acheter (ex: leboncoin, paruvendu ou un garage).",
                      ),
                      stepContent(
                        image:
                            "assets/icons/launchpage-inscription-client-06.jpg",
                        title: "ÉTAPE 2".toUpperCase(),
                        content:
                            "Demandez un rendez-vous avec le vendeur du véhicule.",
                      ),
                      stepContent(
                        image:
                            "assets/icons/launchpage-inscription-client-07.jpg",
                        title: "ÉTAPE 3".toUpperCase(),
                        content:
                            'Cliquez sur "TROUVER UN TECHNICIEN" et remplissez le formulaire pour envoyer un technicien sur le lieu ou se trouve la voiture.',
                      ),
                      stepContent(
                        image:
                            "assets/icons/launchpage-inscription-client-08.jpg",
                        title: "ÉTAPE 4".toUpperCase(),
                        content:
                            "Le technicien vous rédige un rapport complet sur le véhicule (vis caché, usure de pneu etc..) et vous l'envoi directement dans votre boite e-mail.",
                      ),
                      //
                      const SizedBox(
                        height: 15,
                      ),
                      Center(
                        child: Container(
                          decoration: BoxDecoration(
                              color: blueColor,
                              borderRadius: BorderRadius.circular(6)),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          margin: const EdgeInsets.symmetric(horizontal: 15),
                          child: Text(
                            "VOUS POUVEZ ENSUITE ACHETER OU NON VOTRE VOITURE"
                                .toUpperCase(),
                            style: gothicBold.copyWith(
                              color: Colors.white,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),
                      // title
                      Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 15),
                        width: sizeWidth(context: context),
                        child: Text(
                          "NOS SERVICES PROPOSÉS".toUpperCase(),
                          textAlign: TextAlign.start,
                          style: gothicBold.copyWith(
                              color: blueColor, fontSize: 16),
                        ),
                      ),
                      // content
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 15),
                        child: Text(
                          "FAITES CONTRÔLER LE VÉHICULE D’OCCASION DE VOTRE CHOIX ET N’AYEZ PLUS DE SECRET SUR LE VÉHICULE QUE VOUS SOUHAITEZ ACQUÉRIR.",
                          style: gothicBold.copyWith(fontSize: 12),
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      for (String contnt in [
                        "Qu’il s’agisse d’une Voiture, d’un Camping-Car, ou d’un Utilitaire.",
                        "Le contrôle a lieu avant l’achat du véhicule.",
                        "Par un technicien qualifié, professionnel dans le domaine de l’automobile."
                      ])
                        Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 3),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.circle,
                                size: 7,
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Text(
                                  contnt,
                                  style: gothicBold.copyWith(fontSize: 11),
                                ),
                              ),
                            ],
                          ),
                        ),
                      // more content
                      moreContent(
                        image:
                            "assets/icons/launchpage-inscription-client-09.jpg",
                        title: "RAPPORT COMPLET PAR UN TECHNICIEN EN 1 HEURE",
                        content:
                            "Le procédé de contrôle du véhicule se déroule en 1 heure, pendant laquelle un technicien automobile, vas inspecter le véhicule choisi selon 160 points de contrôle. Notamment les organes de sécurité, le freinage, les systèmes électroniques, les trains roulans, la transmission, la direction, le moteur, la climatisation, la suralimentation (turbo ou compresseur)...",
                      ),
                      moreContent(
                        image:
                            "assets/icons/launchpage-inscription-client-10.jpg",
                        title: "INTERVENTION DANS TOUTE LA FRANCE",
                        content:
                            "Nos techniciens sont disponible au niveau national (le plus souvent dans les grandes villes). Nous enverrons un technicien là ou se trouve le véhicule pour l'inspection. Votre présence n'est pas nécessaire pendant le contrôle, vous pouvez donc vacquer à vos occupations de la journée. Vous recevrez ensuite un rapport complet sur l'état de santé du véhicule et nos recommandations sur l'achat du véhicule choisi. Vous aurez alors toutes les cartes en main pour faire votre choix !",
                      ),
                      moreContent(
                        image:
                            "assets/icons/launchpage-inscription-client-11.jpg",
                        title:
                            "NOUS VÉRIFIONS QUE VOTRE FUTUR VÉHICULE SOIT BIEN CONFORME À L'ANNONCE",
                        content:
                            "Vous obtenez un bilan détaillé de l’état du véhicule, sans mauvaise surprise (vis caché, usure des pneus, diagnostique valise OBD, etc...)",
                      ),
                      moreContent(
                        image:
                            "assets/icons/launchpage-inscription-client-12.jpg",
                        title:
                            "LES TECHNICIENS DE CONTROL-CAR VOUS CONSEILLENT ET VOUS ORIENTENT VERS LE BON CHOIX DE VÉHICULE",
                      ),
                      moreContent(
                        image:
                            "assets/icons/launchpage-inscription-client-13.jpg",
                        title:
                            "GRÂCE À NOS SERVICES, PLUS DE MAUVAISES SURPRISES OU DE COÛTS CACHÉS A L'AVENIR",
                      ),
                      //
                      Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 10),
                        child: Row(
                          children: [
                            // icon
                            Image.asset(
                              "assets/icons/lauch-page-pro-11.png",
                              width: 50,
                            ),
                            const SizedBox(
                              width: 6,
                            ),
                            // info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "06 99 54 71 98",
                                    style: gothicBold.copyWith(
                                      fontSize: 26,
                                    ),
                                  ),
                                  Text(
                                    "Service client".toUpperCase(),
                                    textAlign: TextAlign.center,
                                    style: gothicBold.copyWith(
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      //
                      Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 10),
                        child: Row(
                          children: [
                            // icon
                            Image.asset(
                              "assets/icons/lauch-page-pro-12.png",
                              width: 50,
                            ),
                            const SizedBox(
                              width: 6,
                            ),
                            // info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "contact@control-car.fr",
                                    style: gothicBold.copyWith(
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      //
                      Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 10),
                        child: Row(
                          children: [
                            // icon
                            Image.asset(
                              "assets/icons/lauch-page-pro-13.png",
                              width: 50,
                            ),
                            const SizedBox(
                              width: 6,
                            ),
                            // info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Lundi – Dimanche",
                                    style: gothicBold.copyWith(
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    "6:00h – 22:00h",
                                    style: gothicBold.copyWith(
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      //
                      const SizedBox(
                        height: 15,
                      ),
                      Center(
                        child: InkWell(
                          onTap: () {
                            // Get.back();
                            Get.to(
                              () => const LoginScreen(),
                              routeName: RouteHelper.getLoginRoute(),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                color: blueColor,
                                borderRadius: BorderRadius.circular(6)),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            margin: const EdgeInsets.symmetric(horizontal: 15),
                            child: Text(
                              "TROUVER MON TECHNICIEN".toUpperCase(),
                              style: gothicBold.copyWith(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 150,
                        width: sizeWidth(context: context),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget moreContent(
      {required String image, required String title, String? content}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: Row(
        children: [
          // image
          Image.asset(
            image,
            width: 100,
            height: 100,
            fit: BoxFit.fill,
          ),
          // title + content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: gothicBold.copyWith(
                    color: blueColor,
                    fontSize: 12,
                  ),
                ),
                //
                if (content != null)
                  Text(
                    content,
                    style: gothicBold.copyWith(fontSize: 9),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget stepContent(
      {required String image, required String title, String? content}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: Row(
        children: [
          // image
          Image.asset(
            image,
            width: 70,
          ),
          // title + content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: gothicBold.copyWith(
                    color: blueColor,
                    fontSize: 16,
                  ),
                ),
                //
                if (content != null)
                  Text(
                    content,
                    style: gothicBold.copyWith(fontSize: 11),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     backgroundColor: Colors.white,
  //     // backgroundColor: Color(0xffE3E2E2).withOpacity(.2),

  //     body: Column(
  //       children: [
  //         Expanded(
  //           child: Center(
  //             child: Container(
  //               constraints: const BoxConstraints(
  //                 maxWidth: 500,
  //               ),
  //               child: DemoWidget(
  //                 demoModel: listDemo[indexDemo],
  //                 index: indexDemo,
  //                 onTap: () {
  //                   if (indexDemo < listDemo.length - 1) {
  //                     setState(() {
  //                       indexDemo++;
  //                     });
  //                   } else {
  //                     Get.to(
  //                       () => const LoginScreen(),
  //                       routeName: RouteHelper.getLoginRoute(),
  //                     );
  //                     // Get.toNamed(RouteHelper.getLoginRoute());
  //                   }
  //                 },
  //               ),
  //             ),
  //           ),
  //         ),
  //         Center(
  //           child: Container(
  //             constraints: const BoxConstraints(
  //               maxWidth: 500,
  //             ),
  //             margin: const EdgeInsets.symmetric(horizontal: 10),
  //             // width: sizeWidth(context:context),
  //             child: Row(
  //               crossAxisAlignment: CrossAxisAlignment.center,
  //               mainAxisAlignment: MainAxisAlignment.center,
  //               children: [
  //                 for (int i = 0; i < listDemo.length; i++)
  //                   Container(
  //                     margin: const EdgeInsets.symmetric(horizontal: 3),
  //                     child: InkWell(
  //                       onTap: () {
  //                         setState(() {
  //                           indexDemo = i;
  //                         });
  //                       },
  //                       child: Icon(
  //                         Icons.circle,
  //                         color: indexDemo == i ? blueColor : greyColor,
  //                         size: indexDemo == i ? 12 : 11,
  //                       ),
  //                     ),
  //                   )
  //               ],
  //             ),
  //           ),
  //         ),
  //         const SizedBox(
  //           height: 50,
  //         )
  //       ],
  //     ),
  //   );
  // }
}

class DemoModel {
  String title;
  String content;
  String image;

  DemoModel({
    required this.title,
    required this.content,
    required this.image,
  });
}
