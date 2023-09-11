import 'dart:developer';
import 'dart:io';

import 'package:client_control_car/constants/app_constant.dart';
import 'package:client_control_car/control_repository/api_client.dart';
import 'package:client_control_car/controllers/auth_controller.dart';
import 'package:client_control_car/models/user_model.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepo {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  AuthRepo({required this.apiClient, required this.sharedPreferences});

  Future<Response> deleteProfilRepo() async {
    AuthController authController = Get.find();

    return await apiClient.deleteData(
      AppConstant.DELETE_PROFILE_URL,
      headers: {
        'Content-Type': 'application/json;charset=UTF-8',
        'Authorization':
            'Bearer ${authController.userModel!.access ?? authController.accessUserJWS}',
      },
    );
  }

  // send phone otp
  Future<Response> confirmPhoneRepo(
      {required String destination, required String otp}) async {
    return await apiClient.postData(
      AppConstant.CONFIRM_OTP_PHONE,
      {
        "destination": destination,
        "otp": otp,
      },
      headers: {
        'Content-Type': 'application/json;charset=UTF-8',
      },
    );
  }

  // send phone otp
  Future<Response> sendPhoneRepo({required String destination}) async {
    return await apiClient.postData(
      AppConstant.SEND_OTP_PHONE,
      {
        "destination": destination,
      },
      headers: {
        'Content-Type': 'application/json;charset=UTF-8',
      },
    );
  }

