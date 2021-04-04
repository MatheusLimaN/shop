import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shop/providers/cart.dart';

class Order {
  final String id;
  final double total;
  final List<CartItem> products;
  final DateTime date;

  Order({this.id, this.total, this.products, this.date});
}

class Orders with ChangeNotifier {
  List<Order> _items = [];

  List<Order> get items => [..._items];

  int get itemsCount => _items.length;

  void addOrder(Cart cart) {
    final products = cart.items.values.toList();
    final total = products.fold(
        0.0,
        (previousValue, element) =>
            previousValue + element.price * element.quantity);

    _items.insert(
      0,
      Order(
        id: Random().nextDouble().toString(),
        total: total,
        date: DateTime.now(),
        products: products,
      ),
    );

    notifyListeners();
  }
}
