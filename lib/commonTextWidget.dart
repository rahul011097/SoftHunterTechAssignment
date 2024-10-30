import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CommonTextWidget extends StatelessWidget {
  final EdgeInsets? padding;
  final TextEditingController? controller;
  final String hintText;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final bool? obscureText;
  final int? maxLines;
  final bool isDisabled;
  final FocusNode? focusNode;
  final Function(String?)? onChanged;
  final bool? enabled;
  final bool? autoFocus;
  const CommonTextWidget({
    Key? key,
    this.padding,
    this.controller,
    required this.hintText,
    this.validator,
    this.inputFormatters,
    this.keyboardType,
    this.suffixIcon,
    this.prefixIcon,
    this.obscureText,
    this.maxLines,
    this.isDisabled = false,
    this.focusNode,
    this.onChanged,
    this.enabled,
    this.autoFocus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AbsorbPointer(
            absorbing: isDisabled,
            child: TextFormField(
              controller: controller,
              focusNode: focusNode,
              validator: validator,
              onChanged: onChanged,
              inputFormatters: inputFormatters,
              keyboardType: keyboardType,
              obscureText: obscureText ?? false,
              enabled: enabled,
              autofocus: autoFocus ?? false,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF03467D),
                  fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(14),
                filled: true,
                fillColor: Colors.white.withOpacity(.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Color(0xFF03467D)),
                ),
                hintText: hintText,
                hintStyle: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF03467D),
                    fontWeight: FontWeight.w500),
                suffixIcon: suffixIcon,
                prefixIcon: prefixIcon,
                prefixIconColor: Colors.grey,
                suffixIconColor: Colors.grey,
                errorStyle: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF03467D),
                    fontWeight: FontWeight.w500),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Color(0xFF03467D)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(
                    width: 2,
                    color: Color(0xFF03467D),
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(
                    width: 2,
                    color: Colors.blue.shade700,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(
                    width: 2,
                    color: Colors.red.shade700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
