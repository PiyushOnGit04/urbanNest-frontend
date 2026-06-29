class Amenity {
  final int id;
  final String name;

  Amenity({required this.id, required this.name});

  factory Amenity.fromJson(Map<String, dynamic> json) {
    return Amenity(id: json["id"], name: json["name"]);
  }

  Map<String, dynamic> toJson() {
    return {"id": id, "name": name};
  }
}
