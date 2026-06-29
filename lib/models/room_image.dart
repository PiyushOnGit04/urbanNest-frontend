class RoomImage {
  final int id;
  final String imageUrl;
  final bool coverImage;

  RoomImage({
    required this.id,
    required this.imageUrl,
    required this.coverImage,
  });

  factory RoomImage.fromJson(Map<String, dynamic> json) {
    return RoomImage(
      id: json["id"],
      imageUrl: json["imageUrl"],
      coverImage: json["coverImage"] ?? false,
    );
  }
}
