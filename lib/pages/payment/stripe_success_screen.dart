import 'package:client_control_car/constants/app_constant.dart';
import 'package:client_control_car/constants/constants.dart';
import 'package:client_control_car/constants/route_helper.dart';
import 'package:client_control_car/controllers/control_controller.dart';
import 'package:client_control_car/pages/info_vehicule/info_vehicule_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StripeSuccessScreen extends StatefulWidget {
  // final String controlId;
  // final String total;
  // final String hasCoupon;
  // final String discount;
  const StripeSuccessScreen({
    super.key,
    // required this.controlId,
    // required this.discount,
    // required this.hasCoupon,
    // required this.total,
  });

  @override
  State<StripeSuccessScreen> createState() => _StripeSuccessScreenState();
}

class _StripeSuccessScreenState extends State<StripeSuccessScreen> {
  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    check().then((value) {
      Future.delayed(const Duration(seconds: 1), () async {
        ControlController controlController = Get.find();
        SharedPreferences sharedPreferences =
            await SharedPreferences.getInstance();
        if (sharedPreferences.getString(AppConstant.client_OBJECT_controlId) !=
            null) {
          String controlId =
              sharedPreferences.getString(AppConstant.client_OBJECT_controlId)!;
          String price =
              sharedPreferences.getString(AppConstant.client_OBJECT_price)!;
          String discount =
              sharedPreferences.getString(AppConstant.client_OBJECT_discount)!;
          String hasCoupon =
              sharedPreferences.getString(AppConstant.client_OBJECT_hasCoupon)!;
          controlController
              .checkPayControl(
                  idControl: controlId,
                  hasCoupon: hasCoupon,
                  price: price,
                  discount: discount)
              .then((value) {
            if (value.isSuccess) {
              sharedPreferences.remove(AppConstant.client_OBJECT_controlId);

              sharedPreferences.remove(AppConstant.client_OBJECT_price);

              sharedPreferences.remove(AppConstant.client_OBJECT_discount);

              sharedPreferences.remove(AppConstant.client_OBJECT_hasCoupon);

              Get.to(() => const InfoVehiculeScreen(),
                  routeName: RouteHelper.getInfoVehiculeRoute());
              // Get.to(() => const HomeMapScreen(),
              //     routeName: RouteHelper.getHomeMapRoute());
              Get.bottomSheet(Container(
                color: Colors.white,
                height: sizeHeight(context: context) * .45,
                child: SingleChildScrollView(
                  child: SizedBox(
                    width: sizeWidth(context: context),
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 15,
                        ),
                        Image.asset(
                          "assets/images/Groupe 422.png",
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Text(
                          "Paiement effectué avec succès",
                          style: gothicBold.copyWith(
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ));
            } else {
              Get.to(() => const InfoVehiculeScreen(),
                  routeName: RouteHelper.getInfoVehiculeRoute());
            }
          }).catchError((onError) {
            Get.to(() => const InfoVehiculeScreen(),
                routeName: RouteHelper.getInfoVehiculeRoute());
          });
        } else {
          Get.to(() => const InfoVehiculeScreen(),
              routeName: RouteHelper.getInfoVehiculeRoute());
        }
      });
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
