import 'package:flutter/material.dart';

class PayPayment extends StatefulWidget {
  const PayPayment({super.key});

  @override
  State<PayPayment> createState() => _PayPaymentState();
}

class _PayPaymentState extends State<PayPayment> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Text('pay Payment'),
      ),
    );
  }
}
