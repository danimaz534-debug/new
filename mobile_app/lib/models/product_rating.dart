class ProductRating {
  ProductRating({
    required this.productId,
    required this.averageRating,
    required this.totalReviews,
  });

  final String productId;
  final double averageRating;
  final int totalReviews;

  factory ProductRating.fromMap(Map<String, dynamic> map) {
    return ProductRating(
      productId: (map['product_id'] ?? '').toString(),
      averageRating: double.tryParse((map['average_rating'] ?? 0).toString()) ?? 0.0,
      totalReviews: int.tryParse((map['total_reviews'] ?? 0).toString()) ?? 0,
    );
  }
}
