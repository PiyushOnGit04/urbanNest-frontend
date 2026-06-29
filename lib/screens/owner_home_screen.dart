import 'package:flutter/material.dart';
import 'package:urban_nest/models/room.dart';
import 'package:urban_nest/screens/CreateRoomScreen.dart';
import 'package:urban_nest/screens/login_screen.dart';
import 'package:urban_nest/screens/owner_inquiry_screen.dart';
import 'package:urban_nest/screens/profile_screen.dart';
import 'package:urban_nest/service/api_service.dart';
import 'package:urban_nest/service/token_service.dart';
import 'package:google_fonts/google_fonts.dart';

class OwnerHomeScreen extends StatefulWidget {
  const OwnerHomeScreen({super.key});

  @override
  State<OwnerHomeScreen> createState() => _OwnerHomeScreenState();
}

class _OwnerHomeScreenState extends State<OwnerHomeScreen> {
  final ApiService _apiService = ApiService();
  final TokenService _tokenService = TokenService();

  List<Room> rooms = [];
  bool isLoading = true;

  // Global Cool-Mint Theme Colors
  final Color primaryColor = const Color(0xFF1A5F7A); // Deep Slate Blue
  final Color accentColor = const Color(0xFF57C5B6); // Clean Mint Green
  final Color backgroundColor = const Color(
    0xFFF5F9FA,
  ); // Clean premium background
  final Color cardColor = Colors.white;

  @override
  void initState() {
    super.initState();
    loadRooms();
  }

