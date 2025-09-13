// lib/models/order.dart
class Order {
  final String id;
  final List<String> productIds;
  final double total;
  final DateTime date;

  Order({
    required this.id,
    required this.productIds,
    required this.total,
    required this.date,
  });
}