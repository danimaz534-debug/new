class Review {
  Review({
    required this.id,
    required this.userId,
    required this.productId,
    required this.rating,
    required this.comment,
    required this.createdAt,
    required this.reviewerName,
    required this.reviewerEmail,
  });

  final String id;
  final String userId;
  final String productId;
  final int rating;
  final String comment;
  final DateTime? createdAt;
  final String reviewerName;
  final String reviewerEmail;

  factory Review.fromMap(Map<String, dynamic> map) {
    final profile = map['profiles'];
    final profileMap = profile is Map<String, dynamic>
        ? profile
        : profile is Map
        ? Map<String, dynamic>.from(profile)
        : <String, dynamic>{};

    return Review(
      id: map['id'].toString(),
      userId: (map['user_id'] ?? '').toString(),
      productId: (map['product_id'] ?? '').toString(),
      rating: int.tryParse((map['rating'] ?? 0).toString()) ?? 0,
      comment: (map['comment'] ?? '').toString(),
      createdAt: map['created_at'] == null
          ? null
          : DateTime.tryParse(map['created_at'].toString()),
      reviewerName: (profileMap['full_name'] ?? '').toString(),
      reviewerEmail: (profileMap['email'] ?? '').toString(),
    );
  }
}
