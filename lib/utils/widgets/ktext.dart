import 'package:flutter/material.dart';

import '../../app/kcolor.dart';


/// Text with the app's default style (same API as your original KText).
class KText extends Text {
  KText({
    super.key,
    super.overflow,
    super.softWrap,
    super.maxLines,
    super.textAlign,
    required String text,
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    double? height,
    double? letterSpacing,
    TextDecoration? decoration,
  }) : super(
          text,
          style: TextStyle(
            color: color ?? KColors.textPrimary,
            fontSize: fontSize ?? 14,
            fontWeight: fontWeight ?? FontWeight.w400,
            height: height ?? 1.3,
            letterSpacing: letterSpacing,
            decoration: decoration,
          ),
        );
}
