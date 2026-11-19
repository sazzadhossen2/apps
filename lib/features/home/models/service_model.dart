class ServiceModel {
  final String id;
  final String name;
  final String description;
  final String image;
  final String category;
  final double price;
  final int durationMinutes;
  final bool isFeatured;
  final double rating;
  final int bookingsCount;
  final int reviewsCount;
  final bool isActive;

  const ServiceModel({
    required this.id,
    required this.name,
    this.description = '',
    this.image = '',
    this.category = '',
    this.price = 0,
    this.durationMinutes = 60,
    this.isFeatured = false,
    this.rating = 0,
    this.bookingsCount = 0,
    this.reviewsCount = 0,
    this.isActive = true,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> j) => ServiceModel(
        id: (j['id'] ?? j['_id'] ?? '').toString(),
        name: (j['name'] ?? '').toString(),
        description: (j['description'] ?? '').toString(),
        image: (j['image'] ?? '').toString(),
        category: (j['category'] ?? '').toString(),
        price: (j['price'] as num?)?.toDouble() ?? 0,
        durationMinutes: (j['durationMinutes'] as num?)?.toInt() ?? 60,
        isFeatured: j['isFeatured'] == true,
        rating: (j['rating'] as num?)?.toDouble() ?? 0,
        bookingsCount: (j['bookingsCount'] as num?)?.toInt() ?? 0,
        reviewsCount: (j['reviewsCount'] as num?)?.toInt() ?? 0,
        isActive: j['isActive'] != false,
      );
}
