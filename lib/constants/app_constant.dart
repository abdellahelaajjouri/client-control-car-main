// ignore_for_file: constant_identifier_names

import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class AppConstant {
  static const String APP_NAME = "Control-Car - Acheter Occasion";

  // static const String publishableKey =
  //     "pk_test_51LOP9yC6otGGSz7JRj6dxrA7sNIRIuIgdRqq6duGqSemHgJDpkq65RkBQOHU6uf3Gdbx XrM0C0yyXwV5VprrVVXe00mD0IZnsF";

  // static const String secruteKey =
  //     "sk_test_51LOP9yC6otGGSz7Jg6pPgsYRwU3ZX2tFonCB6WRmATBy7FdwsuTBVZZyHOx5shu5Dd itZJugcLeNdLDILBqC7gb300HgIcU0ox";

  //static const String publishableKey = "pk_live_51LOP9yC6otGGSz7JSfmjtl05YqdYQJEX82JPudRpIHeqp73WqUAWB4iN2z8ZxxkCzHhE RTgZTjyss19cJNlcetS000lKicLUCQ";
 // static const String secruteKey = "sk_live_51LOP9yC6otGGSz7JHv79V2W4UFpp2xebM6Jje80RIYsBToEOOt5E0zoZAwpwmYrF5qIld UJHq5Aq2Io0EQxui1h000IsDao5ex";

  static const String publishableKey = "pk_test_MMlMqLCiRcChg43q1v1A5x3t00CfQB6kjb";
  static const String secruteKey = "sk_test_Srl0RcimludMAdiCap5R0TNo006scBiP2i";

  static const String TOKEN = 'client_token';
  static const String USER_PASSWORD = 'user_password';
  static const String USER_EMAIL = 'user_email';
  static const String USER_OBJECT = 'user_object_client';
  static const String CRDBNK_OBJECT = 'crdbnk_object';

  static const String client_OBJECT_price = 'client_OBJECT_price';
  static const String client_OBJECT_discount = 'client_OBJECT_discount';
  static const String client_OBJECT_controlId = 'client_OBJECT_controlId';
  static const String client_OBJECT_hasCoupon = 'client_OBJECT_hasCoupon';

  static const String API_GOOGLE_MAPS =
      "AIzaSyAZ32rbtd7xmfHPE3CWjW_2DN1BfgtpPEs";

  // static const String BASE_URL = 'https://backend.ctitechnologie.ma';
  // static const String BASE_URL = 'http://79.137.34.143';
  // static const String BASE_URL = 'http://192.168.1.36:8000';
  static const String BASE_URL = 'https://control-car.fr';
  static const String BASE_File_URL = 'https://admin.control-car.fr';
  // static const String GEOCODE_URI =
  //     'https://alis187.sg-host.com/api/config/geocode-api';

  static const String BASE_ADDRESS_URL = '$BASE_URL/api/cartegrises';
  static const String GEOCODE_URI = '$BASE_ADDRESS_URL/geocode-api';

  static const String LOGIN_URL = '/api/users/login';
  // static const String LOGIN_URL = '/api/users/login-client';
  static const String REGISTER_URL = '/api/users/register-client';
  static const String PROFILE_URL = '/api/users/profile';

  static const String UPDATE_PROFILE_URL = '/api/users/update';
  static const String DELETE_PROFILE_URL = '/api/users/delete';

  static const String ADDINFOVEHICULE_URL = '/api/controls/add-info-vehicule';
  static const String ADDINFOPERSOVEHICULE_URL = '/api/controls/add-info-perso';
  static const String ADDRendezVousCntr_URL = '/api/controls/add-rendez-vous';
  static const String ADDCONTROL_URL = '/api/controls/add-control';
  static const String ADDFACTURATION_URL = '/api/controls/add-facturation';
  static const String CONTROLDETAIL_URL = '/api/controls/';
  static const String CLIENT_LIST_CONTROLS = '/api/controls/client';
  static const String LIST_CONTROLS = '/api/controls/';
  static const String CANCEL_CONTROLS = '/api/controls/client/';
  static const String CREATE_PAYMENT_CONTROLS = '/api/controls/create_payment/';

  static const String TECHNICIENT_URL = '/api/techniciens/';

  static const String VEHICULETYPE_URL = '/api/types';
  static const String VEHICULEMARQUE_URL = '/api/marques';

  static const String TECHNO_LAST_MESSAGES = '/api/messages/users';
  static const String TECHNO_MESSAGES = '/api/messages/';

  static const String CONTACT_ASSISTANCE = '/api/tickets/';

  static const String SEND_OTP_PHONE = "/api/users/send-otp";
  static const String CONFIRM_OTP_PHONE = "/api/users/confirm-otp";

  static const String NOTIFICATION_URL = "/api/notifications/";
  static const String CODEPROMO_URL = "/api/coupons/apply";

  static const String REVIEW_URL = "/api/reviews/";
  static const String PROFIL_URL = "/api/users/profile";

  static const String PASSWORD_RESET_URL = "/api/users/password-reset/";
  static const String PASSWORD_confirm_URL =
      "/api/users/password-reset-confirm/";

  static const String ADD_CARTE_GRISE =
      "https://www.service-public.fr/simulateur/calcul/cout-certificat-immatriculation/api?Poids=300&PrixAchat=40000&declareVehiculeDemonstration=1&demarche=1&energie=3&franceOuImport=1&puissanceAdministrative=2&typeVehicule=1";

  static Future<String> uploadFile({
    required File file,
    required String path,
    Uint8List? putDataWeb,
    SettableMetadata? settableMetadata,
  }) async {
    FirebaseStorage firebaseStorage = FirebaseStorage.instance;

    final destination = path;
    DateTime dateTime = DateTime.now();
    final ref = firebaseStorage
        .ref(destination)
        .child(dateTime.millisecondsSinceEpoch.toString());
    if (kIsWeb) {
      await ref.putData(putDataWeb!, settableMetadata);
    } else {
      await ref.putFile(File(file.path));
    }

    String url = (await ref.getDownloadURL()).toString();
    return url;
  }
}


// rest
// client cancel control
