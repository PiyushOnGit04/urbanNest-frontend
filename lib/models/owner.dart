class Owner {
  final int id;
  final String name;
  final String email;
  final String? phoneNumber;

  Owner({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
  });

  factory Owner.fromJson(Map<String, dynamic> json) {
    return Owner(
      id: json["id"],
      name: json["name"],
      email: json["email"],
      phoneNumber: json["phoneNumber"],
    );
  }
}