// get profile
  Future<Response> getProfileRepo() async {
    AuthController authController = Get.find();
    return await apiClient.getData(
      AppConstant.PROFILE_URL,
      headers: {
        'Content-Type': 'application/json;charset=UTF-8',
        'Authorization':
            'Bearer ${authController.userModel!.access ?? authController.accessUserJWS}',
      },
    );
  }

  // login by phone and password
  Future<Response> loginRepo(
      {required String username, required String password}) async {
    String? tokenFb = '';
    if (kIsWeb) {
      tokenFb = '';
    } else {
      try {
        if (Platform.isIOS || Platform.isMacOS) {
          tokenFb = await FirebaseMessaging.instance.getAPNSToken();
        } else {
          tokenFb = await FirebaseMessaging.instance.getToken();
        }

        // tokenFb = await FirebaseMessaging.instance.getAPNSToken();
      } catch (e) {
        log(e.toString());
        tokenFb = "";
      }
    }
    String login = username;
    if (username[0].toString() == "0") {
      login = username.toString().substring(1);
    } else if (username.toString().contains("+33")) {
      login = username.toString().replaceAll("+33", "");
    }

    return await apiClient.postData(
      AppConstant.LOGIN_URL,
      {
        "username": login,
        "password": password,
        "token_fb": tokenFb,
      },
      headers: {
        'Content-Type': 'application/json;charset=UTF-8',
      },
    );
  }

  Future<Response> registerRepo(
      {required UserModel userModel, required String password}) async {
    String? tokenFb = '';
    if (GetPlatform.isWeb) {
      tokenFb = '';
    } else {
      try {
        if (Platform.isIOS || Platform.isMacOS) {
          tokenFb = await FirebaseMessaging.instance.getAPNSToken();
        } else {
          tokenFb = await FirebaseMessaging.instance.getToken();
        }
        // tokenFb = await FirebaseMessaging.instance.getAPNSToken();
      } catch (e) {
        log(e.toString());
        tokenFb = "";
      }
    }
    String login = userModel.phone!.replaceAll(" ", "");
    if (userModel.phone!.replaceAll(" ", "")[0].toString() == "0") {
      login = userModel.phone!.replaceAll(" ", "").toString().substring(1);
    } else if (userModel.phone!
        .replaceAll(" ", "")
        .toString()
        .contains("+33")) {
      login =
          userModel.phone!.replaceAll(" ", "").toString().replaceAll("+33", "");
    }
    return await apiClient.postData(
      '/api/users/register-client',
      {
        "phone": login.replaceAll(" ", ""),
        // "username": userModel.phone!.replaceAll(" ", ""),
        "password": password,
        "email": userModel.email,
        "token_fb": tokenFb,
        "nom": userModel.first_name,
        "prenom": userModel.last_name,
        "role": 2,
        "address": userModel.address,
        "ville": userModel.city,
        "location_x": userModel.location_x,
        "location_y": userModel.location_y,
        "code_postal": userModel.code_postal,
      },
      headers: {
        'Content-Type': 'application/json;charset=UTF-8',
      },
    );
  }

  Future<void> saveDataLoginReg(
      {required String username, String password = ""}) async {
    try {
      await sharedPreferences.setString(AppConstant.USER_PASSWORD, password);
      await sharedPreferences.setString(AppConstant.USER_EMAIL, username);
    } catch (e) {
      // printError(info: e.toString());
      log(e.toString());
    }
  }

  // get location by latlng
  Future<Response> getAddressFromGeocode(LatLng latLng) async {
    return await apiClient.getLocationData(
      '${AppConstant.GEOCODE_URI}?lat=${latLng.latitude}&lng=${latLng.longitude}',
      headers: {
        'Content-Type': 'application/json;charset=UTF-8',
      },
    );
  }

  // update profile
  Future<Response> updateProfilRepo({
    required String firstname,
    required String lastname,
    required String email,
    required String phone,
    required String photo,
    required String password,
    required String address,
    required String city,
    required String codepostal,
    required String locationx,
    required String locationy,
  }) async {
    AuthController authController = Get.find();
    String login = phone.replaceAll(" ", "");
    if (phone.replaceAll(" ", "")[0].toString() == "0") {
      login = phone.replaceAll(" ", "").toString().substring(1);
    } else if (phone.replaceAll(" ", "").toString().contains("+33")) {
      login = phone.replaceAll(" ", "").toString().replaceAll("+33", "");
    }
    return await apiClient.putMultipartData(
      AppConstant.UPDATE_PROFILE_URL,
      {
        "nom": firstname,
        "prenom": lastname,
        "photo": photo,
        "phone": login.replaceAll(" ", ""),
        "email": email,
        // "rib": "-",
        "password": password,
        "address": address,
        "ville": city,
        "location_x": locationx,
        "location_y": locationy,
        "code_postal": codepostal,
      },
      [],
      headers: {
        'Content-Type': 'application/json;charset=UTF-8',
        'Authorization':
            'Bearer ${authController.userModel!.access ?? authController.accessUserJWS}',
      },
    );
  }

  // get profile
  Future<Response> getProfilInfo() async {
    AuthController authController = Get.find();
    return await apiClient.getData(
      AppConstant.PROFIL_URL,
      headers: {
        'Content-Type': 'application/json;charset=UTF-8',
        'Authorization':
            'Bearer ${authController.userModel!.access ?? authController.accessUserJWS}',
      },
    );
  }

  // PASSWORD_RESET_URL
  Future<Response> resetPassword({String? email, String? phone}) async {
    // AuthController authController = Get.find();
    var data = {};
    if (email != null) {
      data = {"email": email};
    } else {
      String login = phone!.replaceAll(" ", "");
      if (phone.replaceAll(" ", "")[0].toString() == "0") {
        login = phone.replaceAll(" ", "").toString().substring(1);
      } else if (phone.replaceAll(" ", "").toString().contains("+33")) {
        login = phone.replaceAll(" ", "").toString().replaceAll("+33", "");
      }
      data = {"phone": login};
    }

    return await apiClient.postData(
      AppConstant.PASSWORD_RESET_URL,
      data,
      headers: {
        'Content-Type': 'application/json;charset=UTF-8',
        // 'Authorization': 'Bearer ${authController.userModel!.access ?? authController.accessUserJWS}',
      },
    );
  }

  Future<Response> confirmPassword(
      {required String email,
      required String otp,
      required String password}) async {
    // AuthController authController = Get.find();

    return await apiClient.postData(
      AppConstant.PASSWORD_confirm_URL,
      {
        "email": email,
        "otp": otp,
        "new_password": password,
      },
      headers: {
        'Content-Type': 'application/json;charset=UTF-8',
        // 'Authorization': 'Bearer ${authController.userModel!.access ?? authController.accessUserJWS}',
      },
    );
  }
}
