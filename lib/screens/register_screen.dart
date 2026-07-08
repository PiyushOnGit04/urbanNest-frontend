import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_nest/models/register_request.dart';
import 'package:urban_nest/service/api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final ApiService _apiService = ApiService();

  String selectedRole = "ROLE_TENANT";
  bool _isLoading = false;
  bool _obscurePassword = true;

  // Global Cool-Mint Theme Definitions (Synced with Login)
  final Color primaryColor = const Color(0xFF1A5F7A); // Deep Slate Blue
  final Color accentColor = const Color(0xFF57C5B6); // Clean Mint Green
  final Color backgroundColor = const Color(
    0xFFF5F9FA,
  ); // Ultra-light background
  final Color cardColor = Colors.white;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Refactored helper method for clean, premium input styling
  InputDecoration _buildInputDecoration({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.poppins(
        color: Colors.grey.shade500,
        fontSize: 14,
      ),
      floatingLabelStyle: GoogleFonts.poppins(
        color: primaryColor,
        fontWeight: FontWeight.w600,
      ),
      prefixIcon: Icon(icon, size: 20, color: Colors.grey.shade400),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: backgroundColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: accentColor, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          "Create Account",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: primaryColor,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: primaryColor),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Join UrbanNest",
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: primaryColor,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Sign up to find or manage your perfect home.",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 32),

                // Main registration container card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Name Field
                      TextField(
                        controller: _nameController,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: _buildInputDecoration(
                          label: "Full Name",
                          icon: Icons.person_outline_rounded,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Email Field
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: _buildInputDecoration(
                          label: "Email Address",
                          icon: Icons.mail_outline_rounded,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Phone Field
                      TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: _buildInputDecoration(
                          label: "Phone Number",
                          icon: Icons.phone_android_rounded,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Password Field
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: _buildInputDecoration(
                          label: "Password",
                          icon: Icons.lock_open_rounded,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              size: 20,
                              color: Colors.grey.shade400,
                            ),
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Role Dropdown
                      DropdownButtonFormField<String>(
                        value: selectedRole,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: _buildInputDecoration(
                          label: "I want to...",
                          icon: Icons.assignment_ind_outlined,
                        ),
                        dropdownColor: cardColor,
                        icon: Icon(
                          Icons.arrow_drop_down_rounded,
                          color: Colors.grey.shade400,
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: "ROLE_TENANT",
                            child: Text("Search Room"),
                          ),
                          DropdownMenuItem(
                            value: "ROLE_OWNER",
                            child: Text("List room / PG / Hostel"),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedRole = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 32),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: primaryColor.withOpacity(
                              0.6,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          onPressed: _isLoading
                              ? null
                              : () async {
                                  setState(() {
                                    _isLoading = true;
                                  });

                                  try {
                                    await _apiService.register(
                                      RegisterRequest(
                                        name: _nameController.text.trim(),
                                        email: _emailController.text.trim(),
                                        password: _passwordController.text
                                            .trim(),
                                        phoneNumber: _phoneController.text
                                            .trim(),
                                        role: selectedRole,
                                      ),
                                    );

                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          behavior: SnackBarBehavior.floating,
                                          content: Text(
                                            "Registration Successful",
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          backgroundColor: primaryColor,
                                        ),
                                      );
                                      Navigator.pop(context);
                                    }
                                  } catch (e) {
                                    if (e is DioException) {
                                      debugPrint(
                                        "STATUS CODE: ${e.response?.statusCode}",
                                      );
                                      debugPrint(
                                        "RESPONSE BODY: ${e.response?.data}",
                                      );
                                    }
                                    debugPrint(e.toString());

                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "Registration failed. Please try again.",
                                          ),
                                          backgroundColor: Colors.redAccent,
                                        ),
                                      );
                                    }
                                  } finally {
                                    if (mounted) {
                                      setState(() {
                                        _isLoading = false;
                                      });
                                    }
                                  }
                                },
                          child: _isLoading
                              ? SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: cardColor,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : Text(
                                  "Register",
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
