/// Numbers for one month (from GET /admin/stats).
class MonthSummary {
  final int total, pending, confirmed, completed, cancelled, reviews, paidCount;
  final double avgRating, revenue;

  const MonthSummary({
    this.total = 0,
    this.pending = 0,
    this.confirmed = 0,
    this.completed = 0,
    this.cancelled = 0,
    this.reviews = 0,
    this.paidCount = 0,
    this.avgRating = 0,
    this.revenue = 0,
  });

  factory MonthSummary.fromJson(Map<String, dynamic> j) {
    int i(String k) => (j[k] as num?)?.toInt() ?? 0;
    double d(String k) => (j[k] as num?)?.toDouble() ?? 0;
    return MonthSummary(
      total: i('total'),
      pending: i('pending'),
      confirmed: i('confirmed'),
      completed: i('completed'),
      cancelled: i('cancelled'),
      reviews: i('reviews'),
      paidCount: i('paidCount'),
      avgRating: d('avgRating'),
      revenue: d('revenue'),
    );
  }
}

class MonthPoint {
  final String month; // yyyy-MM
  final int total, completed, cancelled, reviews;

  const MonthPoint({required this.month, this.total = 0, this.completed = 0, this.cancelled = 0, this.reviews = 0});

  factory MonthPoint.fromJson(Map<String, dynamic> j) => MonthPoint(
        month: (j['month'] ?? '').toString(),
        total: (j['total'] as num?)?.toInt() ?? 0,
        completed: (j['completed'] as num?)?.toInt() ?? 0,
        cancelled: (j['cancelled'] as num?)?.toInt() ?? 0,
        reviews: (j['reviews'] as num?)?.toInt() ?? 0,
      );
}

class TopService {
  final String name;
  final int bookings;
  const TopService({required this.name, required this.bookings});

  factory TopService.fromJson(Map<String, dynamic> j) =>
      TopService(name: (j['name'] ?? '').toString(), bookings: (j['bookings'] as num?)?.toInt() ?? 0);
}

class AdminStats {
  final String month;
  final MonthSummary summary;
  final List<MonthPoint> series;
  final List<TopService> topServices;
  final int customers, activeServices, pendingRequests;

  const AdminStats({
    required this.month,
    required this.summary,
    required this.series,
    required this.topServices,
    this.customers = 0,
    this.activeServices = 0,
    this.pendingRequests = 0,
  });

  factory AdminStats.fromJson(Map<String, dynamic> j) {
    List<Map<String, dynamic>> list(dynamic v) =>
        v is List ? v.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList() : <Map<String, dynamic>>[];
    final overall = j['overall'] is Map ? Map<String, dynamic>.from(j['overall'] as Map) : <String, dynamic>{};
    return AdminStats(
      month: (j['month'] ?? '').toString(),
      summary: MonthSummary.fromJson(j['summary'] is Map ? Map<String, dynamic>.from(j['summary'] as Map) : {}),
      series: list(j['series']).map(MonthPoint.fromJson).toList(),
      topServices: list(j['topServices']).map(TopService.fromJson).toList(),
      customers: (overall['customers'] as num?)?.toInt() ?? 0,
      activeServices: (overall['activeServices'] as num?)?.toInt() ?? 0,
      pendingRequests: (overall['pendingRequests'] as num?)?.toInt() ?? 0,
    );
  }
}

/// A time range the business is not available.
class BusyBlock {
  final String id;
  final String? serviceName; // null = all services
  final DateTime startAt;
  final DateTime endAt;
  final String reason;

  const BusyBlock({required this.id, required this.serviceName, required this.startAt, required this.endAt, required this.reason});

  factory BusyBlock.fromJson(Map<String, dynamic> j) {
    final svc = j['service'];
    return BusyBlock(
      id: (j['id'] ?? j['_id'] ?? '').toString(),
      serviceName: svc is Map ? (svc['name'] ?? '').toString() : null,
      startAt: DateTime.parse(j['startAt'].toString()).toLocal(),
      endAt: DateTime.parse(j['endAt'].toString()).toLocal(),
      reason: (j['reason'] ?? '').toString(),
    );
  }
}
