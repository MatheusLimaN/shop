import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shop/constants/endpoints.dart';
import 'package:shop/providers/cart.dart';

class Order {
  final String id;
  final double total;
  final List<CartItem> products;
  final DateTime date;

  Order({this.id, this.total, this.products, this.date});
}

class Orders with ChangeNotifier {
  final _baseUrl = '${Endpoints.BASE_API_URL}/orders';
  List<Order> _items = [];
  String _token;
  String _userId;

  Orders([this._token, this._userId, this._items = const []]);

  List<Order> get items => [..._items];

  int get itemsCount => _items.length;

  Future<void> loadOrders() async {
    List<Order> loadedItem = [];
    final response = await http.get('$_baseUrl/$_userId.json?auth=$_token');
    Map<String, dynamic> data = json.decode(response.body);

    if (data != null) {
      data.forEach((orderId, orderData) {
        loadedItem.add(Order(
          id: orderId,
          total: orderData['total'],
          date: DateTime.parse(orderData['date']),
          products: (orderData['products'] as List<dynamic>)
              .map((prod) => CartItem(
                    productId: prod["productId"],
                    id: prod["id"],
                    title: prod["title"],
                    quantity: prod["quantity"],
                    price: prod["price"],
                  ))
              .toList(),
        ));
      });
    }
    _items = loadedItem.reversed.toList();
    notifyListeners();
    return Future.value();
  }

  Future<void> addOrder(Cart cart) async {
    final products = cart.items.values.toList();
    final date = DateTime.now();

    final response = await http.post('$_baseUrl/$_userId.json?auth=$_token',
        body: json.encode({
          "total": cart.totalAmount,
          "date": date.toIso8601String(),
          "products": cart.items.values
              .map((cartItem) => {
                    'id': cartItem.id,
                    'productId': cartItem.productId,
                    'title': cartItem.title,
                    'quantity': cartItem.quantity,
                    'price': cartItem.price,
                  })
              .toList(),
        }));

    print(response.body);

    _items.insert(
      0,
      Order(
        id: json.decode(response.body)['name'],
        total: cart.totalAmount,
        date: date,
        products: products,
      ),
    );

    notifyListeners();
  }
}
