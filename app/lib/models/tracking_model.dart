/* classes */
class Tracking {
  final String? displayName;
  final String number;
  final String carrier;
  final String? lockerId;
  final Map<String, dynamic>? shipperAddress;
  final Map<String, dynamic>? recipientAddress;
  final List<dynamic>? events;

  Tracking({
    this.displayName,
    required this.number,
    required this.carrier,
    this.lockerId,
    this.shipperAddress,
    this.recipientAddress,
    this.events,
  });
}
