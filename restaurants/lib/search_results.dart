import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'product_page.dart';

class SearchResultsPage extends StatefulWidget {
  final String product;

  SearchResultsPage({required this.product});

  @override
  _SearchResultsPageState createState() => _SearchResultsPageState();
}


class _SearchResultsPageState extends State<SearchResultsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> searchResults = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchSearchResults(widget.product);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _fetchSearchResults(String product) async {
    try {
      final response = await http.get(
        Uri.parse('http://www.emaproject.somee.com/api/Product/${Uri.encodeComponent(product)}/searchByProduct'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          searchResults = data.map<Map<String, dynamic>>((place) {
            return {
              'placeName': place['placeName'],
              'category': place['category'],
              'placeImage': place['placeImage'],
              'latitude': place['latitude'],
              'longitude': place['longitude'],
            };
          }).toList();
        });
      } else {
        print('Failed to fetch search results: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching search results: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Results'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.list), text: 'List View'),
            Tab(icon: Icon(Icons.map), text: 'Map View'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ListView.builder(
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
          FlutterMap(
            options: MapOptions(
              initialCenter: searchResults.isNotEmpty
                  ? LatLng(searchResults[0]['latitude'],
                  searchResults[0]['longitude'])
                  : const LatLng(51.5, -0.09),
              initialZoom: 13.0,
            ),
            children: [
              TileLayer(
                urlTemplate:
                'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
              ),
              MarkerLayer(
                markers: searchResults.map((result) {
                  return Marker(
                    width: 80.0,
                    height: 80.0,
                    point: LatLng(result['latitude'], result['longitude']),
                    child: const Icon(
                      Icons.location_pin,
                      color: Colors.red,
                      size: 40.0,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ],
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