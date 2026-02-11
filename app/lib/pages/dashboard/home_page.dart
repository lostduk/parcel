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
      displayName: "นมอัดเม็ด",
      number: "TH07018BR0VH4F",
      carrier: "Flash",
      shipperAddress: {
        "country": "TH",
        "city": "Phra Nakhon Sri Ayutthaya",
      },
      recipientAddress: {
        "country": "TH",
        "city": "Lopburi",
        "state": "Lopburi",
        "postal_code": "15000",
      },
    ),
    Tracking(
      displayName: "ดอกกุหลาบ",
      number: "829206130782",
      carrier: "J&T",
      lockerId: "01",
      shipperAddress: {
        "country": "TH",
        "city": "Nonthaburi",
        "state": "Bang Yai",
      },
      recipientAddress: {
        "country": "TH",
        "city": "Lopburi",
        "state": "Lopburi",
        "postal_code": "15000",
      },
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: trackingList.length,
        itemBuilder: (context, index) {
          final tracking = trackingList[index];

          final shipperCountry = tracking.shipperAddress?["country"] as String?;
          final shipperCity = tracking.shipperAddress?["city"] as String?;
          final recipientCountry = tracking.recipientAddress?["country"] as String?;
          final recipientCity = tracking.recipientAddress?["city"] as String?;

          return Card(
            margin: EdgeInsets.all(10),
            child: ListTile(
              title: Text(tracking.displayName ?? tracking.number),
              subtitle: Text(
                "${shipperCountry?.isNotEmpty == true ? "$shipperCountry, " : ""}"
                "${shipperCity?.isNotEmpty == true ? shipperCity : ""}"
                " -> "
                "${recipientCountry?.isNotEmpty == true ? "$recipientCountry, " : ""}"
                "${recipientCity?.isNotEmpty == true ? recipientCity : ""}",
              ),
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
