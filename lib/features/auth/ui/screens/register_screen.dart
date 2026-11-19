import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/kcolor.dart';
import '../../../../app/utils.dart';
import '../../../../utils/widgets/common_widgets.dart';
import '../../../../utils/widgets/input_field.dart';
import '../../../../utils/widgets/kbutton.dart';
import '../../../../utils/widgets/ktext.dart';
import '../controller/auth_controller.dart';
import 'otp_screen.dart';
import '../widget/auth_header.dart';


class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthController>();
    final ok = await auth.register(_name.text, _email.text, _password.text);
    if (!mounted) return;
    if (ok) {
      AppSnack.show('We emailed a 6-digit code to ${_email.text.trim()}');
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => OtpScreen(email: _email.text.trim())));
    } else {
      AppSnack.show(auth.error ?? 'Registration failed', error: true);
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
            const AuthHeader(title: 'Create account', subtitle: 'Join in seconds and start booking services.'),
            ResponsiveBody(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InputFieldText(
                        controller: _name,
                        label: 'Full name',
                        hint: 'Your name',
                        icon: Icons.person_outline_rounded,
                        keyboardType: TextInputType.name,
                        validator: Validators.name,
                      ),
                      InputFieldText(
                        controller: _email,
                        label: 'Email',
                        hint: 'you@example.com',
                        icon: Icons.mail_outline_rounded,
                        keyboardType: TextInputType.emailAddress,
                        validator: Validators.email,
                      ),
                      InputFieldText(
                        controller: _password,
                        label: 'Password',
                        hint: 'At least 8 characters, letters and numbers',
                        icon: Icons.lock_outline_rounded,
                        isPassword: true,
                        validator: Validators.password,
                      ),
                      InputFieldText(
                        controller: _confirm,
                        label: 'Confirm password',
                        hint: 'Re-enter your password',
                        icon: Icons.lock_outline_rounded,
                        isPassword: true,
                        textInputAction: TextInputAction.done,
                        validator: Validators.confirmPassword(_password),
                        onSubmitted: (_) => _submit(),
                      ),
                      const SizedBox(height: 8),
                      Consumer<AuthController>(
                        builder: (_, auth, __) => KButton(label: 'Continue', isLoading: auth.isBusy, onPressed: _submit),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            KText(text: 'Already have an account? ', color: KColors.textSecondary),
                            GestureDetector(
                              onTap: () => Navigator.of(context).pop(),
                              child: KText(text: 'Log in', color: KColors.primary, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
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
