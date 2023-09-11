import 'dart:convert';

import 'package:client_control_car/constants/app_constant.dart';
import 'package:client_control_car/control_repository/auth_repo.dart';
import 'package:client_control_car/models/card_bank_model.dart';
import 'package:client_control_car/models/errors/response_model.dart';
import 'package:client_control_car/models/facturation_model.dart';
import 'package:client_control_car/models/user_model.dart';
import 'package:client_control_car/pages/book_rdv/forfait_control_screen.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends GetxController implements GetxService {
  AuthRepo authRepo;
  AuthController({required this.authRepo});
  // vehicule
  String? selectedDate;
  DateTime? dateTime;
  List<Technicien> listTechnicien = [];
  List<CardBankModel> listCardBank = [
    CardBankModel(
        namUser: "Anaîs Lecrelc",
        numberCard: "**** **** **** 5262",
        image: "assets/icons/Master.png",
        yearCard: "2024",
        monthCard: "01",
        cvvCard: "123"),
  ];
  FacturationModel? facturationModel;

  String accessUserJWS = "";

  //
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool isShozGriz = false;

  UserModel? userModel;
  UserModel? userModelProfile;

  void startloading() {
    _isLoading = true;
    Future.delayed(Duration.zero, () {
      update();
    });
  }

  void stoploading() {
    _isLoading = false;
    Future.delayed(Duration.zero, () {
      update();
    });
  }

  //
  Future<ResponseModel> deleteProfileController() async {
    Response response = await authRepo.deleteProfilRepo();
    ResponseModel responseModel;

    if (response.statusCode == 200) {
      // userAppModel = UserAppModel.fromJson(response.body);
      responseModel = ResponseModel(true, response.body.toString());
      update();
    } else {
      responseModel = ResponseModel(false, response.body.toString());
      update();
    }
    update();
    return responseModel;
  }

  // confirm otp
  Future<ResponseModel> confirmPhoneController(
      {required String destination, required String otp}) async {
    Response response =
        await authRepo.confirmPhoneRepo(destination: destination, otp: otp);
    ResponseModel responseModel;

    if (response.statusCode == 200 || response.statusCode == 201) {
      responseModel = ResponseModel(true, response.body.toString());
      update();
    } else {
      responseModel = ResponseModel(false, response.body.toString());
      update();
    }
    update();
    return responseModel;
  }

  // send phone
  Future<ResponseModel> sendPhoneController(
      {required String destination}) async {
    Response response = await authRepo.sendPhoneRepo(destination: destination);
    ResponseModel responseModel;

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (response.body["is_sent"].toString() == 'true') {
        responseModel = ResponseModel(true, response.body.toString());
      } else {
        responseModel = ResponseModel(false, response.body.toString());
      }

      update();
    } else {
      responseModel = ResponseModel(false, response.body.toString());
      update();
    }
    update();
    return responseModel;
  }

  // get location by latlng
  Future<String> getAddressFromGeocode({required LatLng latLng}) async {
    Response response = await authRepo.getAddressFromGeocode(latLng);
    String address = "Trouvez votre position";
    // String _address = "location a été trouvé n'est pas inconnue";

    if (response.statusCode == 200 && response.body['status'] == 'OK') {
      address = response.body['results'][0]['formatted_address'].toString();
    } else {
      // showCustomSnackBar(response.body['error_message'] ?? response.bodyString);
    }
    return address;
  }

  // get profile
  Future<ResponseModel> getCProfileController() async {
    Response response = await authRepo.getProfileRepo();
    ResponseModel responseModel;

    if (response.statusCode == 200 || response.statusCode == 201) {
      userModelProfile = UserModel.fromJsonProf(response.body);
      userModel = UserModel.fromJsonProf(response.body);
      responseModel = ResponseModel(true, response.body.toString());
      update();
    } else {
      responseModel = ResponseModel(false, response.body.toString());
      update();
    }
    update();
    return responseModel;
  }

  // login by email
  Future<ResponseModel> loginController(
      {required String username, required String password}) async {
    Response response =
        await authRepo.loginRepo(username: username, password: password);
    ResponseModel responseModel;

    if (response.statusCode == 200) {
      userModel = null;
      userModel = UserModel.fromJson(response.body);
      authRepo.saveDataLoginReg(username: username, password: password);
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      accessUserJWS = userModel!.access.toString();
      sharedPreferences.setStringList(
          AppConstant.USER_OBJECT, [jsonEncode(userModel!.toJson())]);
      responseModel = ResponseModel(true, response.body.toString());
      update();
    } else {
      responseModel = ResponseModel(false, response.body.toString());
      update();
    }
    _isLoading = false;
    update();
    return responseModel;
  }

  // register client
  Future<ResponseModel> registerController(
      {required UserModel userMdl, required String password}) async {
    Response response =
        await authRepo.registerRepo(userModel: userMdl, password: password);
    ResponseModel responseModel;

    if (response.statusCode == 200 || response.statusCode == 201) {
      userModel = null;
      userModel = UserModel.fromJson(response.body);
      authRepo.saveDataLoginReg(
        username: userMdl.phone.toString().replaceAll(" ", ""),
        password: password,
      );
      accessUserJWS = userModel!.access.toString();
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();

      sharedPreferences.setStringList(
          AppConstant.USER_OBJECT, [jsonEncode(userModel!.toJson())]);
      responseModel = ResponseModel(true, response.body.toString());
      update();
    } else {
      responseModel = ResponseModel(false, response.statusCode.toString());
      update();
    }
    update();
    return responseModel;
  }

  // update profile
  Future<ResponseModel> updateProfileController({
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
    Response response = await authRepo.updateProfilRepo(
        firstname: firstname,
        lastname: lastname,
        email: email,
        phone: phone,
        password: password,
        photo: photo,
        address: address,
        city: city,
        codepostal: codepostal,
        locationx: locationx,
        locationy: locationy);
    ResponseModel responseModel;

    if (response.statusCode == 200) {
      userModel!.email = email;
      userModel!.first_name = firstname;
      userModel!.phone = phone;
      userModel!.last_name = lastname;
      userModel!.photo = photo;
      userModel!.address = address;
      userModel!.city = city;
      userModel!.code_postal = codepostal;
      userModel!.location_x = locationx;
      userModel!.location_y = locationy;

      userModelProfile!.email = email;
      userModelProfile!.first_name = firstname;
      userModelProfile!.phone = phone;
      userModelProfile!.last_name = lastname;
      userModelProfile!.photo = photo;
      userModelProfile!.address = address;
      userModelProfile!.city = city;
      userModelProfile!.code_postal = codepostal;
      userModelProfile!.location_x = locationx;
      userModelProfile!.location_y = locationy;

      // userAppModel = UserAppModel.fromJson(response.body);
      responseModel = ResponseModel(true, response.body.toString());
      update();
    } else {
      responseModel = ResponseModel(false, response.body.toString());
      update();
    }
    update();
    return responseModel;
  }

  // reset password
  Future<ResponseModel> resetPasswordController(
      {String? email, String? phone}) async {
    Response response =
        await authRepo.resetPassword(email: email, phone: phone);
    ResponseModel responseModel;

    if (response.statusCode == 200 || response.statusCode == 201) {
      responseModel = ResponseModel(true, response.body['email']);
      update();
    } else {
      responseModel = ResponseModel(false, response.body['detail']);
      update();
    }
    update();
    return responseModel;
  }

  // reset password
  Future<ResponseModel> confirmPasswordController(
      {required String email,
      required String otp,
      required String password}) async {
    Response response = await authRepo.confirmPassword(
        email: email, otp: otp, password: password);
    ResponseModel responseModel;

    if (response.statusCode == 200 || response.statusCode == 201) {
      responseModel = ResponseModel(true, response.body['detail']);
      update();
    } else {
      responseModel = ResponseModel(false, response.body['detail']);
      update();
    }
    update();
    return responseModel;
  }
}
