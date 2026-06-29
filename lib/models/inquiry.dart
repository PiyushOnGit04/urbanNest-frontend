class Inquiry {
  final int id;
  final String status;

  final String tenantName;
  final String tenantEmail;
  final String tenantPhone;

  Inquiry({
    required this.id,
    required this.status,
    required this.tenantName,
    required this.tenantEmail,
    required this.tenantPhone,
  });

  factory Inquiry.fromJson(Map<String, dynamic> json) {
    return Inquiry(
      id: json["id"],
      status: json["status"],

      tenantName: json["tenant"]["name"],
      tenantEmail: json["tenant"]["email"],
      tenantPhone: json["tenant"]["phoneNumber"],
    );
  }
}
