import 'package:flutter/material.dart';
import 'package:mobimart/supabase_manager.dart';

class CartPage extends StatefulWidget {
  final List<Map<String, dynamic>> cart; // List of products in cart
  const CartPage({super.key, required this.cart});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  double get totalPrice {
    double total = 0;
    for (var item in widget.cart) {
      total += item['price'] ?? 0;
    }
    return total;
  }

  /// Remove item from cart
  void _removeFromCart(int index) {
    setState(() {
      widget.cart.removeAt(index);
    });
  }

  /// Validate order and insert into order table
  Future<void> _validateOrder() async {
    final user = SupabaseManager.client.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not logged in")),
      );
      return;
    }

    try {
      // Insert each product as an order row
      for (var item in widget.cart) {
        await SupabaseManager.client.from('orders').insert({
          'product_id': item['id'], // your product id
          'user_id': user.id,
          'total_price': item['price'],
          'status': 'pending', // or whatever default
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Order validated!")),
      );

      // Clear cart
      setState(() {
        widget.cart.clear();
      });

      // Optionally, navigate back or refresh home
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error validating order: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Cart"),
      ),
      body: widget.cart.isEmpty
          ? const Center(child: Text("Your cart is empty"))
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: widget.cart.length,
              itemBuilder: (context, index) {
                final item = widget.cart[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 12.0),
                  child: ListTile(
                    leading: item['image_url'] != null
                        ? Image.network(
                      item['image_url'],
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    )
                        : const SizedBox(width: 50, height: 50),
                    title: Text(item['name'] ?? "Unnamed"),
                    subtitle: Text("${item['price'] ?? 0} XAF"),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeFromCart(index),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  "Total: ${totalPrice.toStringAsFixed(0)} XAF",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: widget.cart.isEmpty ? null : _validateOrder,
                  child: const Text("Validate Order"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
