class InquiryPayload {
  final int tenantId;
  final int roomId;

  InquiryPayload({required this.tenantId, required this.roomId});

  Map<String, dynamic> toJson() {
    return {"tenantId": tenantId, "roomId": roomId};
  }
}
