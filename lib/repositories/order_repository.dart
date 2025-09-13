// lib/repositories/order_repository.dart
import '../models/order.dart';

class OrderRepository {
  final List<Order> _orders = [];

  List<Order> fetchOrders() {
    return List.unmodifiable(_orders);
  }

  void saveOrder(Order order) {
    _orders.add(order);
  }
}