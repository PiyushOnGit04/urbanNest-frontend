import 'package:flutter/material.dart';
import 'package:urban_nest/models/inquiry.dart';
import 'package:urban_nest/service/api_service.dart';

class OwnerInquiryScreen extends StatefulWidget {
  final int roomId;

  const OwnerInquiryScreen({super.key, required this.roomId});

  @override
  State<OwnerInquiryScreen> createState() => _OwnerInquiryScreenState();
}

class _OwnerInquiryScreenState extends State<OwnerInquiryScreen> {
  final ApiService _apiService = ApiService();
  List<Inquiry> inquiries = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadInquiries();
  }

  Future<void> loadInquiries() async {
    try {
      inquiries = await _apiService.getRoomInquiries(widget.roomId);
    } catch (e) {
      print(e);
    }
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> updateStatus(int inquiryId, String status) async {
    try {
      await _apiService.updateInquiryStatus(inquiryId, status);
      loadInquiries();
    } catch (e) {
      print(e);
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case "ACCEPTED":
        return Color(0xFF059669);
      case "REJECTED":
        return Colors.red.shade600;
      default:
        return Colors.amber.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          "Room Inquiries",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.teal.shade700,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.teal))
          : inquiries.isEmpty
          ? Center(
              child: Text(
                "No inquiries yet",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: inquiries.length,
              itemBuilder: (context, index) {
                final inquiry = inquiries[index];
                final colorScheme = getStatusColor(inquiry.status);

                return Card(
                  color: Colors.white,
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.teal.shade50, width: 1.5),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              inquiry.tenantName,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal.shade900,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                inquiry.status,
                                style: TextStyle(
                                  color: colorScheme,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Tenant details with icons
                        Row(
                          children: [
                            Icon(
                              Icons.email_outlined,
                              size: 16,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              inquiry.tenantEmail,
                              style: TextStyle(color: Colors.grey.shade700),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.phone_android_outlined,
                              size: 16,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              inquiry.tenantPhone,
                              style: TextStyle(color: Colors.grey.shade700),
                            ),
                          ],
                        ),

                        if (inquiry.status == "PENDING") ...[
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12.0),
                            child: Divider(height: 1),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.red.shade600,
                                    side: BorderSide(
                                      color: Colors.red.shade200,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                  ),
                                  onPressed: () =>
                                      updateStatus(inquiry.id, "REJECTED"),
                                  child: const Text(
                                    "Reject",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.teal.shade600,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                  ),
                                  onPressed: () =>
                                      updateStatus(inquiry.id, "ACCEPTED"),
                                  child: const Text(
                                    "Accept",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
