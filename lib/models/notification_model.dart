// ignore_for_file: non_constant_identifier_names

import 'package:client_control_car/models/control_model.dart';

class NotificationModel {
  String? id;
  String? title;
  String? body;
  String? type;
  String? icon;
  String? create_date;
  String? demande_control;
  ControlModel? demandecontrol;
  String? isvu;

  NotificationModel({
    this.id,
    this.body,
    this.title,
    this.create_date,
    this.demande_control,
    this.icon,
    this.demandecontrol,
    this.type,
    this.isvu,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json["id"].toString(),
      body: json["body"].toString(),
      title: json["title"].toString(),
      icon: json["icon"].toString(),
      type: json["_type"].toString(),
      create_date: json["create_date"].toString(),
      demande_control: json["demande_control"].toString(),
      isvu: json["isvu"].toString(),
      demandecontrol: json["demande_control"].toString().toLowerCase() != "null"
          ? ControlModel.fromJson(json["demandecontrol"])
          : null,
    );
  }

  @override
  String toString() {
    return "{id: $id, body: $body, control: $demande_control}";
  }
}
