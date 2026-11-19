class ReviewModel {
  final String id;
  final String userName;
  final String serviceName;
  final int rating;
  final String comment;
  final DateTime createdAt;

  const ReviewModel({
    required this.id,
    required this.userName,
    required this.serviceName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> j) {
    final user = j['user'];
    final service = j['service'];
    return ReviewModel(
      id: (j['id'] ?? j['_id'] ?? '').toString(),
      userName: user is Map ? (user['name'] ?? 'Customer').toString() : 'Customer',
      serviceName: service is Map ? (service['name'] ?? '').toString() : '',
      rating: (j['rating'] as num?)?.toInt() ?? 0,
      comment: (j['comment'] ?? '').toString(),
      createdAt: DateTime.tryParse((j['createdAt'] ?? '').toString())?.toLocal() ?? DateTime.now(),
    );
  }
}
