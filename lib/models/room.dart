import 'package:urban_nest/models/amenity.dart';
import 'package:urban_nest/models/room_image.dart';

import 'owner.dart';

class Room {
  final int id;
  final String title;
  final String description;
  final double rent;
  final double deposit;
  final String address;
  final String city;
  final String locality;
  final String roomType;
  final bool available;
  final List<RoomImage> images;
  final List<Amenity> amenities;
  final Owner? owner;

  Room({
    required this.id,
    required this.title,
    required this.description,
    required this.rent,
    required this.deposit,
    required this.address,
    required this.city,
    required this.locality,
    required this.roomType,
    required this.available,
    required this.images,
    required this.amenities,
    this.owner,
  });

  String? get coverImage {
    if (images.isEmpty) return null;
    return images.first.imageUrl;
  }

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json["id"],
      title: json["title"],
      description: json["description"],
      rent: (json["rent"] as num).toDouble(),
      deposit: (json["deposit"] as num).toDouble(),
      address: json["address"],
      city: json["city"],
      locality: json["locality"],
      roomType: json["roomType"],
      available: json["available"],

      images: json["images"] != null
          ? (json["images"] as List).map((e) => RoomImage.fromJson(e)).toList()
          : [],

      amenities: json["amenities"] != null
          ? (json["amenities"] as List).map((e) => Amenity.fromJson(e)).toList()
          : [],

      owner: json["owner"] != null ? Owner.fromJson(json["owner"]) : null,
    );
  }
}
