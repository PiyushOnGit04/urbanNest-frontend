class UpdateProfileRequest {
  final String? name;
  final String? phoneNumber;

  UpdateProfileRequest({this.name, this.phoneNumber});

  Map<String, dynamic> toJson() {
    return {
      if (name != null) "name": name,
      if (phoneNumber != null) "phoneNumber": phoneNumber,
    };
  }
}
