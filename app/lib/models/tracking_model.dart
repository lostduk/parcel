/* classes */
class Tracking {
  final String number;
  final String carrier;
  final Map<String, dynamic>? shipperAddress;
  final Map<String, dynamic>? recipientAddress;
  final List<dynamic>? events;

  Tracking({
    required this.number,
    required this.carrier,
    this.shipperAddress,
    this.recipientAddress,
    this.events,
  });
}
