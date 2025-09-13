import 'package:flutter_test/flutter_test.dart';
import 'package:mobimart/providers/order_provider.dart';
import 'package:mobimart/models/order.dart';

void main() {
  group('OrderProvider', () {
    test('should add and retrieve orders', () {
      final provider = OrderProvider();
      final order = Order(
        id: '1',
        productIds: ['p1', 'p2'],
        total: 100.0,
        date: DateTime.now(),
      );

      provider.addOrder(order);

      expect(provider.orders.length, 1);
      expect(provider.orders.first.id, '1');
    });
  });
}