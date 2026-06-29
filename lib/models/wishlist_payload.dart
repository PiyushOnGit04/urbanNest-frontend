class WishlistPayload {
  final int tenantId;
  final int roomId;

  WishlistPayload({required this.tenantId, required this.roomId});

  Map<String, dynamic> toJson() {
    return {"tenantId": tenantId, "roomId": roomId};
  }
}
