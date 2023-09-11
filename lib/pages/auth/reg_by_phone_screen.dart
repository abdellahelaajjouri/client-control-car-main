import 'package:client_control_car/constants/constants.dart';
import 'package:client_control_car/constants/route_helper.dart';
import 'package:client_control_car/controllers/auth_controller.dart';
import 'package:client_control_car/pages/auth/login_screen.dart';
import 'package:client_control_car/pages/auth/otp_phone_screen.dart';
import 'package:client_control_car/pages/auth/widgets/custom_input_validator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class RegByPhoneScreen extends StatefulWidget {
  const RegByPhoneScreen({Key? key}) : super(key: key);

  @override
  State<RegByPhoneScreen> createState() => _RegByPhoneScreenState();
}

class _RegByPhoneScreenState extends State<RegByPhoneScreen> {
  TextEditingController phoneController = TextEditingController();
  final FocusNode phoneFocus = FocusNode();
  String otpCode = '00000';
  bool isLoading = false;

  var phoneFormatter = MaskTextInputFormatter(
      mask: '# ## ## ## ##',
      filter: {
        "#": RegExp(r'[0-9]'),
      },
      type: MaskAutoCompletionType.lazy);
  final _formKey = GlobalKey<FormState>();

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
                            "Inscription",
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
                            "Nous allons vous envoyé un code de vérification sur votre numéro de téléphone",
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
                          hintText: "1 00 00 00 00",
                          inputFormatters: [phoneFormatter],
                          marginContainer: const EdgeInsets.only(bottom: 11),
                          width: sizeWidth(context: context) * .9,
                          icon: SizedBox(
                            width: 80,
                            child: Row(
                              children: [
                                const SizedBox(
                                  width: 10,
                                ),
                                Image.asset("assets/icons/Groupe 171.png"),
                                const SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  "+33",
                                  style: gothicBold.copyWith(
                                      color: normalText, fontSize: 18),
                                ),
                              ],
                            ),
                          ),
                          inputType: TextInputType.text,
                          focusNode: phoneFocus,
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                value.replaceAll(" ", "").length != 9) {
                              return '';
                            }
                            return null;
                          },
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
                            onPressed: () async {
                              if (!_formKey.currentState!.validate()) {
                                Get.snackbar(
                                  maxWidth: 500,
                                  backgroundColor: blueColor.withOpacity(.7),
                                  "Certains champs sont invalide",
                                  "Veuillez confirmer les champs!",
                                );
                              } else {
                                if (phoneController.text.isNotEmpty) {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  AuthController authController = Get.find();
                                  authController
                                      .sendPhoneController(
                                          destination: phoneController.text
                                              .trim()
                                              .replaceAll(" ", ""))
                                      .then((value) {
                                    setState(() {
                                      isLoading = false;
                                    });
                                    if (value.isSuccess) {
                                      Get.to(
                                        () => OtpPhoneScreen(
                                            otpCode: "00000",
                                            phone: phoneController.text
                                                .trim()
                                                .replaceAll(" ", "")),
                                        routeName: RouteHelper.getOtpPhoneRoute(
                                            otpCode: otpCode.toString(),
                                            phone: phoneController.text),
                                      );
                                    } else {
                                      if (value.message
                                              .contains("existe déjà") ||
                                          value.message.contains("exist")) {
                                        Get.snackbar(
                                          maxWidth: 500,
                                          backgroundColor:
                                              blueColor.withOpacity(.7),
                                          "L'utilisateur avec ce téléphone existe déjà",
                                          "Veuillez confirmer les champs!",
                                        );
                                      } else {
                                        // opération invalide, veuillez réessayer
                                        Get.snackbar(
                                          maxWidth: 500,
                                          backgroundColor:
                                              blueColor.withOpacity(.7),
                                          "opération invalide",
                                          "Veuillez confirmer les champs!",
                                        );
                                      }
                                    }
                                  }).catchError((onError) {
                                    setState(() {
                                      isLoading = false;
                                    });
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
                                          routeName:
                                              RouteHelper.getLoginRoute());
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
      ),
    );
  }
}
