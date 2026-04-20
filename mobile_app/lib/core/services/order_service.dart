import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/order_summary.dart';

class OrderService {
  OrderService() : _client = Supabase.instance.client;

  final SupabaseClient _client;

  Future<List<OrderSummary>> fetchOrders() async {
    final user = _client.auth.currentUser;
    if (user == null) return [];

    final response = await _client
        .from('orders')
        .select('*, order_items(*, product:products(*))')
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    return (response as List)
        .map((item) => OrderSummary.fromMap(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  Future<OrderSummary> createOrderFromCart({
    required String paymentMethod,
    required Map<String, dynamic> shippingAddress,
  }) async {
    final result = await _client.rpc(
      'create_order_from_cart',
      params: {
        'p_payment_method': paymentMethod,
        'p_shipping_address': shippingAddress,
      },
    );

    return OrderSummary.fromMap(Map<String, dynamic>.from(result as Map));
  }
}
