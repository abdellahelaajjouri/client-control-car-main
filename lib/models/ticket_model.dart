// ignore_for_file: non_constant_identifier_names

import 'package:client_control_car/models/user_model.dart';

class TicketModel {
  String? id;
  String? nom;
  String? prenom;
  String? status;
  String? ticket_number;
  String? email;
  String? is_read;
  String? create_date;
  UserModel? user;
  List<Conversation>? conversation;

  TicketModel({
    this.conversation,
    this.email,
    this.id,
    this.nom,
    this.prenom,
    this.status,
    this.ticket_number,
    this.user,
    this.create_date,
    this.is_read,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      id: json["id"].toString(),
      email: json["email"].toString(),
      nom: json["nom"].toString(),
      prenom: json["prenom"].toString(),
      status: json["status"].toString(),
      create_date: json["create_date"].toString(),
      is_read: json["is_read"].toString(),
      ticket_number: json["ticket_number"].toString(),
      conversation: json["conversation"] == null ||
              json["conversation"].toString() == "[]"
          ? []
          : json["conversation"]
              .map<Conversation>((j) => Conversation.fromJson(j))
              .toList(),
      user: UserModel.fromJson(json["user"]),
    );
  }
}

class Conversation {
  String? sender;
  String? message;

  Conversation({this.message, this.sender});

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      message: json["message"].toString(),
      sender: json["sender"].toString(),
    );
  }
}
