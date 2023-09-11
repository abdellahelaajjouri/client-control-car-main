class PlanModel {
  String? id;
  String? name;
  String? prix;
  String? description;
  String? options;

  PlanModel({
    this.id,
    this.name,
    this.prix,
    this.description,
    this.options,
  });

  factory PlanModel.fromJson(Map<String, dynamic> json) {
    return PlanModel(
      id: json["id"].toString(),
      name: json["name"].toString(),
      prix: json["prix"].toString(),
      description: json["description"].toString(),
      options: json["options"].toString(),
    );
  }
}
