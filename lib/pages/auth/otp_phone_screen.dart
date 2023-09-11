import 'package:client_control_car/constants/constants.dart';
import 'package:client_control_car/constants/route_helper.dart';
import 'package:client_control_car/controllers/auth_controller.dart';
import 'package:client_control_car/pages/auth/inscription_screen.dart';
import 'package:client_control_car/pages/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:otp_text_field/otp_text_field.dart';
import 'package:otp_text_field/style.dart';

class OtpPhoneScreen extends StatefulWidget {
  final String otpCode;
  final String phone;
  const OtpPhoneScreen({Key? key, this.otpCode = "00000", required this.phone})
      : super(key: key);

  @override
  State<OtpPhoneScreen> createState() => _OtpPhoneScreenState();
}

class _OtpPhoneScreenState extends State<OtpPhoneScreen> {
  TextEditingController otpController = TextEditingController();

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SizedBox(
          width: sizeWidth(context: context),
          child: LoadingOverlay(
            isLoading: isLoading,
            child: SingleChildScrollView(
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(
                    maxWidth: 500,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 30,
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 5),
                        alignment: Alignment.topLeft,
                        child: const BackButton(),
                      ),
                      // image
                      Container(
                        width: sizeWidth(context: context),
                        height: sizeHeight(context: context) * .5,
                        alignment: Alignment.center,
                        child: Image.asset("assets/images/Groupe 173.png"),
                      ),
                      // title
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          "Vérification Numéro",
                          style: gothicBold.copyWith(
                            color: Colors.black,
                            fontSize: 18,
                          ),
                        ),
                      ),

                      // content
                      Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 1),
                        child: Text(
                          "Nous vous avons envoyé un code à 5 chiffres pour vérifier votre numéro.",
                          textAlign: TextAlign.center,
                          style: gothicRegular.copyWith(
                            color: normalText,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 35,
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 15),
                        child: OTPTextField(
                          length: 5,
                          width: MediaQuery.of(context).size.width,
                          fieldWidth: 45,
                          style: gothicBold.copyWith(
                            fontSize: 18,
                            color: const Color(0xff707070),
                          ),
                          otpFieldStyle: OtpFieldStyle(
                            borderColor: const Color(0xff707070),
                            focusBorderColor: const Color(0xff707070),
                            enabledBorderColor: const Color(0xff707070),
                          ),
                          textFieldAlignment: MainAxisAlignment.spaceAround,
                          fieldStyle: FieldStyle.box,
                          onCompleted: (pin) {
                            setState(() {
                              otpController.text = pin;
                            });
                          },
                        ),
                      ),

                      // btn conx
                      const SizedBox(
                        height: 25,
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        width: sizeWidth(context: context) * .9,
                        child: ElevatedButton(
                          onPressed: () {
                            if (otpController.text.isNotEmpty &&
                                otpController.text.length == 5) {
                              setState(() {
                                isLoading = true;
                              });
                              //
                              AuthController authController = Get.find();
                              authController
                                  .confirmPhoneController(
                                      destination: widget.phone,
                                      otp: otpController.text)
                                  .then((value) {
                                setState(() {
                                  isLoading = false;
                                });
                                if (value.isSuccess) {
                                  Get.to(
                                    () => InscriptionScreen(
                                      otpCode: value.message,
                                      phone: widget.phone,
                                    ),
                                    routeName: RouteHelper.getInsciprionRoute(
                                      otpCode: value.message,
                                      phone: widget.phone,
                                    ),
                                  );
                                } else {
                                  Get.snackbar(
                                    maxWidth: 500,
                                    backgroundColor: blueColor.withOpacity(.7),
                                    "Code invalide",
                                    "Veuillez confirmer les champs!",
                                  );
                                  // delete here
                                  // Get.to(
                                  //   () => InscriptionScreen(
                                  //     otpCode: value.message,
                                  //     phone: widget.phone,
                                  //   ),
                                  //   routeName: RouteHelper.getInsciprionRoute(
                                  //     otpCode: value.message,
                                  //     phone: widget.phone,
                                  //   ),
                                  // );
                                }
                              }).catchError((onError) {
                                setState(() {
                                  isLoading = false;
                                });
                                Get.snackbar(
                                  maxWidth: 500,
                                  backgroundColor: blueColor.withOpacity(.7),
                                  "Code invalide",
                                  "Veuillez confirmer les champs!",
                                );
                              });
                            } else {
                              Get.snackbar(
                                maxWidth: 500,
                                backgroundColor: blueColor.withOpacity(.7),
                                "Code invalide",
                                "Veuillez confirmer les champs!",
                              );
                            }
                            // Get.to(
                            //   () => InscriptionScreen(
                            //       otpCode: widget.otpCode, phone: widget.phone),
                            //   routeName: RouteHelper.getInsciprionRoute(
                            //     otpCode: widget.otpCode,
                            //     phone: widget.phone,
                            //   ),
                            // );
                          },
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(blueColor),
                            padding: MaterialStateProperty.all(
                              const EdgeInsets.symmetric(vertical: 15),
                            ),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              const RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero,
                              ),
                            ),
                          ),
                          child: Text(
                            "Continuer",
                            style: gothicBold.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      // inscription
                      Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 40),
                        child: RichText(
                          text: TextSpan(
                            style: gothicRegular.copyWith(
                              color: normalText,
                            ),
                            children: [
                              const TextSpan(
                                  text: "Vous avez déjà un compte ? "),
                              WidgetSpan(
                                child: InkWell(
                                  onTap: () {
                                    Get.to(() => const LoginScreen(),
                                        routeName: RouteHelper.getLoginRoute());
                                  },
                                  child: Text(
                                    "Connectez-vous",
                                    style: gothicBold.copyWith(
                                      color: blueColor,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 70,
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
