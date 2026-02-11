/* imports */
import 'package:flutter/material.dart';

import "dashboard_page.dart";
import '../session_manager.dart';

/* classes */
class SigninPage extends StatelessWidget {
  final TextEditingController useridController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> signin(BuildContext context) async {
    /* fake validation */
    if (useridController.text == "1234" && passwordController.text == "1234") {
      await SessionManager.setSession("fake_token");

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => DashboardPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Invalid credentials"),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Signin")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextField(
                controller: useridController,
                decoration: InputDecoration(labelText: "User ID"),
              ),
              SizedBox(height: 20),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(labelText: "Password"),
                obscureText: true,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => signin(context),
                child: Text("Signin")
              ),
            ],
          ),
        ),
      ),
    );
  }
}
