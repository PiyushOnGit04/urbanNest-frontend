import 'package:flutter/material.dart';
import 'package:urban_nest/models/user.dart';
import 'package:urban_nest/service/api_service.dart';
import 'package:urban_nest/service/token_service.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiService _apiService = ApiService();
  final TokenService _tokenService = TokenService();

  User? user;
  bool isLoading = true;

  // Theme Palette matching Home & Details
  final Color primaryColor = const Color(0xFF1A5F7A); // Deep Slate Blue
  final Color accentColor = const Color(0xFF57C5B6); // Clean Mint Green
  final Color backgroundColor = const Color(
    0xFFF5F9FA,
  ); // Ultra-light cool background
  final Color cardColor = Colors.white;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      final userId = await _tokenService.getUserId();
      if (userId == null) return;

      final profile = await _apiService.getUserById(userId);

      setState(() {
        user = profile;
      });
    } catch (e) {
      debugPrint("Error loading profile: $e");
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(accentColor),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Profile",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: primaryColor,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              const SizedBox(height: 10),

              // Profile Picture / Avatar Block
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 54,
                      backgroundColor: accentColor.withOpacity(0.15),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: cardColor,
                        child: Icon(
                          Icons.person_outline_rounded,
                          size: 52,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // User Name
              Text(
                user?.name ?? "User Name",
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: primaryColor,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 32),

              // Info Details Form/List Container
              Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildProfileTile(
                      Icons.email_outlined,
                      "Email Address",
                      user?.email ?? "Not Available",
                    ),
                    _buildDivider(),
                    _buildProfileTile(
                      Icons.phone_android_outlined,
                      "Phone Number",
                      user?.phoneNumber ?? "Not Available",
                    ),
                    _buildDivider(),
                    _buildProfileTile(
                      Icons.badge_outlined,
                      "Account Role",
                      user?.role ?? "Not Available",
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Edit Profile Action Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // Logic remains pristine
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    "Edit Profile",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Profile data block builder method
  Widget _buildProfileTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: accentColor, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey.shade400,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: backgroundColor,
      indent: 20,
      endIndent: 20,
    );
  }
}
