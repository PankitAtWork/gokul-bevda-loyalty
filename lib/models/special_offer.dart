// lib/models/special_offer.dart
import 'store.dart';

class SpecialOffer {
  final String id;
  final String title;
  final String description;
  final String category;
  final String availability;
  final String expires;
  final String tag; // 'Limited Time', 'Popular', etc.
  final String type; // 'all', 'discounts', 'buy1get1'
  final String iconType; // 'percentage' or 'bottle'
  final List<Store> stores; // List of stores where offer is available

  SpecialOffer({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.availability,
    required this.expires,
    required this.tag,
    required this.type,
    required this.iconType,
    this.stores = const [], // Default to empty list
  });

  factory SpecialOffer.fromJson(Map<String, dynamic> json) {
    final storesJson = json['stores'] as List<dynamic>? ?? [];
    final stores = storesJson
        .map((storeJson) => Store.fromJson(storeJson as Map<String, dynamic>))
        .toList();

    return SpecialOffer(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      availability: json['availability'] as String,
      expires: json['expires'] as String,
      tag: json['tag'] as String,
      type: json['type'] as String,
      iconType: json['icon_type'] as String,
      stores: stores,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'availability': availability,
      'expires': expires,
      'tag': tag,
      'type': type,
      'icon_type': iconType,
      'stores': stores.map((store) => store.toJson()).toList(),
    };
  }
}
