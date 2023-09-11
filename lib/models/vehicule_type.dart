// ignore_for_file: non_constant_identifier_names

class VehiculeType {
  String? id;
  String? name_vehicule;
  String? icon_vehicule;

  VehiculeType({
    this.id,
    this.name_vehicule,
    this.icon_vehicule,
  });

  factory VehiculeType.fromJson(Map<String, dynamic> json) {
    return VehiculeType(
      id: json["id"].toString(),
      name_vehicule: json["name_vehicule"].toString(),
      icon_vehicule: json["icon_vehicule"].toString(),
    );
  }

  @override
  String toString() {
    return "{id: $id, name: $name_vehicule}";
  }
}
