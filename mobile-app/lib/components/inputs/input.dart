import 'package:flutter/material.dart';

class ReusableInputField extends StatelessWidget {
  final String? labelText;
  final String? hintText;
  final TextEditingController? controller;
  final bool isPassword;
  final TextInputType keyboardType;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final dynamic onTap;
  final bool readOnly, isEnabled;
  final String? Function(String?)? validator;

  const ReusableInputField({
    super.key,
    this.labelText = "",
    this.controller,
    this.hintText,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.validator,
    this.readOnly = false,
    this.isEnabled = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hintText != null) ...[
          Text(
            hintText!,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 5),
        ],
        TextFormField(
          onTap: onTap,
          controller: controller,
          obscureText: isPassword,
          readOnly: readOnly,
          enabled: isEnabled,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            labelText: labelText,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
            suffixIcon:
                suffixIcon != null
                    ? IconButton(onPressed: onSuffixTap, icon: Icon(suffixIcon))
                    : null,
          ),
          validator: validator,
        ),
      ],
    );
  }
}
