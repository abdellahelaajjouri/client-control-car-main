class CardBankModel {
  String? id;
  String? numberCard;
  String? monthCard;
  String? yearCard;
  String? cvvCard;
  String? namUser;
  String? image;

  CardBankModel(
      {this.id,
      this.numberCard,
      this.monthCard,
      this.yearCard,
      this.cvvCard,
      this.namUser,
      this.image});

  Map<String, String> toJsonString() {
    final Map<String, String> data = <String, String>{};

    data["id"] = id.toString();
    data["numberCard"] = numberCard.toString();
    data["monthCard"] = monthCard.toString();
    data["yearCard"] = yearCard.toString();
    data["cvvCard"] = cvvCard.toString();
    data["namUser"] = namUser.toString();
    data["image"] = image.toString();

    return data;
  }

  factory CardBankModel.fromJson(Map<String, dynamic> json) {
    return CardBankModel(
      id: json["id"].toString(),
      numberCard: json["numberCard"].toString(),
      monthCard: json["monthCard"].toString(),
      yearCard: json["yearCard"].toString(),
      cvvCard: json["cvvCard"].toString(),
      namUser: json["namUser"].toString(),
      image: json["image"].toString(),
    );
  }
}
