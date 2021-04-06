import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/constants/app_route.dart';
import 'package:shop/providers/cart.dart';
import 'package:shop/providers/products.dart';
import 'package:shop/widgets/app_drawer.dart';
import 'package:shop/widgets/badge.dart';
import 'package:shop/widgets/product_grid.dart';

enum FilterOptions { Favorite, All }

class ProductsOverviewScreen extends StatefulWidget {
  @override
  _ProductsOverviewScreenState createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  bool _showFavoriteOnly = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Provider.of<Products>(context, listen: false)
        .loadProducts()
        .then((_) => setState(() {
              _isLoading = false;
            }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Minha loja'),
        actions: [
          PopupMenuButton(
            onSelected: (FilterOptions option) {
              setState(() {
                switch (option) {
                  case FilterOptions.Favorite:
                    _showFavoriteOnly = true;
                    break;
                  default:
                    _showFavoriteOnly = false;
                }
              });
            },
            icon: Icon(Icons.more_vert),
            itemBuilder: (_) => [
              PopupMenuItem(
                child: Text('Somente Favoritos'),
                value: FilterOptions.Favorite,
              ),
              PopupMenuItem(
                child: Text('Todos'),
                value: FilterOptions.All,
              ),
            ],
          ),
          Consumer<Cart>(
            child: IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: () {
                Navigator.of(context).pushNamed(AppRoutes.CART);
              },
            ),
            builder: (ctx, cart, child) => Badge(
              value: '${cart.itemCount}',
              child: child,
            ),
          )
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ProductGrid(showFavoriteOnly: _showFavoriteOnly),
      drawer: AppDrawer(),
    );
  }
}
