import 'package:flutter/material.dart';
import 'package:mobimart/supabase_manager.dart';

class AdminOrdersPage extends StatefulWidget {
  const AdminOrdersPage({Key? key}) : super(key: key);

  @override
  State<AdminOrdersPage> createState() => _AdminOrdersPageState();
}

class _AdminOrdersPageState extends State<AdminOrdersPage> {
  List<Map<String, dynamic>> orders = [];
  bool loading = false;
  String? error;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final response = await SupabaseManager.client
          .from('orders')
          .select(
            'id, product_id, user_id, total_price, status, created_at, product(name, image_url), profiles(name)',
          )
          .order('created_at', ascending: false);
      setState(() {
        orders = List<Map<String, dynamic>>.from(response);
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Failed to load orders.';
        loading = false;
      });
    }
  }

  Future<void> _updateOrderStatus(int orderId, String status) async {
    await SupabaseManager.client
        .from('orders')
        .update({'status': status})
        .eq('id', orderId);
    _fetchOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin - Orders')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(child: Text(error!))
          : orders.isEmpty
          ? const Center(child: Text('No orders found.'))
          : ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, i) {
                final order = orders[i];
                final product = order['product'] ?? {};
                final user = order['profiles'] ?? {};
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    leading: product['image_url'] != null
                        ? Image.network(
                            product['image_url'],
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          )
                        : const Icon(Icons.image, size: 50),
                    title: Text(product['name'] ?? 'Product'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('User: ${user['name'] ?? order['user_id']}'),
                        Text('Total: ${order['total_price']} XAF'),
                        Text('Status: ${order['status']}'),
                        Text('Date: ${order['created_at']}'),
                      ],
                    ),
                    trailing: order['status'] == 'pending'
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ElevatedButton.icon(
                                icon: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                ),
                                label: const Text(
                                  'Approve',
                                  style: TextStyle(color: Colors.white),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                ),
                                onPressed: () =>
                                    _updateOrderStatus(order['id'], 'approved'),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton.icon(
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                ),
                                label: const Text(
                                  'Reject',
                                  style: TextStyle(color: Colors.white),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                onPressed: () =>
                                    _updateOrderStatus(order['id'], 'rejected'),
                              ),
                            ],
                          )
                        : null,
                  ),
                );
              },
            ),
    );
  }
}
