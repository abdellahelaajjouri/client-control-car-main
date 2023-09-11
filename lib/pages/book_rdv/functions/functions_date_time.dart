import 'package:client_control_car/constants/app_constant.dart';
import 'package:client_control_car/constants/constants.dart';
import 'package:client_control_car/controllers/control_controller.dart';
import 'package:client_control_car/models/vehicule_marque.dart';
import 'package:client_control_car/models/vehicule_type.dart';
import 'package:client_control_car/pages/info_vehicule/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

List<DateTime> listDate({int nbrDays = 60}) {
  List<DateTime> list = [];

  for (var i = 1; i < nbrDays; i++) {
    list.add(DateTime.now().add(Duration(days: i)));
  }

  return list;
}

Widget getStart({required int start, bool isCheck = false, double? size}) {
  List<Widget> listPlan = [];
  List<Widget> listNull = [];
  for (var i = 0; i < start; i++) {
    listPlan.add(
      Icon(
        Icons.star,
        color: isCheck ? Colors.white : blueColor,
        size: size,
      ),
    );
  }

  for (var i = 0; i < 5 - start; i++) {
    listNull.add(
      Icon(
        Icons.star_border,
        color: isCheck ? Colors.white : normalText,
        size: size,
      ),
    );
  }

  return Row(
    children: [
      for (var item in listPlan) item,
      for (var item in listNull) item,
    ],
  );
}

String getTimeAdd({required String time, required String date}) {
  String start =
      DateFormat("HH:mm", 'fr').format(DateTime.parse('$date $time'));
  String end = DateFormat("HH:mm", 'fr')
      .format(DateTime.parse('$date $time').add(const Duration(hours: 1)));

  return "$start - $end";
}

String getTypeMarque(
    {required ControlController controlController,
    required String type,
    required String marque}) {
  String test = "";
  for (var element in controlController.listVehiculeType) {
    if (element.id == type) {
      test = element.name_vehicule.toString();
    }
  }
  if (test != "") {
    test += " - ";
  }
  for (var element in controlController.listVehiculeMarque) {
    if (element.id == marque) {
      test += element.name_marque.toString();
    }
  }
  return test;
}

Widget getVehiculeType(
    {required ControlController controlController, required String type}) {
  VehiculeType? vehiculeType;
  for (var element in controlController.listVehiculeType) {
    if (element.id == type) {
      vehiculeType = element;
    }
  }
  if (vehiculeType != null) {
    return InkWell(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        constraints: const BoxConstraints(
          minWidth: 100,
        ),
        decoration: BoxDecoration(
            color: blueColor, borderRadius: BorderRadius.circular(8)),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // logo
              // Image.network(
              //   vehiculeType.icon_vehicule.toString(),
              //   color: Colors.white,
              //   scale: 1.2,
              // ),
              // if (vehiculeType.icon_vehicule.toString().contains('.svg'))
              //   SvgPicture.asset(
              //     "assets/icons/type/${vehiculeType.icon_vehicule}",
              //     color: Colors.white,
              //     width: 30,
              //     height: 30,
              //   )
              // else
              CustomImage(
                image: AppConstant.BASE_File_URL +
                    vehiculeType.icon_vehicule.toString(),
                width: 60,
                height: 30,
                fit: BoxFit.contain,
                color: Colors.white,
              ),

              const SizedBox(
                height: 10,
              ),
              // name
              Text(
                vehiculeType.name_vehicule.toString(),
                style: gothicBold.copyWith(color: Colors.white),
              )
            ]),
      ),
    );
  } else {
    return Container();
  }
}

Widget getVehiculeMarque(
    {required ControlController controlController, required String marque}) {
  VehiculeMarque? vehiculeMarque;
  for (var element in controlController.listVehiculeMarque) {
    if (element.id == marque) {
      vehiculeMarque = element;
    }
  }

  if (vehiculeMarque != null) {
    return InkWell(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        constraints: const BoxConstraints(
          minWidth: 100,
        ),
        decoration: BoxDecoration(
          color: blueColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // logo
              CustomImage(
                image: AppConstant.BASE_File_URL +
                    vehiculeMarque.icon_marque.toString(),
                width: 60,
                height: 30,
                fit: BoxFit.contain,
                color: Colors.white,
              ),
              const SizedBox(
                height: 10,
              ),
              // name
              Text(
                vehiculeMarque.name_marque.toString(),
                style: gothicBold.copyWith(color: Colors.white),
              )
            ]),
      ),
    );
  } else {
    return Container();
  }
}

String getStatusControlByIndex({required String status}) {
  if (status == "1") {
    return "En Attente";
  } else if (status == "2") {
    return "Acceptée";
  } else if (status == "3") {
    return "Arrivé";
  } else if (status == "4") {
    return "Diagnostic Impossible";
  } else if (status == "5") {
    return "En Cours";
  } else if (status == "6") {
    return "Resultat";
  } else if (status == "7") {
    return "Fini";
  } else if (status == "8") {
    return "Annulée";
  } else {
    return "En suspens";
  }
}

Color getColorControlByPart({required String status, required int partie}) {
  if (partie == 1) {
    if (status == "DONE") {
      return blueColor;
    } else {
      return const Color(0xffDDDBDB);
    }
  } else {
    // return getColorinitial(status: status);
    if (status == "DONE") {
      return blueColor;
    } else if (status == "ARRIVED") {
      return greenColor;
    } else if (status == "CANCLED") {
      return greenColor;
    } else {
      return const Color(0xffDDDBDB);
    }
  }
}

Color getColorinitial({required String status}) {
  if (status == "1") {
    return const Color(0xffF57A0F).withOpacity(.5);
  } else if (["2", "3", "5"].contains(status)) {
    return const Color(0xff1FE179).withOpacity(.5);
  } else if (["6", "7"].contains(status)) {
    return blueColor;
  } else {
    return const Color(0xffE3E2E2).withOpacity(.2);
  }
}

String getIdControlFormat({required String id}) {
  if (id.length >= 5) {
    return id;
  } else {
    String tst = "";
    for (var i = 0; i < 5 - id.length; i++) {
      tst += "0";
    }
    tst += id;
    return tst;
  }
}
