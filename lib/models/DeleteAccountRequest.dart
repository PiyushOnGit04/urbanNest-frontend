class DeleteAccountRequest {
  final String password;

  DeleteAccountRequest({required this.password});

  Map<String, dynamic> toJson() {
    return {"password": password};
  }
}
