import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/cart_entry.dart';

class CartService {
  CartService() : _client = Supabase.instance.client;

  final SupabaseClient _client;

  Future<List<CartEntry>> fetchCart() async {
    final user = _client.auth.currentUser;
    if (user == null) return [];

    final response = await _client
        .from('cart_items')
        .select('id, product_id, quantity, created_at, product:products(*)')
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    return (response as List)
        .map((item) => CartEntry.fromMap(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  Future<void> addToCart({
    required String productId,
    int quantity = 1,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw StateError('Create an account to add products to cart.');
    }

    final existing = await _client
        .from('cart_items')
        .select('id, quantity')
        .eq('user_id', user.id)
        .eq('product_id', productId)
        .maybeSingle();

    if (existing != null) {
      final currentQuantity =
          int.tryParse((existing['quantity'] ?? 0).toString()) ?? 0;
      await _client
          .from('cart_items')
          .update({'quantity': currentQuantity + quantity})
          .eq('id', existing['id']);
      return;
    }

    await _client.from('cart_items').insert({
      'user_id': user.id,
      'product_id': productId,
      'quantity': quantity,
    });
  }

  Future<void> updateQuantity({
    required String itemId,
    required int quantity,
  }) async {
    if (quantity <= 0) {
      await removeItem(itemId);
      return;
    }

    await _client.from('cart_items').update({'quantity': quantity}).eq('id', itemId);
  }

  Future<void> removeItem(String itemId) {
    return _client.from('cart_items').delete().eq('id', itemId);
  }

  Future<void> clearCart() async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    await _client.from('cart_items').delete().eq('user_id', user.id);
  }
}
