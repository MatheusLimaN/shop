import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop/constants/endpoints.dart';
import 'package:shop/exceptions/http_exception.dart';
import 'package:shop/providers/product.dart';

class Products with ChangeNotifier {
  final _baseUrl = '${Endpoints.BASE_API_URL}/products';
  List<Product> _items;
  String _token;
  String _userId;

  Products([this._token, this._userId, this._items = const []]);

  List<Product> get items => [..._items];

  int get itemsCount => _items.length;

  List<Product> get favoriteItems =>
      _items.where((product) => product.isFavorite).toList();

  Future<void> loadProducts() async {
    final response = await http.get('$_baseUrl.json?auth=$_token');
    final Map<String, dynamic> data = json.decode(response.body);

    final responseFav = await http.get(
        '${Endpoints.BASE_API_URL}/userFavorites/$_userId.json?auth=$_token');
    final favMap = json.decode(responseFav.body);

    _items.clear();

    if (data != null) {
      data.forEach((productId, productData) {
        final isFavorite = favMap == null ? false : favMap[productId] ?? false;

        _items.add(Product(
            id: productId,
            title: productData['title'],
            description: productData['description'],
            price: productData['price'],
            imageUrl: productData['imageUrl'],
            isFavorite: isFavorite));
      });
      notifyListeners();
    }

    return Future.value();
  }

  Future<void> addProduct(Product product) async {
    final response = await http.post(
      '$_baseUrl.json?auth=$_token',
      body: json.encode({
        'title': product.title,
        'description': product.description,
        'price': product.price,
        'imageUrl': product.imageUrl,
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
      await http.patch('$_baseUrl/${product.id}.json?auth=$_token',
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

      final response =
          await http.delete('$_baseUrl/${product.id}.json?auth=$_token');

      if (response.statusCode >= 400) {
        _items.insert(index, product);
        notifyListeners();
        throw HttpException('Ocorreu um erro na exclusão do produto');
      }
    }
  }
}
