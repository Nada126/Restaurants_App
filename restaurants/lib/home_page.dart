import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:restaurants/search_results.dart';
import 'dart:convert';
import 'product_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> places = [];
  List<String> products = [];
  List<dynamic> searchResults = [];
  String selectedProduct = '';
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchPlaces();
    _fetchProducts();
  }

  void _fetchPlaces() async {
    final response = await http.get(
      Uri.parse('http://www.emaproject.somee.com/api/Place/getAllPlaces'),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        places = data.map<Map<String, dynamic>>((place) {
          return {
            'name': place['placeName'],
            'category': place['category'],
            'imagePath': place['placeImage'],
          };
        }).toList();
      });
    } else {
      throw Exception('Failed to fetch places');
    }
  }

  void _fetchProducts() async {
    final response = await http.get(
      Uri.parse('http://www.emaproject.somee.com/GetAllProducts'),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        products = data.cast<String>().toList();
      });
    } else {
      throw Exception('Failed to fetch products');
    }
  }

  void _searchByProduct(String product) async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://www.emaproject.somee.com/api/Product/$product/searchByProduct'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        // Navigate to SearchResultsPage with the search results
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SearchResultsPage(searchResults: data),
          ),
        );
      } else {
        throw Exception('Failed to fetch search results');
      }
    } catch (e) {
      print('Error fetching search results: $e');
      // Handle error - Display a snackbar, toast message, or dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to fetch search results. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Places'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: ProductSearch(products),
              ).then((value) {
                if (value != null) {
                  setState(() {
                    selectedProduct = value;
                    _searchByProduct(selectedProduct);
                  });
                }
              });
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.white,
        child: ListView.builder(
          itemCount:
              searchResults.length > 0 ? searchResults.length : places.length,
          itemBuilder: (BuildContext context, int index) {
            if (searchResults.length > 0) {
              // Display search results
              return _buildSearchResultCard(
                context,
                searchResults[index]['placeName'],
                searchResults[index]['category'],
                searchResults[index]['placeImage'],
              );
            } else {
              // Display regular place cards
              return _buildCard(
                context,
                places[index]['name'],
                places[index]['category'],
                places[index]['imagePath'],
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildCard(
      BuildContext context, String name, String category, String? imagePath) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: ListTile(
        title: Text(name),
        subtitle: Text(category),
        leading: imagePath != null ? Image.network(imagePath) : null,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductPage(placeName: name),
            ),
          );
        },
      ),
    );
  }
}

Widget _buildSearchResultCard(
    BuildContext context, String name, String category, String? imagePath) {
  return Card(
    elevation: 3,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0),
    ),
    child: ListTile(
      title: Text(name),
      subtitle: Text(category),
      leading: imagePath != null ? Image.network(imagePath) : null,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductPage(placeName: name),
          ),
        );
      },
    ),
  );
}

class ProductSearch extends SearchDelegate<String> {
  final List<String> products;

  ProductSearch(this.products);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Not used for this example
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestionList = query.isEmpty
        ? products
        : products.where((product) {
            return product.toLowerCase().contains(query.toLowerCase());
          }).toList();

    return ListView.builder(
      itemCount: suggestionList.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(suggestionList[index]),
          onTap: () {
            close(context, suggestionList[index]);
          },
        );
      },
    );
  }
}
