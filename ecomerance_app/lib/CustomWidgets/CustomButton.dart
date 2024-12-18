

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final String? imagePath;
  final double? height, width, borderRadius, fontSize;
  final Color? labelColor, bgColor,borderColor,iconColor;
  final FontWeight? fontWeight;
  final void Function()? onTap;
  final IconData? icon;
  const CustomButton({
    super.key,
    required this.label,
    this.height,
    this.width,
    this.borderRadius,
    this.fontSize,
    this.labelColor,
    this.bgColor,
    this.fontWeight,
    this.onTap,
    this.borderColor, this.imagePath, this.iconColor, this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height ?? 55,
        width: width ??  double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius ?? 10),
          color: bgColor ?? Colors.white,
          border: Border.all(
              width: 1.5,
              color: borderColor ?? Colors.transparent),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (imagePath != null) ...[
              SvgPicture.asset(
                imagePath!,
                width: 25,
                height: 25,
                color: iconColor ,
              ),
              SizedBox(width: 15),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: fontSize ?? 14,
                fontWeight: fontWeight ?? FontWeight.w400,
                color: labelColor,
              ),
            ),
            if (icon != null) ...[
            SizedBox(width: 2),
            Icon(icon,color: Colors.white,size: 18,),

            ],
          ],
        ),
      ),
    );
  }
}
