import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Receive the data (the application title or an error string).
    final String data = ModalRoute.of(context)!.settings.arguments as String;

    // 2. Check if the data is an error message (based on the format used in LoadingScreen).
    final bool isError = data.startsWith('Error:');
    
    // 3. Determine the main title for the AppBar and the content message.
    final String appBarTitle = isError ? 'Error Loading' : data;
    final String contentMessage = isError ? 'Failed to fetch application data.' : 'Data successfully loaded:';

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle), // Use the dynamic title here
        backgroundColor: isError ? Colors.red.shade700 : Theme.of(context).primaryColor,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isError ? 'Oops! An Error Occurred' : 'Welcome to your App!',
                style: TextStyle(
                  fontSize: 24, 
                  fontWeight: FontWeight.bold,
                  color: isError ? Colors.red.shade900 : Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                contentMessage,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 10),
              // Display the raw data or error details.
              Text(
                data, 
                style: TextStyle(
                  fontSize: 16, 
                  color: isError ? Colors.red : Colors.blue.shade700,
                  fontStyle: isError ? FontStyle.italic : FontStyle.normal,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
