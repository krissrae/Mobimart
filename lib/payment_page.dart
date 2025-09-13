import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PaymentPage extends StatefulWidget {
  final double total;
  final VoidCallback onPaymentSuccess;
  const PaymentPage({
    super.key,
    required this.total,
    required this.onPaymentSuccess,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String? paymentCode;
  bool paid = false;
  bool copied = false;

  void _simulatePayment() {
    setState(() {
      paymentCode = '*126*14*683694402*${widget.total.toStringAsFixed(0)}#';
      paid = true;
      copied = false;
    });
    // Do not call onPaymentSuccess yet
  }

  void _copyCode() async {
    if (paymentCode != null) {
      await Clipboard.setData(ClipboardData(text: paymentCode!));
      setState(() {
        copied = true;
      });
      // Now show success and call onPaymentSuccess
      Future.delayed(const Duration(milliseconds: 500), () {
        widget.onPaymentSuccess();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: paid
              ? !copied
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.payment,
                            color: Colors.pink,
                            size: 80,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Payment Code:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SelectableText(
                            paymentCode ?? '',
                            style: const TextStyle(
                              fontSize: 22,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.copy, color: Colors.white),
                            label: const Text(
                              'Copy Code',
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.pink,
                            ),
                            onPressed: _copyCode,
                          ),
                        ],
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 80,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Payment Successful!',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Payment Code: $paymentCode',
                            style: const TextStyle(fontSize: 18),
                          ),
                        ],
                      )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Total: ${widget.total} XAF',
                      style: TextStyle(fontSize: 22),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _simulatePayment,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, // Ensures label is white
                      ),
                      child: const Text('Simulate Mobile Money Payment'),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
