import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/constants/app_route.dart';
import 'package:shop/providers/product.dart';
import 'package:shop/providers/products.dart';

class ProductItem extends StatelessWidget {
  final Product product;

  const ProductItem({Key key, this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(product.imageUrl),
      ),
      title: Text(product.title),
      trailing: Container(
        width: 100,
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.edit),
              color: Theme.of(context).primaryColor,
              onPressed: () {
                Navigator.of(context)
                    .pushNamed(AppRoutes.PRODUCT_FORM, arguments: product);
              },
            ),
            IconButton(
              icon: Icon(Icons.delete),
              color: Theme.of(context).errorColor,
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                          title: Text('Tem certeza?'),
                          content: Text('Quer excluir o produto?'),
                          actions: [
                            TextButton(
                              child: Text('Não'),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                            TextButton(
                                child: Text('Sim'),
                                onPressed: () {
                                  Provider.of<Products>(context, listen: false)
                                      .deleteProducts(product.id);
                                  Navigator.of(context).pop();
                                })
                          ],
                        ));
              },
            )
          ],
        ),
      ),
    );
  }
}
