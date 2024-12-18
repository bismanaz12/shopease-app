import 'package:ecomerance_app/AppColors/appcolors.dart';
import 'package:flutter/material.dart';
import 'appText.dart';

class CustomListTile extends StatelessWidget {
  final String title;
  final void Function()? onTap;
  final IconData? icon;
  final Widget? trailingWidget;
  final Color? color;

  const CustomListTile({
    Key? key,
    required this.title,
    this.onTap,
    this.icon,
    this.trailingWidget,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ListTile(
        leading: icon != null
            ? _buildLeadingIcon()
            : null, // Conditionally show leading container
        title: AppText(text: title, fontSize: 16, fontWeight: FontWeight.w600),
        trailing: Transform.scale(
          scale: 0.7,
          child: trailingWidget ??
              Icon(
                Icons.arrow_forward_ios_outlined,
                size: 15,
              ),
        ),
      ),
    );
  }

  Widget _buildLeadingIcon() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        // border: Border.all(color: color ?? Colors.black,)
        color: AppColors.primary,
      ),
      child: Icon(icon ?? Icons.error, size: 25, color: Colors.yellow),
    );
  }
}
