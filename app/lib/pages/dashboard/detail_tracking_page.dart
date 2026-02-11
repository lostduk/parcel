/* imports */
import 'package:flutter/material.dart';

import '../../models/tracking_model.dart';

/* classes */
class DetailTrackingPage extends StatelessWidget {
  final Tracking tracking;

  const DetailTrackingPage({super.key, required this.tracking});

  Widget buildBox(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 20),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey.shade50,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Divider(),
          ...children,
        ],
      ),
    );
  }

  Widget buildRow(String label, String? value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text("$label:", style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          Expanded(child: Text((value == null || value.isEmpty) ? "-" : value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tracking.number),
        actions: [
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: () => {},
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: ListView(
          children: [
            buildBox("General", [
              buildRow("Number", tracking.number),
              buildRow("Carrier", tracking.carrier),
            ]),
            buildBox("Shipper Address", [
              buildRow("Country", tracking.shipperAddress?["country"]),
              buildRow("State", tracking.shipperAddress?["state"]),
              buildRow("City", tracking.shipperAddress?["city"]),
              buildRow("Street", tracking.shipperAddress?["street"]),
              buildRow("Postal Code", tracking.shipperAddress?["postal_code"]),
            ]),
            buildBox("Recipient Address", [
              buildRow("Country", tracking.recipientAddress?["country"]),
              buildRow("State", tracking.recipientAddress?["state"]),
              buildRow("City", tracking.recipientAddress?["city"]),
              buildRow("Street", tracking.recipientAddress?["street"]),
              buildRow("Postal Code", tracking.recipientAddress?["postal_code"]),
            ]),
            buildBox("Events", [
              Text("Failed to fetch information!"),
            ]),
          ],
        ),
      ),
    );
  }
}
