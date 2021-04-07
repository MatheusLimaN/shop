import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shop/constants/endpoints.dart';
import 'package:shop/exceptions/http_exception.dart';

class Product with ChangeNotifier {
  final _baseUrl = '${Endpoints.BASE_API_URL}/userFavorites';
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.imageUrl,
    this.isFavorite = false,
  });

  void _toggleFavorite() {
    isFavorite = !isFavorite;
    notifyListeners();
  }

  Future<void> toggleFavorite(String token, String userId) async {
    _toggleFavorite();

    try {
      final response = await http.put('$_baseUrl/$userId/$id.json?auth=$token',
          body: json.encode(isFavorite));

      if (response.statusCode >= 400) {
        _toggleFavorite();
        throw HttpException('Ocorreu um erro ao salvar o favorito');
      }
    } catch (e) {
      _toggleFavorite();
    }
  }
}
