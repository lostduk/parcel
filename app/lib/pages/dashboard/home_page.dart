/* imports */
import 'package:flutter/material.dart';

import '../../models/tracking_model.dart';

import "add_tracking_page.dart";
import "detail_tracking_page.dart";

/* classes */
class DashboardHomePage extends StatelessWidget {
  /* fake data */
  final List<Tracking> trackingList = [
    Tracking(
      number: "RR123465789CN",
      carrier: "Flash",
      shipperAddress: {
        "country": "CN",
        "city": "SHENZHEN",
      },
      recipientAddress: {
        "country": "AF",
        "city": "KABUl",
      },
      events: [
        {
          "description": "Package receiveed at facility",
          "time_utc": "2023-08-14T05:00:00Z",
        }
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: trackingList.length,
        itemBuilder: (context, index) {
          final tracking = trackingList[index];

          return Card(
            margin: EdgeInsets.all(10),
            child: ListTile(
              title: Text(tracking.number),
              subtitle: Text("Fuck"),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetailTrackingPage(tracking: tracking),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddTrackingPage()),
          );
        },
      ),
    );
  }
}
