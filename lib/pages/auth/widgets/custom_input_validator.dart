// ignore_for_file: must_be_immutable

import 'package:client_control_car/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomInputValidatore extends StatefulWidget {
  double width;
  EdgeInsetsGeometry marginContainer;
  String? labelText;
  TextEditingController controller;
  bool isPassword;
  TextInputType inputType;
  FocusNode focusNode;
  FocusNode? nextFocus;
  Function? onChanged;
  Function? onSubmit;
  bool isReadOnly;
  Widget? icon;
  Widget? iconRigth;
  String? hintText;
  String? errorText;
  String? Function(String?)? validator;
  int? maxLines;
  Widget? labelWidget;
  int? minLines;
  bool isradius;
  List<TextInputFormatter>? inputFormatters;
  CustomInputValidatore({
    Key? key,
    required this.controller,
    required this.labelText,
    required this.marginContainer,
    required this.width,
    this.isPassword = false,
    this.inputType = TextInputType.text,
    required this.focusNode,
    this.nextFocus,
    this.onChanged,
    this.onSubmit,
    this.isReadOnly = false,
    this.icon,
    this.iconRigth,
    this.hintText,
    this.errorText,
    this.validator,
    this.inputFormatters,
    this.isradius = false,
    this.labelWidget,
    this.maxLines = 1,
    this.minLines,
  }) : super(key: key);

  @override
  State<CustomInputValidatore> createState() => _CustomInputValidatoreState();
}

class _CustomInputValidatoreState extends State<CustomInputValidatore> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.marginContainer,
      padding: const EdgeInsets.all(0),
      width: widget.width,
      color: widget.isReadOnly ? Colors.grey[200] : Colors.transparent,
      child: TextFormField(
        focusNode: widget.focusNode,
        obscureText: widget.isPassword,
        controller: widget.controller,
        keyboardType: widget.inputType,
        readOnly: widget.isReadOnly,
        autofocus: false,
        //
        maxLines: widget.maxLines,
        minLines: widget.minLines,
        //
        inputFormatters: widget.inputFormatters,
        style: const TextStyle(
            color: Color(0xff505F79),
            fontSize: 17,
            fontWeight: FontWeight.w400),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintMaxLines: 10,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          errorText: null,
          errorStyle: const TextStyle(
            height: 0,
          ),
          errorBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red)),
          prefixIcon: widget.icon,
          suffixIcon: widget.iconRigth,
          labelStyle: TextStyle(
            color: normalText,
          ),
          hintStyle: TextStyle(
            color: normalText,
          ),
          labelText: widget.labelText,
          label: widget.labelWidget,
          border: const OutlineInputBorder(),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Color(0xffDFE1E6),
              width: 1.2,
            ),
            borderRadius: widget.isradius
                ? const BorderRadius.all(Radius.circular(0.0))
                : const BorderRadius.all(Radius.circular(8.0)),
          ),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: normalText,
                width: 1.2,
              ),
              borderRadius: widget.isradius
                  ? const BorderRadius.all(Radius.circular(0.0))
                  : const BorderRadius.all(Radius.circular(8.0))),
        ),
        validator: widget.validator,
        // onChanged: (value) {
        //   widget.onChanged;
        // },
      ),
    );
  }
}
