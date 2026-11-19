import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/kcolor.dart';
import '../../../../app/utils.dart';
import '../../../../utils/widgets/common_widgets.dart';
import '../../../../utils/widgets/kbutton.dart';
import '../../../../utils/widgets/ktext.dart';
import '../../../../utils/widgets/state_views.dart';
import '../../../auth/ui/controller/auth_controller.dart';
import '../../../details/ui/screens/service_details_screen.dart';
import '../../../navigation_menu/ui/screens/main_shell.dart';
import '../../models/service_model.dart';
import '../controller/home_controller.dart';
import '../widget/service_card.dart';



class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<HomeController>().init());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _open(ServiceModel s) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => ServiceDetailsScreen(serviceId: s.id, initial: s)));
  }

  void _openFilters() {
    final home = context.read<HomeController>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _FilterSheet(
        sort: home.sort,
        range: RangeValues(home.minPrice, home.maxPrice),
        onApply: (sort, range) => home.applyFilters(sort: sort, minPrice: range.start, maxPrice: range.end),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final home = context.watch<HomeController>();
    final user = context.watch<AuthController>().user;
    final side = Responsive.side(context);
    final showFeatured = !home.hasFilters && home.featured.isNotEmpty;

    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        color: KColors.primary,
        onRefresh: home.init,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // ---------- Header + search ----------
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(side, 16, side, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              KText(text: 'Hello, ${user?.firstName ?? 'there'}', fontSize: 22, fontWeight: FontWeight.w800, maxLines: 1, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 2),
                              KText(text: 'What service do you need today?', color: KColors.textSecondary),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => MainShell.tab.value = 3,
                          child: CircleAvatar(
                            radius: 22,
                            backgroundColor: KColors.primary,
                            child: Text(user?.initial ?? '?', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchCtrl,
                            textInputAction: TextInputAction.search,
                            onChanged: (v) {
                              home.setSearch(v);
                              setState(() {});
                            },
                            decoration: InputDecoration(
                              hintText: 'Search services',
                              prefixIcon: const Icon(Icons.search_rounded, color: KColors.textSecondary),
                              suffixIcon: _searchCtrl.text.isEmpty
                                  ? null
                                  : IconButton(
                                      icon: const Icon(Icons.close_rounded, size: 20),
                                      onPressed: () {
                                        _searchCtrl.clear();
                                        home.setSearch('');
                                        setState(() {});
                                      },
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: _openFilters,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                width: 54,
                                height: 54,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(colors: KColors.gradient),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(Icons.tune_rounded, color: Colors.white),
                              ),
                              if (home.hasAdvancedFilters)
                                Positioned(
                                  top: -3,
                                  right: -3,
                                  child: Container(
                                    width: 14,
                                    height: 14,
                                    decoration: BoxDecoration(color: KColors.accent, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ---------- Category chips ----------
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: SizedBox(
                  height: 42,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: side),
                    children: [
                      _chip('All', home.category == null, () => home.selectCategory(null)),
                      for (final c in home.categories) _chip(c, home.category == c, () => home.selectCategory(c)),
                    ],
                  ),
                ),
              ),
            ),

            // ---------- Featured ----------
            if (showFeatured) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(side, 22, side, 12),
                  child: const SectionTitle(title: 'Featured services'),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 190,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: side),
                    itemCount: home.featured.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 14),
                    itemBuilder: (_, i) => FeaturedCard(service: home.featured[i], onTap: () => _open(home.featured[i])),
                  ),
                ),
              ),
            ],

            // ---------- All services ----------
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(side, 22, side, 12),
                child: SectionTitle(
                  title: home.hasFilters ? 'Results' : 'All services',
                  trailing: home.state == ViewState.success
                      ? KText(text: '${home.services.length} found', color: KColors.textSecondary, fontSize: 13)
                      : null,
                ),
              ),
            ),
            if (home.state == ViewState.loading && home.services.isNotEmpty)
              const SliverToBoxAdapter(child: LinearProgressIndicator(minHeight: 2, color: KColors.primary, backgroundColor: KColors.mint)),
            ..._body(home, side),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  List<Widget> _body(HomeController home, double side) {
    if (home.state == ViewState.loading && home.services.isEmpty) {
      return [const SliverToBoxAdapter(child: SizedBox(height: 260, child: LoadingView(message: 'Loading services...')))];
    }
    if (home.state == ViewState.error && home.services.isEmpty) {
      return [
        SliverToBoxAdapter(
          child: SizedBox(height: 320, child: ErrorView(message: home.error ?? 'Could not load services.', onRetry: home.init)),
        ),
      ];
    }
    if (home.state == ViewState.success && home.services.isEmpty) {
      return [
        SliverToBoxAdapter(
          child: SizedBox(
            height: 320,
            child: EmptyView(
              icon: Icons.search_off_rounded,
              title: 'No services found',
              subtitle: home.hasFilters ? 'Try a different search or clear your filters.' : 'There are no services available right now.',
              actionLabel: home.hasFilters ? 'Clear filters' : null,
              onAction: home.hasFilters
                  ? () {
                      _searchCtrl.clear();
                      home.clearFilters();
                    }
                  : null,
            ),
          ),
        ),
      ];
    }
    return [
      SliverPadding(
        padding: EdgeInsets.symmetric(horizontal: side),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 560,
            mainAxisExtent: 116,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
          ),
          delegate: SliverChildBuilderDelegate(
            (_, i) => ServiceCard(service: home.services[i], onTap: () => _open(home.services[i])),
            childCount: home.services.length,
          ),
        ),
      ),
    ];
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        showCheckmark: false,
        onSelected: (_) => onTap(),
        selectedColor: KColors.primary,
        backgroundColor: KColors.surface,
        shape: StadiumBorder(side: BorderSide(color: selected ? KColors.primary : KColors.border)),
        labelStyle: TextStyle(color: selected ? Colors.white : KColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 13.5),
      ),
    );
  }
}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({required this.sort, required this.range, required this.onApply});

  final String sort;
  final RangeValues range;
  final void Function(String sort, RangeValues range) onApply;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late String _sort = widget.sort;
  late RangeValues _range = widget.range;

  static const _sorts = {
    'popular': 'Most popular',
    'rating': 'Top rated',
    'price_asc': 'Price: low to high',
    'price_desc': 'Price: high to low',
    'newest': 'Newest',
  };

  @override
  Widget build(BuildContext context) {
    final maxLabel = _range.end >= HomeController.priceCeiling ? '${Fmt.price(HomeController.priceCeiling)}+' : Fmt.price(_range.end);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle(title: 'Filter & sort'),
              const SizedBox(height: 18),
              KText(text: 'Sort by', fontWeight: FontWeight.w700),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final e in _sorts.entries)
                    ChoiceChip(
                      label: Text(e.value),
                      selected: _sort == e.key,
                      showCheckmark: false,
                      onSelected: (_) => setState(() => _sort = e.key),
                      selectedColor: KColors.primary,
                      backgroundColor: KColors.surface,
                      shape: StadiumBorder(side: BorderSide(color: _sort == e.key ? KColors.primary : KColors.border)),
                      labelStyle: TextStyle(color: _sort == e.key ? Colors.white : KColors.textPrimary, fontWeight: FontWeight.w600),
                    ),
                ],
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  KText(text: 'Price range', fontWeight: FontWeight.w700),
                  const Spacer(),
                  KText(text: '${Fmt.price(_range.start)} – $maxLabel', color: KColors.primary, fontWeight: FontWeight.w700),
                ],
              ),
              RangeSlider(
                values: _range,
                min: 0,
                max: HomeController.priceCeiling,
                divisions: 100,
                activeColor: KColors.primary,
                inactiveColor: KColors.mint,
                onChanged: (v) => setState(() => _range = v),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: KButton(
                      label: 'Reset',
                      type: KButtonType.outline,
                      onPressed: () => setState(() {
                        _sort = 'popular';
                        _range = const RangeValues(0, HomeController.priceCeiling);
                      }),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: KButton(
                      label: 'Apply',
                      onPressed: () {
                        Navigator.of(context).pop();
                        widget.onApply(_sort, _range);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
