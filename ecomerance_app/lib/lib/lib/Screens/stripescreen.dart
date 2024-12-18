import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

class PaymentController with ChangeNotifier {
  Map<String, dynamic>? paymentIntentData;

  Future<void> makePayment({
    required String amount,
    required String currency,
    required VoidCallback addSubFunction,
  }) async {
    try {
      paymentIntentData = await createPaymentIntent(amount, currency);
      if (paymentIntentData != null) {
        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            merchantDisplayName: 'Prospects',
            customerId: paymentIntentData!['customer'],
            paymentIntentClientSecret: paymentIntentData!['client_secret'],
            customerEphemeralKeySecret: paymentIntentData!['ephemeralKey'],
            style: ThemeMode.system,
          ),
        );

        displayPaymentSheet(addSubFunction);
      }
    } catch (e) {
      // Handle error appropriately
      log('Error in makePayment: $e');
    }
  }

  Future<void> displayPaymentSheet(VoidCallback addSubFunction) async {
    try {
      await Stripe.instance.presentPaymentSheet();

      // Payment successful, execute the callback
      addSubFunction();
    } on StripeException catch (e) {
      log("Error from Stripe: ${e.error.localizedMessage}");
    } catch (e) {
      log("Unforeseen error: $e");
    }
  }

  Future<Map<String, dynamic>> createPaymentIntent(
      String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': calculateAmount(amount),
        'currency': currency,
        'payment_method_types[]': 'card',
      };

      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        body: body,
        headers: {
          'Authorization':
          'Bearer sk_test_51PlB8iBwFdLEhpT1aOVSUaR71WGGAnDB4eIC2fiG5gg6gQ5HFKPZdoFjq6qw00bonxZpxnjoz6FVOS92SphJhF8Q00Z2yMYHBd',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      );

      return jsonDecode(response.body);
    } catch (err) {
      log('err charging user: ${err.toString()}');
      return {};
    }
  }

  String calculateAmount(String amount) {
    final a = (int.parse(amount)) * 100;
    return a.toString();
  }
}
