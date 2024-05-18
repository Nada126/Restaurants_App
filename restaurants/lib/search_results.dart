import 'package:flutter/material.dart';
import 'package:restaurants/product_page.dart';

class SearchResultsPage extends StatelessWidget {
  final List<dynamic> searchResults;

  SearchResultsPage({required this.searchResults});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Results'),
      ),
      body: ListView.builder(
        itemCount: searchResults.length,
        itemBuilder: (BuildContext context, int index) {
          return _buildCard(
            context,
            searchResults[index]['placeName'],
            searchResults[index]['category'],
            searchResults[index]['placeImage'],
          );
        },
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
