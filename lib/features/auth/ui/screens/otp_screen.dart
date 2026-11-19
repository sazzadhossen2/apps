import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../app/app_router.dart';
import '../../../../app/kcolor.dart';
import '../../../../app/utils.dart';
import '../../../../utils/widgets/common_widgets.dart';
import '../../../../utils/widgets/input_field.dart';
import '../../../../utils/widgets/kbutton.dart';
import '../../../../utils/widgets/ktext.dart';
import '../controller/auth_controller.dart';
import '../widget/auth_header.dart';

/// Step 2 of registration (and of login for unverified accounts): enter the 6-digit emailed code.
class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key, required this.email});
  final String email;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  static const int _cooldown = 60;
  final _code = TextEditingController();
  Timer? _timer;
  int _left = _cooldown; // the server just sent a code
  bool _resending = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _code.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _left = _cooldown);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return t.cancel();
      setState(() => _left = _left > 0 ? _left - 1 : 0);
      if (_left == 0) t.cancel();
    });
  }

  Future<void> _verify() async {
    FocusScope.of(context).unfocus();
    if (_code.text.trim().length != 6) {
      AppSnack.show('Enter the 6-digit code', error: true);
      return;
    }
    final auth = context.read<AuthController>();
    final ok = await auth.verifyEmail(widget.email, _code.text);
    if (!mounted) return;
    if (ok) {
      AppSnack.show('Email verified. Welcome, ${auth.user?.firstName ?? ''}!');
      AppRouter.resetToHome();
    } else {
      _code.clear();
      AppSnack.show(auth.error ?? 'Verification failed', error: true);
    }
  }

  Future<void> _resend() async {
    setState(() => _resending = true);
    final auth = context.read<AuthController>();
    final ok = await auth.resendCode(widget.email);
    if (!mounted) return;
    setState(() => _resending = false);
    if (ok) {
      _startTimer();
      AppSnack.show('A new code was sent to ${widget.email}');
    } else {
      AppSnack.show(auth.error ?? 'Could not send a new code', error: true);
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
            const AuthHeader(title: 'Verify your email', subtitle: 'Enter the 6-digit code we sent you.'),
            ResponsiveBody(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    KText(text: 'Code sent to', color: KColors.textSecondary, fontSize: 13),
                    const SizedBox(height: 2),
                    KText(text: widget.email, fontWeight: FontWeight.w800, fontSize: 16),
                    const SizedBox(height: 22),
                    InputFieldText(
                      controller: _code,
                      label: 'Verification code',
                      hint: '6-digit code',
                      icon: Icons.pin_outlined,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      textInputAction: TextInputAction.done,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      autofillHints: const [AutofillHints.oneTimeCode],
                      onSubmitted: (_) => _verify(),
                    ),
                    Consumer<AuthController>(
                      builder: (_, auth, __) => KButton(label: 'Verify', isLoading: auth.isBusy, onPressed: _verify),
                    ),
                    const SizedBox(height: 18),
                    Center(
                      child: _left > 0
                          ? KText(text: 'Resend code in ${_left}s', color: KColors.textSecondary)
                          : TextButton(
                              onPressed: _resending ? null : _resend,
                              child: Text(_resending ? 'Sending...' : 'Resend code'),
                            ),
                    ),
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Use a different email'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const AppCard(
                      color: KColors.mint,
                      child: Row(
                        children: [
                          Icon(Icons.info_outline_rounded, color: KColors.primaryDark, size: 20),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'The code expires in 10 minutes. Check your spam folder if you cannot find it.',
                              style: TextStyle(fontSize: 12.5, color: KColors.primaryDark),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
