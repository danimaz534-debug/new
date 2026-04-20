import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/product.dart';

class CatalogService {
  CatalogService() : _client = Supabase.instance.client;

  final SupabaseClient _client;

  Future<List<Product>> fetchProducts() async {
    final response = await _client
        .from('products')
        .select('*')
        .order('created_at', ascending: false);

    return (response as List)
        .map((item) => Product.fromMap(Map<String, dynamic>.from(item as Map)))
        .toList();
  }
}
