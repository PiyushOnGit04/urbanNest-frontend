import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  static const Color primaryColor = Color(0xFF1A5F7A);
  static const Color accentColor = Color(0xFF57C5B6);
  static const Color backgroundColor = Color(0xFFF5F9FA);
  static const Color cardColor = Colors.white;

  static const List<Map<String, String>> _faqs = [
    {
      "question": "How do I send an inquiry for a room?",
      "answer":
          "Open any room's details page and tap \"Send Inquiry.\" The owner will be notified and can respond to your request.",
    },
    {
      "question": "How do I list my own room?",
      "answer":
          "From your home screen, use the \"Add Room\" option to create a new listing with photos, pricing, and amenities.",
    },
    {
      "question": "Can I edit my profile information?",
      "answer":
          "Yes, go to Profile > Edit Profile to update your name and phone number.",
    },
    {
      "question": "How do I contact a room owner directly?",
      "answer":
          "Owner contact details are shown on the room details page once you view a listing.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Help & Support",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: primaryColor,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        children: [
          Text(
            "Frequently Asked Questions",
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          ..._faqs.map(
            (faq) => _buildFaqTile(faq["question"]!, faq["answer"]!),
          ),
          const SizedBox(height: 32),

          Text(
            "Still need help?",
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.support_agent_rounded, color: accentColor, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Reach out to us at support@urbannest.app and we'll get back within 24 hours.",
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqTile(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            question,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: primaryColor,
            ),
          ),
          iconColor: accentColor,
          collapsedIconColor: Colors.grey.shade400,
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              answer,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
