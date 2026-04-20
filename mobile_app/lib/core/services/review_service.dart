import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/review.dart';

class ReviewService {
  ReviewService() : _client = Supabase.instance.client;

  final SupabaseClient _client;

  Future<List<Review>> fetchReviews(String productId) async {
    final response = await _client
        .from('reviews')
        .select('*, profiles(full_name, email)')
        .eq('product_id', productId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((item) => Review.fromMap(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  Future<void> addReview({
    required String productId,
    required int rating,
    required String comment,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw StateError('Create an account to leave a review.');
    }

    await _client.from('reviews').insert({
      'user_id': user.id,
      'product_id': productId,
      'rating': rating,
      'comment': comment.trim(),
    });
  }
}
