import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobimart/supabase_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'cart_page.dart';
import 'auth_pages.dart';
import 'order_history_page.dart';
import 'product_details.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> filteredProducts = [];
  List<Map<String, dynamic>> cart = [];
  String? errorMessage;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadCart();
    _fetchProducts();
  }

  Future<void> _loadCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartString = prefs.getString('cart');
      if (cartString != null) {
        final List<dynamic> decoded = jsonDecode(cartString);
        setState(() {
          cart = List<Map<String, dynamic>>.from(decoded);
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load cart.';
      });
    }
  }

  Future<void> _saveCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cart', jsonEncode(cart));
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to save cart.';
      });
    }
  }

  Future<void> _fetchProducts() async {
    try {
      final List<dynamic> response = await SupabaseManager.client
          .from('product')
          .select()
          .order('created_at', ascending: false);
      setState(() {
        products = List<Map<String, dynamic>>.from(response);
        _filterProducts();
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching products.';
      });
      print('Error fetching products: $e');
    }
  }

  void _addToCart(Map<String, dynamic> product) {
    setState(() {
      cart.add(product);
    });
    _saveCart();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${product['name']} added to cart!')),
    );
  }

  void _filterProducts() {
    if (searchQuery.isEmpty) {
      filteredProducts = List<Map<String, dynamic>>.from(products);
    } else {
      filteredProducts = products
          .where((p) => (p['name'] ?? '').toString().toLowerCase().contains(searchQuery.toLowerCase()) ||
              (p['description'] ?? '').toString().toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    }
    setState(() {});
  }

  void _updateCart(List<Map<String, dynamic>> updatedCart) {
    setState(() {
      cart = updatedCart;
    });
    _saveCart();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/logo.png', // Your logo
          height: 50,
        ),
        centerTitle: true,
        backgroundColor: Colors.pink,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Profile',
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
          IconButton(
            icon: const Icon(Icons.receipt_long),
            tooltip: 'Order History',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const OrderHistoryPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: () async {
              await SupabaseManager.client.auth.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const AuthPage()),
              );
            },
          ),
        ],
      ),
      body: errorMessage != null
          ? Center(child: Text(errorMessage!))
          : products.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: 'Search products...',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          searchQuery = value;
                          _filterProducts();
                        },
                      ),
                    ),
                    Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.all(10),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 0.7,
                        ),
                        itemCount: filteredProducts.length,
                        itemBuilder: (context, index) {
                          final product = filteredProducts[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ProductDetailsPage(
                                    id: product['id'],
                                    title: product['name'] ?? '',
                                    price: product['price'],
                                    imageUrl: product['image_url'] ?? '',
                                    // description: product['description'] ?? '', // Remove if not in ProductDetailsPage
                                  ),
                                ),
                              );
                            },
                            child: Card(
                              elevation: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    child: product['image_url'] != null && product['image_url'].toString().isNotEmpty
                                        ? Image.network(
                                            product['image_url'],
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 60),
                                          )
                                        : const Icon(Icons.image_not_supported, size: 60),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      children: [
                                        Text(
                                          product['name'] ?? '',
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          '${product['price']} XAF',
                                          style: const TextStyle(color: Colors.green, fontSize: 14),
                                        ),
                                        const SizedBox(height: 5),
                                        ElevatedButton(
                                          onPressed: () => _addToCart(product),
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.green,
                                              foregroundColor: Colors.white),
                                          child: const Text("Add to Cart"),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final updatedCart = await Navigator.push<List<Map<String, dynamic>>>(
            context,
            MaterialPageRoute(
              builder: (_) => CartPage(cart: List<Map<String, dynamic>>.from(cart)),
            ),
          );
          if (updatedCart != null) {
            _updateCart(updatedCart);
          }
        },
        backgroundColor: Colors.pink,
        child: const Icon(Icons.shopping_cart),
      ),
  );
  }
}
