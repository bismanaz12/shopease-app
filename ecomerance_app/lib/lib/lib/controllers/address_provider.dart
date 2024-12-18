import 'package:flutter/material.dart';

class AddressProvider with ChangeNotifier {
  String _currentAddress = '';

  String get currentAddress => _currentAddress;

  void updateAddress(String newAddress) {
    _currentAddress = newAddress;
    notifyListeners();
  }
}