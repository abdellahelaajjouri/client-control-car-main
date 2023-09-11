import 'dart:convert';

import 'package:client_control_car/constants/app_constant.dart';
import 'package:client_control_car/constants/route_helper.dart';
import 'package:client_control_car/controllers/auth_controller.dart';
import 'package:client_control_car/models/user_model.dart';
import 'package:client_control_car/pages/book_rdv/forfait_control_screen.dart';
import 'package:client_control_car/pages/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_termii/flutter_termii.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

// colors
Color blueColor = const Color(0xff2C73F3);
Color normalText = const Color(0xff707070);
Color greyColor = const Color(0xffE3E2E2);
Color iconColor = const Color(0xffFB0101);
Color linetimColor = const Color(0xff5D5D5D);
Color greenColor = const Color(0xff1FE179);
Color orengeColor = const Color(0xffF57A0F);

Widget labelInput({required String text, bool req = false}) {
  return Text.rich(
    TextSpan(children: [
      TextSpan(text: text, style: gothicRegular.copyWith()),
      if (req)
        TextSpan(
            text: '*',
            style: gothicRegular.copyWith(
              color: Colors.red,
            )),
    ]),
    style: gothicRegular.copyWith(),
  );
}

double sizeWidth({required BuildContext context}) {
  return MediaQuery.of(context).size.width;
}

double sizeHeight({required BuildContext context}) {
  return MediaQuery.of(context).size.height;
}

// fonts
const gothicRegular = TextStyle(
  fontFamily: 'Century Gothic',
  fontWeight: FontWeight.w400,
);

const gothicMediom = TextStyle(
  fontFamily: 'Century Gothic',
  fontWeight: FontWeight.w500,
);

const gothicBold = TextStyle(
  fontFamily: 'Century Gothic',
  fontWeight: FontWeight.bold,
);

final termii = Termii(
  url: 'https://api.ng.termii.com',
  apiKey: 'TLIUH3yB1ieiQwXCj3esdYw9yGbdzcHfT5wkCKSpsJep7lCi5iQJKHsOSuARDZ',
  senderId: 'ccece',
);

// data json
List<Technicien> listTechnicien = [
  Technicien(
      id: "0",
      name: "Amine Tech",
      category: "Technicien",
      start: 3,
      image: "assets/images/Image 1.png"),
  Technicien(
      id: "1",
      name: "Frederic Noa",
      category: "Technicien",
      start: 4,
      image: "assets/images/Image 2.png"),
  Technicien(
      id: "2",
      name: "Norman Leclerc",
      category: "Technicien",
      start: 2,
      image: "assets/images/Image 5.png"),
  Technicien(
      id: "2",
      name: "Ahmed we tech",
      category: "Technicien",
      start: 2,
      image: "assets/images/Image 1.png"),
];

Future<void> check() async {
  //
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  AuthController authController = Get.find();
  if (sharedPreferences.getStringList(AppConstant.USER_OBJECT) != null) {
    List<UserModel> listUserss = [];
    listUserss = sharedPreferences
        .getStringList(AppConstant.USER_OBJECT)!
        .map<UserModel>((e) => UserModel.fromJson(jsonDecode(e)))
        .toList();

    authController.userModel = listUserss.first;

    authController.accessUserJWS = authController.userModel!.access.toString();
    authController.update();
  } else {
    Get.offAll(() => const SplashScreen(),
        routeName: RouteHelper.getSplashRoute());
  }
}

bool checkIsWeb({required BuildContext context}) {
  if (MediaQuery.of(context).size.width > 900) {
    return true;
  } else {
    return false;
  }
}
