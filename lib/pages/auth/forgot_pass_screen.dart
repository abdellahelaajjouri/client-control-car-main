import 'package:client_control_car/constants/constants.dart';
import 'package:client_control_car/constants/route_helper.dart';
import 'package:client_control_car/controllers/auth_controller.dart';
import 'package:client_control_car/pages/auth/login_screen.dart';
import 'package:client_control_car/pages/auth/reinitial_password_screen.dart';
import 'package:client_control_car/pages/auth/widgets/custom_input_validator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_overlay/loading_overlay.dart';

class ForgotPassScreen extends StatefulWidget {
  const ForgotPassScreen({super.key});

  @override
  State<ForgotPassScreen> createState() => _ForgotPassScreenState();
}

class _ForgotPassScreenState extends State<ForgotPassScreen> {
  bool isLoading = false;
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  final FocusNode phoneFocus = FocusNode();
  final FocusNode emailFocus = FocusNode();
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
                        height: sizeHeight(context: context) * .5,
                        alignment: Alignment.center,
                        child: Image.asset("assets/images/Groupe 135.png"),
                      ),
                      //
                      CustomInputValidatore(
                        controller: emailController,
                        labelText: null,
                        labelWidget: labelInput(text: "E-mail", req: true),
                        marginContainer: const EdgeInsets.only(bottom: 11),
                        width: sizeWidth(context: context) * .9,
                        inputType: TextInputType.text,
                        focusNode: emailFocus,
                        nextFocus: emailFocus,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '';
                          }
                          return null;
                        },
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 10, bottom: 20),
                        child: Row(
                          children: [
                            const Expanded(child: Divider()),
                            Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                "OU",
                                style: gothicBold.copyWith(color: normalText),
                              ),
                            ),
                            const Expanded(child: Divider()),
                          ],
                        ),
                      ),

                      //
                      CustomInputValidatore(
                        controller: phoneController,
                        labelText: null,
                        labelWidget: labelInput(text: "Téléphone", req: true),
                        marginContainer: const EdgeInsets.only(bottom: 11),
                        width: sizeWidth(context: context) * .9,
                        inputType: TextInputType.text,
                        focusNode: phoneFocus,
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
                            if (phoneController.text.isEmpty &&
                                emailController.text.isEmpty) {
                              Get.snackbar(
                                maxWidth: 500,
                                backgroundColor: blueColor.withOpacity(.7),
                                "Certains champs sont vides",
                                "Veuillez confirmer les champs!",
                              );
                            } else {
                              setState(() {
                                isLoading = true;
                              });

                              authController
                                  .resetPasswordController(
                                      email: emailController.text.isEmpty
                                          ? null
                                          : emailController.text,
                                      phone: phoneController.text.isEmpty
                                          ? null
                                          : phoneController.text)
                                  .then((value) {
                                setState(() {
                                  isLoading = false;
                                });
                                if (value.isSuccess) {
                                  Get.to(
                                    () => ReinitialPasswordScreen(
                                      email: value.message.toString(),
                                    ),
                                    routeName:
                                        RouteHelper.getReinitialPasswordRoute(
                                      email: value.message.toString(),
                                    ),
                                  );
                                } else {
                                  Get.snackbar(
                                    maxWidth: 500,
                                    backgroundColor: blueColor.withOpacity(.7),
                                    "L’email / Téléphone est inconnu",
                                    "Veuillez renseigner l'email/téléphone associé à votre compte",
                                  );
                                }
                              }).catchError((onError) {
                                setState(() {
                                  isLoading = false;
                                });
                                Get.snackbar(
                                  maxWidth: 500,
                                  backgroundColor: blueColor.withOpacity(.7),
                                  "L’email / Téléphone est inconnu",
                                  "Veuillez renseigner l'email/téléphone associé à votre compte",
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
