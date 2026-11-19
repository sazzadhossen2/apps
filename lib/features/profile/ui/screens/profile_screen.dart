import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/app_router.dart';
import '../../../../app/kcolor.dart';
import '../../../../app/utils.dart';
import '../../../../utils/widgets/common_widgets.dart';
import '../../../../utils/widgets/input_field.dart';
import '../../../../utils/widgets/kbutton.dart';
import '../../../../utils/widgets/ktext.dart';
import '../../../../utils/widgets/net_image.dart';
import '../../../../utils/widgets/state_views.dart';
import '../../../admin/ui/controller/admin_controller.dart';
import '../../../ai_assistant/ui/controller/ai_controller.dart';
import '../../../auth/ui/controller/auth_controller.dart';
import '../../../my_bookings/ui/controller/my_bookings_controller.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _email;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthController>().user;
    _name = TextEditingController(text: user?.name ?? '');
    _phone = TextEditingController(text: user?.phone ?? '');
    _email = TextEditingController(text: user?.email ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthController>();
    final ok = await auth.updateProfile(name: _name.text, phone: _phone.text);
    AppSnack.show(ok ? 'Profile updated' : (auth.error ?? 'Could not update profile'), error: !ok);
  }

  Future<void> _logout() async {
    final auth = context.read<AuthController>();
    final bookings = context.read<MyBookingsController>();
    final ai = context.read<AiController>();
    final admin = context.read<AdminController>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('You will need to log in again to manage your bookings.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Stay')),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: KColors.danger),
            child: const Text('Log out'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await auth.logout();
    bookings.reset();
    ai.reset();
    admin.reset();
    AppRouter.resetToLogin();
  }

  void _openChangePassword() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _ChangePasswordSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: ResponsiveBody(
          maxWidth: 640,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            child: Column(
              children: [
                // Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [KColors.primaryDark, KColors.primary, KColors.primaryLight], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: Colors.white,
                        child: Text(user?.initial ?? '?', style: const TextStyle(color: KColors.primary, fontSize: 28, fontWeight: FontWeight.w800)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            KText(text: user?.name ?? '', color: Colors.white, fontSize: 19, fontWeight: FontWeight.w800, maxLines: 1, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 3),
                            KText(text: user?.email ?? '', color: Colors.white.withValues(alpha: 0.9), fontSize: 13, maxLines: 1, overflow: TextOverflow.ellipsis),
                            if (user?.isAdmin ?? false) ...[
                              const SizedBox(height: 8),
                              const IconPill(icon: Icons.admin_panel_settings_rounded, text: 'Administrator', color: KColors.primaryDark, background: Colors.white),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Personal info
                AppCard(
                  padding: const EdgeInsets.all(18),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionTitle(title: 'Personal information'),
                        const SizedBox(height: 16),
                        InputFieldText(controller: _name, label: 'Full name', icon: Icons.person_outline_rounded, validator: Validators.name),
                        InputFieldText(
                          controller: _phone,
                          label: 'Phone (optional)',
                          hint: '+8801XXXXXXXXX',
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.done,
                          validator: Validators.phone,
                          onSubmitted: (_) => _save(),
                        ),
                        InputFieldText(controller: _email, label: 'Email', icon: Icons.mail_outline_rounded, readOnly: true),
                        KButton(label: 'Save changes', icon: Icons.save_rounded, isLoading: auth.isBusy, onPressed: _save),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Security
                AppCard(
                  padding: EdgeInsets.zero,
                  onTap: _openChangePassword,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                    leading: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(color: KColors.mint, borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.lock_reset_rounded, color: KColors.primary),
                    ),
                    title: const Text('Change password', style: TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: const Text('Keep your account secure'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                  ),
                ),
                const SizedBox(height: 20),
                KButton(label: 'Log out', icon: Icons.logout_rounded, type: KButtonType.outline, onPressed: _logout),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChangePasswordSheet extends StatefulWidget {
  const _ChangePasswordSheet();

  @override
  State<_ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<_ChangePasswordSheet> {
  final _formKey = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthController>();
    final ok = await auth.changePassword(_current.text, _next.text);
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop();
      AppSnack.show('Password changed successfully');
    } else {
      AppSnack.show(auth.error ?? 'Could not change password', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 0, 24, MediaQuery.viewInsetsOf(context).bottom + 20),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle(title: 'Change password'),
              const SizedBox(height: 16),
              InputFieldText(
                controller: _current,
                label: 'Current password',
                icon: Icons.lock_outline_rounded,
                isPassword: true,
                validator: (v) => (v == null || v.isEmpty) ? 'Current password is required' : null,
              ),
              InputFieldText(controller: _next, label: 'New password', icon: Icons.lock_reset_rounded, isPassword: true, validator: Validators.password),
              InputFieldText(
                controller: _confirm,
                label: 'Confirm new password',
                icon: Icons.lock_reset_rounded,
                isPassword: true,
                textInputAction: TextInputAction.done,
                validator: Validators.confirmPassword(_next),
                onSubmitted: (_) => _submit(),
              ),
              Consumer<AuthController>(
                builder: (_, auth, __) => KButton(label: 'Update password', isLoading: auth.isBusy, onPressed: _submit),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
