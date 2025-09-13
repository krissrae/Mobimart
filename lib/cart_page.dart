import 'package:flutter/material.dart';
import 'package:mobimart/supabase_manager.dart';
import 'payment_page.dart';
import 'confirmation_page.dart';

class CartPage extends StatefulWidget {
  final List<Map<String, dynamic>> cart; // List of products in cart
  const CartPage({super.key, required this.cart});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late List<Map<String, dynamic>> _cart;

  @override
  void initState() {
    super.initState();
    _cart = List<Map<String, dynamic>>.from(widget.cart);
  }

  double get totalPrice {
    double total = 0;
    for (var item in _cart) {
      total += item['price'] ?? 0;
    }
    return total;
  }

  /// Remove item from cart
  void _removeFromCart(int index) {
    setState(() {
      _cart.removeAt(index);
    });
  }

  void _checkout() async {
    if (_cart.isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentPage(
          total: totalPrice,
          onPaymentSuccess: () async {
            final user = SupabaseManager.client.auth.currentUser;
            if (user == null) return;
            try {
              for (var item in _cart) {
                await SupabaseManager.client.from('orders').insert({
                  'product_id': item['id'],
                  'user_id': user.id,
                  'total_price': item['price'],
                  'status': 'pending',
                });
              }
              setState(() {
                _cart.clear();
              });
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => ConfirmationPage(
                    message:
                        'Order placed! You will be notified when validated.',
                  ),
                ),
                (route) => route.isFirst,
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Error validating order: $e")),
              );
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Cart"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, _cart);
          },
        ),
      ),
      body: _cart.isEmpty
          ? const Center(child: Text("Your cart is empty"))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: _cart.length,
                    itemBuilder: (context, index) {
                      final item = _cart[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 12.0,
                        ),
                        child: ListTile(
                          leading:
                              item['image_url'] != null &&
                                  item['image_url'].toString().isNotEmpty
                              ? Image.network(
                                  item['image_url'],
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.broken_image, size: 30),
                                )
                              : const Icon(Icons.image_not_supported, size: 30),
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Total: $totalPrice XAF",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _cart.isEmpty ? null : _checkout,
                        style: ElevatedButton.styleFrom(
                          foregroundColor:
                              Colors.white, // Ensures label is white
                        ),
                        child: const Text("Checkout"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
