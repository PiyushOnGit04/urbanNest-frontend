class User {
  final int id;
  final String name;
  final String email;
  final String phoneNumber;
  final String role;
  final String? profileImage;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.role,
    this.profileImage,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json["id"],
      name: json["name"] ?? "",
      email: json["email"] ?? "",
      phoneNumber: json["phoneNumber"] ?? "",
      role: json["role"] ?? "",
      profileImage: json["profileImage"],
    );
  }
}
