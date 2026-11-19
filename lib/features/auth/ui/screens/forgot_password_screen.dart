import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../app/kcolor.dart';
import '../../../../app/utils.dart';
import '../../../../utils/widgets/common_widgets.dart';
import '../../../../utils/widgets/input_field.dart';
import '../../../../utils/widgets/kbutton.dart';
import '../controller/auth_controller.dart';
import '../widget/auth_header.dart';

/// Forgot password: 1) enter email -> code is emailed, 2) enter code + new password.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _code = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _codeSent = false;

  @override
  void dispose() {
    _email.dispose();
    _code.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    FocusScope.of(context).unfocus();
    if (Validators.email(_email.text) != null) {
      AppSnack.show(Validators.email(_email.text)!, error: true);
      return;
    }
    final auth = context.read<AuthController>();
    final ok = await auth.forgotPassword(_email.text);
    if (!mounted) return;
    if (ok) {
      setState(() => _codeSent = true);
      AppSnack.show('If this email has an account, a code is on its way.');
    } else {
      AppSnack.show(auth.error ?? 'Could not send the code', error: true);
    }
  }

  Future<void> _reset() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthController>();
    final ok = await auth.resetPassword(_email.text, _code.text, _password.text);
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop();
      AppSnack.show('Password reset. You can log in now.');
    } else {
      AppSnack.show(auth.error ?? 'Could not reset the password', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KColors.background,
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          children: [
            const AuthHeader(title: 'Forgot password', subtitle: 'We will email you a code to set a new password.'),
            ResponsiveBody(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InputFieldText(
                        controller: _email,
                        label: 'Email',
                        hint: 'you@example.com',
                        icon: Icons.mail_outline_rounded,
                        keyboardType: TextInputType.emailAddress,
                        readOnly: _codeSent,
                        validator: Validators.email,
                      ),
                      if (!_codeSent)
                        Consumer<AuthController>(
                          builder: (_, auth, __) => KButton(label: 'Send code', isLoading: auth.isBusy, onPressed: _sendCode),
                        )
                      else ...[
                        InputFieldText(
                          controller: _code,
                          label: 'Code from your email',
                          hint: '6-digit code',
                          icon: Icons.pin_outlined,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          validator: (v) => (v == null || v.trim().length != 6) ? 'Enter the 6-digit code' : null,
                        ),
                        InputFieldText(
                          controller: _password,
                          label: 'New password',
                          hint: 'At least 8 characters, letters and numbers',
                          icon: Icons.lock_reset_rounded,
                          isPassword: true,
                          validator: Validators.password,
                        ),
                        InputFieldText(
                          controller: _confirm,
                          label: 'Confirm new password',
                          icon: Icons.lock_reset_rounded,
                          isPassword: true,
                          textInputAction: TextInputAction.done,
                          validator: Validators.confirmPassword(_password),
                          onSubmitted: (_) => _reset(),
                        ),
                        Consumer<AuthController>(
                          builder: (_, auth, __) => KButton(label: 'Reset password', isLoading: auth.isBusy, onPressed: _reset),
                        ),
                        TextButton(onPressed: _sendCode, child: const Text('Send the code again')),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
