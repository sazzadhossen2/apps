import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/kcolor.dart';
import '../../../../app/utils.dart';
import '../../../../utils/widgets/widgets.dart';
import '../../models/admin_models.dart';
import '../controller/admin_controller.dart';

/// Times the business is NOT available. Customers cannot book slots inside these ranges.
class AdminBusyScreen extends StatelessWidget {
  const AdminBusyScreen({super.key});

  Future<void> _delete(BuildContext context, BusyBlock b) async {
    final controller = context.read<AdminController>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove busy time?'),
        content: const Text('Customers will be able to book this time again.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Keep')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Remove')),
        ],
      ),
    );
    if (ok != true) return;
    final error = await controller.removeBusy(b.id);
    AppSnack.show(error ?? 'Busy time removed', error: error != null);
  }

  void _openAdd(BuildContext context) {
    showModalBottomSheet<void>(context: context, isScrollControlled: true, builder: (_) => const _BusySheet());
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<AdminController>();
    final side = Responsive.side(context, maxWidth: 760);

    Widget body;
    if (c.busyState == ViewState.loading || c.busyState == ViewState.idle) {
      body = const LoadingView();
    } else if (c.busyState == ViewState.error && c.busy.isEmpty) {
      body = ErrorView(message: c.busyError ?? 'Could not load busy times.', onRetry: c.loadBusy);
    } else {
      body = RefreshIndicator(
        color: KColors.primary,
        onRefresh: () => c.loadBusy(silent: true),
        child: c.busy.isEmpty
            ? LayoutBuilder(
                builder: (context, box) => ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(
                      height: box.maxHeight,
                      child: EmptyView(
                        icon: Icons.event_available_rounded,
                        title: 'No busy times',
                        subtitle: 'Block a holiday, a day off or maintenance so customers cannot book it.',
                        actionLabel: 'Mark busy',
                        onAction: () => _openAdd(context),
                      ),
                    ),
                  ],
                ),
              )
            : ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(side, 12, side, 96),
                itemCount: c.busy.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final b = c.busy[i];
                  return AppCard(
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(color: KColors.pendingBg, borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.event_busy_rounded, color: KColors.pendingFg),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              KText(text: b.serviceName ?? 'All services', fontWeight: FontWeight.w800),
                              const SizedBox(height: 3),
                              KText(text: '${Fmt.date(b.startAt)}', fontSize: 13, color: KColors.textSecondary),
                              KText(text: '${Fmt.time(b.startAt)} – ${Fmt.time(b.endAt)}', fontSize: 13, color: KColors.textSecondary),
                              if (b.reason.isNotEmpty) KText(text: b.reason, fontSize: 12.5, color: KColors.textSecondary),
                            ],
                          ),
                        ),
                        IconButton(onPressed: () => _delete(context, b), icon: const Icon(Icons.delete_outline_rounded, color: KColors.danger), tooltip: 'Remove'),
                      ],
                    ),
                  );
                },
              ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Busy times')),
      body: body,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAdd(context),
        backgroundColor: KColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Mark busy'),
      ),
    );
  }
}

class _BusySheet extends StatefulWidget {
  const _BusySheet();

  @override
  State<_BusySheet> createState() => _BusySheetState();
}

class _BusySheetState extends State<_BusySheet> {
  final _reason = TextEditingController();
  DateTime _date = DateUtils.dateOnly(DateTime.now());
  TimeOfDay _from = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _to = const TimeOfDay(hour: 18, minute: 0);
  String? _serviceId; // null = all services
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    final c = context.read<AdminController>();
    if (c.servicesState == ViewState.idle) c.loadServices(silent: true);
  }

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime(bool from) async {
    final picked = await showTimePicker(context: context, initialTime: from ? _from : _to);
    if (picked != null) setState(() => from ? _from = picked : _to = picked);
  }

  Future<void> _save() async {
    final fromMin = _from.hour * 60 + _from.minute;
    final toMin = _to.hour * 60 + _to.minute;
    if (toMin <= fromMin) {
      AppSnack.show('End time must be after the start time', error: true);
      return;
    }
    setState(() => _busy = true);
    final error = await context.read<AdminController>().addBusy(
          date: Fmt.ymd(_date),
          from: Fmt.hm(_from),
          to: Fmt.hm(_to),
          serviceId: _serviceId,
          reason: _reason.text,
          info: (m) => AppSnack.show(m),
        );
    if (!mounted) return;
    setState(() => _busy = false);
    if (error == null) {
      Navigator.of(context).pop();
    } else {
      AppSnack.show(error, error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final services = context.watch<AdminController>().services;
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 0, 24, MediaQuery.viewInsetsOf(context).bottom + 20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle(title: 'Mark time as busy'),
            const SizedBox(height: 16),
            _PickerTile(icon: Icons.calendar_today_rounded, label: 'Date', value: Fmt.date(_date), onTap: _pickDate),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _PickerTile(icon: Icons.schedule_rounded, label: 'From', value: _from.format(context), onTap: () => _pickTime(true))),
                const SizedBox(width: 10),
                Expanded(child: _PickerTile(icon: Icons.schedule_rounded, label: 'To', value: _to.format(context), onTap: () => _pickTime(false))),
              ],
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String?>(
              value: _serviceId,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Applies to', prefixIcon: Icon(Icons.design_services_rounded, color: KColors.primary)),
              items: [
                const DropdownMenuItem<String?>(value: null, child: Text('All services')),
                for (final s in services) DropdownMenuItem<String?>(value: s.id, child: Text(s.name, overflow: TextOverflow.ellipsis)),
              ],
              onChanged: (v) => setState(() => _serviceId = v),
            ),
            const SizedBox(height: 14),
            TextField(controller: _reason, maxLength: 120, decoration: const InputDecoration(labelText: 'Reason (optional)', hintText: 'e.g. Public holiday')),
            const SizedBox(height: 8),
            KButton(label: 'Save busy time', icon: Icons.event_busy_rounded, isLoading: _busy, onPressed: _save),
            const SizedBox(height: 6),
            KText(text: 'Existing bookings in this window are not cancelled automatically. Review them in Requests.', fontSize: 12, color: KColors.textSecondary, height: 1.4),
          ],
        ),
      ),
    );
  }
}

class _PickerTile extends StatelessWidget {
  const _PickerTile({required this.icon, required this.label, required this.value, required this.onTap});
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: KColors.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                KText(text: label, fontSize: 11.5, color: KColors.textSecondary),
                KText(text: value, fontWeight: FontWeight.w700, maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
