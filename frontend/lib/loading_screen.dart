import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {

  @override
  void initState() {
    super.initState();
    _fetchDataAndNavigate();
  }

  // This is the function that does all the work
  Future<void> _fetchDataAndNavigate() async {
    try {
      // --- IMPORTANT ---
      String apiUrl = 'http://10.0.2.2:8080/api/v1/title';
      
      // Use the 'http' package to send a GET request
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        // 1. Decode the raw JSON string (response.body) into a Dart Map.
        final data = jsonDecode(response.body); 
        
        // 2. Extract the specific 'title' string value from the Map.
        // We expect the JSON structure to be like: {"title": "Application Title"}
        final String titleMessage = data['title']; 

        // We are all done! Navigate to the HomeScreen.
        // The argument passed is now just the simple String 'Application Title'.
        if (mounted) { // Check if the widget is still on screen
          Navigator.pushReplacementNamed(
            context,
            '/home',
            arguments: titleMessage, // Pass the extracted string
          );
        }
      } else {
        // If the server did not return a 200 OK response, throw an exception.
        throw Exception('Failed to load data (Status code: ${response.statusCode})');
      }
    } catch (e) {
      // If anything went wrong (no internet, server down, JSON parsing error, etc.)
      if (mounted) {
        Navigator.pushReplacementNamed(
          context,
          '/home',
          arguments: 'Error: ${e.toString()}',
        );
      }
    }
  }

  // This is what the user sees while the code above is running.
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        // A simple loading spinner
        child: CircularProgressIndicator(),
      ),
    );
  }
}
