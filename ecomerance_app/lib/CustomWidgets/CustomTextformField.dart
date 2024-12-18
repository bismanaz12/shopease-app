import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextFormField extends StatelessWidget {
  final String hintText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final TextEditingController? controller;
  final Color? bgColor,suffixIconColor,borderColor;
  final void Function()? onTapSuffixIcon;
  final EdgeInsetsGeometry? contentPadding;
  String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final double ? height,width;
  final void Function(String)? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  bool? obscureText ;
  CustomTextFormField(
      {super.key,
        this.obscureText,
        this.validator,
      this.prefixIcon,
      required this.hintText,
      this.controller,
      this.bgColor,
      this.suffixIcon,
        this.onTapSuffixIcon,
        this.suffixIconColor,
        this.contentPadding, this.borderColor, this.height, this.width, this.keyboardType, this.inputFormatters, this.onChanged,
      });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: TextFormField(
        onChanged: onChanged,
        inputFormatters:inputFormatters,
        keyboardType:keyboardType,
        obscureText: obscureText ?? false,
        validator: validator,
        controller: controller,
        cursorColor: Colors.black,
        decoration: InputDecoration(
          filled: true,
          fillColor: bgColor ?? Colors.grey.shade200,
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey),
          prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
          suffixIcon: suffixIcon != null
              ? GestureDetector(
                  onTap: onTapSuffixIcon,
                  child: Icon(
                    suffixIcon,
                    color: suffixIconColor ?? Colors.transparent,
                    size: 22,
                  ),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: borderColor??Colors.transparent),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(width: 1.5, color: Colors.black),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.red),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.red),
          ),
          contentPadding:contentPadding,
        ),
      ),
    );
  }
}
