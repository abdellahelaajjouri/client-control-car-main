// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'dart:developer';

import 'package:client_control_car/constants/app_constant.dart';
import 'package:client_control_car/control_repository/control_repo.dart';
import 'package:client_control_car/controllers/auth_controller.dart';
import 'package:client_control_car/models/card_bank_model.dart';
import 'package:client_control_car/models/control_model.dart';
import 'package:client_control_car/models/errors/response_model.dart';
import 'package:client_control_car/models/technicien_model.dart';
import 'package:client_control_car/models/vehicule_marque.dart';
import 'package:client_control_car/models/vehicule_type.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ControlController extends GetxController implements GetxService {
  ControlRepo controlRepo;
  ControlController({required this.controlRepo});

  //
  bool isPop = false;

  int maxPage = 1;
  int currentPage = 1;

  // id info_vehicule
  String? idInfoVehicule;
  String? idInfoPersoVehicule;
  String? idRendezVous;
  String? idFacturation;
  String? idControl;
  String? listTechselected;

  // address
  String? facaddress;
  String? faccity;
  String? faccodepostal;
  String? facbatiment;
  String? faclocation_x;
  String? faclocation_y;

  Position? currentPosition;
  LatLng? currentPositionLatLng;

  List<TechnicienModel> listTechniciens = [];

  List<VehiculeType> listVehiculeType = [];
  List<VehiculeMarque> listVehiculeMarque = [];

  ControlModel? controlModel;
  List<ControlModel> listControlModel = [];

  List<CardBankModel> listCardBank = [];

  Future<ResponseModel> createPaymentController({
    required String idControl,
    required String card_number,
    required String exp_month,
    required String exp_year,
    required String cvc,
    required String name,
    required String email,
    required String address_line1,
    required String address_line2,
    required String address_city,
    required String address_state,
    required String address_postal_code,
    required String address_country,
    required String amount,
    required String description,
  }) async {
    Response response = await controlRepo.createPaymentControlRepo(
        idControl: idControl,
        card_number: card_number,
        exp_month: exp_month,
        exp_year: exp_year,
        cvc: cvc,
        name: name,
        email: email,
        address_line1: address_line1,
        address_line2: address_line2,
        address_city: address_city,
        address_state: address_state,
        address_postal_code: address_postal_code,
        address_country: address_country,
        amount: amount,
        description: description);
    ResponseModel responseModel;
    if (response.statusCode == 200 || response.statusCode == 201) {
      responseModel = ResponseModel(true, response.body.toString());
      update();
    } else {
      responseModel = ResponseModel(false, response.body["detail"].toString());
      update();
    }
    update();
    return responseModel;
  }

  Future<ResponseModel> checkCodePromoController(
      {required String promocode}) async {
    Response response =
        await controlRepo.checkCodePromoRepo(codepromo: promocode);
    ResponseModel responseModel;
    if (response.statusCode == 200 || response.statusCode == 201) {
      responseModel = ResponseModel(true, response.body["discount"].toString());
      update();
    } else {
      responseModel = ResponseModel(false, response.body.toString());
      update();
    }
    update();
    return responseModel;
  }

  Future<ResponseModel> sendAmountToStripeController() async {
    Response response = await controlRepo.sendAmountToStripeRepo();
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

  // add cart bancair
  Future<bool> addCartBancair({required CardBankModel cardBankModel}) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    // get listCard
    List<String> lsString = [];
    List<String>? items =
        sharedPreferences.getStringList(AppConstant.CRDBNK_OBJECT);
    if (items != null) {
      for (var element in items) {
        lsString.add(element);
      }
    }

    lsString.add(json.encode(cardBankModel.toJsonString()));

    // save
    sharedPreferences.setStringList(AppConstant.CRDBNK_OBJECT, lsString);

    getListCartBancair();
    return true;
  }

  // add cart bancair
  Future<bool> deleteCartBancair({required String numberCard}) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    AuthController authController = Get.find();
    Map<String, dynamic> payload =
        Jwt.parseJwt(authController.accessUserJWS.toString());
    bool check = false;
    List<CardBankModel> listCardBankNv = [];
    for (var card in listCardBank) {
      if (card.numberCard.toString() != numberCard.toString() &&
          card.id.toString() == payload["user_id"].toString()) {
        listCardBankNv.add(card);
      }
    }
    listCardBank = listCardBankNv;
    List<String> lsString = [];
    for (var element in listCardBank) {
      lsString.add(json.encode(element.toJsonString()));
    }
    sharedPreferences.setStringList(AppConstant.CRDBNK_OBJECT, lsString);

    getListCartBancair();
    return check;
  }

  // get list Cards
  Future<void> getListCartBancair() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    AuthController authController = Get.find();

    Map<String, dynamic> payload =
        Jwt.parseJwt(authController.accessUserJWS.toString());
    List<String>? listString =
        sharedPreferences.getStringList(AppConstant.CRDBNK_OBJECT);
    listCardBank = [];
    List<CardBankModel> listCardBankNull = [];

    if (listString != null) {
      listCardBankNull = listString
          .map<CardBankModel>(
              (model) => CardBankModel.fromJson(jsonDecode(model)))
          .toList();
      listCardBank = [];
      for (var element in listCardBankNull) {
        if (element.id.toString() == payload["user_id"].toString()) {
          listCardBank.add(element);

          if (checkCartBancair(
              listcardBankModel: listCardBank,
              cardnumber: element.numberCard!.replaceAll(" ", "").toString())) {
            listCardBank.add(element);
          }
        }
      }
      update();
    } else {}
  }

  bool checkCartBancair(
      {required List<CardBankModel> listcardBankModel,
      required String cardnumber}) {
    bool check = false;
    AuthController authController = Get.find();
    Map<String, dynamic> payload =
        Jwt.parseJwt(authController.accessUserJWS.toString());
    // get listCard
    if (listcardBankModel.isNotEmpty) {
      for (var element in listcardBankModel) {
        if (element.numberCard!.replaceAll(" ", "") == cardnumber &&
            payload["user_id"].toString() == element.id.toString()) {
          check == true;
        }
      }
    }

    return check;
  }

  // get list controls
  Future<ResponseModel> getAllControlsController(
      {required String state, required int page}) async {
    Response response =
        await controlRepo.getAllControlsRepo(state: state, page: page);
    ResponseModel responseModel;

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (page == 1) {
        listControlModel = response.body["controls"]
            .map<ControlModel>((model) => ControlModel.fromJson(model))
            .toList();
      } else {
        listControlModel.addAll(response.body["controls"]
            .map<ControlModel>((model) => ControlModel.fromJson(model))
            .toList());
      }
      maxPage = int.parse(response.body["pages"].toString());
      currentPage = int.parse(response.body["page"].toString());
      responseModel = ResponseModel(true, response.body.toString());
      update();
    } else {
      responseModel = ResponseModel(false, response.body.toString());
      update();
    }
    update();
    return responseModel;
  }

  // get detail Control
  Future<ResponseModel> getControlDetailController(
      {required String idcontrol}) async {
    Response response =
        await controlRepo.getAInfoControlRepo(idcontrol: idcontrol);
    ResponseModel responseModel;
    controlModel = null;

    if (response.statusCode == 200 || response.statusCode == 201) {
      controlModel = ControlModel.fromJson(response.body);
      responseModel = ResponseModel(true, response.body.toString());
      update();
    } else {
      responseModel = ResponseModel(false, response.body.toString());
      update();
    }
    update();
    return responseModel;
  }

  // get list Type vehicule
  Future<ResponseModel> getListMarqueVehiculeController() async {
    Response response = await controlRepo.getAllMarqueVehiculeRepo();
    ResponseModel responseModel;
    listVehiculeMarque = [];
    Future.delayed(Duration.zero, () {
      update();
    });
    if (response.statusCode == 200 || response.statusCode == 201) {
      listVehiculeMarque = response.body
          .map<VehiculeMarque>((model) => VehiculeMarque.fromJson(model))
          .toList();
      responseModel = ResponseModel(true, response.body.toString());
      update();
    } else {
      responseModel = ResponseModel(false, response.body.toString());
      update();
    }
    update();
    return responseModel;
  }

  // get list Type vehicule
  Future<ResponseModel> getListTypeVehiculeController() async {
    Response response = await controlRepo.getAllTypeVehiculeRepo();
    ResponseModel responseModel;

    listVehiculeType = [];
    if (response.statusCode == 200 || response.statusCode == 201) {
      listVehiculeType = response.body
          .map<VehiculeType>((model) => VehiculeType.fromJson(model))
          .toList();
      responseModel = ResponseModel(true, response.body.toString());
      update();
    } else {
      responseModel = ResponseModel(false, response.body.toString());
      update();
    }
    update();
    return responseModel;
  }

  // add Control
  Future<ResponseModel> addfactureController(
      {required String nom,
      required String prenom,
      required String ville,
      required String address,
      required String code_postal,
      required String email,
      required String phone,
      required String demande_control}) async {
    Response response = await controlRepo.addFactureControlRepo(
        nom: nom,
        prenom: prenom,
        ville: ville,
        address: address,
        code_postal: code_postal,
        email: email,
        phone: phone,
        demande_control: demande_control);
    ResponseModel responseModel;
    if (response.statusCode == 200 || response.statusCode == 201) {
      idFacturation = response.body["facturation_id"].toString();
      responseModel = ResponseModel(true, "response.body.toString()");
      update();
    } else {
      responseModel = ResponseModel(false, response.body.toString());
      update();
    }
    update();
    return responseModel;
  }

  // add Control
  Future<ResponseModel> addController({
    required String rendez_vous,
    required String info_perso,
    required String info_vehicule,
    required String techniciens,
    required String facturation,
  }) async {
    Response response = await controlRepo.addControlRepo(
      rendez_vous: rendez_vous,
      info_perso: info_perso,
      info_vehicule: info_vehicule,
      techniciens: techniciens,
      facturation: facturation,
    );
    ResponseModel responseModel;
    if (response.statusCode == 200 || response.statusCode == 201) {
      idControl = response.body["countrol_id"].toString();
      responseModel = ResponseModel(true, "response.body.toString()");
      update();
    } else {
      responseModel = ResponseModel(false, response.body.toString());
      update();
    }
    update();
    return responseModel;
  }

  // get list techniciens
  Future<ResponseModel> getListTechniciensController({String? rdv}) async {
    Response response = await controlRepo.getAllTechniciensRepo(rdv: rdv);
    ResponseModel responseModel;
    listTechniciens = [];

    if (response.statusCode == 200 || response.statusCode == 201) {
      listTechniciens = response.body
          .map<TechnicienModel>((model) => TechnicienModel.fromJson(model))
          .toList();

      responseModel = ResponseModel(true, response.body.toString());
      update();
    } else {
      responseModel = ResponseModel(false, response.body.toString());
      update();
    }
    update();
    return responseModel;
  }

  // add info_vehicule
  Future<ResponseModel> addInfoVehiculeController(
      {required String type_vehicule,
      required String marque_vehicule,
      required String lien_annonce,
      required String immatriculation}) async {
    Response response = await controlRepo.addInfoVehiculeRepo(
      type_vehicule: type_vehicule,
      marque_vehicule: marque_vehicule,
      lien_annonce: lien_annonce,
      immatriculation: immatriculation,
    );

    ResponseModel responseModel;
    if (response.statusCode == 200 || response.statusCode == 201) {
      idInfoVehicule = response.body["info_vehicule_id"].toString();
      responseModel =
          ResponseModel(true, response.body["info_vehicule_id"].toString());
      update();
    } else {
      responseModel = ResponseModel(false, response.body['body'].toString());
      update();
    }
    update();
    return responseModel;
  }

  // add info perso vehilcule
  Future<ResponseModel> addInfoPersoVehiculeController({
    required String present_ctrl,
    required String demande_particuliere,
    required String addresse,
    required String code_postal,
    required String batiment,
    required String ville,
    required String location_x,
    required String location_y,
  }) async {
    Response response = await controlRepo.addInfoPersoVehiculeRepo(
      present_ctrl: present_ctrl,
      demande_particuliere: demande_particuliere,
      addresse: addresse,
      code_postal: code_postal,
      batiment: batiment,
      ville: ville,
      location_x: location_x,
      location_y: location_y,
    );
    ResponseModel responseModel;

    if (response.statusCode == 200 || response.statusCode == 201) {
      idInfoPersoVehicule = response.body["info_perso_id"].toString();
      responseModel =
          ResponseModel(true, response.body["info_perso_id"].toString());
      update();
    } else {
      responseModel = ResponseModel(false, response.body.toString());
      update();
    }
    update();
    return responseModel;
  }

  Future<ResponseModel> addAddRendezVousController({
    required String date,
    required String time,
  }) async {
    Response response = await controlRepo.addAddRendezVousCntrolRepo(
      date: date,
      time: time,
    );
    ResponseModel responseModel;
    if (response.statusCode == 200 || response.statusCode == 201) {
      idRendezVous = response.body["rendez_vous_id"].toString();
      responseModel =
          ResponseModel(true, response.body["rendez_vous_id"].toString());
      update();
    } else {
      responseModel = ResponseModel(false, response.body.toString());
      update();
    }
    update();
    return responseModel;
  }

  Future<ResponseModel> addreviewController({
    required String control,
    required String comment,
    required String technicien,
    required String notation,
  }) async {
    Response response = await controlRepo.addReviewsRepo(
      control: control,
      technicien: technicien,
      comment: comment,
      notation: notation,
    );

    ResponseModel responseModel;

    if (response.statusCode == 200 || response.statusCode == 201) {
      responseModel = ResponseModel(true, response.body["detail"].toString());
      update();
    } else {
      responseModel = ResponseModel(false, response.body["detail"].toString());
      update();
    }
    update();
    return responseModel;
  }

  // update status Control
  Future<ResponseModel> updateStatuControlsController(
      {required String idControl, required String status}) async {
    Response response = await controlRepo.statusControlsRepo(
        idControl: idControl, status: status);

    ResponseModel responseModel;
    if (response.statusCode == 200 || response.statusCode == 201) {
      try {
        responseModel = ResponseModel(true, response.body.toString());
        update();
      } catch (e) {
        responseModel = ResponseModel(false, response.body.toString());
        update();
      }
    } else {
      responseModel = ResponseModel(false, response.body.toString());
      update();
    }
    update();
    return responseModel;
  }

  // check api carte grise
  Future<ResponseModel> addCarteGrise() async {
    Response response = await controlRepo.addCarteGriseRepo();
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

  // check Pay Control
  Future<ResponseModel> checkPayControl({
    required String idControl,
    required String price,
    required String hasCoupon,
    required String discount,
  }) async {
    Response response = await controlRepo.checkPayControl(
        idControl: idControl,
        price: price,
        hasCoupon: hasCoupon,
        discount: discount);
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

  // session checkout stripe
  Future<ResponseModel> sessionCheckoutStripeControl({
    required String idControl,
    required String price,
    required String hasCoupon,
    required String discount,
  }) async {
    Response response = await controlRepo.sessionCheckoutRepo(
        controlId: idControl,
        total: price,
        hasCoupon: hasCoupon,
        discount: discount);
    ResponseModel responseModel;
    log(response.body.toString());
    if (response.statusCode == 200 || response.statusCode == 201) {
      responseModel = ResponseModel(true, response.body['id'].toString());
      update();
    } else {
      responseModel = ResponseModel(false, response.body.toString());
      update();
    }
    update();
    return responseModel;
  }
}
