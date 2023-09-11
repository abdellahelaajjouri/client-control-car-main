// ignore_for_file: non_constant_identifier_names

class UserChat {
  String? id;
  String? phone;
  String? username;
  String? role;
  String? email;
  String? nom;
  String? prenom;
  String? photo;

  UserChat({
    this.id,
    this.phone,
    this.username,
    this.role,
    this.email,
    this.nom,
    this.prenom,
    this.photo,
  });

  factory UserChat.fromJson(Map<String, dynamic> json) {
    return UserChat(
      id: json["id"].toString(),
      phone: json["phone"].toString(),
      username: json["username"].toString(),
      role: json["role"].toString(),
      email: json["email"].toString(),
      nom: json["nom"].toString(),
      prenom: json["prenom"].toString(),
      photo: json["photo"].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['phone'] = phone;
    data['username'] = username;
    data['role'] = role;
    data['email'] = email;
    data['nom'] = nom;
    data['prenom'] = prenom;
    data['photo'] = photo;
    return data;
  }
}

class MessageChat {
  String? sender;
  String? receiver;
  String? message;
  String? timestamp;
  String? is_read;

  MessageChat({
    this.sender,
    this.message,
    this.receiver,
    this.timestamp,
    this.is_read,
  });

  factory MessageChat.fromJson(Map<String, dynamic> json) {
    return MessageChat(
      sender: json["sender"].toString(),
      receiver: json["receiver"].toString(),
      message: json["message"].toString(),
      timestamp: json["timestamp"].toString(),
      is_read: json["is_read"].toString(),
    );
  }
}

class LastMessagesModel {
  UserChat? user;
  MessageChat? messageChat;

  LastMessagesModel({
    this.user,
    this.messageChat,
  });

  factory LastMessagesModel.fromJson(Map<String, dynamic> json) {
    return LastMessagesModel(
      user: UserChat.fromJson(json["user"]),
      messageChat: MessageChat.fromJson(json["message"]),
    );
  }
}
