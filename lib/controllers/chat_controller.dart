import 'package:client_control_car/control_repository/chat_repo.dart';
import 'package:client_control_car/models/errors/response_model.dart';
import 'package:client_control_car/models/last_messages_model.dart';
import 'package:client_control_car/models/ticket_model.dart';
import 'package:get/get.dart';

class ChatController extends GetxController implements GetxService {
  ChatRepo chatRepo;
  ChatController({required this.chatRepo});

  List<LastMessagesModel> listLastMessages = [];
  List<MessageChat> listMessages = [];

  List<TicketModel> listTickets = [];

  TicketModel? detailTicketModel;

  int maxPageTicket = 1;
  int currentPageTicket = 1;

  Future<ResponseModel> addFromToListMessages(
      {required String userId, required String message}) async {
    Response response =
        await chatRepo.addFromToListMessages(userId: userId, message: message);
    //
    ResponseModel responseModel;

    if (response.statusCode == 200) {
      // response.body["appareils"].toString();
      update();
      // listAppariel=AppareilModel.fromJson(response.body["appareils"]);
      responseModel = ResponseModel(true, response.body.toString());
    } else {
      responseModel = ResponseModel(false, response.body.toString());
    }
    update();
    return responseModel;
  }

// get list messages
  Future<ResponseModel> getListMessagesController(
      {required String userId}) async {
    Response response = await chatRepo.getMessagesRepo(userId: userId);
    // listControlModel = [];
    ResponseModel responseModel;
    Future.delayed(Duration.zero, () {
      update();
    });
    if (response.statusCode == 200 || response.statusCode == 201) {
      try {
        listMessages = response.body
            .map<MessageChat>((model) => MessageChat.fromJson(model))
            .toList();
        listMessages.reversed;
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

  // getLastMessagesController
  Future<ResponseModel> getLastMessagesController() async {
    Response response = await chatRepo.getLastMessagesRepo();
    // listControlModel = [];
    ResponseModel responseModel;

    if (response.statusCode == 200 || response.statusCode == 201) {
      try {
        listLastMessages = response.body
            .map<LastMessagesModel>(
                (model) => LastMessagesModel.fromJson(model))
            .toList();

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

  // contact with assistance admin
  Future<ResponseModel> sendContactAssistance(
      {required String nom,
      required String prenom,
      required String email,
      required String message}) async {
    Response response = await chatRepo.sendContactAssistance(
        nom: nom, prenom: prenom, email: email, message: message);
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

  // get list tickets
  Future<ResponseModel> getListTeckets({required int page}) async {
    Response response = await chatRepo.getListTickets();
    ResponseModel responseModel;

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (page == 1) {
        listTickets = response.body["tickets"]
            .map<TicketModel>((model) => TicketModel.fromJson(model))
            .toList();
      } else {
        listTickets.addAll(response.body["tickets"]
            .map<TicketModel>((model) => TicketModel.fromJson(model))
            .toList());
      }
      maxPageTicket = int.parse(response.body["pages"].toString());
      currentPageTicket = int.parse(response.body["page"].toString());
      responseModel = ResponseModel(true, response.body.toString());
      update();
    } else {
      responseModel = ResponseModel(false, response.body.toString());
      update();
    }
    update();
    return responseModel;
  }

  // get list tickets
  Future<ResponseModel> getDetailTecket({required String idTicket}) async {
    Response response = await chatRepo.getDetailTicket(idTicket: idTicket);
    ResponseModel responseModel;

    if (response.statusCode == 200 || response.statusCode == 201) {
      detailTicketModel = TicketModel.fromJson(response.body["ticket"]);

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
