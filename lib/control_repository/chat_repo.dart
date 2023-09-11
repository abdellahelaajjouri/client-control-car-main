import 'package:client_control_car/constants/app_constant.dart';
import 'package:client_control_car/control_repository/api_client.dart';
import 'package:client_control_car/controllers/auth_controller.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatRepo {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;

  ChatRepo({required this.apiClient, required this.sharedPreferences});

  Future<Response> addFromToListMessages(
      {required String userId, required String message}) async {
    AuthController authController = Get.find();
    return await apiClient.postData(
      AppConstant.TECHNO_MESSAGES + userId,
      {
        "message": message,
      },
      headers: {
        'Content-Type': 'application/json;charset=UTF-8',
        'Authorization': 'Bearer ${authController.userModel!.access}',
      },
    );
  }

  // get  messages last
  Future<Response> getLastMessagesRepo() async {
    AuthController authController = Get.find();
    return await apiClient.getData(
      AppConstant.TECHNO_LAST_MESSAGES,
      headers: {
        'Content-Type': 'application/json;charset=UTF-8',
        'Authorization': 'Bearer ${authController.userModel!.access}',
      },
    );
  }

  // get  messages
  Future<Response> getMessagesRepo({required String userId}) async {
    AuthController authController = Get.find();
    return await apiClient.getData(
      AppConstant.TECHNO_MESSAGES + userId,
      headers: {
        'Content-Type': 'application/json;charset=UTF-8',
        'Authorization': 'Bearer ${authController.userModel!.access}',
      },
    );
  }

  // send message to assistance
  Future<Response> sendContactAssistance(
      {required String nom,
      required String prenom,
      required String email,
      required String message}) async {
    AuthController authController = Get.find();
    return await apiClient.postData(
      AppConstant.CONTACT_ASSISTANCE,
      {
        "nom": nom,
        "prenom": prenom,
        "email": email,
        "conversation": [
          {
            "sender": "user",
            "message": message,
          }
        ],
        "message": message,
      },
      headers: {
        'Content-Type': 'application/json;charset=UTF-8',
        'Authorization': 'Bearer ${authController.userModel!.access}',
      },
    );
  }

  // get list tickets
  Future<Response> getListTickets() async {
    AuthController authController = Get.find();
    return await apiClient.getData(
      AppConstant.CONTACT_ASSISTANCE,
      headers: {
        'Content-Type': 'application/json;charset=UTF-8',
        'Authorization': 'Bearer ${authController.userModel!.access}',
      },
    );
  }

  // get detail ticket
  Future<Response> getDetailTicket({required String idTicket}) async {
    AuthController authController = Get.find();

    return await apiClient.getData(
      "${AppConstant.CONTACT_ASSISTANCE}$idTicket",
      headers: {
        'Content-Type': 'application/json;charset=UTF-8',
        'Authorization': 'Bearer ${authController.userModel!.access}',
      },
    );
  }
}