  Future<void> loadRooms() async {
    try {
      final ownerId = await _tokenService.getUserId();
      if (ownerId == null) return;
      rooms = await _apiService.getOwnerRooms(ownerId);
    } catch (e) {
      debugPrint(e.toString());
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    int availableRooms = rooms.where((r) => r.available).length;

    return Scaffold(
      backgroundColor: backgroundColor,
      drawer: Drawer(
        backgroundColor: const Color(0xFFF5F9FA),
        child: Column(
          children: [
            const Spacer(), // Pushes the logout tile right to the bottom
            const Divider(indent: 16, endIndent: 16),
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: ListTile(
                leading: const Icon(
                  Icons.logout_rounded,
                  color: Colors.redAccent,
                ),
                title: Text(
                  "Logout",
                  style: GoogleFonts.poppins(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () async {
                  // Wipes storage session
                  await _tokenService.clearToken();

                  if (!context.mounted) return;

                  // Wipes backstack and routes to Login
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                },
              ),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor:
            Colors.transparent, // Required to let the gradient show through
        elevation: 0,
        scrolledUnderElevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.fromARGB(
                  255,
                  7,
                  168,
                  152,
                ), // Your starting gradient color
                Colors.blue,
              ],
            ),
          ),
        ),
        title: Text(
          "UrbanNest",
          style: GoogleFonts.croissantOne(
            fontWeight: FontWeight.w800,
            fontSize: 22,
            color: Colors
                .white, // Changed to white for better contrast on a gradient
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
              icon: const Icon(
                Icons.account_circle_outlined,
                color: Colors.white, // Changed to white for better contrast
                size: 28,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateRoomScreen()),
          ).then((_) => loadRooms());
        },
        icon: const Icon(Icons.add_rounded, size: 22),
        label: Text(
          "Add Room",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(accentColor),
              ),
            )
          : RefreshIndicator(
              color: accentColor,
              onRefresh: loadRooms,
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                children: [
                  Text(
                    "Welcome Back 👋",
                    style: GoogleFonts.poppins(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Dashboard KPI Metrics Section
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.grey.shade200,
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.home_work_rounded,
                                  color: primaryColor,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                "${rooms.length}",
                                style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: primaryColor,
                                ),
                              ),
                              Text(
                                "Total Listings",
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.grey.shade200,
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: accentColor.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.verified_user_rounded,
                                  color: accentColor,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                "$availableRooms",
                                style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: primaryColor,
                                ),
                              ),
                              Text(
                                "Available Now",
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),
                  Text(
                    "Your Listings",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 14),

                  if (rooms.isEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 40,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade100),
                      ),
                      child: Center(
                        child: Text(
                          "No properties listed yet.",
                          style: GoogleFonts.poppins(
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                  ...rooms.map(
                    (room) => Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.grey.shade200,
                          width: 1,
                        ),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          // OwnerRoomDetailsScreen mapping later
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (room.images.isNotEmpty)
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(16),
                                ),
                                child: Image.network(
                                  room.images.first.imageUrl,
                                  height: 180,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          room.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.poppins(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w700,
                                            color: primaryColor,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            room.available
                                                ? "Available"
                                                : "Occupied",
                                            style: GoogleFonts.poppins(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: room.available
                                                  ? Colors.green
                                                  : Colors.red,
                                            ),
                                          ),
                                          Switch(
                                            value: room.available,
                                            activeColor: accentColor,
                                            onChanged: (value) async {
                                              try {
                                                await _apiService
                                                    .updateRoomAvailability(
                                                      room.id,
                                                      value,
                                                    );

                                                loadRooms(); // Refresh from backend
                                              } catch (e) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      "Couldn't update room status",
                                                    ),
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on_outlined,
                                        size: 14,
                                        color: Colors.grey.shade500,
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          "${room.locality}, ${room.city}",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            color: Colors.grey.shade600,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    "₹${room.rent.toInt()}/month",
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: accentColor,
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // Structured Buttons Row
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    OwnerInquiryScreen(
                                                      roomId: room.id,
                                                    ),
                                              ),
                                            );
                                          },
                                          style: OutlinedButton.styleFrom(
                                            side: BorderSide(
                                              color: primaryColor.withOpacity(
                                                0.5,
                                              ),
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 12,
                                            ),
                                          ),
                                          icon: Icon(
                                            Icons.forum_outlined,
                                            size: 16,
                                            color: primaryColor,
                                          ),
                                          label: Text(
                                            "Inquiries",
                                            style: GoogleFonts.poppins(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: primaryColor,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          onPressed: () async {
                                            final updated =
                                                await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) =>
                                                        CreateRoomScreen(
                                                          room: room,
                                                        ),
                                                  ),
                                                );

                                            if (updated == true) {
                                              loadRooms();
                                            }
                                          },
                                          style: OutlinedButton.styleFrom(
                                            side: BorderSide(
                                              color: primaryColor.withOpacity(
                                                0.5,
                                              ),
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 12,
                                            ),
                                          ),
                                          icon: Icon(
                                            Icons.mode_edit_outline_rounded,
                                            size: 16,
                                            color: primaryColor,
                                          ),
                                          label: Text(
                                            "Edit",
                                            style: GoogleFonts.poppins(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: primaryColor,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        onPressed: () async {
                                          final confirm = await showDialog<bool>(
                                            context: context,
                                            builder: (_) => AlertDialog(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),
                                              title: Text(
                                                "Delete Listing",
                                                style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.w700,
                                                  color: primaryColor,
                                                ),
                                              ),
                                              content: Text(
                                                "Are you completely sure you want to remove this property listing?",
                                                style: GoogleFonts.poppins(
                                                  color: Colors.grey.shade700,
                                                ),
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                        context,
                                                        false,
                                                      ),
                                                  child: Text(
                                                    "Cancel",
                                                    style: GoogleFonts.poppins(
                                                      color:
                                                          Colors.grey.shade600,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                        context,
                                                        true,
                                                      ),
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                        backgroundColor:
                                                            Colors.red.shade600,
                                                        elevation: 0,
                                                      ),
                                                  child: Text(
                                                    "Delete",
                                                    style: GoogleFonts.poppins(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );

                                          if (confirm == true) {
                                            await _apiService.deleteRoom(
                                              room.id,
                                            );
                                            loadRooms();
                                          }
                                        },
                                        style: IconButton.styleFrom(
                                          backgroundColor: Colors.red.shade50,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          padding: const EdgeInsets.all(12),
                                        ),
                                        icon: Icon(
                                          Icons.delete_outline_rounded,
                                          size: 20,
                                          color: Colors.red.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
