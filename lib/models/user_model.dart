// ignore_for_file: non_constant_identifier_names

class UserModel {
  String? id;
  String? email;
  String? first_name;
  String? last_name;
  String? address;
  String? phone;
  String? city;
  String? code_postal;
  String? location_x;
  String? location_y;
  String? is_active;
  String? otp;
  String? fb_token;
  String? role;
  String? access;
  String? photo;

  UserModel({
    this.id,
    this.email,
    this.first_name,
    this.last_name,
    this.address,
    this.phone,
    this.city,
    this.code_postal,
    this.location_x,
    this.location_y,
    this.is_active,
    this.otp,
    this.fb_token,
    this.role,
    this.access,
    this.photo,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'].toString(),
      email: json['email'].toString(),
      first_name: json['nom'].toString(),
      last_name: json['prenom'].toString(),
      address: json['address'].toString(),
      phone: json['phone'].toString(),
      city: json['city'].toString(),
      code_postal: json['code_postal'].toString(),
      location_x: json['location_x'].toString(),
      location_y: json['location_y'].toString(),
      is_active: json['is_active'].toString(),
      otp: json['otp'].toString(),
      fb_token: json['fb_token'].toString(),
      role: json['role'].toString(),
      access: json['access'].toString(),
      photo: json['photo'].toString(),
    );
  }

  factory UserModel.fromJsonProf(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'].toString(),
      email: UserInfo.fromJson(json["user"]).email ?? "",
      first_name: UserInfo.fromJson(json["user"]).nom ?? "",
      last_name: UserInfo.fromJson(json["user"]).prenom ?? "",
      address: json['address'].toString(),
      phone: UserInfo.fromJson(json["user"]).phone ?? "",
      city: json['ville'].toString(),
      code_postal: json['code_postal'].toString(),
      location_x: json['location_x'].toString(),
      location_y: json['location_y'].toString(),
      is_active: json['is_active'].toString(),
      otp: json['otp'].toString(),
      fb_token: json['fb_token'].toString(),
      role: UserInfo.fromJson(json["user"]).role ?? "",
      photo: UserInfo.fromJson(json["user"]).photo ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['email'] = email;
    data['nom'] = first_name;
    data['prenom'] = last_name;
    data['address'] = address;
    data['phone'] = phone;
    data['city'] = city;
    data['code_postal'] = code_postal;
    data['location_x'] = location_x;
    data['location_y'] = location_y;
    data['is_active'] = is_active;
    data['otp'] = otp;
    data['fb_token'] = fb_token;
    data['role'] = role;
    data['access'] = access;
    data['photo'] = photo;
    return data;
  }

  @override
  String toString() {
    return '{id: $id, email: $email}';
  }
}

class UserInfo {
  String? phone;
  String? username;
  String? role;
  String? email;
  String? nom;
  String? prenom;
  String? photo;

  UserInfo({
    this.email,
    this.nom,
    this.phone,
    this.photo,
    this.prenom,
    this.role,
    this.username,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      nom: json["nom"].toString(),
      prenom: json["prenom"].toString(),
      email: json["email"].toString(),
      phone: json["phone"].toString(),
      photo: json["photo"].toString(),
      role: json["role"].toString(),
      username: json["username"].toString(),
    );
  }
}
