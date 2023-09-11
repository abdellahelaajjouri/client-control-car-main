import 'package:client_control_car/constants/app_constant.dart';
import 'package:client_control_car/control_repository/api_client.dart';
import 'package:client_control_car/controllers/auth_controller.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationRepo {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  NotificationRepo({required this.apiClient, required this.sharedPreferences});

  //
  Future<Response> getAllNotificationRepo(
      {bool isvuupdate = false, required int page}) async {
    AuthController authController = Get.find();

    return await apiClient.getData(
      isvuupdate
          ? "${AppConstant.NOTIFICATION_URL}?isvuupdate=update&page=$page"
          : "${AppConstant.NOTIFICATION_URL}?page=$page",
      headers: {
        'Content-Type': 'application/json;charset=UTF-8',
        'Authorization':
            'Bearer ${authController.userModel!.access ?? authController.accessUserJWS}',
      },
    );
  }
}
