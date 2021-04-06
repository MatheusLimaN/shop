import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop/constants/endpoints.dart';
import 'package:shop/exceptions/http_exception.dart';
import 'package:shop/providers/product.dart';

class Products with ChangeNotifier {
  final _baseUrl = '${Endpoints.BASE_API_URL}/products';

  List<Product> _items = [];

  List<Product> get items => [..._items];

  int get itemsCount => _items.length;

  List<Product> get favoriteItems =>
      _items.where((product) => product.isFavorite).toList();

  Future<void> loadProducts() async {
    final response = await http.get('$_baseUrl.json');
    Map<String, dynamic> data = json.decode(response.body);
    _items.clear();

    if (data != null) {
      data.forEach((productId, productData) {
        _items.add(Product(
          id: productId,
          title: productData['title'],
          description: productData['description'],
          price: productData['price'],
          imageUrl: productData['imageUrl'],
          isFavorite: productData['isFavorite'],
        ));
      });
      notifyListeners();
    }

    return Future.value();
  }

  Future<void> addProduct(Product product) async {
    final response = await http.post(
      '$_baseUrl.json',
      body: json.encode({
        'title': product.title,
        'description': product.description,
        'price': product.price,
        'imageUrl': product.imageUrl,
        'isFavorite': product.isFavorite,
      }),
    );

    _items.add(Product(
      id: json.decode(response.body)['name'],
      title: product.title,
      description: product.description,
      price: product.price,
      imageUrl: product.imageUrl,
    ));

    notifyListeners();
  }

  Future<void> updateProduct(Product product) async {
    if (product == null || product.id == null) {
      return;
    }

    final index = _items.indexWhere((prod) => prod.id == product.id);

    if (index >= 0) {
      await http.patch('$_baseUrl/${product.id}.json',
          body: json.encode({
            'title': product.title,
            'description': product.description,
            'price': product.price,
            'imageUrl': product.imageUrl,
          }));

      _items[index] = product;
      notifyListeners();
    }
  }

  Future<void> deleteProducts(String id) async {
    final index = _items.indexWhere((prod) => prod.id == id);

    if (index >= 0) {
      final product = _items[index];
      _items.remove(product);
      notifyListeners();

      final response = await http.delete('$_baseUrl/${product.id}.json');

      if (response.statusCode >= 400) {
        _items.insert(index, product);
        notifyListeners();
        throw HttpException('Ocorreu um erro na exclusão do produto');
      }
    }
  }
}
