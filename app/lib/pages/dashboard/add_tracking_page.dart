/* imports */
import 'package:flutter/material.dart';

import '../../models/tracking_model.dart';

/* classes */
class AddTrackingPage extends StatelessWidget {
  final TextEditingController trackingController = TextEditingController();
  final TextEditingController displaynameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Tracking")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: displaynameController,
              decoration: InputDecoration(labelText: "Display Name"),
            ),
            SizedBox(height: 15),
            TextField(
              controller: trackingController,
              decoration: InputDecoration(labelText: "Tracking ID"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Failed to connect to server")),
                );
              },
              child: Text("Add")
            ),
          ],
        ),
      ),
    );
  }
}
