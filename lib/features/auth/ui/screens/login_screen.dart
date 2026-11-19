import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/app_router.dart';
import '../../../../app/kcolor.dart';
import '../../../../app/kstrings.dart';
import '../../../../app/utils.dart';
import '../../../../utils/widgets/common_widgets.dart';
import '../../../../utils/widgets/input_field.dart';
import '../../../../utils/widgets/kbutton.dart';
import '../../../../utils/widgets/ktext.dart';
import '../controller/auth_controller.dart';
import 'forgot_password_screen.dart';
import 'otp_screen.dart';
import 'register_screen.dart';
import '../widget/auth_header.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthController>();
    final next = await auth.login(_email.text, _password.text);
    if (!mounted) return;
    switch (next) {
      case AuthNext.home:
        AppRouter.resetToHome();
      case AuthNext.verifyEmail:
        AppSnack.show('Please verify your email. We sent you a code.');
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => OtpScreen(email: _email.text.trim())));
      case AuthNext.failed:
        AppSnack.show(auth.error ?? 'Login failed', error: true);
    }
  }

  void _fillDemo({bool admin = false}) {
    _email.text = admin ? KStrings.adminEmail : KStrings.demoEmail;
    _password.text = admin ? KStrings.adminPassword : KStrings.demoPassword;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KColors.background,
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          children: [
            const AuthHeader(title: 'Welcome back', subtitle: 'Log in to book and manage your services.'),
            ResponsiveBody(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                child: Form(
                  key: _formKey,
                  child: AutofillGroup(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InputFieldText(
                          controller: _email,
                          label: 'Email',
                          hint: 'you@example.com',
                          icon: Icons.mail_outline_rounded,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.email],
                          validator: Validators.email,
                        ),
                        InputFieldText(
                          controller: _password,
                          label: 'Password',
                          hint: 'Enter your password',
                          icon: Icons.lock_outline_rounded,
                          isPassword: true,
                          textInputAction: TextInputAction.done,
                          autofillHints: const [AutofillHints.password],
                          validator: (v) => (v == null || v.isEmpty) ? 'Password is required' : null,
                          onSubmitted: (_) => _submit(),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ForgotPasswordScreen())),
                            child: const Text('Forgot password?'),
                          ),
                        ),
                        Consumer<AuthController>(
                          builder: (_, auth, __) => KButton(label: 'Log in', isLoading: auth.isBusy, onPressed: _submit),
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              KText(text: 'New here? ', color: KColors.textSecondary),
                              GestureDetector(
                                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RegisterScreen())),
                                child: KText(text: 'Create an account', color: KColors.primary, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        InkWell(
                          onTap: _fillDemo,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: KColors.mint, borderRadius: BorderRadius.circular(12)),
                            child: Row(
                              children: [
                                const Icon(Icons.touch_app_rounded, color: KColors.primary, size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: KText(text: 'Tap to fill the demo account (${KStrings.demoEmail})', fontSize: 12.5, color: KColors.primaryDark),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        InkWell(
                          onTap: () => _fillDemo(admin: true),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: KColors.mint, borderRadius: BorderRadius.circular(12)),
                            child: Row(
                              children: [
                                const Icon(Icons.admin_panel_settings_rounded, color: KColors.primary, size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: KText(text: 'Tap to fill the admin account (${KStrings.adminEmail})', fontSize: 12.5, color: KColors.primaryDark),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
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
