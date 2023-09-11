// ignore_for_file: non_constant_identifier_names

class ProfilInfoModel {
  String? id;
  ProfilUserModel? profilUserModel;
  String? raison_social;
  String? extrait_kbis;
  String? siret;
  String? address;
  String? ville;
  String? code_postal;
  String? numero_tva;
  String? location_x;
  String? location_y;
  String? create_date;
  String? update_date;
  String? rayon;
  String? notation;

  ProfilInfoModel({
    this.id,
    this.address,
    this.code_postal,
    this.create_date,
    this.extrait_kbis,
    this.location_x,
    this.location_y,
    this.numero_tva,
    this.profilUserModel,
    this.raison_social,
    this.siret,
    this.update_date,
    this.ville,
    this.rayon,
    this.notation,
  });

  factory ProfilInfoModel.fromJson(Map<String, dynamic> json) {
    return ProfilInfoModel(
      id: json["id"].toString(),
      profilUserModel: ProfilUserModel.fromJson(json["user"]),
      raison_social: json["raison_social"].toString(),
      extrait_kbis: json["extrait_kbis"].toString(),
      siret: json["siret"].toString(),
      address: json["address"].toString(),
      ville: json["ville"].toString(),
      code_postal: json["code_postal"].toString(),
      numero_tva: json["numero_tva"].toString(),
      location_x: json["location_x"].toString(),
      location_y: json["location_y"].toString(),
      create_date: json["create_date"].toString(),
      update_date: json["update_date"].toString(),
      rayon: json["rayon"].toString(),
      notation: json["notation"].toString(),
    );
  }

  @override
  String toString() {
    return "{id: $id}";
  }
}

class ProfilUserModel {
  String? id;
  String? phone;
  String? rib;
  String? role;
  String? email;
  String? nom;
  String? prenom;
  String? photo;
  String? is_active;
  String? code_parraine;
  String? code_parrainage;
  String? token_fb;

  ProfilUserModel({
    this.code_parrainage,
    this.code_parraine,
    this.email,
    this.id,
    this.is_active,
    this.nom,
    this.phone,
    this.photo,
    this.prenom,
    this.rib,
    this.role,
    this.token_fb,
  });

  factory ProfilUserModel.fromJson(Map<String, dynamic> json) {
    return ProfilUserModel(
      id: json["id"].toString(),
      code_parrainage: json["code_parrainage"].toString(),
      code_parraine: json["code_parraine"].toString(),
      email: json["email"].toString(),
      is_active: json["is_active"].toString(),
      nom: json["nom"].toString(),
      prenom: json["prenom"].toString(),
      photo: json["photo"].toString(),
      phone: json["phone"].toString(),
      rib: json["rib"].toString(),
      role: json["role"].toString(),
      token_fb: json["token_fb"].toString(),
    );
  }

  @override
  String toString() {
    return "{id: $id}";
  }
}
