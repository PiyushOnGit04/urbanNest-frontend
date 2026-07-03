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

// ─── Root shell with bottom nav ───────────────────────────────────────────────

class TenantHomeScreen extends StatefulWidget {
  const TenantHomeScreen({super.key});

  @override
  State<TenantHomeScreen> createState() => _TenantHomeScreenState();
}

class _TenantHomeScreenState extends State<TenantHomeScreen> {
  int _currentIndex = 0;

  // Keep pages alive when switching tabs
  final List<Widget> _pages = const [
    _HomeTab(),
    WishlistScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Each tab manages its own Scaffold/AppBar
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFF1A5F7A).withOpacity(0.12),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(
              Icons.home_rounded,
              color: Color(0xFF1A5F7A),
            ),
            label: 'Home',
          ),
          NavigationDestination(
            icon: const Icon(Icons.favorite_border_rounded),
            selectedIcon: const Icon(
              Icons.favorite_rounded,
              color: Color(0xFF1A5F7A),
            ),
            label: 'Wishlist',
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline_rounded),
            selectedIcon: const Icon(
              Icons.person_rounded,
              color: Color(0xFF1A5F7A),
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// ─── Home tab (your original screen, now without the drawer/profile icon) ────

class _HomeTab extends StatefulWidget {
  const _HomeTab();

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  final TextEditingController searchController = TextEditingController();
  final ApiService _apiService = ApiService();
  final TokenService _tokenService = TokenService();
  List<Room> rooms = [];
  bool isLoading = true;

  final Color primaryColor = const Color(0xFF1A5F7A);
  final Color accentColor = const Color(0xFF57C5B6);
  final Color backgroundColor = const Color(0xFFF4F7F8);
  final Color cardColor = Colors.white;

  String? search;
  double? minRent;
  double? maxRent;
  String? roomType;
  String? sortBy = "createdAt";
  String? order = "desc";

  @override
  void initState() {
    super.initState();
    loadRooms();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

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
      setState(() => isLoading = false);
    }
  }

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      elevation: 4,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        // Helper to check if a specific sort option is currently active
        bool isSelected(String field, String ord) =>
            sortBy == field && order == ord;

        Widget buildSortOption({
          required IconData icon,
          required String title,
          required String field,
          required String ord,
        }) {
          final active = isSelected(field, ord);
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: active
                  ? primaryColor.withOpacity(0.05)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              dense: true,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              leading: Icon(
                icon,
                color: active ? primaryColor : Colors.grey.shade600,
                size: 20,
              ),
              title: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                  color: active ? primaryColor : Colors.black87,
                ),
              ),
              trailing: active
                  ? Icon(
                      Icons.check_circle_rounded,
                      color: primaryColor,
                      size: 20,
                    )
                  : null,
              onTap: () async {
                sortBy = field;
                order = ord;
                Navigator.pop(context);
                await loadRooms();
              },
            ),
          );
        }

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Elegant Top Grabber / Drag Handle
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Sort By",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 16),
                buildSortOption(
                  icon: Icons.arrow_downward_rounded,
                  title: "Price: Low to High",
                  field: "rent",
                  ord: "asc",
                ),
                buildSortOption(
                  icon: Icons.arrow_upward_rounded,
                  title: "Price: High to Low",
                  field: "rent",
                  ord: "desc",
                ),
                buildSortOption(
                  icon: Icons.new_releases_outlined,
                  title: "Newest Arrivals",
                  field: "createdAt",
                  ord: "desc",
                ),
                buildSortOption(
                  icon: Icons.history_toggle_off_rounded,
                  title: "Oldest Listings",
                  field: "createdAt",
                  ord: "asc",
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
      backgroundColor: Colors.white,
      elevation: 5,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 12,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Drag Handle Indicator
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        "Filter Properties",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Section: Room Type
                    Text(
                      "Room / Property Type",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Clean ChoiceChip selection grid replacing the legacy dropdown
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: ["PG", "HOSTEL", "ROOM", "FLAT"].map((type) {
                        final isSelected = selectedRoomType == type;
                        return ChoiceChip(
                          label: Text(type),
                          selected: isSelected,
                          labelStyle: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: isSelected
                                ? Colors.white
                                : Colors.grey.shade700,
                          ),
                          selectedColor: primaryColor,
                          backgroundColor: backgroundColor,
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          showCheckmark: false,
                          onSelected: (bool selected) {
                            setModalState(() {
                              selectedRoomType = selected ? type : null;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Section: Price Range
                    Text(
                      "Budget Range (Monthly)",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: minController,
                            keyboardType: TextInputType.number,
                            style: GoogleFonts.poppins(fontSize: 14),
                            decoration: InputDecoration(
                              labelText: "Min Rent",
                              labelStyle: GoogleFonts.poppins(
                                color: Colors.grey.shade500,
                                fontSize: 13,
                              ),
                              prefixIcon: Icon(
                                Icons.currency_rupee_rounded,
                                size: 16,
                                color: primaryColor,
                              ),
                              filled: true,
                              fillColor: backgroundColor,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: accentColor,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: maxController,
                            keyboardType: TextInputType.number,
                            style: GoogleFonts.poppins(fontSize: 14),
                            decoration: InputDecoration(
                              labelText: "Max Rent",
                              labelStyle: GoogleFonts.poppins(
                                color: Colors.grey.shade500,
                                fontSize: 13,
                              ),
                              prefixIcon: Icon(
                                Icons.currency_rupee_rounded,
                                size: 16,
                                color: primaryColor,
                              ),
                              filled: true,
                              fillColor: backgroundColor,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: accentColor,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Primary Action Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
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
                        child: Text(
                          "Apply Filters",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Secondary Action Button (Reset)
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          roomType = null;
                          minRent = null;
                          maxRent = null;
                          Navigator.pop(context);
                          await loadRooms();
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.refresh_rounded,
                              color: Colors.grey.shade600,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "Reset All Filters",
                              style: GoogleFonts.poppins(
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
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

  void _navigateToDetails(Room room) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => RoomDetailsScreen(room: room)),
    );
  }

  void _logout() async {
    await _tokenService.clearToken();
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false, // no drawer burger
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
      ),
      body: Column(
        children: [
          // Search + Sort/Filter controls
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
                Row(
                  children: [
                    _buildActionButton(
                      icon: Icons.sort_rounded,
                      label: "Sort",
                      onTap: _showSortSheet,
                    ),
                    const SizedBox(width: 8),
                    _buildActionButton(
                      icon: Icons.tune_rounded,
                      label: "Filter",
                      onTap: _showFilterSheet,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Room list
          Expanded(
            child: isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                    ),
                  )
                : RefreshIndicator(
                    color: primaryColor,
                    onRefresh: loadRooms,
                    child: rooms.isEmpty
                        ? ListView(
                            // ListView (not Center) so the pull-to-refresh drag
                            // gesture has something to scroll against when empty
                            children: [
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.5,
                                child: Center(
                                  child: Text(
                                    "No rooms available right now",
                                    style: GoogleFonts.poppins(
                                      color: Colors.grey.shade500,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            itemCount: rooms.length,
                            padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                            itemBuilder: (context, index) =>
                                _buildRoomCard(rooms[index]),
                          ),
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
