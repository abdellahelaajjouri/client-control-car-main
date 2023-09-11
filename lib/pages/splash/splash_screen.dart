import 'dart:async';

import 'package:client_control_car/constants/app_constant.dart';
import 'package:client_control_car/constants/constants.dart';
import 'package:client_control_car/constants/route_helper.dart';
import 'package:client_control_car/controllers/auth_controller.dart';
import 'package:client_control_car/pages/demo/demo_screen.dart';
import 'package:client_control_car/pages/info_vehicule/info_vehicule_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    nextScreenDemo();
  }

  nextScreenDemo() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    if (sharedPreferences.getString(AppConstant.USER_EMAIL) != null &&
        sharedPreferences.getString(AppConstant.USER_PASSWORD) != null) {
      AuthController authController = Get.find();
      authController
          .loginController(
              username: sharedPreferences.getString(AppConstant.USER_EMAIL)!,
              password: sharedPreferences.getString(AppConstant.USER_PASSWORD)!)
          .then((value) {
        if (value.isSuccess) {
          Get.to(() => const InfoVehiculeScreen(),
              routeName: RouteHelper.getInfoVehiculeRoute());
          // Get.to(() => const HomeMapScreen(),
          //     routeName: RouteHelper.homeMapPage);
        } else {
          Timer(const Duration(seconds: 5), () {
            Get.to(() => const DemoScreen(),
                routeName: RouteHelper.getDemoRoute());
          });
        }
      }).catchError((onError) {
        Timer(const Duration(seconds: 5), () {
          Get.to(() => const DemoScreen(),
              routeName: RouteHelper.getDemoRoute());
        });
      });
    } else {
      Timer(const Duration(seconds: 5), () {
        Get.to(() => const DemoScreen(), routeName: RouteHelper.getDemoRoute());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: blueColor,
      // backgroundColor: Colors.white,
      body: SizedBox(
        width: sizeWidth(context: context),
        height: sizeHeight(context: context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // logo
            Image.asset(
              "assets/icons/logo-cntrolcar.png",
              width: sizeWidth(context: context) * .5,
            ),
            // circle
            const CircularProgressIndicator(
              // color: blueColor,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
