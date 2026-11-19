import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/kcolor.dart';


/// Labelled text field with prefix icon, password toggle and validation.
class InputFieldText extends StatefulWidget {
  const InputFieldText({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.icon,
    this.isPassword = false,
    this.validator,
    this.keyboardType,
    this.textInputAction = TextInputAction.next,
    this.maxLines = 1,
    this.maxLength,
    this.readOnly = false,
    this.onSubmitted,
    this.onChanged,
    this.autofillHints,
    this.inputFormatters,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? icon;
  final bool isPassword;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;
  final int maxLines;
  final int? maxLength;
  final bool readOnly;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;

  @override
  State<InputFieldText> createState() => _InputFieldTextState();
}

class _InputFieldTextState extends State<InputFieldText> {
  late bool _obscure = widget.isPassword;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: KColors.textPrimary),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: widget.controller,
            readOnly: widget.readOnly,
            obscureText: _obscure,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            maxLines: widget.isPassword ? 1 : widget.maxLines,
            maxLength: widget.maxLength,
            autofillHints: widget.autofillHints,
            inputFormatters: widget.inputFormatters,
            validator: widget.validator,
            onFieldSubmitted: widget.onSubmitted,
            onChanged: widget.onChanged,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: widget.readOnly ? KColors.textSecondary : KColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: widget.hint,
              counterText: '',
              fillColor: widget.readOnly ? KColors.background : KColors.surface,
              prefixIcon: widget.icon == null ? null : Icon(widget.icon, color: KColors.primary, size: 22),
              suffixIcon: widget.isPassword
                  ? IconButton(
                      icon: Icon(
                        _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: KColors.textSecondary,
                        size: 22,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
