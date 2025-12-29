class Event {
  String id;
  String name;
  String description;
  String category;
  String city;
  double price;
  DateTime date;
  String imageUrl;
  String location;
  int capacity;

  Event({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.city,
    required this.price,
    required this.date,
    required this.imageUrl,
    required this.location,
    required this.capacity,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      city: json['city'] ?? '',
      price: (json['price'] as num).toDouble(),
      date: DateTime.parse(json['date']),
      imageUrl: json['imageUrl'] ?? '',
      location: json['location'] ?? '',
      capacity: json['capacity'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'city': city,
      'price': price,
      'date': date.toIso8601String(),
      'imageUrl': imageUrl,
      'location': location,
      'capacity': capacity,
    };
  }
}
