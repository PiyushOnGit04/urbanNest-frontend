class RoomRequest {
  final String title;
  final String description;
  final double rent;
  final double deposit;
  final String address;
  final String city;
  final String locality;
  final String roomType;
  final int ownerId;
  final List<int> amenityIds;

  RoomRequest({
    required this.title,
    required this.description,
    required this.rent,
    required this.deposit,
    required this.address,
    required this.city,
    required this.locality,
    required this.roomType,
    required this.ownerId,
    required this.amenityIds,
  });

  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "description": description,
      "rent": rent,
      "deposit": deposit,
      "address": address,
      "city": city,
      "locality": locality,
      "roomType": roomType,
      "ownerId": ownerId,
      "amenityIds": amenityIds,
    };
  }
}
