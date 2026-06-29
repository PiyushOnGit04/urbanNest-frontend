import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:urban_nest/models/room.dart';
import 'package:urban_nest/screens/login_screen.dart';
import 'package:urban_nest/screens/profile_screen.dart';
import 'package:urban_nest/screens/room_details_screen.dart';
import 'package:urban_nest/screens/wishlist_screen.dart';
import 'package:urban_nest/service/api_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_nest/service/token_service.dart';

class TenantHomeScreen extends StatefulWidget {
  const TenantHomeScreen({super.key});

  @override
  State<TenantHomeScreen> createState() => _TenantHomeScreenState();
}

class _TenantHomeScreenState extends State<TenantHomeScreen> {
  final TextEditingController searchController = TextEditingController();
  final ApiService _apiService = ApiService();
  final TokenService _tokenService = TokenService();
  List<Room> rooms = [];
  bool isLoading = true;

  // Cohesive brand palette
  final Color primaryColor = const Color(0xFF1A5F7A);
  final Color accentColor = const Color(0xFF57C5B6);
  final Color backgroundColor = const Color(0xFFF4F7F8);
  final Color cardColor = Colors.white;

  @override
  void initState() {
    super.initState();
    loadRooms();
  }

  String? search;
  double? minRent;
  double? maxRent;
  String? roomType;
  String? sortBy;
  String? order;
  Future<void> loadRooms() async {
    try {
      final fetchedRooms = await _apiService.getRooms(
        search: search,
        minRent: minRent,
        maxRent: maxRent,
        roomType: roomType,
        sortBy: sortBy,
        order: order,
      );

      if (!mounted) return;

      setState(() {
        rooms = fetchedRooms;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading rooms: $e");

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Sort By",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                ListTile(
                  leading: const Icon(Icons.currency_rupee),
                  title: const Text("Price: Low to High"),
                  onTap: () async {
                    sortBy = "rent";
                    order = "asc";
                    Navigator.pop(context);
                    await loadRooms();
                  },
                ),

                ListTile(
                  leading: const Icon(Icons.currency_rupee),
                  title: const Text("Price: High to Low"),
                  onTap: () async {
                    sortBy = "rent";
                    order = "desc";
                    Navigator.pop(context);
                    await loadRooms();
                  },
                ),

                ListTile(
                  leading: const Icon(Icons.new_releases),
                  title: const Text("Newest"),
                  onTap: () async {
                    sortBy = "createdAt";
                    order = "desc";
                    Navigator.pop(context);
                    await loadRooms();
                  },
                ),

                ListTile(
                  leading: const Icon(Icons.history),
                  title: const Text("Oldest"),
                  onTap: () async {
                    sortBy = "createdAt";
                    order = "asc";
                    Navigator.pop(context);
                    await loadRooms();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showFilterSheet() {
    final minController = TextEditingController(
      text: minRent?.toString() ?? "",
    );

    final maxController = TextEditingController(
      text: maxRent?.toString() ?? "",
    );

    String? selectedRoomType = roomType;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Text(
                        "Filters",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      "Room Type",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 10),

                    DropdownButtonFormField<String>(
                      initialValue: selectedRoomType,
                      items: ["PG", "HOSTEL", "ROOM", "FLAT"]
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setModalState(() {
                          selectedRoomType = value;
                        });
                      },
                    ),

                    const SizedBox(height: 20),

                    TextField(
                      controller: minController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Minimum Rent",
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextField(
                      controller: maxController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Maximum Rent",
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          roomType = selectedRoomType;

                          minRent = minController.text.isEmpty
                              ? null
                              : double.tryParse(minController.text);

                          maxRent = maxController.text.isEmpty
                              ? null
                              : double.tryParse(maxController.text);

                          Navigator.pop(context);

                          await loadRooms();
                        },
                        child: const Text("Apply Filters"),
                      ),
                    ),

                    TextButton(
                      onPressed: () async {
                        roomType = null;
                        minRent = null;
                        maxRent = null;

                        Navigator.pop(context);

                        await loadRooms();
                      },
                      child: const Center(child: Text("Clear Filters")),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _navigateToDetails(Room room) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => RoomDetailsScreen(room: room)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      drawer: Drawer(
        backgroundColor: backgroundColor,
        child: Column(
          children: [
            const Spacer(),
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
                  await _tokenService.clearToken();
                  if (!context.mounted) return;
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
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [primaryColor, accentColor],
            ),
          ),
        ),
        title: Text(
          "UrbanNest",
          style: GoogleFonts.croissantOne(
            fontWeight: FontWeight.w800,
            fontSize: 22,
            color: Colors.white,
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
              icon: const Icon(Icons.account_circle_outlined, size: 26),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Integrated Control Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                // Modernized Search
                Container(
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: searchController,
                    onChanged: (value) async {
                      search = value.trim().isEmpty ? null : value.trim();
                      await loadRooms();
                    },
                    style: GoogleFonts.poppins(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: "Search city, locality, room...",
                      hintStyle: GoogleFonts.poppins(
                        color: Colors.grey.shade400,
                        fontSize: 14,
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: primaryColor.withOpacity(0.7),
                        size: 22,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Action Buttons Row
                Row(
                  children: [
                    _buildActionButton(
                      icon: Icons.sort_rounded,
                      label: "Sort",
                      onTap: () {
                        _showSortSheet();
                      },
                    ),
                    const SizedBox(width: 8),
                    _buildActionButton(
                      icon: Icons.tune_rounded,
                      label: "Filter",
                      onTap: () {
                        _showFilterSheet();
                      },
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.favorite_rounded, size: 18),
                        label: const Text("Wishlist"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor.withOpacity(0.15),
                          foregroundColor: primaryColor,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          textStyle: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const WishlistScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Main Content Section
          Expanded(
            child: isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                    ),
                  )
                : rooms.isEmpty
                ? Center(
                    child: Text(
                      "No rooms available right now",
                      style: GoogleFonts.poppins(
                        color: Colors.grey.shade500,
                        fontSize: 14,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: rooms.length,
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                    itemBuilder: (context, index) {
                      final room = rooms[index];
                      return _buildRoomCard(room);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      flex: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: primaryColor, size: 18),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  color: primaryColor,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoomCard(Room room) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => _navigateToDetails(room),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Stack with Visual Badge
              if (room.coverImage != null)
                Stack(
                  children: [
                    Image.network(
                      room.coverImage!,
                      height: 210,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      cacheWidth: 800,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return Container(
                          height: 210,
                          color: Colors.grey.shade100,
                          child: const Center(
                            child: CupertinoActivityIndicator(),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 210,
                          color: Colors.grey.shade100,
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            size: 36,
                            color: Colors.grey.shade300,
                          ),
                        );
                      },
                    ),
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "Verified",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: room.available ? Colors.green : Colors.red,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          room.available ? "Available" : "Occupied",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              // Room Details Text Content Block
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            room.title,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: primaryColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "₹${room.rent.toStringAsFixed(0)}/mo",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: accentColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          size: 15,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            "${room.locality}, ${room.city}",
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
    );
  }
}
