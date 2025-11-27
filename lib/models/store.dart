// lib/models/store.dart
class Store {
  final String id;
  final String name;
  final String address;
  final String hours;
  final String stock;

  Store({
    required this.id,
    required this.name,
    required this.address,
    required this.hours,
    required this.stock,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      address: json['address'] as String? ?? '',
      hours: json['hours'] as String? ?? '',
      stock: json['stock'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'hours': hours,
      'stock': stock,
    };
  }
}
