import 'package:flutter/material.dart';
import 'package:urban_nest/models/login_request.dart';
import 'package:urban_nest/screens/owner_home_screen.dart';
import 'package:urban_nest/screens/tenant_homescreen.dart';
import 'package:urban_nest/service/api_service.dart';
import 'register_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  bool _obscurePassword = true;

  // Global Cool-Mint Theme Definitions
  final Color primaryColor = const Color(0xFF1A5F7A); // Deep Slate Blue
  final Color accentColor = const Color(0xFF57C5B6); // Clean Mint Green
  final Color backgroundColor = const Color(
    0xFFF5F9FA,
  ); // Ultra-light background
  final Color cardColor = Colors.white;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Brand Vector/Icon Frame
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: cardColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.home_work_rounded,
                    size: 64,
                    color: accentColor,
                  ),
                ),
                const SizedBox(height: 16),

                Text(
                  "UrbanNest",
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: primaryColor,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  "Find your comfort space seamlessly",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 44),

                // Email Input Field
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    labelText: "Email Address",
                    labelStyle: GoogleFonts.poppins(
                      color: Colors.grey.shade500,
                      fontSize: 14,
                    ),
                    floatingLabelStyle: GoogleFonts.poppins(
                      color: primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                    prefixIcon: Icon(
                      Icons.mail_outline_rounded,
                      size: 20,
                      color: Colors.grey.shade400,
                    ),
                    filled: true,
                    fillColor: cardColor,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: Colors.grey.shade200,
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: accentColor, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Password Input Field
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    labelText: "Password",
                    labelStyle: GoogleFonts.poppins(
                      color: Colors.grey.shade500,
                      fontSize: 14,
                    ),
                    floatingLabelStyle: GoogleFonts.poppins(
                      color: primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                    prefixIcon: Icon(
                      Icons.lock_open_rounded,
                      size: 20,
                      color: Colors.grey.shade400,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 20,
                        color: Colors.grey.shade400,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    filled: true,
                    fillColor: cardColor,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: Colors.grey.shade200,
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: accentColor, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Premium Action Submission Button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () async {
                            try {
                              setState(() => _isLoading = true);
                              debugPrint("Login button clicked");

                              final response = await _apiService.login(
                                LoginRequest(
                                  email: _emailController.text.trim(),
                                  password: _passwordController.text.trim(),
                                ),
                              );

                              debugPrint(
                                "Login success. ROLE = ${response.role}",
                              );

                              if (!context.mounted) return;

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Welcome back, ${response.email}",
                                  ),
                                  backgroundColor: primaryColor,
                                ),
                              );

                              if (response.role == "ROLE_OWNER") {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const OwnerHomeScreen(),
                                  ),
                                );
                              } else {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const TenantHomeScreen(),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(e.toString()),
                                    backgroundColor: Colors.redAccent,
                                  ),
                                );
                              }
                              debugPrint(e.toString());
                            } finally {
                              if (mounted) setState(() => _isLoading = false);
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: primaryColor.withOpacity(0.6),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                cardColor,
                              ),
                            ),
                          )
                        : Text(
                            "Login",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),

                // Register Secondary Navigation
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterScreen()),
                    );
                  },
                  style: TextButton.styleFrom(foregroundColor: primaryColor),
                  child: RichText(
                    text: TextSpan(
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                      children: [
                        const TextSpan(text: "Don't have an account? "),
                        TextSpan(
                          text: "Register",
                          style: TextStyle(
                            color: accentColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
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
