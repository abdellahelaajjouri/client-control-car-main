import 'dart:async';

import 'package:client_control_car/constants/app_constant.dart';
import 'package:client_control_car/constants/constants.dart';
import 'package:client_control_car/constants/route_helper.dart';
import 'package:client_control_car/controllers/auth_controller.dart';
import 'package:client_control_car/models/user_model.dart';
import 'package:client_control_car/pages/auth/widgets/custom_input_validator.dart';
import 'package:client_control_car/pages/comment-ca-march/comment_ca_marche_screen.dart';
import 'package:client_control_car/pages/info_vehicule/info_vehicule_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:get/get.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:url_launcher/url_launcher.dart';

class InscriptionScreen extends StatefulWidget {
  final String otpCode;
  final String phone;
  const InscriptionScreen(
      {Key? key, required this.otpCode, required this.phone})
      : super(key: key);

  @override
  State<InscriptionScreen> createState() => _InscriptionScreenState();
}

class _InscriptionScreenState extends State<InscriptionScreen> {
  int step = 0;
  bool isCheck = false;
  //
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController codePostalController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController paswordController = TextEditingController();

  FocusNode firstNameFocus = FocusNode();
  FocusNode lastNameFocus = FocusNode();
  FocusNode addressFocus = FocusNode();
  FocusNode cityFocus = FocusNode();
  FocusNode codePostalFocus = FocusNode();
  FocusNode emailFocus = FocusNode();
  FocusNode paswordFocus = FocusNode();

  var codepostallFormatter = MaskTextInputFormatter(
      mask: '#####',
      filter: {
        "#": RegExp(r'[0-9]'),
      },
      type: MaskAutoCompletionType.lazy);
  final _formKeyfirst = GlobalKey<FormState>();
  final _formKeylast = GlobalKey<FormState>();

