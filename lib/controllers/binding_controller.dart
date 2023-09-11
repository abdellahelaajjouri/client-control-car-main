import 'package:client_control_car/constants/app_constant.dart';
import 'package:client_control_car/control_repository/api_client.dart';
import 'package:client_control_car/control_repository/auth_repo.dart';
import 'package:client_control_car/control_repository/chat_repo.dart';
import 'package:client_control_car/control_repository/control_repo.dart';
import 'package:client_control_car/control_repository/notification_repo.dart';
import 'package:client_control_car/controllers/auth_controller.dart';
import 'package:client_control_car/controllers/chat_controller.dart';
import 'package:client_control_car/controllers/control_controller.dart';
import 'package:client_control_car/controllers/notification_controller.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BindingController implements Bindings {
  @override
  void dependencies() async {
    final sharedPreferences = await SharedPreferences.getInstance();

    Get.put(
      sharedPreferences,
      permanent: true,
    );

    Get.put(
      ApiClient(
        appBaseUrl: AppConstant.BASE_URL,
        sharedPreferences: Get.find(),
      ),
      permanent: true,
    );

    // Repository
    Get.put(
      AuthRepo(
        apiClient: Get.find(),
        sharedPreferences: Get.find(),
      ),
      permanent: true,
    );

    Get.put(
      ControlRepo(
        apiClient: Get.find(),
        sharedPreferences: Get.find(),
      ),
      permanent: true,
    );
    Get.put(
      ChatRepo(
        apiClient: Get.find(),
        sharedPreferences: Get.find(),
      ),
      permanent: true,
    );

    Get.put(
      NotificationRepo(
        apiClient: Get.find(),
        sharedPreferences: Get.find(),
      ),
      permanent: true,
    );
    // Controller
    Get.put(
      AuthController(
        authRepo: Get.find(),
      ),
      permanent: true,
    );

    Get.put(
      ControlController(
        controlRepo: Get.find(),
      ),
      permanent: true,
    );

    Get.put(
      ChatController(
        chatRepo: Get.find(),
      ),
      permanent: true,
    );

    Get.put(
      NotificationControl(
        notificationRepo: Get.find(),
      ),
      permanent: true,
    );
  }
}
