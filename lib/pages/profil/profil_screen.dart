import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:client_control_car/constants/app_constant.dart';
import 'package:client_control_car/constants/constants.dart';
import 'package:client_control_car/constants/route_helper.dart';
import 'package:client_control_car/controllers/auth_controller.dart';
import 'package:client_control_car/pages/auth/widgets/custom_input_validator.dart';
import 'package:client_control_car/pages/info_vehicule/widgets/widgets.dart';
import 'package:client_control_car/pages/menu/drawer_widget.dart';
import 'package:client_control_car/pages/menu/menu_bottom.dart';
import 'package:client_control_car/pages/splash/splash_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:get/get.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({Key? key}) : super(key: key);

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController postalController = TextEditingController();

  FocusNode firstNameFocus = FocusNode();
  FocusNode lastNameFocus = FocusNode();
  FocusNode emailFocus = FocusNode();
  FocusNode phoneFocus = FocusNode();
  FocusNode passwordFocus = FocusNode();
  FocusNode addressFocus = FocusNode();
  FocusNode postalFocus = FocusNode();
  FocusNode cityFocus = FocusNode();

  LatLng latLng = const LatLng(47.442685, 2.273293);
  String photo = '';

  bool isLoading = true;
  bool isLoadingShow = true;

  @override
  void initState() {
    super.initState();
    check().then((value) {
      getDataInfo();
    });
    // Future.delayed(const Duration(seconds: 1), () {

    // });
    // getData();
  }

  getDataInfo() async {
    AuthController authController = Get.find();
    authController.getCProfileController().then((value) {
      if (value.isSuccess) {
        getData();
      } else {
        Timer(const Duration(seconds: 1), () {
          setState(() {
            isLoading = false;
            isLoadingShow = false;
          });
        });
      }
    }).catchError((onError) {
      Timer(const Duration(seconds: 1), () {
        setState(() {
          isLoading = false;
          isLoadingShow = false;
        });
      });
    });
  }

  getData() async {
    AuthController authController = Get.find();
    if (authController.userModelProfile != null) {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      var pass = sharedPreferences.getString(AppConstant.USER_PASSWORD);

      setState(() {
        firstNameController.text =
            authController.userModelProfile!.first_name.toString();
        lastNameController.text =
            authController.userModelProfile!.last_name.toString();
        emailController.text =
            authController.userModelProfile!.email.toString();
        phoneController.text =
            authController.userModelProfile!.phone.toString().length == 9
                ? "0${authController.userModelProfile!.phone}"
                : authController.userModelProfile!.phone.toString();
        photo = authController.userModelProfile!.photo.toString();
        addressController.text =
            authController.userModelProfile!.address.toString();
        cityController.text = authController.userModelProfile!.city.toString();
        postalController.text =
            authController.userModelProfile!.code_postal.toString();
        if (double.tryParse(
                    authController.userModelProfile!.location_x.toString()) !=
                null &&
            double.tryParse(
                    authController.userModelProfile!.location_y.toString()) !=
                null) {
          latLng = LatLng(
              double.parse(
                  authController.userModelProfile!.location_x.toString()),
              double.parse(
                  authController.userModelProfile!.location_y.toString()));
        }

        if (pass != null) {
          passwordController.text = pass;
        } else {
          passwordController.text = "";
        }
      });
    }
    Timer(const Duration(seconds: 1), () {
      setState(() {
        isLoading = false;
        isLoadingShow = false;
      });
    });
  }

  final _formKey = GlobalKey<FormState>();
  var phoneFormatter = MaskTextInputFormatter(
      mask: '##########',
      filter: {
        "#": RegExp(r'[0-9]'),
      },
      type: MaskAutoCompletionType.lazy);
  var codepostallFormatter = MaskTextInputFormatter(
    mask: '#####',
    filter: {
      "#": RegExp(r'[0-9]'),
    },
    type: MaskAutoCompletionType.lazy,
  );

  XFile? photoProfile;
  Uint8List? photoProfileU8;

  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    check();
    return Scaffold(
      backgroundColor: Colors.white,
      key: scaffoldKey,
      endDrawerEnableOpenDragGesture: true,
      drawer: checkIsWeb(context: context)
          ? null
          : StreamBuilder<QuerySnapshot>(
              stream: firebaseFirestore.collection("notification").snapshots(),
              builder: (context, snapshotNotif) {
                int countMessage = 0;
                int countNotif = 0;
                if (snapshotNotif.hasData) {
                  if (snapshotNotif.data!.docs.isNotEmpty) {
                    AuthController authController = Get.find();
                    String access =
                        authController.userModel!.access.toString() == "null"
                            ? authController.accessUserJWS.toString()
                            : authController.userModel!.access.toString();
                    Map<String, dynamic> payload = Jwt.parseJwt(access);
                    int msgCont = 0;
                    int ntfCont = 0;
                    for (var element in snapshotNotif.data!.docs) {
                      if (element["type"].toString().toLowerCase() ==
                          "Nouveau message".toLowerCase()) {
                        if (element["isvue"].toString() == "false" &&
                            payload["user_id"].toString() ==
                                element["user"].toString()) {
                          msgCont++;
                        }
                      } else {
                        if (element["isvue"].toString() == "false" &&
                            payload["user_id"].toString() ==
                                element["user"].toString()) {
                          ntfCont++;
                        }
                      }
                    }
                    countMessage = msgCont;
                    countNotif = ntfCont;
                  }
                }
                return DrawerWidget(
                  countMessage: countMessage,
                  countNotification: countNotif,
                  onThen: () {
                    setState(() {
                      isLoading = true;
                    });
                    getData();
                  },
                );
              }),
      appBar: checkIsWeb(context: context)
          ? null
          : AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: InkWell(
                  onTap: () {
                    scaffoldKey.currentState!.openDrawer();
                  },
                  child: Image.asset("assets/icons/drawer.png"))),
      bottomNavigationBar: checkIsWeb(context: context)
          ? null
          : StreamBuilder<QuerySnapshot>(
              stream: firebaseFirestore.collection("notification").snapshots(),
              builder: (context, snapshotNotif) {
                int countMessage = 0;
                int countNotif = 0;
                if (snapshotNotif.hasData) {
                  if (snapshotNotif.data!.docs.isNotEmpty) {
                    AuthController authController = Get.find();
                    String access =
                        authController.userModel!.access.toString() == "null"
                            ? authController.accessUserJWS.toString()
                            : authController.userModel!.access.toString();
                    Map<String, dynamic> payload = Jwt.parseJwt(access);
                    int msgCont = 0;
                    int ntfCont = 0;
                    for (var element in snapshotNotif.data!.docs) {
                      if (element["type"].toString().toLowerCase() ==
                          "Nouveau message".toLowerCase()) {
                        if (element["isvue"].toString() == "false" &&
                            payload["user_id"].toString() ==
                                element["user"].toString()) {
                          msgCont++;
                        }
                      } else {
                        if (element["isvue"].toString() == "false" &&
                            payload["user_id"].toString() ==
                                element["user"].toString()) {
                          ntfCont++;
                        }
                      }
                    }
                    countMessage = msgCont;
                    countNotif = ntfCont;
                  }
                }
                return MenuBottom(
                  countMessages: countMessage,
                  countNotification: countNotif,
                );
              }),
      body: SafeArea(
          child: SizedBox(
        width: sizeWidth(context: context),
        height: sizeHeight(context: context),
        child: LoadingOverlay(
          isLoading: isLoading,
          child: GetBuilder<AuthController>(builder: (authController) {
            return Row(
              children: [
                checkIsWeb(context: context)
                    ? Container(
                        margin: const EdgeInsets.only(right: 10),
                        child: StreamBuilder<QuerySnapshot>(
                            stream: firebaseFirestore
                                .collection("notification")
                                .snapshots(),
                            builder: (context, snapshotNotif) {
                              int countMessage = 0;
                              int countNotif = 0;
                              if (snapshotNotif.hasData) {
                                if (snapshotNotif.data!.docs.isNotEmpty) {
                                  AuthController authController = Get.find();
                                  String access = authController
                                              .userModel!.access
                                              .toString() ==
                                          "null"
                                      ? authController.accessUserJWS.toString()
                                      : authController.userModel!.access
                                          .toString();
                                  Map<String, dynamic> payload =
                                      Jwt.parseJwt(access);
                                  int msgCont = 0;
                                  int ntfCont = 0;
                                  for (var element
                                      in snapshotNotif.data!.docs) {
                                    if (element["type"]
                                            .toString()
                                            .toLowerCase() ==
                                        "Nouveau message".toLowerCase()) {
                                      if (element["isvue"].toString() ==
                                              "false" &&
                                          payload["user_id"].toString() ==
                                              element["user"].toString()) {
                                        msgCont++;
                                      }
                                    } else {
                                      if (element["isvue"].toString() ==
                                              "false" &&
                                          payload["user_id"].toString() ==
                                              element["user"].toString()) {
                                        ntfCont++;
                                      }
                                    }
                                  }
                                  countMessage = msgCont;
                                  countNotif = ntfCont;
                                }
                              }
                              return DrawerWidget(
                                countMessage: countMessage,
                                countNotification: countNotif,
                                onThen: () {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  getData();
                                },
                              );
                            }),
                      )
                    : Container(),
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // appbar
                        Expanded(
                          child: SingleChildScrollView(
                            child: Center(
                              child: Container(
                                constraints: const BoxConstraints(
                                  maxWidth: 800,
                                ),
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 15),
                                child: Column(
                                  children: [
                                    const SizedBox(
                                      height: 30,
                                    ),
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 15, vertical: 5),
                                      width: 100,
                                      height: 100,
                                      alignment: Alignment.center,
                                      child: Center(
                                        child: InkWell(
                                          onTap: () async {
                                            XFile? imgFile = await ImagePicker()
                                                .pickImage(
                                                    source:
                                                        ImageSource.gallery);
                                            try {
                                              if (imgFile != null) {
                                                photoProfileU8 =
                                                    await imgFile.readAsBytes();

                                                setState(() {
                                                  photoProfile = imgFile;
                                                });
                                                setState(() {});
                                              }
                                            } catch (e) {
                                              // printError(info: e.toString());
                                              log(e.toString());
                                            }
                                          },
                                          child: SizedBox(
                                            width: 120,
                                            height: 120,
                                            child: Stack(
                                              children: [
                                                if (photoProfile != null)
                                                  if (kIsWeb)
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        color: greyColor
                                                            .withOpacity(.2),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(120),
                                                        image: DecorationImage(
                                                            image: MemoryImage(
                                                                photoProfileU8!),
                                                            fit: BoxFit.fill),
                                                      ),
                                                    )
                                                  else
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        color: greyColor
                                                            .withOpacity(.2),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(120),
                                                        image: DecorationImage(
                                                            image: FileImage(
                                                                File(
                                                                    photoProfile!
                                                                        .path)),
                                                            fit: BoxFit.fill),
                                                      ),
                                                    )
                                                else
                                                  CustomImageCircle(
                                                    image: photo,
                                                    width: 120,
                                                    height: 120,
                                                  ),
                                                Positioned(
                                                  top: 0,
                                                  left: 0,
                                                  right: 0,
                                                  bottom: 0,
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.white
                                                          .withOpacity(.3),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              120),
                                                    ),
                                                    width: 120,
                                                    height: 120,
                                                    child: const Icon(
                                                      Icons.edit,
                                                      size: 30,
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 15, vertical: 2),
                                      child: Text(
                                        authController.userModelProfile == null
                                            ? ""
                                            : "${authController.userModelProfile!.first_name.toString()} ${authController.userModelProfile!.last_name.toString()}",
                                        style: gothicBold.copyWith(
                                            color: Colors.black, fontSize: 17),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 25,
                                    ),

                                    // first name
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
                                      nextFocus: lastNameFocus,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return '';
                                        }
                                        return null;
                                      },
                                    ),

                                    // last name
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
                                      nextFocus: emailFocus,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return '';
                                        }
                                        return null;
                                      },
                                    ),
                                    InkWell(
                                      onTap: () async {
                                        var place =
                                            await PlacesAutocomplete.show(
                                                context: context,
                                                apiKey:
                                                    AppConstant.API_GOOGLE_MAPS,
                                                mode: Mode.overlay,
                                                types: [],
                                                strictbounds: false,
                                                language: "fr",
                                                proxyBaseUrl: AppConstant
                                                    .BASE_ADDRESS_URL,
                                                components: [],
                                                onError: (err) {});
                                        if (place != null) {
                                          final plist = GoogleMapsPlaces(
                                            apiKey: AppConstant.API_GOOGLE_MAPS,
                                            baseUrl:
                                                AppConstant.BASE_ADDRESS_URL,
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
                                            if (value == null ||
                                                value.isEmpty) {
                                              return '';
                                            }
                                            return null;
                                          },
                                          labelWidget: labelInput(
                                              text: "Adresse", req: true),
                                          marginContainer:
                                              const EdgeInsets.only(bottom: 11),
                                          width:
                                              sizeWidth(context: context) * .9,
                                          inputType: TextInputType.text,
                                          focusNode: addressFocus,
                                        ),
                                      ),
                                    ),

                                    SizedBox(
                                      width: sizeWidth(context: context) * .9,
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: CustomInputValidatore(
                                              controller: cityController,
                                              labelText: null,
                                              labelWidget: labelInput(
                                                  text: "Ville", req: true),
                                              marginContainer:
                                                  const EdgeInsets.only(
                                                      bottom: 11),
                                              width:
                                                  sizeWidth(context: context) *
                                                      .9,
                                              inputType: TextInputType.text,
                                              focusNode: cityFocus,
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return '';
                                                }
                                                return null;
                                              },
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          Expanded(
                                            child: CustomInputValidatore(
                                              controller: postalController,
                                              labelText: null,
                                              labelWidget: labelInput(
                                                  text: "Code postal",
                                                  req: true),
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty ||
                                                    value.length != 5) {
                                                  return '';
                                                }
                                                return null;
                                              },
                                              marginContainer:
                                                  const EdgeInsets.only(
                                                      bottom: 11),
                                              width:
                                                  sizeWidth(context: context) *
                                                      .9,
                                              inputType: TextInputType.text,
                                              focusNode: postalFocus,
                                              inputFormatters: [
                                                codepostallFormatter,
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // email
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
                                      // isReadOnly: true,
                                      nextFocus: phoneFocus,
                                      validator: (value) {
                                        if (value == null ||
                                            value.isEmpty ||
                                            !value.isEmail) {
                                          return '';
                                        }
                                        return null;
                                      },
                                    ),

                                    // phone
                                    CustomInputValidatore(
                                      controller: phoneController,
                                      labelText: null,
                                      inputFormatters: [
                                        phoneFormatter,
                                      ],
                                      // isReadOnly: true,
                                      labelWidget: labelInput(
                                          text: "Numero de téléphone",
                                          req: true),
                                      marginContainer:
                                          const EdgeInsets.only(bottom: 11),
                                      width: sizeWidth(context: context) * .9,
                                      inputType: TextInputType.text,
                                      hintText: "0#########",
                                      focusNode: phoneFocus,
                                      validator: (value) {
                                        if (value == null ||
                                            value.isEmpty ||
                                            value.replaceAll(" ", "").length !=
                                                10) {
                                          return '';
                                        }
                                        return null;
                                      },
                                    ),
                                    CustomInputValidatore(
                                      controller: passwordController,
                                      labelText: null,
                                      isPassword: true,
                                      // isReadOnly: true,
                                      labelWidget: labelInput(
                                        text: "Mot de passe",
                                      ),
                                      marginContainer:
                                          const EdgeInsets.only(bottom: 11),
                                      width: sizeWidth(context: context) * .9,
                                      inputType: TextInputType.text,
                                      focusNode: passwordFocus,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return '';
                                        }
                                        return null;
                                      },
                                    ),

                                    // btn update
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 3),
                                      width: sizeWidth(context: context) * .9,
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          if (!_formKey.currentState!
                                              .validate()) {
                                            Get.snackbar(
                                              maxWidth: 500,
                                              backgroundColor:
                                                  blueColor.withOpacity(.7),
                                              "Certains champs sont invalide",
                                              "Veuillez confirmer les champs!",
                                            );
                                          } else {
                                            if (firstNameController
                                                    .text.isEmpty ||
                                                lastNameController
                                                    .text.isEmpty ||
                                                emailController.text.isEmpty ||
                                                phoneController.text.isEmpty) {
                                              Get.snackbar(
                                                maxWidth: 500,
                                                backgroundColor:
                                                    blueColor.withOpacity(.7),
                                                "Certains champs sont vides",
                                                "Veuillez confirmer les champs!",
                                              );
                                            } else {
                                              setState(() {
                                                isLoading = true;
                                              });
                                              String photoPr = photo;
                                              if (photoProfile != null) {
                                                photoPr = await AppConstant
                                                    .uploadFile(
                                                        file: File(
                                                            photoProfile!.path),
                                                        path: 'profile/',
                                                        putDataWeb:
                                                            photoProfileU8,
                                                        settableMetadata:
                                                            SettableMetadata(
                                                          contentType:
                                                              "image/jpeg",
                                                        ));
                                              }
                                              authController
                                                  .updateProfileController(
                                                      firstname:
                                                          firstNameController
                                                              .text,
                                                      lastname:
                                                          lastNameController
                                                              .text,
                                                      email:
                                                          emailController.text,
                                                      photo: photoPr,
                                                      phone: phoneController
                                                          .text
                                                          .replaceAll(" ", ""),
                                                      password:
                                                          passwordController
                                                              .text,
                                                      address: addressController
                                                          .text,
                                                      city: cityController.text,
                                                      codepostal:
                                                          postalController.text,
                                                      locationx: latLng.latitude
                                                          .toString(),
                                                      locationy: latLng
                                                          .longitude
                                                          .toString())
                                                  .then((value) async {
                                                if (value.isSuccess) {
                                                  /* SharedPreferences
                                                     sharedPreferences =
                                                      await SharedPreferences
                                                          .getInstance();*/

                                                  setState(() {
                                                    isLoading = false;
                                                  });

                                                  Get.snackbar(
                                                    maxWidth: 500,
                                                    backgroundColor:
                                                    blueColor
                                                        .withOpacity(
                                                        .7),
                                                    "Votre profil a été mis a jour",
                                                    "",
                                                  );
                                                  getData();

                                                  /*
                                                  String email =
                                                      emailController.text;
                                                  var password =
                                                      passwordController.text;
                                                  authController
                                                      .loginController(
                                                          username: email,
                                                          password: password
                                                              .toString())
                                                      .then((value) {
                                                    if (value.isSuccess) {
                                                      setState(() {
                                                        isLoading = false;
                                                      });

                                                      Get.snackbar(
                                                        maxWidth: 500,
                                                        backgroundColor:
                                                            blueColor
                                                                .withOpacity(
                                                                    .7),
                                                        "Votre profil a été mis a jour",
                                                        "",
                                                      );
                                                      getData();
                                                    } else {
                                                      Get.snackbar(
                                                        maxWidth: 500,
                                                        backgroundColor:
                                                            blueColor
                                                                .withOpacity(
                                                                    .7),
                                                        "Votre profil a été mis a jour",
                                                        "Vuillez réessayer votre connexion",
                                                      );
                                                      sharedPreferences.remove(
                                                          AppConstant
                                                              .USER_EMAIL);
                                                      sharedPreferences.remove(
                                                          AppConstant
                                                              .USER_PASSWORD);
                                                      sharedPreferences.remove(
                                                          AppConstant
                                                              .USER_OBJECT);
                                                      Get.offAll(
                                                        () =>
                                                            const SplashScreen(),
                                                        routeName: RouteHelper
                                                            .getSplashRoute(),
                                                      );
                                                    }
                                                  });*/

                                                  // SharedPreferences
                                                  //     sharedPreferences =
                                                  //     await SharedPreferences
                                                  //         .getInstance();
                                                  // sharedPreferences.remove(
                                                  //     AppConstant.USER_EMAIL);
                                                  // sharedPreferences.remove(
                                                  //     AppConstant
                                                  //         .USER_PASSWORD);
                                                  // sharedPreferences.remove(
                                                  //     AppConstant.USER_OBJECT);
                                                  // Get.offAll(
                                                  //   () => const SplashScreen(),
                                                  //   routeName: RouteHelper
                                                  //       .getSplashRoute(),
                                                  // );
                                                  // getData();
                                                } else {
                                                  setState(() {
                                                    isLoading = false;
                                                  });
                                                  if (value.message
                                                          .toLowerCase()
                                                          .contains("phone") &&
                                                      value.message
                                                          .toLowerCase()
                                                          .contains("mail")) {
                                                    Get.snackbar(
                                                      maxWidth: 500,
                                                      backgroundColor: blueColor
                                                          .withOpacity(.7),
                                                      "Modification impossible",
                                                      "Téléphone et Email renseigné est déjà utilisé par un compte existant",
                                                    );
                                                  } else if (value.message
                                                      .toLowerCase()
                                                      .contains("phone")) {
                                                    Get.snackbar(
                                                      maxWidth: 500,
                                                      backgroundColor: blueColor
                                                          .withOpacity(.7),
                                                      "Modification impossible",
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
                                                      backgroundColor: blueColor
                                                          .withOpacity(.7),
                                                      "Modification impossible",
                                                      "LL’adresse email renseignée est déjà utilisée par un compte existant",
                                                    );
                                                  } else {
                                                    Get.snackbar(
                                                      maxWidth: 500,
                                                      backgroundColor: blueColor
                                                          .withOpacity(.7),
                                                      "L'opération a échoué",
                                                      "Une erreur s'est produite, réessayez.",
                                                    );
                                                  }
                                                }
                                              }).catchError((onError) {
                                                setState(() {
                                                  isLoading = false;
                                                });
                                                Get.snackbar(
                                                  maxWidth: 500,
                                                  backgroundColor:
                                                      blueColor.withOpacity(.7),
                                                  "L'opération a échoué",
                                                  "Une erreur s'est produite, réessayez.",
                                                );
                                              });
                                            }
                                          }
                                        },
                                        style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                                  blueColor),
                                          padding: MaterialStateProperty.all(
                                            const EdgeInsets.symmetric(
                                                vertical: 15),
                                          ),
                                          shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(
                                            const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.zero,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          "Enregistrer modification",
                                          style: gothicBold.copyWith(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(
                                      height: 3,
                                    ),

                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 7),
                                      width: sizeWidth(context: context) * .9,
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          Get.defaultDialog(
                                              title: "Confirmation !",
                                              middleText:
                                                  "êtes-vous sûr de vouloir supprimer votre compte",
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Get.back();
                                                  },
                                                  child: Text(
                                                    "Annuler",
                                                    style: gothicBold.copyWith(
                                                      color: Colors.red,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 15,
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    Get.back();
                                                    setState(() {
                                                      isLoading = true;
                                                    });
                                                    authController
                                                        .deleteProfileController()
                                                        .then((value) async {
                                                      setState(() {
                                                        isLoading = false;
                                                      });
                                                      if (value.isSuccess) {
                                                        SharedPreferences
                                                            sharedPreferences =
                                                            await SharedPreferences
                                                                .getInstance();
                                                        sharedPreferences
                                                            .remove(AppConstant
                                                                .USER_EMAIL);
                                                        sharedPreferences
                                                            .remove(AppConstant
                                                                .USER_PASSWORD);
                                                        Get.offAll(
                                                          () =>
                                                              const SplashScreen(),
                                                          routeName: RouteHelper
                                                              .getSplashRoute(),
                                                        );
                                                        Get.snackbar(
                                                          maxWidth: 500,
                                                          backgroundColor:
                                                              blueColor
                                                                  .withOpacity(
                                                                      .7),
                                                          "Votre profil a été supprimé",
                                                          "",
                                                        );
                                                      } else {
                                                        Get.snackbar(
                                                          maxWidth: 500,
                                                          backgroundColor:
                                                              blueColor
                                                                  .withOpacity(
                                                                      .7),
                                                          "L'opération a échoué",
                                                          "Une erreur s'est produite, réessayez.",
                                                        );
                                                      }
                                                    }).catchError((onError) {
                                                      setState(() {
                                                        isLoading = false;
                                                      });
                                                      Get.snackbar(
                                                        maxWidth: 500,
                                                        backgroundColor:
                                                            blueColor
                                                                .withOpacity(
                                                                    .7),
                                                        "L'opération a échoué",
                                                        "Une erreur s'est produite, réessayez.",
                                                      );
                                                    });
                                                  },
                                                  child: Text(
                                                    "Supprimer",
                                                    style: gothicBold.copyWith(
                                                      color: blueColor,
                                                    ),
                                                  ),
                                                ),
                                              ]);
                                        },
                                        style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                                  Colors.red),
                                          padding: MaterialStateProperty.all(
                                            const EdgeInsets.symmetric(
                                                vertical: 15),
                                          ),
                                          shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(
                                            const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.zero,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          "Supprimer mon compte",
                                          style: gothicBold.copyWith(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 50,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      )),
    );
  }
}
