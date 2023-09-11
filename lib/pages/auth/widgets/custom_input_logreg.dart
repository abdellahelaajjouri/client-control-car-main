// ignore_for_file: must_be_immutable

import 'package:client_control_car/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomInputLogReg extends StatefulWidget {
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
  String? hintText;
  int? maxLines;
  Widget? labelWidget;
  int? minLines;
  bool isradius;
  List<TextInputFormatter>? inputFormatters;
  CustomInputLogReg({
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
    this.isradius = false,
    this.icon,
    this.hintText,
    this.maxLines = 1,
    this.minLines,
    this.labelWidget,
    this.inputFormatters,
  }) : super(key: key);

  @override
  State<CustomInputLogReg> createState() => _CustomInputLogRegState();
}

class _CustomInputLogRegState extends State<CustomInputLogReg> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.marginContainer,
      width: sizeWidth(context: context),
      color: widget.isReadOnly ? Colors.grey[200] : Colors.transparent,
      child: TextField(
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
        inputFormatters: widget.inputType == TextInputType.phone
            ? <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp('[0-9]'))
              ]
            : widget.inputFormatters,
        style: const TextStyle(
            color: Color(0xff505F79),
            fontSize: 17,
            fontWeight: FontWeight.w400),
        decoration: InputDecoration(
          hintText: widget.hintText,
          prefixIcon: widget.icon,
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
        onSubmitted: (text) => widget.nextFocus != null
            ? FocusScope.of(context).requestFocus(widget.nextFocus)
            : widget.onSubmit != null
                ? widget.onSubmit!(text)
                : null,
        onChanged: (text) =>
            widget.onChanged != null ? widget.onChanged! : null,
      ),
    );
  }
}
