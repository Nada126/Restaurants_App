import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProductPage extends StatefulWidget {
  final String placeName;

  ProductPage({required this.placeName});

  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  List<Map<String, dynamic>> products = [];

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  void _fetchProducts() async {
    try {
      final response = await http.get(
        Uri.parse('http://www.emaproject.somee.com/api/Product/${Uri.encodeComponent(widget.placeName)}/products'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          products = data.map<Map<String, dynamic>>((product) {
            return {
              'name': product['productName'],
              'imagePath': product['productImage'],
            };
          }).toList();
        });
      } else {
        print('Failed to fetch products: ${response.statusCode}');
        throw Exception('Failed to fetch products');
      }
    } catch (e) {
      print('Error fetching products: $e');
    }
  }

  void _showSearch() {
    showSearch(
      context: context,
      delegate: CustomSearchDelegate(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.placeName} Products'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: _showSearch,
          ),
        ],
      ),
      body: Container(
        color: Colors.white,
        child: ListView.builder(
          itemCount: products.length,
          itemBuilder: (BuildContext context, int index) {
            return _buildProductCard(
              context,
              products[index]['name'],
              products[index]['imagePath'],
            );
          },
        ),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, String name, String? imagePath) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: ListTile(
        title: Text(name),
        leading: imagePath != null ? Image.network(imagePath) : null,
      ),
    );
  }
}

class CustomSearchDelegate extends SearchDelegate<String> {
  String errorMessage = '';

  @override
  ThemeData appBarTheme(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return theme.copyWith(
      scaffoldBackgroundColor: const Color.fromARGB(255, 21, 82, 113),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color.fromARGB(140, 21, 82, 113),
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [IconButton(icon: Icon(Icons.clear), onPressed: () => query = '')];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _searchProducts(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No results found'));
        } else {
          final places = snapshot.data!;
          return ListView.builder(
            itemCount: places.length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                title: Text(places[index]['placeName']),
                subtitle: Text(places[index]['category']),
                leading: places[index]['imagePath'] != null
                    ? Image.network(places[index]['imagePath'])
                    : null,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductPage(placeName: places[index]['placeName']),
                    ),
                  );
                },
              );
            },
          );
        }
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Center(
      child: Text('Suggestions for "$query"'),
    );
  }

  Future<List<Map<String, dynamic>>> _searchProducts(String query) async {
    try {
      final response = await http.get(
        Uri.parse('http://www.emaproject.somee.com/api/Product/${Uri.encodeComponent(query)}/searchByProduct'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('Search response data: $data'); // Debug print
        return data.map<Map<String, dynamic>>((place) {
          return {
            'placeName': place['placeName'],
            'category': place['category'],
            'imagePath': place['placeImage'],
          };
        }).toList();
      } else {
        print('Failed to search products: ${response.statusCode}');
        errorMessage = 'Failed to search products';
        return [];
      }
    } catch (e) {
      print('Error searching products: $e');
      errorMessage = 'Error searching products: $e';
      return [];
    }
  }
}