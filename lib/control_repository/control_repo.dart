// ignore_for_file: non_constant_identifier_names

import 'package:client_control_car/constants/app_constant.dart';
import 'package:client_control_car/constants/route_helper.dart';
import 'package:client_control_car/control_repository/api_client.dart';
import 'package:client_control_car/controllers/auth_controller.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ControlRepo {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  ControlRepo({required this.apiClient, required this.sharedPreferences});

  // insert info vehicule
  Future<Response> createPaymentControlRepo({
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
    AuthController authController = Get.find();

    return await apiClient.postData(
      AppConstant.CREATE_PAYMENT_CONTROLS,
      {
        "idControl": idControl,
        "card_number": card_number,
        "exp_month": exp_month,
        "exp_year": exp_year,
        "cvc": cvc,
        "name": name,
        "email": email,
        "address_line1": address_line1,
        "address_line2": address_line2,
        "address_city": address_city,
        "address_state": address_state,
        "address_postal_code": address_postal_code,
        "address_country": address_country,
        "amount": int.parse(amount.split(".").first.toString()),
        "description": description,
      },
      headers: {
        'Content-Type': 'application/json;charset=UTF-8',
        'Authorization':
            'Bearer ${authController.userModel!.access ?? authController.accessUserJWS}',
      },
    );
  }

  Future<Response> checkCodePromoRepo({required String codepromo}) async {
    AuthController authController = Get.find();

    return await apiClient.postData(
      AppConstant.CODEPROMO_URL,
      {
        "code": codepromo,
      },
      headers: {
        'Content-Type': 'application/json;charset=UTF-8',
        'Authorization':
            'Bearer ${authController.userModel!.access ?? authController.accessUserJWS}',
      },
    );
  }

  // insert info vehicule
  Future<Response> addInfoVehiculeRepo(
      {required String type_vehicule,
      required String marque_vehicule,
      required String lien_annonce,
      required String immatriculation}) async {
    AuthController authController = Get.find();

    return await apiClient.postData(
      AppConstant.ADDINFOVEHICULE_URL,
      {
        "type_vehicule": type_vehicule,
        "marque_vehicule": marque_vehicule,
        "lien_annonce": lien_annonce,
        "immatriculation": immatriculation,
      },
      headers: {
        'Content-Type': 'application/json;charset=UTF-8',
        'Authorization':
            'Bearer ${authController.userModel!.access ?? authController.accessUserJWS}',
      },
    );
  }

  Future<Response> sendAmountToStripeRepo() async {
    return await apiClient.postDataCustom(
      "https://api.stripe.com/v1/charges",
      {
        "amount": "1000", // Amount in cents
        "currency": "usd",
        "source": {
          "object": "card",
          "number": "42424242424242424",
          "exp_month": 12,
          "exp_year": 24,
          "cvc": "123",
        },
        "metadata": {
          "user_id": "123456",
          "user_name": "John Doe",
          "user_email": "john.doe@gmail.com",
        },
      },
      headers: {
        "Authorization": "Bearer sk_test_iFlJptPIlzfJk9uJRwAt0GkY00znkgozn6",
        "Content-Type": "application/json;charset=UTF-8",
      },
    );
  }

// add info perso vehicule
  Future<Response> addInfoPersoVehiculeRepo({
    required String present_ctrl,
    required String demande_particuliere,
    required String addresse,
    required String code_postal,
    required String batiment,
    required String ville,
    required String location_x,
    required String location_y,
  }) async {
    AuthController authController = Get.find();
    return await apiClient.postData(
      AppConstant.ADDINFOPERSOVEHICULE_URL,
      {
        "present_ctrl": present_ctrl,
        "demande_particuliere": demande_particuliere,
        "addresse": addresse,
        "code_postal": code_postal,
        "batiment": batiment,
        "ville": ville,
        "location_x": location_x,
        "location_y": location_y,
      },
      headers: {
        'Content-Type': 'application/json;charset=UTF-8',
        'Authorization':
            'Bearer ${authController.userModel!.access ?? authController.accessUserJWS}',
      },
    );
  }

  // add add-rendez-vous
  Future<Response> addAddRendezVousCntrolRepo({
    required String date,
    required String time,
  }) async {
    AuthController authController = Get.find();
    return await apiClient.postData(
      AppConstant.ADDRendezVousCntr_URL,
      {
        "date": date,
        "time": time,
      },
      headers: {
        'Content-Type': 'application/json;charset=UTF-8',
        'Authorization':
            'Bearer ${authController.userModel!.access ?? authController.accessUserJWS}',
      },
    );
  }

  // list Techniciens
  Future<Response> getAllTechniciensRepo({String? rdv}) async {
    AuthController authController = Get.find();

    return await apiClient.getData(
      rdv != null
          // ? AppConstant.TECHNICIENT_URL
          ? "${AppConstant.TECHNICIENT_URL}?rdv=$rdv"
          : AppConstant.TECHNICIENT_URL,
      headers: {
        'Content-Type': 'application/json;charset=UTF-8',
        'Authorization':
            'Bearer ${authController.userModel!.access ?? authController.accessUserJWS}',
      },
    );
  }

  // add add-control
  Future<Response> addControlRepo({
    required String rendez_vous,
    required String info_perso,
    required String info_vehicule,
    required String techniciens,
    required String facturation,
  }) async {
    AuthController authController = Get.find();

    return await apiClient.postData(
      AppConstant.ADDCONTROL_URL,
      {
        "rendez_vous": rendez_vous,
        "info_perso": info_perso,
        "info_vehicule": info_vehicule,
        "techniciens": techniciens,
        "facturation": facturation,
        "plan": 1,
        "user": authController.userModel!.access
      },
      headers: {
        'Content-Type': 'application/json;charset=UTF-8',
        'Authorization':
            'Bearer ${authController.userModel!.access ?? authController.accessUserJWS}',
      },
    );
  }

  // add add-control
  Future<Response> addFactureControlRepo({
    required String nom,
    required String prenom,
    required String ville,
    required String address,
    required String code_postal,
    required String email,
    required String phone,
    required String demande_control,
  }) async {
    AuthController authController = Get.find();
    return await apiClient.postData(
      AppConstant.ADDFACTURATION_URL,
      {
        "nom": nom,
        "prenom": prenom,
        "ville": ville,
        "address": address,
        "code_postal": code_postal,
        "email": email,
        "phone": phone,
        "user": authController.userModel!.access,
        "demande_control": demande_control
      },
      headers: {
        'Content-Type': 'application/json;charset=UTF-8',
        'Authorization':
            'Bearer ${authController.userModel!.access ?? authController.accessUserJWS}',
      },
    );
  }

  // list TypeVehicule
  Future<Response> getAllTypeVehiculeRepo() async {
    return await apiClient.getData(
      AppConstant.VEHICULETYPE_URL,
      headers: {
        'Content-Type': 'application/json;charset=UTF-8',
        // 'Authorization': 'Bearer ${authController.userModel!.access ?? authController.accessUserJWS}',
      },
    );
  }

  // list MarqueVehicule
  Future<Response> getAllMarqueVehiculeRepo() async {
    return await apiClient.getData(
      AppConstant.VEHICULEMARQUE_URL,
      headers: {
        'Content-Type': 'application/json;charset=UTF-8',
        // 'Authorization': 'Bearer ${authController.userModel!.access ?? authController.accessUserJWS}',
      },
    );
  }

  // info control
  Future<Response> getAInfoControlRepo({required String idcontrol}) async {
    AuthController authController = Get.find();
    return await apiClient.getData(
      AppConstant.CONTROLDETAIL_URL + idcontrol,
      headers: {
        'Content-Type': 'application/json;charset=UTF-8',
        'Authorization':
            'Bearer ${authController.userModel!.access ?? authController.accessUserJWS}',
      },
    );
  }

  // list control
  Future<Response> getAllControlsRepo(
      {required String state, required int page}) async {
    AuthController authController = Get.find();

    return await apiClient.getData(
      "${AppConstant.LIST_CONTROLS}?state=$state&page=$page",
      headers: {
        'Content-Type': 'application/json;charset=UTF-8',
        'Authorization':
            'Bearer ${authController.userModel!.access ?? authController.accessUserJWS}',
      },
    );
  }

  // add reviews
  Future<Response> addReviewsRepo({
    required String control,
    required String comment,
    required String technicien,
    required String notation,
  }) async {
    AuthController authController = Get.find();

    return await apiClient.postData(
      AppConstant.REVIEW_URL,
      {
        "control": control,
        "technicien": technicien,
        "comment": comment,
        "notation": notation,
      },
      headers: {
        'Content-Type': 'application/json;charset=UTF-8',
        'Authorization':
            'Bearer ${authController.userModel!.access ?? authController.accessUserJWS}',
      },
    );
  }

  // update status Control
  Future<Response> statusControlsRepo(
      {required String idControl, required String status}) async {
    AuthController authController = Get.find();
    return await apiClient.putData(
      "${AppConstant.LIST_CONTROLS}$idControl/update-status/$status",
      {},
      headers: {
        'Content-Type': 'application/json;charset=UTF-8',
        'Authorization':
            'Bearer ${authController.userModel!.access ?? authController.accessUserJWS}',
      },
    );
  }

  Future<Response> checkPayControl(
      {required String idControl,
      required String price,
      required String hasCoupon,
      required String discount}) async {
    AuthController authController = Get.find();
    return await apiClient.putDataWithBody(
      "${AppConstant.LIST_CONTROLS}$idControl/pay",
      {
        "has_coupon": hasCoupon == "true" ? true : false,
        "price": price,
        "discount": discount,
      },
      headers: {
        'Content-Type': 'application/json;charset=UTF-8',
        'Authorization':
            'Bearer ${authController.userModel!.access ?? authController.accessUserJWS}',
      },
    );
  }

  // check carte grise
  Future<Response> addCarteGriseRepo() async {
    return await apiClient.getLocationData(
      AppConstant.ADD_CARTE_GRISE,
      headers: {
        // 'Content-Type': 'application/json;charset=UTF-8',
      },
    );
  }

  // session payment checkout
  Future<Response> sessionCheckoutRepo({
    required String total,
    required String controlId,
    required String hasCoupon,
    required String discount,
  }) async {
    String lineUrl =
        "&line_items[0][price_data][product_data][name]=${'control-id-$controlId'}&line_items[0][price_data][unit_amount]=${double.parse(total) * 100}&line_items[0][price_data][currency]=EUR&line_items[0][quantity]=1";
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(
        AppConstant.client_OBJECT_controlId, controlId.toString());
    sharedPreferences.setString(
        AppConstant.client_OBJECT_price, total.toString());
    sharedPreferences.setString(
        AppConstant.client_OBJECT_discount, discount.toString());
    sharedPreferences.setString(
        AppConstant.client_OBJECT_hasCoupon, hasCoupon.toString());
    return await apiClient.postData(
      "https://api.stripe.com/v1/checkout/sessions",
      'success_url=${"${Uri.base.toString().split("/#/")[0]}/#"}${RouteHelper.getStripeSuccessRoute()}&mode=payment${lineUrl.toString()}',
      isExt: true,
      headers: {
        'Authorization': "Bearer ${AppConstant.secruteKey}",
        'Content-Type': 'application/x-www-form-urlencoded'
      },
    );
  }
}
