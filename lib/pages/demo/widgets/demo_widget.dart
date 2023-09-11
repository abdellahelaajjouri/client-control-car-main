import 'package:client_control_car/constants/constants.dart';
import 'package:client_control_car/constants/route_helper.dart';
import 'package:client_control_car/pages/auth/login_screen.dart';
import 'package:client_control_car/pages/demo/demo_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DemoWidget extends StatelessWidget {
  final DemoModel demoModel;
  final int index;
  final Function()? onTap;
  const DemoWidget(
      {Key? key, required this.demoModel, required this.index, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // image
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            child: Image.asset(demoModel.image),
          ),
        ),
        // tile
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            demoModel.title,
            style: gothicBold.copyWith(color: Colors.black, fontSize: 20),
          ),
        ),

        // content
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
          child: Text(
            demoModel.content,
            textAlign: TextAlign.center,
            style: gothicRegular.copyWith(
              color: normalText,
              fontSize: 15,
            ),
          ),
        ),
        const SizedBox(
          height: 40,
        ),
        // btn pass
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          width: sizeWidth(context: context) * .9,
          child: ElevatedButton(
            onPressed: onTap,
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(blueColor),
              padding: MaterialStateProperty.all(
                const EdgeInsets.symmetric(vertical: 15),
              ),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
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
        // pass tuto
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          alignment: Alignment.topRight,
          child: InkWell(
            onTap: () {
              Get.to(
                () => const LoginScreen(),
                routeName: RouteHelper.getLoginRoute(),
              );
            },
            child: Text(
              "Passer le tutoriel",
              style: gothicRegular.copyWith(
                color: normalText,
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 40,
        ),
      ],
    );
  }
}
