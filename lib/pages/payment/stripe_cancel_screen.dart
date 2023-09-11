import 'package:flutter/material.dart';

class StripeCancelScreen extends StatefulWidget {
  final String controlId;
  final String total;
  final String hasCoupon;
  final String discount;
  const StripeCancelScreen(
      {super.key,
      required this.controlId,
      required this.discount,
      required this.hasCoupon,
      required this.total});

  @override
  State<StripeCancelScreen> createState() => _StripeCancelScreenState();
}

class _StripeCancelScreenState extends State<StripeCancelScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Text("Cancel"),
    );
  }
}
