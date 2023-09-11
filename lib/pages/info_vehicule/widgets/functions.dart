import 'package:client_control_car/models/vehicule_marque.dart';

List<VehiculeMarque> getListMarqueVehiculeByType(
    {required List<VehiculeMarque> listVehiculeMarque,
    required String typeVehicule}) {
  List<VehiculeMarque> list = [];

  for (var element in listVehiculeMarque) {
    if (element.type_vehicule == typeVehicule) {
      list.add(element);
    }
  }
  return list;
}
