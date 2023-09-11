import 'package:client_control_car/constants/constants.dart';
import 'package:client_control_car/constants/route_helper.dart';
import 'package:client_control_car/controllers/auth_controller.dart';
import 'package:client_control_car/pages/auth/forgot_pass_screen.dart';
import 'package:client_control_car/pages/auth/reg_by_phone_screen.dart';
import 'package:client_control_car/pages/auth/widgets/custom_input_validator.dart';
import 'package:client_control_car/pages/info_vehicule/info_vehicule_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_overlay/loading_overlay.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final FocusNode phoneFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox(
        width: sizeWidth(context: context),
        child: GetBuilder<AuthController>(builder: (authController) {
          return LoadingOverlay(
            isLoading: authController.isLoading,
            child: SingleChildScrollView(
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(
                    maxWidth: 500,
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 15),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // image
                        Container(
                          width: sizeWidth(context: context),
                          height: sizeHeight(context: context) * .5,
                          alignment: Alignment.center,
                          child: Image.asset("assets/images/Groupe 135.png"),
                        ),
                        // title
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            "Welcome Back!",
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
                            "Meci de vous connecter à votre compte",
                            textAlign: TextAlign.center,
                            style: gothicRegular.copyWith(
                              color: normalText,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 50,
                        ),
                        // input phone password
                        CustomInputValidatore(
                          controller: phoneController,
                          labelText: null,
                          labelWidget: labelInput(
                              text: "Téléphone ou E-mail", req: true),
                          marginContainer: const EdgeInsets.only(bottom: 11),
                          width: sizeWidth(context: context) * .9,
                          inputType: TextInputType.text,
                          focusNode: phoneFocus,
                          nextFocus: passwordFocus,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '';
                            }
                            return null;
                          },
                        ),
                        CustomInputValidatore(
                          controller: passwordController,
                          labelText: null,
                          labelWidget:
                              labelInput(text: "Mot de passe", req: true),
                          marginContainer: const EdgeInsets.only(bottom: 11),
                          width: sizeWidth(context: context) * .9,
                          focusNode: passwordFocus,
                          isPassword: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '';
                            }
                            return null;
                          },
                        ),
                        // forgt pass
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 15),
                          alignment: Alignment.topRight,
                          child: InkWell(
                            onTap: () {
                              Get.to(() => const ForgotPassScreen(),
                                  routeName: RouteHelper.getForgotPassRoute());
                            },
                            child: Text(
                              "Mot de passe oublié",
                              style: gothicRegular.copyWith(
                                color: normalText,
                                // fontSize: 10
                              ),
                            ),
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
                              if (!_formKey.currentState!.validate()) {
                                Get.snackbar(
                                  maxWidth: 500,
                                  backgroundColor: blueColor.withOpacity(.7),
                                  "Certains champs sont vides",
                                  "Veuillez confirmer les champs!",
                                );
                              } else {
                                if (phoneController.text.isNotEmpty &&
                                    passwordController.text.isNotEmpty) {
                                  authController.startloading();

                                  authController
                                      .loginController(
                                          username: phoneController.text,
                                          password: passwordController.text)
                                      .then((value) {
                                    authController.stoploading();
                                    if (value.isSuccess) {
                                      Get.to(() => const InfoVehiculeScreen(),
                                          routeName: RouteHelper
                                              .getInfoVehiculeRoute());
                                      // Get.to(() => const HomeMapScreen(),
                                      //     routeName: RouteHelper.homeMapPage);
                                    } else {
                                      Get.snackbar(
                                        maxWidth: 500,
                                        backgroundColor:
                                            blueColor.withOpacity(.7),
                                        "Vous n'avez pas pu être connecté",
                                        "Veuillez confirmer votre téléphone/e-mail et votre mot de passe",
                                      );
                                    }
                                  }).catchError((onError) {
                                    authController.stoploading();
                                    Get.snackbar(
                                      maxWidth: 500,
                                      backgroundColor:
                                          blueColor.withOpacity(.7),
                                      "Vous n'avez pas pu être connecté",
                                      "Veuillez confirmer votre téléphone/e-mail et votre mot de passe",
                                    );
                                  });
                                } else {
                                  Get.snackbar(
                                    maxWidth: 500,
                                    backgroundColor: blueColor.withOpacity(.7),
                                    "Certains champs sont vides",
                                    "Veuillez confirmer les champs!",
                                  );
                                }
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
                              "Connexion",
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
                                    text: "Vous n'avez pas de compte ? "),
                                WidgetSpan(
                                    child: InkWell(
                                  onTap: () {
                                    Get.to(
                                      () => const RegByPhoneScreen(),
                                      routeName:
                                          RouteHelper.getRegByPhoneRoute(),
                                    );
                                  },
                                  child: Text(
                                    " Inscrivez-vous",
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
                        const SizedBox(
                          height: 70,
                        )
                      ],
                    ),
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
