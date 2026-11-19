import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../app/utils.dart';
import '../../../../core/services/api_service/api_services.dart';
import '../../../../core/services/network/network_response.dart';
import '../../models/service_model.dart';

class HomeController extends ChangeNotifier {
  static const double priceCeiling = 10000;

  final ApiServices _api = ApiServices.instance;

  ViewState state = ViewState.idle;
  String? error;
  List<ServiceModel> services = [];
  List<ServiceModel> featured = [];
  List<String> categories = [];

  String search = '';
  String? category;
  String sort = 'popular';
  double minPrice = 0;
  double maxPrice = priceCeiling;

  Timer? _debounce;
  int _requestId = 0;

  bool get hasFilters =>
      search.isNotEmpty ||
      category != null ||
      sort != 'popular' ||
      minPrice > 0 ||
      maxPrice < priceCeiling;

  /// Price / sort filters (not search or category chips).
  bool get hasAdvancedFilters =>
      sort != 'popular' || minPrice > 0 || maxPrice < priceCeiling;

  Future<void> init() async {
    await Future.wait([
      loadServices(showLoader: services.isEmpty),
      loadFeatured(),
      loadCategories(),
    ]);
  }

  Future<void> loadServices({bool showLoader = true}) async {
    final id = ++_requestId;
    if (showLoader) {
      state = ViewState.loading;
      notifyListeners();
    }
    final res = await _api.services(
      search: search.isEmpty ? null : search,
      category: category,
      sort: sort,
      minPrice: minPrice > 0 ? minPrice : null,
      maxPrice: maxPrice < priceCeiling ? maxPrice : null,
    );
    if (id != _requestId) return; // a newer request superseded this one

    if (res.isSuccess) {
      services = _parse(res);
      state = ViewState.success;
      error = null;
    } else {
      error = res.errorMessage;
      state = ViewState.error;
    }
    notifyListeners();
  }

  Future<void> loadFeatured() async {
    final res = await _api.services(featuredOnly: true, limit: 10);
    if (res.isSuccess) {
      featured = _parse(res);
      notifyListeners();
    }
  }

  Future<void> loadCategories() async {
    final res = await _api.categories();
    if (res.isSuccess) {
      final list = res.dataMap['categories'];
      categories = list is List ? list.map((e) => e.toString()).toList() : [];
      notifyListeners();
    }
  }

  List<ServiceModel> _parse(NetworkResponse res) =>
      res.listOf('items').map(ServiceModel.fromJson).toList();

  void setSearch(String value) {
    search = value.trim();
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), loadServices);
  }

  void selectCategory(String? value) {
    category = value;
    notifyListeners();
    loadServices();
  }

  void applyFilters({
    required String sort,
    required double minPrice,
    required double maxPrice,
  }) {
    this.sort = sort;
    this.minPrice = minPrice;
    this.maxPrice = maxPrice;
    notifyListeners();
    loadServices();
  }

  void clearFilters() {
    search = '';
    category = null;
    sort = 'popular';
    minPrice = 0;
    maxPrice = priceCeiling;
    notifyListeners();
    loadServices();
  }

  /// Loads one service (used by the details screen). Returns null on failure.
  Future<ServiceModel?> fetchService(String id) async {
    final res = await _api.serviceById(id);
    if (!res.isSuccess) return null;

    final data = res.dataMap;
    final candidates = [data['service'], data['item'], data];
    for (final candidate in candidates) {
      if (candidate is Map) {
        final map = Map<String, dynamic>.from(candidate);
        if (map['id'] != null || map['_id'] != null || map['name'] != null) {
          return ServiceModel.fromJson(map);
        }
      }
    }
    return null;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
