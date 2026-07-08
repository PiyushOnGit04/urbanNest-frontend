import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
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

  // Track loading status per inquiry ID to prevent duplicate clicks
  final Map<int, bool> _processingInquiries = {};

  @override
  void initState() {
    super.initState();
    loadInquiries();
  }

  Future<void> loadInquiries() async {
    try {
      final data = await _apiService.getRoomInquiries(widget.roomId);
      if (mounted) {
        setState(() {
          inquiries = data;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading inquiries: $e');
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> updateStatus(int inquiryId, String status) async {
    // Show user dialog verification before mutating state data
    final confirmed = await _showActionConfirmDialog(status);
    if (!confirmed) return;

    setState(() => _processingInquiries[inquiryId] = true);

    try {
      await _apiService.updateInquiryStatus(inquiryId, status);
      await loadInquiries();
    } catch (e) {
      debugPrint('Error updating inquiry: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update status to $status")),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _processingInquiries[inquiryId] = false);
      }
    }
  }

  Future<bool> _showActionConfirmDialog(String status) async {
    final isAccept = status == "ACCEPTED";
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text("${isAccept ? 'Accept' : 'Reject'} Inquiry?"),
            content: Text(
              "Are you sure you want to ${isAccept ? 'accept' : 'reject'} this tenant's request?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text(
                  "Cancel",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(
                  isAccept ? "Accept" : "Reject",
                  style: TextStyle(
                    color: isAccept
                        ? Colors.teal.shade700
                        : Colors.red.shade600,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _launchIntent(String urlString) async {
    final Uri uri = Uri.parse(urlString);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        throw 'Could not launch $urlString';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Could not open the required app")),
        );
      }
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case "ACCEPTED":
        return const Color(0xFF059669);
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
          : RefreshIndicator(
              onRefresh: loadInquiries,
              color: Colors.teal.shade700,
              child: inquiries.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      itemCount: inquiries.length,
                      itemBuilder: (context, index) {
                        final inquiry = inquiries[index];
                        final colorScheme = getStatusColor(inquiry.status);
                        final isBusy =
                            _processingInquiries[inquiry.id] ?? false;

                        return Card(
                          color: Colors.white,
                          elevation: 0,
                          margin: const EdgeInsets.only(bottom: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: Colors.teal.shade50,
                              width: 1.5,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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

                                // Clickable Email Tile Row
                                InkWell(
                                  onTap: () => _launchIntent(
                                    'mailto:${inquiry.tenantEmail}',
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4.0,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.email_outlined,
                                          size: 16,
                                          color: Colors.teal.shade600,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          inquiry.tenantEmail,
                                          style: TextStyle(
                                            color: Colors.teal.shade800,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),

                                // Clickable Phone Number Row
                                InkWell(
                                  onTap: () => _launchIntent(
                                    'tel:${inquiry.tenantPhone}',
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4.0,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.phone_android_outlined,
                                          size: 16,
                                          color: Colors.teal.shade600,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          inquiry.tenantPhone,
                                          style: TextStyle(
                                            color: Colors.teal.shade800,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                if (inquiry.status == "PENDING") ...[
                                  const Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 12.0,
                                    ),
                                    child: Divider(height: 1),
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton(
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor:
                                                Colors.red.shade600,
                                            side: BorderSide(
                                              color: Colors.red.shade200,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 12,
                                            ),
                                          ),
                                          onPressed: isBusy
                                              ? null
                                              : () => updateStatus(
                                                  inquiry.id,
                                                  "REJECTED",
                                                ),
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
                                            backgroundColor:
                                                Colors.teal.shade600,
                                            foregroundColor: Colors.white,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 12,
                                            ),
                                          ),
                                          onPressed: isBusy
                                              ? null
                                              : () => updateStatus(
                                                  inquiry.id,
                                                  "ACCEPTED",
                                                ),
                                          child: isBusy
                                              ? const SizedBox(
                                                  height: 16,
                                                  width: 16,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                          Color
                                                        >(Colors.white),
                                                  ),
                                                )
                                              : const Text(
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
            ),
    );
  }

  Widget _buildEmptyState() {
    return LayoutBuilder(
      builder: (context, constraints) => ListView(
        children: [
          Container(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            alignment: Alignment.center,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.mark_as_unread_outlined,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  "No inquiries yet",
                  style: TextStyle(
                    color: Colors.grey.shade800,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "When prospective tenants express interest in this room, their requests will appear here.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
