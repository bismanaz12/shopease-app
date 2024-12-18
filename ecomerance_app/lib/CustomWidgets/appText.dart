import 'package:flutter/material.dart';

class AppText extends StatelessWidget {
  final String text;
  final FontWeight? fontWeight;
  final double? fontSize;
  final Color? textColor;
  final TextDecoration? decoration;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final int? maxLines;
  const AppText(
      {super.key,
      required this.text,
      this.fontWeight,
      this.fontSize,
      this.textColor,
        this.decoration, this.textAlign, this.overflow, this.maxLines});

  @override
  Widget build(BuildContext context) {
    return Text(
      maxLines:maxLines,
      textAlign: textAlign,
      text,
      style: TextStyle(
        overflow:overflow,
        decoration: decoration,
        fontSize: fontSize ?? 14,
        fontWeight: fontWeight ?? FontWeight.w400,
        color: textColor,
      ),
    );
  }
}
