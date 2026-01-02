class Place {
  final String name;
  final double latitude;
  final double longitude;
  final String category;
  final String? description;

  Place({
    required this.name,
    required this.latitude,
    required this.longitude,
    this.category = 'attraction',
    this.description,
  });
}
