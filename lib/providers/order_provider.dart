// lib/providers/order_provider.dart
import 'package:flutter/foundation.dart';
import '../models/order.dart';
import '../repositories/order_repository.dart';

class OrderProvider with ChangeNotifier {
  final OrderRepository _orderRepository = OrderRepository();

  List<Order> get orders => _orderRepository.fetchOrders();

  void addOrder(Order order) {
    _orderRepository.saveOrder(order);
    notifyListeners();
  }
}