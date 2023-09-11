import 'package:client_control_car/constants/constants.dart';
import 'package:flutter/material.dart';

Widget itemNotification(
    {required String title,
    Function()? onTap,
    required String subtitle,
    required String time}) {
  return InkWell(
    onTap: onTap,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 2),
          child: Text(
            title,
            style: gothicBold.copyWith(
              color: Colors.black,
              fontSize: 16,
            ),
          ),
        ),
        if (subtitle != "")
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 2),
            child: Text(
              subtitle,
              style: gothicRegular.copyWith(
                color: normalText,
                fontSize: 14,
              ),
            ),
          ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 2),
          child: Text(
            time,
            style: gothicRegular.copyWith(
              color: normalText,
              fontSize: 12,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 2),
          child: Divider(color: normalText, thickness: 1),
        ),
      ],
    ),
  );
}
