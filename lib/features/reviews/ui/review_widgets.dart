import 'package:flutter/material.dart';

import '../../../app/kcolor.dart';
import '../../../app/utils.dart';
import '../../../core/services/api_service/api_services.dart';
import '../../../core/services/network/network_response.dart';
import '../../../utils/widgets/widgets.dart';
import '../models/review_model.dart';

/// Row of 5 stars. Tappable when [onChanged] is given.
class StarRating extends StatelessWidget {
  const StarRating({super.key, required this.value, this.size = 16, this.onChanged});
  final int value;
  final double size;
  final ValueChanged<int>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final star = Icon(i < value ? Icons.star_rounded : Icons.star_outline_rounded, color: KColors.accent, size: size);
        if (onChanged == null) return star;
        return GestureDetector(
          onTap: () => onChanged!(i + 1),
          child: Padding(padding: const EdgeInsets.symmetric(horizontal: 3), child: star),
        );
      }),
    );
  }
}

/// Bottom sheet for rating a completed booking. Returns true when the review was saved.
Future<bool> showReviewSheet(BuildContext context, {required String appointmentId, required String serviceName}) async {
  final saved = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _ReviewSheet(appointmentId: appointmentId, serviceName: serviceName),
  );
  return saved == true;
}

class _ReviewSheet extends StatefulWidget {
  const _ReviewSheet({required this.appointmentId, required this.serviceName});
  final String appointmentId;
  final String serviceName;

  @override
  State<_ReviewSheet> createState() => _ReviewSheetState();
}

class _ReviewSheetState extends State<_ReviewSheet> {
  final _comment = TextEditingController();
  int _rating = 0;
  bool _busy = false;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_rating == 0) {
      AppSnack.show('Please choose a star rating', error: true);
      return;
    }
    setState(() => _busy = true);
    final res = await ApiServices.instance.createReview(appointmentId: widget.appointmentId, rating: _rating, comment: _comment.text);
    if (!mounted) return;
    setState(() => _busy = false);
    if (res.isSuccess) {
      Navigator.of(context).pop(true);
      AppSnack.show('Thanks for your review!');
    } else {
      AppSnack.show(res.errorMessage, error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 0, 24, MediaQuery.viewInsetsOf(context).bottom + 20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle(title: 'Rate this service'),
            const SizedBox(height: 4),
            KText(text: widget.serviceName, color: KColors.textSecondary),
            const SizedBox(height: 16),
            Center(child: StarRating(value: _rating, size: 40, onChanged: (v) => setState(() => _rating = v))),
            const SizedBox(height: 16),
            TextField(
              controller: _comment,
              maxLines: 3,
              maxLength: 500,
              decoration: const InputDecoration(hintText: 'Tell others about your experience (optional)'),
            ),
            const SizedBox(height: 8),
            KButton(label: 'Submit review', isLoading: _busy, onPressed: _submit),
          ],
        ),
      ),
    );
  }
}

/// Reviews list shown on the service details screen.
class ReviewsSection extends StatefulWidget {
  const ReviewsSection({super.key, required this.serviceId});
  final String serviceId;

  @override
  State<ReviewsSection> createState() => _ReviewsSectionState();
}

class _ReviewsSectionState extends State<ReviewsSection> {
  ViewState _state = ViewState.loading;
  List<ReviewModel> _items = [];
  int _total = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _state = ViewState.loading);
    final NetworkResponse res = await ApiServices.instance.serviceReviews(widget.serviceId, limit: 10);
    if (!mounted) return;
    setState(() {
      if (res.isSuccess) {
        _items = res.listOf('items').map(ReviewModel.fromJson).toList();
        _total = (res.dataMap['total'] as num?)?.toInt() ?? _items.length;
        _state = ViewState.success;
      } else {
        _state = ViewState.error;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(title: _state == ViewState.success ? 'Reviews ($_total)' : 'Reviews'),
        const SizedBox(height: 12),
        if (_state == ViewState.loading)
          const Padding(padding: EdgeInsets.all(16), child: LoadingView())
        else if (_state == ViewState.error)
          Align(alignment: Alignment.centerLeft, child: TextButton.icon(onPressed: _load, icon: const Icon(Icons.refresh_rounded), label: const Text('Could not load reviews. Retry')))
        else if (_items.isEmpty)
          KText(text: 'No reviews yet. Be the first after your booking is completed.', color: KColors.textSecondary)
        else
          for (final r in _items) ReviewTile(review: r),
      ],
    );
  }
}

class ReviewTile extends StatelessWidget {
  const ReviewTile({super.key, required this.review, this.showService = false});
  final ReviewModel review;
  final bool showService;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: KColors.mint,
                  child: Text(review.userName.isEmpty ? '?' : review.userName[0].toUpperCase(), style: const TextStyle(color: KColors.primaryDark, fontWeight: FontWeight.w800)),
                ),
                const SizedBox(width: 10),
                Expanded(child: KText(text: review.userName, fontWeight: FontWeight.w700, maxLines: 1, overflow: TextOverflow.ellipsis)),
                StarRating(value: review.rating, size: 15),
              ],
            ),
            if (showService && review.serviceName.isNotEmpty) ...[
              const SizedBox(height: 6),
              KText(text: review.serviceName, fontSize: 12.5, color: KColors.primaryDark, fontWeight: FontWeight.w600),
            ],
            if (review.comment.isNotEmpty) ...[
              const SizedBox(height: 8),
              KText(text: review.comment, color: KColors.textSecondary, height: 1.4),
            ],
            const SizedBox(height: 6),
            KText(text: Fmt.date(review.createdAt), fontSize: 11.5, color: KColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
