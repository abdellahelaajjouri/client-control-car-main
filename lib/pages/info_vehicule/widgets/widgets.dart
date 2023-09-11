import 'package:cached_network_image/cached_network_image.dart';
import 'package:client_control_car/constants/app_constant.dart';
import 'package:client_control_car/constants/constants.dart';
import 'package:client_control_car/models/vehicule_marque.dart';
import 'package:client_control_car/models/vehicule_type.dart';
import 'package:flutter/material.dart';

Widget typeVehiculeItems(
    {required VehiculeType typeItem,
    Function()? onTap,
    required String typeVehicule}) {
  return InkWell(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      constraints: const BoxConstraints(
        minWidth: 100,
      ),
      decoration: BoxDecoration(
          color: typeVehicule == typeItem.id.toString() ? blueColor : greyColor,
          borderRadius: BorderRadius.circular(8)),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomImage(
              image:
                  AppConstant.BASE_File_URL + typeItem.icon_vehicule.toString(),
              width: 60,
              height: 30,
              fit: BoxFit.contain,
              // color: typeVehicule == typeItem.id.toString()
              //     ? Colors.white
              //     : Colors.black,
            ),
            const SizedBox(
              height: 10,
            ),
            // name
            Text(
              typeItem.name_vehicule.toString(),
              style: gothicBold.copyWith(
                  color: typeVehicule == typeItem.id.toString()
                      ? Colors.white
                      : Colors.black),
            )
          ]),
    ),
  );
}

Widget marqueVehiculeItems(
    {Function()? onTap,
    required VehiculeMarque marqueItem,
    required String marqueVehicule}) {
  return InkWell(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      constraints: const BoxConstraints(
        minWidth: 100,
      ),
      decoration: BoxDecoration(
        color:
            marqueVehicule == marqueItem.id.toString() ? blueColor : greyColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // logo
            CustomImage(
              image:
                  AppConstant.BASE_File_URL + marqueItem.icon_marque.toString(),
              width: 60,
              height: 30,
              fit: BoxFit.contain,
              // color: marqueVehicule == marqueItem.id.toString()
              //     ? Colors.white
              //     : Colors.black,
            ),
            // Image.asset(
            //   "assets/icons/pngkit_burning-money-png_1081786.png",
            //   color: marqueVehicule == marqueItem.id.toString()
            //       ? Colors.white
            //       : Colors.black,
            //   scale: 1.2,
            // ),
            const SizedBox(
              height: 10,
            ),
            // name
            Text(
              marqueItem.name_marque.toString(),
              style: gothicBold.copyWith(
                  color: marqueVehicule == marqueItem.id.toString()
                      ? Colors.white
                      : Colors.black),
            )
          ]),
    ),
  );
}

class CustomImageCircle extends StatelessWidget {
  final String image;
  final double height;
  final double width;
  final BoxFit fit;
  final String placeholder;

  const CustomImageCircle(
      {super.key,
      required this.image,
      this.height = 30,
      this.width = 30,
      this.fit = BoxFit.cover,
      this.placeholder = "assets/images/placeholder.jpg"});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(width / 2),
      child: CachedNetworkImage(
        imageUrl: image,
        height: height,
        width: width,
        fit: fit,
        placeholder: (context, url) => Image.asset(
            "assets/images/placeholder.jpg",
            height: height,
            width: width,
            fit: fit),
        errorWidget: (context, url, error) =>
            Image.asset(placeholder, height: height, width: width, fit: fit),
      ),
    );
  }
}

class CustomImage extends StatelessWidget {
  final String image;
  final double height;
  final double width;
  final BoxFit fit;
  final String placeholder;
  final Color? color;

  const CustomImage(
      {super.key,
      required this.image,
      this.height = 30,
      this.width = 30,
      this.fit = BoxFit.cover,
      this.placeholder = "assets/images/placeholder.jpg",
      this.color});

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: image,
      height: height,
      width: width,
      fit: fit,
      color: color,
      placeholder: (context, url) => Image.asset(
          "assets/images/placeholder.jpg",
          height: height,
          width: width,
          fit: fit),
      errorWidget: (context, url, error) =>
          Image.asset(placeholder, height: height, width: width, fit: fit),
    );
  }
}
