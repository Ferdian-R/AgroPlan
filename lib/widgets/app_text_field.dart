import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Text field custom sesuai desain Figma dengan radius 20, fill transparan abu-abu,
/// border tipis, ikon prefix, dan dukungan validasi serta toggle password.
class AppTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final bool isPassword;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final String? Function(String?)? validator;

  const AppTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.validator,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscureText,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      style: AppTextStyles.authInput,
      validator: widget.validator,
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.authInputFill,
        hintText: widget.hintText,
        hintStyle: AppTextStyles.authHint,
        prefixIcon: Icon(
          widget.prefixIcon,
          color: AppColors.authTextHint,
          size: 20,
        ),
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: AppColors.authTextHint,
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              )
            : null,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.p16,
          vertical: AppSpacing.p14, // Menghasilkan tinggi total >= 48 dp (NFR-02)
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppSpacing.roundedInput,
          borderSide: const BorderSide(
            color: AppColors.authInputBorder,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppSpacing.roundedInput,
          borderSide: const BorderSide(
            color: AppColors.authPrimary,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppSpacing.roundedInput,
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppSpacing.roundedInput,
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 1.5,
          ),
        ),
        errorStyle: const TextStyle(
          fontSize: 12,
          color: AppColors.error,
        ),
      ),
    );
  }
}
