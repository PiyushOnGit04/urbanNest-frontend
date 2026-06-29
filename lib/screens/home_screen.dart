import 'package:flutter/material.dart';
import 'package:urban_nest/screens/CreateRoomScreen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("UrbanNest")),

      body: const Center(
        child: Text("Welcome to UrbanNest", style: TextStyle(fontSize: 22)),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateRoomScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
