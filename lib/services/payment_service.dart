import 'dart:math';

class PaymentService {
  static String generatePaymentCode() {
    return (Random().nextInt(900000) + 100000).toString();
  }

  static Future<bool> simulatePayment(double amount) async {
    await Future.delayed(const Duration(seconds: 2));
    return true;
  }
}
