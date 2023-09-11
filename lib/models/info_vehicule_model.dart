// ignore_for_file: non_constant_identifier_names

class InfoVehiculeModel {
  String? id;
  String? lien_annonce;
  String? photo_ctrl_technique;
  String? photo_carte_grise;
  String? immatriculation;
  TypeVehicule? type_vehicule;
  MarqueVehicule? marque_vehicule;
  // String? marque_vehicule;
  // String? type_vehicule;

  InfoVehiculeModel({
    this.id,
    this.immatriculation,
    this.lien_annonce,
    this.marque_vehicule,
    this.photo_carte_grise,
    this.photo_ctrl_technique,
    this.type_vehicule,
  });

  factory InfoVehiculeModel.fromJson(Map<String, dynamic> json) {
    return InfoVehiculeModel(
      id: json['id'].toString(),
      immatriculation: json['immatriculation'].toString(),
      lien_annonce: json['lien_annonce'].toString(),
      photo_carte_grise: json['photo_carte_grise'].toString(),
      photo_ctrl_technique: json['photo_ctrl_technique'].toString(),
      type_vehicule: TypeVehicule.fromJson(json["type_vehicule"]),
      marque_vehicule: MarqueVehicule.fromJson(json["marque_vehicule"]),
    );
  }
}

class TypeVehicule {
  String? id;
  String? name_vehicule;
  String? icon_vehicule;

  TypeVehicule({
    this.id,
    this.name_vehicule,
    this.icon_vehicule,
  });

  factory TypeVehicule.fromJson(Map<String, dynamic> json) {
    return TypeVehicule(
      id: json["id"].toString(),
      name_vehicule: json["name_vehicule"].toString(),
      icon_vehicule: json["icon_vehicule"].toString(),
    );
  }
}

class MarqueVehicule {
  String? id;
  String? name_marque;
  String? icon_marque;
  String? type_vehicule;

  MarqueVehicule({
    this.id,
    this.name_marque,
    this.icon_marque,
    this.type_vehicule,
  });

  factory MarqueVehicule.fromJson(Map<String, dynamic> json) {
    return MarqueVehicule(
      id: json["id"].toString(),
      name_marque: json["name_marque"].toString(),
      icon_marque: json["icon_marque"].toString(),
      type_vehicule: json["type_vehicule"].toString(),
    );
  }
}
