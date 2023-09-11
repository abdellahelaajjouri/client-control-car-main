// ignore_for_file: non_constant_identifier_names

import 'package:client_control_car/models/user_model.dart';

class TechnicienModel {
  String? id;
  String? raison_social;
  UserModel? userModel;
  String? extrait_kbis;
  String? siret;
  String? numero_tva;
  String? location_x;
  String? location_y;
  String? photo;
  String? notation;
  String? city;
  String? is_disponible;
  String? type_technicien;
  String? user;
  String? garage;

  String? zone_address;
  String? zone_location_x;
  String? zone_location_y;
  String? rayon;

  TechnicienModel({
    this.id,
    this.raison_social,
    this.extrait_kbis,
    this.siret,
    this.numero_tva,
    this.location_x,
    this.location_y,
    this.photo,
    this.notation,
    this.city,
    this.is_disponible,
    this.type_technicien,
    this.user,
    this.garage,
    this.userModel,
    this.rayon,
    this.zone_address,
    this.zone_location_x,
    this.zone_location_y,
  });

  factory TechnicienModel.fromJson(Map<String, dynamic> json) {
    return TechnicienModel(
      id: json["id"].toString(),
      raison_social: json["raison_social"].toString(),
      extrait_kbis: json["extrait_kbis"].toString(),
      siret: json["siret"].toString(),
      numero_tva: json["numero_tva"].toString(),
      location_x: json["location_x"].toString(),
      location_y: json["location_y"].toString(),
      photo: json["photo"].toString(),
      notation: json["notation"].toString(),
      city: json["city"].toString(),
      is_disponible: json["is_disponible"].toString(),
      type_technicien: json["type_technicien"].toString(),
      user: json["user"].toString(),
      garage: json["garage"].toString(),
      userModel: UserModel.fromJson(json["user"]),
      rayon: json["rayon"].toString(),
      zone_address: json["zone_address"].toString(),
      zone_location_x: json["zone_location_x"].toString(),
      zone_location_y: json["zone_location_y"].toString(),
    );
  }

  @override
  String toString() {
    return "{id: $id ,${userModel!.first_name.toString()} }";
  }
}
