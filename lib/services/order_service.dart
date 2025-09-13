// lib/services/order_service.dart
import '../models/order.dart';

class OrderService {
  final List<Order> _orders = [];

  List<Order> getOrders() {
    return List.unmodifiable(_orders);
  }

  void addOrder(Order order) {
    _orders.add(order);
  }
}