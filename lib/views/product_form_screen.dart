import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/product.dart';
import 'package:shop/providers/products.dart';

class ProductFormScreen extends StatefulWidget {
  @override
  _ProductFormScreenState createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _form = GlobalKey<FormState>();
  final _formData = Map<String, Object>();
  bool _isLoading = false;

  void _listenerImageUrl() {
    if (isValidImageUrl(_imageUrlController.text)) {
      setState(() {
        print('muddou!');
      });
    }
  }

  bool isValidImageUrl(String url) {
    bool isValidProtocol = url.toLowerCase().startsWith('http://') ||
        url.toLowerCase().startsWith('https://');

    bool isValidExtension = url.toLowerCase().endsWith('.png') ||
        url.toLowerCase().endsWith('.jpg') ||
        url.toLowerCase().endsWith('.jpeg');

    return isValidProtocol && isValidExtension;
  }

  @override
  void initState() {
    super.initState();
    _imageUrlFocusNode.addListener(_listenerImageUrl);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_formData.isEmpty) {
      final product = ModalRoute.of(context).settings.arguments as Product;

      if (product != null) {
        _formData['id'] = product.id;
        _formData['title'] = product.title;
        _formData['description'] = product.description;
        _formData['price'] = product.price;
        _formData['imageUrl'] = product.imageUrl;
        _imageUrlController.text = product.imageUrl;
      } else {
        _formData['price'] = "";
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlFocusNode.removeListener(_listenerImageUrl);
    _imageUrlFocusNode.dispose();
  }

  Future<void> _saveForm() async {
    setState(() {
      _isLoading = true;
    });

    var isValid = _form.currentState.validate();

    if (!isValid) {
      return;
    }

    _form.currentState.save();

    final newProduct = Product(
      id: _formData['id'],
      title: _formData['title'],
      description: _formData['description'],
      price: _formData['price'],
      imageUrl: _formData['imageUrl'],
    );

    final productsProvider = Provider.of<Products>(context, listen: false);

    try {
      if (_formData['id'] == null) {
        await productsProvider.addProduct(newProduct);
        Navigator.of(context).pop();
      } else {
        await productsProvider.updateProduct(newProduct);
        Navigator.of(context).pop();
      }
    } catch (e) {
      print(e);
      await showDialog<Null>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Ocorreu um erro!'),
          content: Text('Ocorreu um erro ao salvar o produto!'),
          actions: [
            TextButton(
                child: Text('Fechar'), onPressed: () => Navigator.of(ctx).pop())
          ],
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Produto'),
        actions: [IconButton(icon: Icon(Icons.save), onPressed: _saveForm)],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(15),
              child: Form(
                key: _form,
                child: ListView(
                  children: [
                    TextFormField(
                      initialValue: _formData['title'],
                      decoration: InputDecoration(labelText: 'Título'),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) =>
                          FocusScope.of(context).requestFocus(_priceFocusNode),
                      onSaved: (value) => _formData['title'] = value,
                      validator: (value) {
                        if (value.trim().isEmpty) {
                          return 'Informe um título válido!';
                        }

                        if (value.trim().length < 3) {
                          return 'Informe um título com no mínimo 3 letras!';
                        }

                        return null;
                      },
                    ),
                    TextFormField(
                      initialValue: _formData['price'].toString(),
                      decoration: InputDecoration(labelText: 'Preço'),
                      textInputAction: TextInputAction.next,
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      focusNode: _priceFocusNode,
                      onFieldSubmitted: (_) => FocusScope.of(context)
                          .requestFocus(_descriptionFocusNode),
                      onSaved: (value) =>
                          _formData['price'] = double.tryParse(value) ?? 0,
                      validator: (value) {
                        if (double.tryParse(value) == null ||
                            double.tryParse(value) == 0) {
                          return 'Informe um preço válido!';
                        }

                        return null;
                      },
                    ),
                    TextFormField(
                      initialValue: _formData['description'],
                      decoration: InputDecoration(labelText: 'Descrição'),
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                      focusNode: _descriptionFocusNode,
                      onFieldSubmitted: (_) =>
                          FocusScope.of(context).requestFocus(_priceFocusNode),
                      onSaved: (value) => _formData['description'] = value,
                      validator: (value) {
                        if (value.trim().isEmpty) {
                          return 'Informe uma descrição válida!';
                        }

                        if (value.trim().length < 10) {
                          return 'Informe uma descrição com no mínimo 10 letras!';
                        }

                        return null;
                      },
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: TextFormField(
                            decoration:
                                InputDecoration(labelText: 'Url da imagem'),
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            focusNode: _imageUrlFocusNode,
                            controller: _imageUrlController,
                            onFieldSubmitted: (_) {
                              _saveForm();
                            },
                            onSaved: (value) => _formData['imageUrl'] = value,
                            validator: (value) {
                              if (value.trim().isEmpty ||
                                  !isValidImageUrl(value)) {
                                return 'Informe uma url válida!';
                              }

                              return null;
                            },
                          ),
                        ),
                        Container(
                          width: 100,
                          height: 100,
                          margin: EdgeInsets.only(top: 8, left: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey, width: 1),
                          ),
                          alignment: Alignment.center,
                          child: _imageUrlController.text.isEmpty
                              ? Text('Informe a URL')
                              : Image.network(
                                  _imageUrlController.text,
                                  fit: BoxFit.cover,
                                ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
