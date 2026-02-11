/* imports */
import 'package:flutter/material.dart';

/* classes */
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Home")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => {},
                child: Text("Signin"),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => {},
                child: Text("Config new Box"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
