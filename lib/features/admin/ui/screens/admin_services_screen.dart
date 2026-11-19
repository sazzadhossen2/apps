import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../app/kcolor.dart';
import '../../../../app/utils.dart';
import '../../../../utils/widgets/widgets.dart';
import '../../../home/models/service_model.dart';
import '../controller/admin_controller.dart';

/// Create, edit, feature and hide services.
class AdminServicesScreen extends StatelessWidget {
  const AdminServicesScreen({super.key});

  void _openForm(BuildContext context, [ServiceModel? service]) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _ServiceForm(service: service),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<AdminController>();
    final side = Responsive.side(context, maxWidth: 760);

    Widget body;
    if (c.servicesState == ViewState.loading || c.servicesState == ViewState.idle) {
      body = const LoadingView();
    } else if (c.servicesState == ViewState.error && c.services.isEmpty) {
      body = ErrorView(message: c.servicesError ?? 'Could not load services.', onRetry: c.loadServices);
    } else if (c.services.isEmpty) {
      body = EmptyView(icon: Icons.design_services_rounded, title: 'No services yet', subtitle: 'Add your first service.', actionLabel: 'Add service', onAction: () => _openForm(context));
    } else {
      body = RefreshIndicator(
        color: KColors.primary,
        onRefresh: () => c.loadServices(silent: true),
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(side, 12, side, 96),
          itemCount: c.services.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) {
            final s = c.services[i];
            return Opacity(
              opacity: s.isActive ? 1 : 0.55,
              child: AppCard(
                padding: const EdgeInsets.all(12),
                onTap: () => _openForm(context, s),
                child: Row(
                  children: [
                    NetImage(url: s.image, width: 60, height: 60, radius: 12),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          KText(text: s.name, fontWeight: FontWeight.w800, maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 3),
                          KText(text: '${s.category} · ${Fmt.duration(s.durationMinutes)}', fontSize: 12.5, color: KColors.textSecondary),
                          const SizedBox(height: 5),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              KText(text: Fmt.price(s.price), fontWeight: FontWeight.w800, color: KColors.primary),
                              if (s.isFeatured) const IconPill(icon: Icons.local_fire_department_rounded, text: 'Featured', color: KColors.pendingFg, background: KColors.pendingBg),
                              if (!s.isActive) const IconPill(icon: Icons.visibility_off_rounded, text: 'Hidden'),
                              if (s.reviewsCount > 0) IconPill(icon: Icons.star_rounded, text: '${s.rating.toStringAsFixed(1)} (${s.reviewsCount})', color: KColors.pendingFg),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.edit_rounded, color: KColors.textSecondary, size: 20),
                  ],
                ),
              ),
            );
          },
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Services')),
      body: body,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context),
        backgroundColor: KColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add service'),
      ),
    );
  }
}

class _ServiceForm extends StatefulWidget {
  const _ServiceForm({this.service});
  final ServiceModel? service;

  @override
  State<_ServiceForm> createState() => _ServiceFormState();
}

class _ServiceFormState extends State<_ServiceForm> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.service?.name ?? '');
  late final _category = TextEditingController(text: widget.service?.category ?? '');
  late final _price = TextEditingController(text: widget.service == null ? '' : widget.service!.price.round().toString());
  late final _duration = TextEditingController(text: widget.service?.durationMinutes.toString() ?? '60');
  late final _image = TextEditingController(text: widget.service?.image ?? '');
  late final _description = TextEditingController(text: widget.service?.description ?? '');
  late bool _featured = widget.service?.isFeatured ?? false;
  late bool _active = widget.service?.isActive ?? true;
  bool _busy = false;

  bool get _editing => widget.service != null;

  @override
  void dispose() {
    for (final c in [_name, _category, _price, _duration, _image, _description]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _number(String? v, {required String label, required num min, num? max}) {
    final n = num.tryParse((v ?? '').trim());
    if (n == null) return '$label is required';
    if (n < min) return '$label must be at least $min';
    if (max != null && n > max) return '$label must be at most $max';
    return null;
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    final error = await context.read<AdminController>().saveService(widget.service?.id, {
      'name': _name.text.trim(),
      'category': _category.text.trim(),
      'description': _description.text.trim(),
      'price': num.parse(_price.text.trim()),
      'durationMinutes': int.parse(_duration.text.trim()),
      'image': _image.text.trim(),
      'isFeatured': _featured,
      'isActive': _active,
    });
    if (!mounted) return;
    setState(() => _busy = false);
    if (error == null) {
      Navigator.of(context).pop();
      AppSnack.show(_editing ? 'Service updated' : 'Service created');
    } else {
      AppSnack.show(error, error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 0, 24, MediaQuery.viewInsetsOf(context).bottom + 20),
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionTitle(title: _editing ? 'Edit service' : 'New service'),
              const SizedBox(height: 16),
              InputFieldText(controller: _name, label: 'Name', icon: Icons.title_rounded, validator: (v) => Validators.required(v, 'Name')),
              InputFieldText(controller: _category, label: 'Category', hint: 'e.g. Salon', icon: Icons.category_rounded, validator: (v) => Validators.required(v, 'Category')),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: InputFieldText(
                      controller: _price,
                      label: 'Price (৳)',
                      icon: Icons.payments_rounded,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                      validator: (v) => _number(v, label: 'Price', min: 0),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InputFieldText(
                      controller: _duration,
                      label: 'Duration (min)',
                      icon: Icons.schedule_rounded,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (v) => _number(v, label: 'Duration', min: 15, max: 480),
                    ),
                  ),
                ],
              ),
              InputFieldText(
                controller: _image,
                label: 'Image URL (optional)',
                hint: 'https://...',
                icon: Icons.image_rounded,
                keyboardType: TextInputType.url,
                validator: (v) {
                  final t = (v ?? '').trim();
                  if (t.isEmpty) return null;
                  final uri = Uri.tryParse(t);
                  return (uri != null && uri.hasAuthority && (uri.scheme == 'http' || uri.scheme == 'https')) ? null : 'Enter a valid http(s) URL';
                },
              ),
              InputFieldText(
                controller: _description,
                label: 'Description',
                icon: Icons.notes_rounded,
                maxLines: 4,
                maxLength: 1000,
                textInputAction: TextInputAction.newline,
                keyboardType: TextInputType.multiline,
                validator: (v) => (v == null || v.trim().length < 5) ? 'Description is too short' : null,
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Featured on the home screen'),
                value: _featured,
                activeColor: KColors.primary,
                onChanged: (v) => setState(() => _featured = v),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Visible to customers'),
                subtitle: const Text('Turn off to hide it without deleting past bookings'),
                value: _active,
                activeColor: KColors.primary,
                onChanged: (v) => setState(() => _active = v),
              ),
              const SizedBox(height: 8),
              KButton(label: _editing ? 'Save changes' : 'Create service', isLoading: _busy, onPressed: _save),
            ],
          ),
        ),
      ),
    );
  }
}
