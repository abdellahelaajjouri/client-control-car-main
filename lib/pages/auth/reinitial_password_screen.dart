import 'package:client_control_car/constants/constants.dart';
import 'package:client_control_car/constants/route_helper.dart';
import 'package:client_control_car/controllers/auth_controller.dart';
import 'package:client_control_car/pages/auth/login_screen.dart';
import 'package:client_control_car/pages/auth/widgets/custom_input_validator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_overlay/loading_overlay.dart';

class ReinitialPasswordScreen extends StatefulWidget {
  final String email;
  const ReinitialPasswordScreen({super.key, required this.email});

  @override
  State<ReinitialPasswordScreen> createState() =>
      _ReinitialPasswordScreenState();
}

class _ReinitialPasswordScreenState extends State<ReinitialPasswordScreen> {
  bool isLoading = false;
  TextEditingController passController = TextEditingController();
  TextEditingController confirmController = TextEditingController();
  TextEditingController otpController = TextEditingController();
  final FocusNode otpFocus = FocusNode();
  final FocusNode passFocus = FocusNode();
  final FocusNode confirmFocus = FocusNode();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox(
        width: sizeWidth(context: context),
        height: sizeHeight(context: context),
        child: GetBuilder<AuthController>(builder: (authController) {
          return LoadingOverlay(
            isLoading: isLoading,
            child: SingleChildScrollView(
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(
                    maxWidth: 500,
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    // crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // image
                      Container(
                        width: sizeWidth(context: context),
                        height: sizeHeight(context: context) * .4,
                        alignment: Alignment.center,
                        child: Image.asset("assets/images/Groupe 135.png"),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          "Nouveau mot de passe!",
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
                          "Merci de renseigner un mot de passe",
                          textAlign: TextAlign.center,
                          style: gothicRegular.copyWith(
                            color: normalText,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      //
                      CustomInputValidatore(
                        controller: otpController,
                        labelText: null,
                        labelWidget: labelInput(text: "Code OTP", req: true),
                        marginContainer: const EdgeInsets.only(bottom: 11),
                        width: sizeWidth(context: context) * .9,
                        inputType: TextInputType.text,
                        focusNode: otpFocus,
                        nextFocus: passFocus,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '';
                          }
                          return null;
                        },
                      ),

                      CustomInputValidatore(
                        controller: passController,
                        labelText: null,
                        labelWidget:
                            labelInput(text: "Mot de passe", req: true),
                        marginContainer: const EdgeInsets.only(bottom: 11),
                        width: sizeWidth(context: context) * .9,
                        inputType: TextInputType.text,
                        focusNode: passFocus,
                        nextFocus: confirmFocus,
                        isPassword: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '';
                          }
                          return null;
                        },
                      ),

                      //
                      CustomInputValidatore(
                        controller: confirmController,
                        labelText: null,
                        labelWidget: labelInput(
                            text: "Confirmation Mot de passe", req: true),
                        marginContainer: const EdgeInsets.only(bottom: 11),
                        width: sizeWidth(context: context) * .9,
                        inputType: TextInputType.text,
                        focusNode: confirmFocus,
                        isPassword: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '';
                          }
                          return null;
                        },
                      ),
                      //
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        width: sizeWidth(context: context) * .9,
                        child: ElevatedButton(
                          onPressed: () {
                            if (otpController.text.isEmpty &&
                                passController.text.isEmpty &&
                                confirmController.text.isEmpty) {
                              Get.snackbar(
                                maxWidth: 500,
                                backgroundColor: blueColor.withOpacity(.7),
                                "Certains champs sont vides",
                                "Veuillez confirmer les champs!",
                              );
                            } else if (passController.text !=
                                confirmController.text) {
                              Get.snackbar(
                                maxWidth: 500,
                                backgroundColor: blueColor.withOpacity(.7),
                                "Votre mot de passe n'est pas confirmé",
                                "Veuillez confirmer votre mot de pass",
                              );
                            } else {
                              setState(() {
                                isLoading = true;
                              });

                              authController
                                  .confirmPasswordController(
                                      email: widget.email,
                                      otp: otpController.text,
                                      password: passController.text)
                                  .then((value) {
                                setState(() {
                                  isLoading = false;
                                });
                                if (value.isSuccess) {
                                  Get.snackbar(
                                    maxWidth: 500,
                                    backgroundColor: blueColor.withOpacity(.7),
                                    "Le mot de passe est réinitialisé",
                                    "Vous allez être redirigé vers la page de connexion",
                                  );

                                  Get.to(
                                    () => const LoginScreen(),
                                    routeName: RouteHelper.getLoginRoute(),
                                  );
                                } else {
                                  Get.snackbar(
                                    maxWidth: 500,
                                    backgroundColor: blueColor.withOpacity(.7),
                                    "Réinitialisation du mot de passe invalide",
                                    value.message.toString(),
                                  );
                                }
                              }).catchError((onError) {
                                setState(() {
                                  isLoading = false;
                                });
                                Get.snackbar(
                                  maxWidth: 500,
                                  backgroundColor: blueColor.withOpacity(.7),
                                  "Réinitialisation du mot de passe invalide",
                                  "Veuillez renseigner Code OTP / mot de passe à votre compte",
                                );
                              });
                              // authController.startloading();

                              // authController
                              //     .loginController(
                              //         username: phoneController.text,
                              //         password: passwordController.text)
                              //     .then((value) {
                              //   authController.stoploading();
                              //   if (value.isSuccess) {
                              //     Get.to(() => const InfoVehiculeScreen(),
                              //         routeName:
                              //             RouteHelper.getInfoVehiculeRoute());
                              //     // Get.to(() => const HomeMapScreen(),
                              //     //     routeName: RouteHelper.homeMapPage);
                              //   } else {
                              //     Get.snackbar(

                              //       "Vous n'avez pas pu être connecté",
                              //       "Veuillez confirmer votre téléphone/e-mail et votre mot de passe",
                              //
                              //     );
                              //   }
                              // }).catchError((onError) {
                              //   authController.stoploading();
                              //   Get.snackbar(

                              //     "Vous n'avez pas pu être connecté",
                              //     "Veuillez confirmer votre téléphone/e-mail et votre mot de passe",
                              //
                              //   );
                              // });
                            }
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
                            "Réinitialiser",
                            style: gothicBold.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      //
                      Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 30),
                        alignment: Alignment.center,
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
                                  if (Navigator.canPop(context)) {
                                    Get.back();
                                  } else {
                                    Get.to(
                                      () => const LoginScreen(),
                                      routeName: RouteHelper.getLoginRoute(),
                                    );
                                  }
                                },
                                child: Text(
                                  "Connectez-vous",
                                  style: gothicBold.copyWith(
                                    color: blueColor,
                                    fontSize: 15,
                                  ),
                                ),
                              ))
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
