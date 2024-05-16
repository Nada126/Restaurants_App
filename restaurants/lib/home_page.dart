import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'product_page.dart';
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> places = [];

  @override
  void initState() {
    super.initState();
    _fetchPlaces();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Places'),
      ),
      body: Container(
        color: Colors.white,
        child: ListView.builder(
          itemCount: places.length,
          itemBuilder: (BuildContext context, int index) {
            return _buildCard(
              context,
              places[index]['name'],
              places[index]['category'],
              places[index]['imagePath'],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, String name, String category, String? imagePath) {
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

