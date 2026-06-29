import 'package:flutter/material.dart';
import 'package:urban_nest/models/inquiry_payload.dart';
import 'package:urban_nest/models/room.dart';
import 'package:urban_nest/models/wishlist_payload.dart';
import 'package:urban_nest/service/api_service.dart';
import 'package:urban_nest/service/token_service.dart';

class RoomDetailsScreen extends StatefulWidget {
  final Room room;

  const RoomDetailsScreen({super.key, required this.room});

  @override
  State<RoomDetailsScreen> createState() => _RoomDetailsScreenState();
}

class _RoomDetailsScreenState extends State<RoomDetailsScreen> {
  final ApiService _apiService = ApiService();
  final TokenService _tokenService = TokenService();

  bool inquirySent = false;
  bool isSending = false;
  bool isWishlisted = false;
  bool isWishlistLoading = false;

  @override
  void initState() {
    super.initState();
    // Step 2: Verify if amenities are loaded into the Flutter object model
    debugPrint("======== AMENITIES COUNT ========");
    debugPrint("Room amenities length: ${widget.room.amenities.length}");
    debugPrint("=================================");

    loadWishlistStatus();
    checkInquiryStatus();
  }

  Future<void> checkInquiryStatus() async {
    try {
      final tenantId = await _tokenService.getUserId();

      if (tenantId == null) return;

      inquirySent = await _apiService.hasInquiry(tenantId, widget.room.id);

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> loadWishlistStatus() async {
    try {
      final tenantId = await _tokenService.getUserId();

      if (tenantId == null) return;

      final status = await _apiService.isRoomWishlisted(
        tenantId,
        widget.room.id,
      );

      if (mounted) {
        setState(() {
          isWishlisted = status;
        });
      }
    } catch (e) {
      debugPrint("Wishlist status error: $e");
    }
  }

  Future<void> toggleWishlist() async {
    try {
      setState(() {
        isWishlistLoading = true;
      });

      final tenantId = await _tokenService.getUserId();

      if (tenantId == null) {
        throw Exception("Please login again");
      }

      if (!isWishlisted) {
        await _apiService.addToWishlist(
          WishlistPayload(tenantId: tenantId, roomId: widget.room.id),
        );

        setState(() {
          isWishlisted = true;
        });

        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Added to wishlist")));
        }
      } else {
        await _apiService.removeFromWishlist(tenantId, widget.room.id);

        setState(() {
          isWishlisted = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Removed from wishlist")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) {
        setState(() {
          isWishlistLoading = false;
        });
      }
    }
  }

  Future<void> sendInquiry() async {
    try {
      setState(() => isSending = true);
      final tenantId = await _tokenService.getUserId();

      if (tenantId == null) throw Exception("Please login again");

      await _apiService.sendInquiry(
        InquiryPayload(tenantId: tenantId, roomId: widget.room.id),
      );
      setState(() {
        inquirySent = true;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Inquiry sent successfully"),
            backgroundColor: Colors.teal.shade800,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => isSending = false);
    }
  }

  // Common section title builder to save code space
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 16.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.teal.shade900,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final room = widget.room;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          room.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.teal.shade700,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: isWishlistLoading ? null : toggleWishlist,
            icon: isWishlistLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Icon(
                    Icons.favorite,
                    color: isWishlisted ? Colors.grey : Colors.red,
                  ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image Gallery with a modern rounded bottom look
                  Stack(
                    children: [
                      SizedBox(
                        height: 260,
                        child: PageView.builder(
                          itemCount: room.images.length,
                          itemBuilder: (context, index) {
                            return Image.network(
                              room.images[index].imageUrl,
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                      ),
                      Positioned(
                        bottom: 12,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black45,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "Type: ${room.roomType}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Core Details Card
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          room.title,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal.shade900,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Pricing Row
                        Row(
                          children: [
                            Text(
                              "₹${room.rent.toInt()}",
                              style: const TextStyle(
                                fontSize: 26,
                                color: Colors.teal,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              " / month",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.teal.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                "Deposit: ₹${room.deposit.toInt()}",
                                style: TextStyle(
                                  color: Colors.teal.shade800,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const Divider(height: 32),

                        const SizedBox(height: 10),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: room.available
                                ? Colors.green.shade100
                                : Colors.red.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            room.available
                                ? "Available Now"
                                : "Currently Occupied",
                            style: TextStyle(
                              color: room.available
                                  ? Colors.green.shade800
                                  : Colors.red.shade800,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),
                        _buildSectionTitle("Location"),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              color: Colors.teal.shade700,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "${room.locality}, ${room.city}\n${room.address}",
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ),

                        _buildSectionTitle("Description"),
                        Text(
                          room.description,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            height: 1.4,
                          ),
                        ),

                        // Step 3: Display Amenities list directly underneath the description
                        if (room.amenities.isNotEmpty) ...[
                          _buildSectionTitle("Facilities"),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: room.amenities.map((amenity) {
                              return Chip(
                                label: Text(amenity.name),
                                backgroundColor: Colors.teal.shade50,
                                side: BorderSide.none,
                              );
                            }).toList(),
                          ),
                        ],

                        _buildSectionTitle("Owner Details"),
                        Card(
                          color: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            children: [
                              ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.teal.shade50,
                                  child: Icon(
                                    Icons.person,
                                    color: Colors.teal.shade700,
                                  ),
                                ),
                                title: Text(
                                  room.owner?.name ?? "Unknown",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.teal.shade50,
                                  child: Icon(
                                    Icons.phone,
                                    color: Colors.teal.shade700,
                                  ),
                                ),
                                title: Text(room.owner?.phoneNumber ?? "N/A"),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Sticky Floating Bottom Action Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: inquirySent
                        ? Colors.grey
                        : Colors.teal.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  onPressed: (isSending || inquirySent) ? null : sendInquiry,
                  child: isSending
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          inquirySent ? "Request Sent" : "Send Inquiry",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
