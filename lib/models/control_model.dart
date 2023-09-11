// ignore_for_file: non_constant_identifier_names

import 'package:client_control_car/models/info_vehicule_model.dart';
import 'package:client_control_car/models/plan_model.dart';
import 'package:client_control_car/models/technicien_model.dart';

class ControlModel {
  String? id;
  PlanModel? plan;
  InfoVehiculeModel? infoVehicule;
  List<ControlTechniciens>? listControlTechniciens;
  RendezVousModel? rendez_vous;
  // String? info_perso;
  InfoPresoModel? info_perso;
  List<String>? listTechniciens;
  DiagnosticModel? diagnostic;
  ReviewModel? reviewModel;
  String? status;

  String? diagnostic_available;
  String? diagnostic_motif;
  String? create_date;
  String? is_paid;
  String? accepted_by;
  String? price;

  ControlModel({
    this.id,
    this.infoVehicule,
    this.info_perso,
    this.listControlTechniciens,
    this.listTechniciens,
    this.plan,
    this.rendez_vous,
    this.status,
    this.diagnostic,
    this.reviewModel,
    this.accepted_by,
    this.create_date,
    this.diagnostic_available,
    this.diagnostic_motif,
    this.is_paid,
    this.price,
  });

  factory ControlModel.fromJson(Map<String, dynamic> json) {
    return ControlModel(
      id: json['id'].toString(),
      plan: PlanModel.fromJson(json['plan']),
      infoVehicule: InfoVehiculeModel.fromJson(json['info_vehicule']),
      rendez_vous: RendezVousModel.fromJson(json['rendez_vous']),
      status: json['status'].toString(),
      info_perso: InfoPresoModel.fromJson(json["info_perso"]),
      listControlTechniciens: json["controltechniciens"]
          .map<ControlTechniciens>((j) => ControlTechniciens.fromJson(j))
          .toList(),
      diagnostic: json["diagnostic"].toString() == "{}"
          ? null
          : DiagnosticModel.fromJson(json["diagnostic"]),
      reviewModel: json["avis"].toString() == "{}"
          ? null
          : ReviewModel.fromJson(json["avis"]),
      diagnostic_available: json['diagnostic_available'].toString(),
      diagnostic_motif: json['diagnostic_motif'].toString(),
      create_date: json['create_date'].toString(),
      is_paid: json['is_paid'].toString(),
      accepted_by: json['accepted_by'].toString(),
      price: json['price'].toString(),
      // listTechniciens:
      //     List<String>.from(jsonDecode(json["techniciens"].toString())),
    );
  }
}

class RendezVousModel {
  String? id;
  String? date;
  String? time;

  RendezVousModel({
    this.date,
    this.id,
    this.time,
  });

  factory RendezVousModel.fromJson(Map<String, dynamic> json) {
    return RendezVousModel(
      id: json['id'].toString(),
      date: json['date'].toString(),
      time: json['time'].toString(),
    );
  }
}

class ControlTechniciens {
  String? id;
  String? date_accpeted;
  String? accepted;
  String? technicien;
  String? demandecontrol;
  TechnicienModel? technicienModel;

  ControlTechniciens({
    this.accepted,
    this.date_accpeted,
    this.demandecontrol,
    this.id,
    this.technicien,
    this.technicienModel,
  });

  factory ControlTechniciens.fromJson(Map<String, dynamic> json) {
    return ControlTechniciens(
      id: json['id'].toString(),
      date_accpeted: json['date_accpeted'].toString(),
      accepted: json['accepted'].toString(),
      technicien: json['technicien'].toString(),
      demandecontrol: json['demandecontrol'].toString(),
      technicienModel: TechnicienModel.fromJson(json['technicien']),
    );
  }
}

class ReviewModel {
  String? id;
  String? client;
  String? technicien;
  String? notation;
  String? comment;
  String? create_date;
  String? update_date;
  String? control;

  ReviewModel({
    this.id,
    this.client,
    this.technicien,
    this.notation,
    this.comment,
    this.create_date,
    this.update_date,
    this.control,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json["id"].toString(),
      client: json["client"].toString(),
      technicien: json["technicien"].toString(),
      notation: json["notation"].toString(),
      comment: json["comment"].toString(),
      create_date: json["create_date"].toString(),
      update_date: json["update_date"].toString(),
      control: json["control"].toString(),
    );
  }

  @override
  String toString() {
    return "{$id, $client, $comment}";
  }
}

class DiagnosticModel {
  String? id;
  String? diagnostic;
  String? favorable;
  String? create_date;
  String? demande_control;

  DiagnosticModel({
    this.id,
    this.diagnostic,
    this.demande_control,
    this.create_date,
    this.favorable,
  });

  factory DiagnosticModel.fromJson(Map<String, dynamic> json) {
    return DiagnosticModel(
      id: json["id"].toString(),
      diagnostic: json["diagnostic"].toString(),
      create_date: json["create_date"].toString(),
      demande_control: json["demande_control"].toString(),
      favorable: json["favorable"].toString(),
    );
  }

  @override
  String toString() {
    return "{id: $id, diagno: $diagnostic}";
  }
}

class DiagnoItem {
  String? title;
  String? etat;
  List<String>? images;
  String? comment;
  String? id;

  DiagnoItem({
    this.title,
    this.etat,
    this.comment,
    this.images,
    this.id,
  });

  factory DiagnoItem.fromString({required String diagn, String? id}) {
    List<String> listAr = diagn.split('|');
    return DiagnoItem(
      title: listAr[0].toString(),
      etat: listAr[1].toString(),
      comment: listAr[2].toString(),
      images: listAr[3].toString().split(','),
      id: id.toString(),
    );
  }
}

class InfoPresoModel {
  String? id;
  String? present_ctrl;
  String? demande_particuliere;
  String? addresse;
  String? ville;
  String? code_postal;
  String? batiment;

  InfoPresoModel({
    this.id,
    this.addresse,
    this.batiment,
    this.code_postal,
    this.demande_particuliere,
    this.present_ctrl,
    this.ville,
  });

  factory InfoPresoModel.fromJson(Map<String, dynamic> json) {
    return InfoPresoModel(
      id: json['id'].toString(),
      addresse: json['addresse'].toString(),
      batiment: json['batiment'].toString(),
      code_postal: json['code_postal'].toString(),
      demande_particuliere: json['demande_particuliere'].toString(),
      present_ctrl: json['present_ctrl'].toString(),
      ville: json['ville'].toString(),
    );
  }
}
