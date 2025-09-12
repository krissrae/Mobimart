// product_details.dart
import 'package:flutter/material.dart';
import 'package:mobimart/supabase_manager.dart';

class ProductDetailsPage extends StatelessWidget {
  final int id;
  final String title;
  final dynamic price;
  final String imageUrl;

  const ProductDetailsPage({super.key, 
    required this.id,
    required this.title,
    required this.price,
    required this.imageUrl,
  });

  /// 🟢 Add item to Supabase cart
  Future<void> _addToCart() async {
    final user = SupabaseManager.client.auth.currentUser;
    if (user == null) return;

    // Check if item already exists
    final existing = await SupabaseManager.client
        .from('cart')
        .select()
        .eq('user_id', user.id)
        .eq('product_id', id)
        .execute();

    if (existing.data != null && (existing.data as List).isNotEmpty) {
      // Increment quantity if exists
      final cartItemId = existing.data[0]['id'];
      await SupabaseManager.client
          .from('cart')
          .update({'quantity': existing.data[0]['quantity'] + 1})
          .eq('id', cartItemId)
          .execute();
    } else {
      // Insert new cart item
      await SupabaseManager.client.from('cart').insert({
        'user_id': user.id,
        'product_id': id,
        'quantity': 1,
      }).execute();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Image.network(imageUrl, height: 200),
            const SizedBox(height: 20),
            Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text('₦$price', style: const TextStyle(fontSize: 20, color: Colors.pink)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await _addToCart();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Added to cart!')),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
              child: const Text('Add to Cart'),
            ),
          ],
        ),
      ),
    );
  }
}
