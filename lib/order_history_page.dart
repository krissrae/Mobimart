import 'package:flutter/material.dart';
import 'package:mobimart/supabase_manager.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  List<Map<String, dynamic>> orders = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() => loading = true);
    final user = SupabaseManager.client.auth.currentUser;
    if (user != null) {
      final response = await SupabaseManager.client
          .from('orders')
          .select('id, total_price, created_at, status')
          .eq('user_id', user.id)
          .order('created_at', ascending: false);
      setState(() {
        orders = List<Map<String, dynamic>>.from(response);
        loading = false;
      });
    } else {
      setState(() {
        orders = [];
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order History')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : orders.isEmpty
          ? const Center(child: Text('No orders yet.'))
          : ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    title: Text('Order #${order['id']}'),
                    subtitle: Text(
                      'Total: ₦${order['total_price']?.toStringAsFixed(2) ?? order['total_price'] ?? ''}\nDate: ${order['created_at']?.toString().split('T').first ?? ''}\nStatus: ${order['status'] ?? ''}',
                    ),
                  ),
                );
              },
            ),
    );
  }
}
