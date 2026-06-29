class RegisterRequest {
  final String name;
  final String email;
  final String password;
  final String phoneNumber;
  final String role;

  RegisterRequest({
    required this.name,
    required this.email,
    required this.password,
    required this.phoneNumber,
    required this.role,
  });

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "email": email,
      "password": password,
      "phoneNumber": phoneNumber,
      "role": role,
    };
  }
}
