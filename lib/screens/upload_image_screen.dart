import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class UploadImagesScreen extends StatefulWidget {
  final int roomId;

  const UploadImagesScreen({super.key, required this.roomId});

  @override
  State<UploadImagesScreen> createState() => _UploadImagesScreenState();
}

class _UploadImagesScreenState extends State<UploadImagesScreen> {
  final ImagePicker _picker = ImagePicker();
  List<XFile> selectedImages = [];
  bool isUploading = false;

  Future<void> pickImages() async {
    final images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        // Appends new selections instead of wiping out previous ones
        selectedImages.addAll(images);
      });
    }
  }

  void removeImage(int index) {
    setState(() {
      selectedImages.removeAt(index);
    });
  }

  Future<void> uploadImages() async {
    if (selectedImages.isEmpty) return;

    try {
      setState(() {
        isUploading = true;
      });

      FormData formData = FormData();
      for (var image in selectedImages) {
        formData.files.add(
          MapEntry("files", await MultipartFile.fromFile(image.path)),
        );
      }

      await Dio().post(
        "https://urban-nest-backend-production.up.railway.app/api/rooms/${widget.roomId}/images",
        data: formData,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Images Uploaded Successfully!",
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Upload failed. Please try again.",
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.teal, Colors.blue],
            ),
          ),
        ),
        title: Text(
          "Upload Room Photos",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontSize: 18,
          ),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Add photos of your room",
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2D3142),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Guests love crisp, clear photos. Select up to 10 images.",
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),

                // Main Workspace Grid
                Expanded(
                  child: selectedImages.isEmpty
                      ? _buildEmptyStatePlaceholder()
                      : GridView.builder(
                          itemCount:
                              selectedImages.length +
                              1, // +1 is the custom "Add More" box
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 14,
                                mainAxisSpacing: 14,
                                childAspectRatio: 1,
                              ),
                          itemBuilder: (context, index) {
                            if (index == selectedImages.length) {
                              return _buildAddMoreGridTile();
                            }
                            return _buildImageGridTile(index);
                          },
                        ),
                ),
                const SizedBox(height: 16),

                // Sticky Action Button at the bottom
                if (selectedImages.isNotEmpty)
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: isUploading ? null : uploadImages,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A2A6C),
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        "Upload ${selectedImages.length} ${selectedImages.length == 1 ? 'Photo' : 'Photos'}",
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

          // Clean, full-screen blur/dim loading overlay
          if (isUploading)
            Container(
              color: Colors.black45,
              child: Center(
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 24,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFFB21F1F),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Uploading files...",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyStatePlaceholder() {
    return GestureDetector(
      onTap: pickImages,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.grey.shade300,
            width: 2,
            style: BorderStyle.solid,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              "Tap to select images",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2D3142),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Supports PNG, JPG",
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGridTile(int index) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.file(
              File(selectedImages[index].path),
              fit: BoxFit.cover,
            ),
          ),
        ),
        // Floating clear button overlay
        Positioned(
          top: 6,
          right: 6,
          child: GestureDetector(
            onTap: () => removeImage(index),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddMoreGridTile() {
    return GestureDetector(
      onTap: pickImages,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey.shade300,
            style: BorderStyle.solid,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: Colors.grey[600], size: 28),
            const SizedBox(height: 4),
            Text(
              "Add More",
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
