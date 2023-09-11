import 'package:client_control_car/control_repository/notification_repo.dart';
import 'package:client_control_car/models/errors/response_model.dart';
import 'package:client_control_car/models/notification_model.dart';
import 'package:get/get.dart';

class NotificationControl extends GetxController implements GetxService {
  NotificationRepo notificationRepo;
  NotificationControl({required this.notificationRepo});

  List<NotificationModel> listNotification = [];

  int maxPage = 1;
  int currentPage = 1;

  Future<ResponseModel> getAllNotificationController(
      {bool isvuupdate = false, int page = 1}) async {
    Response response = await notificationRepo.getAllNotificationRepo(
        isvuupdate: isvuupdate, page: page);

    ResponseModel responseModel;

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (page == 1) {
        listNotification = [];
        update();
        listNotification = response.body["notifications"]
            .map<NotificationModel>(
                (model) => NotificationModel.fromJson(model))
            .toList();
      } else {
        listNotification.addAll(response.body["notifications"]
            .map<NotificationModel>(
                (model) => NotificationModel.fromJson(model))
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
}
