import 'package:flutter/material.dart';
import 'package:urban_nest/models/room.dart';
import 'package:urban_nest/screens/room_details_screen.dart';
import 'package:urban_nest/service/api_service.dart';
import 'package:urban_nest/service/token_service.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  final ApiService _apiService = ApiService();
  final TokenService _tokenService = TokenService();

  List<Room> wishlistRooms = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadWishlist();
  }

  Future<void> loadWishlist() async {
    try {
      final tenantId = await _tokenService.getUserId();
      if (tenantId == null) return;
      wishlistRooms = await _apiService.getWishlistRooms(tenantId);
    } catch (e) {
      debugPrint(e.toString());
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> remove(Room room) async {
    final tenantId = await _tokenService.getUserId();
    if (tenantId == null) return;

    setState(() {
      wishlistRooms.removeWhere((r) => r.id == room.id);
    });

    try {
      await _apiService.removeFromWishlist(tenantId, room.id);
    } catch (e) {
      loadWishlist();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Wishlists",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.black87,
            fontSize: 22,
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black87),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey.shade100, height: 1.0),
        ),
      ),
      body: _buildBodyContent(),
    );
  }

  Widget _buildBodyContent() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.black87,
          strokeWidth: 2.5,
        ),
      );
    }

    if (wishlistRooms.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Create your first wishlist",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "As you search, tap the heart icon on your favorite places to save them here.",
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: loadWishlist,
      color: Colors.black87,
      child: GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 24,
          crossAxisSpacing: 16,
          childAspectRatio:
              0.72, // Perfect proportion for image + text info block
        ),
        itemCount: wishlistRooms.length,
        itemBuilder: (context, index) {
          final room = wishlistRooms[index];

          return GestureDetector(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RoomDetailsScreen(room: room),
                ),
              );
              loadWishlist();
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Aspect ratio box to mimic modern card layouts
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey.shade100,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: room.images.isNotEmpty
                              ? Image.network(
                                  room.images.first.imageUrl,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                )
                              : Icon(
                                  Icons.home_work_outlined,
                                  size: 40,
                                  color: Colors.grey.shade400,
                                ),
                        ),
                      ),
                      // Floating Top Right Wishlist Toggle Action Button
                      Positioned(
                        top: 10,
                        right: 10,
                        child: GestureDetector(
                          onTap: () => remove(room),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white70,
                            ),
                            child: const Icon(
                              Icons.favorite,
                              color: Colors.redAccent,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Content Information Section
                Text(
                  "${room.locality}, ${room.city}",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  room.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                ),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.black87, fontSize: 14),
                    children: [
                      TextSpan(
                        text: "₹${room.rent.toInt()}",
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      TextSpan(
                        text: " month",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
