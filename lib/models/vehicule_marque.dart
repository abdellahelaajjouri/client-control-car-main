// ignore_for_file: non_constant_identifier_names

class VehiculeMarque {
  String? id;
  String? name_marque;
  String? icon_marque;
  String? type_vehicule;

  VehiculeMarque({
    this.id,
    this.name_marque,
    this.icon_marque,
    this.type_vehicule,
  });

  factory VehiculeMarque.fromJson(Map<String, dynamic> json) {
    return VehiculeMarque(
      id: json["id"].toString(),
      name_marque: json["name_marque"].toString(),
      icon_marque: json["icon_marque"].toString(),
      type_vehicule: json["type_vehicule"].toString(),
    );
  }

  @override
  String toString() {
    return "{id: $id, name: $name_marque}";
  }
}