  LatLng latLng = const LatLng(47.442685, 2.273293);

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (step == 0) {
        Get.dialog(const CommentCaMarechScreen());
      }
    });
  }

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
                      Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 5),
                        alignment: Alignment.topLeft,
                        child: BackButton(
                          onPressed: () {
                            if (step == 0) {
                              Get.back();
                            } else {
                              setState(() {
                                step = 0;
                              });
                            }
                          },
                        ),
                      ),
                      // image
                      Container(
                        width: sizeWidth(context: context),
                        height: sizeHeight(context: context) * .47,
                        alignment: Alignment.center,
                        child: Image.asset("assets/images/Groupe 269.png"),
                      ),
                      // title
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          "Finalisez votre inscription",
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
                          "Veuillez compléter vos informations",
                          textAlign: TextAlign.center,
                          style: gothicRegular.copyWith(
                            color: normalText,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      // inputs
                      step == 0
                          ? Form(
                              key: _formKeyfirst,
                              child: Column(
                                children: [
                                  CustomInputValidatore(
                                    controller: firstNameController,
                                    labelText: null,
                                    labelWidget:
                                        labelInput(text: "Prénom", req: true),
                                    marginContainer:
                                        const EdgeInsets.only(bottom: 11),
                                    width: sizeWidth(context: context) * .9,
                                    inputType: TextInputType.text,
                                    focusNode: firstNameFocus,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return '';
                                      }
                                      return null;
                                    },
                                  ),
                                  CustomInputValidatore(
                                    controller: lastNameController,
                                    labelText: null,
                                    labelWidget:
                                        labelInput(text: "Nom", req: true),
                                    marginContainer:
                                        const EdgeInsets.only(bottom: 11),
                                    width: sizeWidth(context: context) * .9,
                                    inputType: TextInputType.text,
                                    focusNode: lastNameFocus,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return '';
                                      }
                                      return null;
                                    },
                                  ),
                                  InkWell(
                                    onTap: () async {
                                      var place = await PlacesAutocomplete.show(
                                          context: context,
                                          apiKey: AppConstant.API_GOOGLE_MAPS,
                                          mode: Mode.overlay,
                                          types: [],
                                          strictbounds: false,
                                          language: "fr",
                                          proxyBaseUrl:
                                              AppConstant.BASE_ADDRESS_URL,
                                          components: [],
                                          onError: (err) {});
                                      if (place != null) {
                                        final plist = GoogleMapsPlaces(
                                          apiKey: AppConstant.API_GOOGLE_MAPS,
                                          baseUrl: AppConstant.BASE_ADDRESS_URL,
                                          apiHeaders:
                                              await const GoogleApiHeaders()
                                                  .getHeaders(),
                                        );

                                        String placeid = place.placeId ?? "0";

                                        final detail = await plist
                                            .getDetailsByPlaceId(placeid);

                                        final geometry =
                                            detail.result.geometry!;

                                        final lat = geometry.location.lat;
                                        final lang = geometry.location.lng;
                                        latLng = LatLng(lat, lang);
                                        addressController.text =
                                            place.description.toString();
                                        setState(() {});
                                      }
                                    },
                                    child: IgnorePointer(
                                      child: CustomInputValidatore(
                                        controller: addressController,
                                        labelText: null,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return '';
                                          }
                                          return null;
                                        },
                                        labelWidget: labelInput(
                                            text: "Adresse", req: true),
                                        marginContainer:
                                            const EdgeInsets.only(bottom: 11),
                                        width: sizeWidth(context: context) * .9,
                                        inputType: TextInputType.text,
                                        focusNode: addressFocus,
                                      ),
                                    ),
                                  ),
                                  // CustomInputValidatore(
                                  //   controller: addressController,
                                  //   labelText: null,
                                  //   labelWidget:
                                  //       labelInput(text: "Adresse", req: true),
                                  //   marginContainer:
                                  //       const EdgeInsets.only(bottom: 11),
                                  //   width: sizeWidth(context: context) * .9,
                                  //   inputType: TextInputType.text,
                                  //   focusNode: addressFocus,
                                  //   validator: (value) {
                                  //     if (value == null || value.isEmpty) {
                                  //       return '';
                                  //     }
                                  //     return null;
                                  //   },
                                  // ),
                                  CustomInputValidatore(
                                    controller: cityController,
                                    labelText: null,
                                    labelWidget:
                                        labelInput(text: "Ville", req: true),
                                    marginContainer:
                                        const EdgeInsets.only(bottom: 11),
                                    width: sizeWidth(context: context) * .9,
                                    inputType: TextInputType.text,
                                    focusNode: cityFocus,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return '';
                                      }
                                      return null;
                                    },
                                  ),
                                  CustomInputValidatore(
                                    controller: codePostalController,
                                    labelText: null,
                                    labelWidget: labelInput(
                                        text: "Code postal", req: true),
                                    marginContainer:
                                        const EdgeInsets.only(bottom: 11),
                                    width: sizeWidth(context: context) * .9,
                                    inputType: TextInputType.text,
                                    focusNode: codePostalFocus,
                                    inputFormatters: [codepostallFormatter],
                                    validator: (value) {
                                      if (value == null ||
                                          value.isEmpty ||
                                          value.length != 5) {
                                        return '';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            )
                          : Form(
                              key: _formKeylast,
                              child: Column(
                                children: [
                                  CustomInputValidatore(
                                    controller: emailController,
                                    labelText: null,
                                    labelWidget:
                                        labelInput(text: "E-mail", req: true),
                                    marginContainer:
                                        const EdgeInsets.only(bottom: 11),
                                    width: sizeWidth(context: context) * .9,
                                    inputType: TextInputType.text,
                                    focusNode: emailFocus,
                                    validator: (value) {
                                      if (value == null ||
                                          value.isEmpty ||
                                          !value.isEmail) {
                                        return '';
                                      }
                                      return null;
                                    },
                                  ),
                                  CustomInputValidatore(
                                    controller: paswordController,
                                    labelText: null,
                                    labelWidget: labelInput(
                                        text: "Mot de passe", req: true),
                                    marginContainer:
                                        const EdgeInsets.only(bottom: 11),
                                    width: sizeWidth(context: context) * .9,
                                    inputType: TextInputType.text,
                                    focusNode: paswordFocus,
                                    isPassword: true,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return '';
                                      }
                                      return null;
                                    },
                                  ),
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 15),
                                    child: Row(
                                      children: [
                                        // check
                                        Checkbox(
                                          value: isCheck,
                                          onChanged: (value) {
                                            setState(() {
                                              isCheck = !isCheck;
                                            });
                                          },
                                        ),
                                        // content
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        Expanded(
                                          child: InkWell(
                                            onTap: () {
                                              setState(() {
                                                isCheck = !isCheck;
                                              });
                                            },
                                            child: RichText(
                                                text: TextSpan(children: [
                                              TextSpan(
                                                text:
                                                    "Je déclare avoir pris connaissance des ",
                                                style: gothicRegular.copyWith(
                                                  fontSize: 13,
                                                  color: normalText,
                                                ),
                                              ),
                                              WidgetSpan(
                                                child: InkWell(
                                                  onTap: () async {
                                                    if (!await launchUrl(Uri.parse(
                                                        "https://control-car.fr/mentions-legals"))) {
                                                      Get.snackbar(
                                                        "l'url n'est pas valide",
                                                        "Impossible d'ouvrir cette URL",
                                                        maxWidth: 500,
                                                        backgroundColor:
                                                            blueColor
                                                                .withOpacity(
                                                                    .7),
                                                      );
                                                    }
                                                  },
                                                  child: Text(
                                                    "conditions générales de vente, mentions légales et politique de confidentialité ",
                                                    style:
                                                        gothicRegular.copyWith(
                                                      fontSize: 13,
                                                      color: blueColor,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              TextSpan(
                                                text:
                                                    "et les accepter sans réserve ",
                                                style: gothicRegular.copyWith(
                                                  fontSize: 13,
                                                  color: normalText,
                                                ),
                                              ),
                                            ])),
                                            // child: Text(
                                            //   "Je déclare avoir pris connaissance des conditions générales de vente, mentions légales et politique de confidentialité et les accepter sans réserve",
                                            //   style: gothicRegular.copyWith(
                                            //     fontSize: 13,
                                            //     color: normalText,
                                            //   ),
                                            // ),
                                          ),
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),

                      // btn conx
                      const SizedBox(
                        height: 40,
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        width: sizeWidth(context: context) * .9,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (step == 0) {
                              if (!_formKeyfirst.currentState!.validate()) {
                                Get.snackbar(
                                  maxWidth: 500,
                                  backgroundColor: blueColor.withOpacity(.7),
                                  "Certains champs sont vides",
                                  "Veuillez confirmer les champs!",
                                );
                              } else {
                                if (firstNameController.text.isEmpty ||
                                    lastNameController.text.isEmpty ||
                                    addressController.text.isEmpty ||
                                    cityController.text.isEmpty ||
                                    codePostalController.text.isEmpty) {
                                  Get.snackbar(
                                    maxWidth: 500,
                                    backgroundColor: blueColor.withOpacity(.7),
                                    "Certains champs sont vides",
                                    "Veuillez confirmer les champs!",
                                  );
                                } else {
                                  setState(() {
                                    step = 1;
                                  });
                                }
                              }
                            } else {
                              if (!_formKeylast.currentState!.validate()) {
                                Get.snackbar(
                                  maxWidth: 500,
                                  backgroundColor: blueColor.withOpacity(.7),
                                  "Certains champs sont vides",
                                  "Veuillez confirmer les champs!",
                                );
                              } else {
                                if (emailController.text.isEmpty ||
                                    paswordController.text.isEmpty) {
                                  Get.snackbar(
                                    maxWidth: 500,
                                    backgroundColor: blueColor.withOpacity(.7),
                                    "Certains champs sont vides",
                                    "Veuillez confirmer les champs!",
                                  );
                                } else if (!isCheck) {
                                  Get.snackbar(
                                    maxWidth: 500,
                                    backgroundColor: blueColor.withOpacity(.7),
                                    "Certains champs sont vides",
                                    "Veuillez accepter les conditions d'utilisation",
                                  );
                                } else {
                                  setState(() {
                                    isLoading = true;
                                  });

                                  UserModel user = UserModel(
                                    first_name: firstNameController.text,
                                    last_name: lastNameController.text,
                                    email: emailController.text,
                                    address: addressController.text,
                                    city: cityController.text,
                                    code_postal: codePostalController.text,
                                    role: "2",
                                    phone: widget.phone.replaceAll(" ", ""),
                                    otp: widget.otpCode,
                                    location_x: latLng.latitude.toString(),
                                    location_y: latLng.longitude.toString(),
                                  );
                                  AuthController authController = Get.find();
                                  authController
                                      .registerController(
                                          userMdl: user,
                                          password: paswordController.text)
                                      .then((value) {
                                    setState(() {
                                      isLoading = false;
                                    });
                                    if (value.isSuccess) {
                                      Get.offAll(
                                          () => const InfoVehiculeScreen(),
                                          routeName: RouteHelper
                                              .getInfoVehiculeRoute());
                                      // Get.offAll(() => const HomeMapScreen(),
                                      //     routeName: RouteHelper.homeMapPage);
                                    } else {
                                      if (value.message
                                              .toLowerCase()
                                              .contains("phone") &&
                                          value.message
                                              .toLowerCase()
                                              .contains("mail")) {
                                        Get.snackbar(
                                          maxWidth: 500,
                                          backgroundColor:
                                              blueColor.withOpacity(.7),
                                          "Inscription impossible",
                                          "Téléphone et Email renseigné est déjà utilisé par un compte existant",
                                        );
                                      } else if (value.message
                                          .toLowerCase()
                                          .contains("phone")) {
                                        Get.snackbar(
                                          maxWidth: 500,
                                          backgroundColor:
                                              blueColor.withOpacity(.7),
                                          "Inscription impossible",
                                          "Le numéro de téléphone renseigné est déjà utilisé par un compte existant",
                                        );
                                      } else if (value.message
                                              .toLowerCase()
                                              .contains("email") ||
                                          value.message
                                              .toLowerCase()
                                              .contains("mail")) {
                                        Get.snackbar(
                                          maxWidth: 500,
                                          backgroundColor:
                                              blueColor.withOpacity(.7),
                                          "Inscription impossible",
                                          "LL’adresse email renseignée est déjà utilisée par un compte existant",
                                        );
                                      } else {
                                        Get.snackbar(
                                          maxWidth: 500,
                                          backgroundColor:
                                              blueColor.withOpacity(.7),
                                          "Inscription impossible",
                                          "Une erreur s'est produite, réessayez.",
                                        );
                                      }
                                      // if (value.message == "400") {
                                      //   Get.snackbar(

                                      //     "Inscription impossible",
                                      //     "téléphone/e-mail  renseigné est déjà utilisé par un compte existant",
                                      //
                                      //   );
                                      // } else {
                                      //   Get.snackbar(

                                      //     "Vous n'avez pas pu être connecté",
                                      //     "Veuillez confirmer votre téléphone/e-mail et votre mot de passe",
                                      //
                                      //   );
                                      // }
                                    }
                                  }).catchError((onError) {
                                    setState(() {
                                      isLoading = false;
                                    });
                                    Get.snackbar(
                                      maxWidth: 500,
                                      backgroundColor:
                                          blueColor.withOpacity(.7),
                                      "Vous n'avez pas pu être connecté",
                                      "Veuillez confirmer votre téléphone/e-mail et votre mot de passe",
                                    );
                                  });
                                }
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
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        width: sizeWidth(context: context),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              child: InkWell(
                                child: Icon(
                                  Icons.circle,
                                  color: step == 0 ? blueColor : greyColor,
                                  size: step == 0 ? 12 : 11,
                                ),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              child: InkWell(
                                child: Icon(
                                  Icons.circle,
                                  color: step == 1 ? blueColor : greyColor,
                                  size: step == 1 ? 12 : 11,
                                ),
                              ),
                            ),
                          ],
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
