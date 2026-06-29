import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:urban_nest/models/amenity.dart';
import 'package:urban_nest/models/room.dart';
import 'package:urban_nest/models/room_request.dart';
import 'package:urban_nest/screens/upload_image_screen.dart';
import 'package:urban_nest/service/api_service.dart';
import 'package:urban_nest/service/token_service.dart';
import 'package:google_fonts/google_fonts.dart';

class CreateRoomScreen extends StatefulWidget {
  final Room? room;

  const CreateRoomScreen({super.key, this.room});

  @override
  State<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  final ApiService _apiService = ApiService();
  final TokenService _tokenService = TokenService();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _rentController = TextEditingController();
  final _depositController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _localityController = TextEditingController();

  int? ownerId;
  String selectedRoomType = "ROOM";
  bool isLoading = false;

  List<Amenity> amenities = [];
  List<int> selectedAmenityIds = [];

  // Global Cool-Mint Theme Definitions
  final Color primaryColor = const Color(0xFF1A5F7A); // Deep Slate Blue
  final Color accentColor = const Color(0xFF57C5B6); // Clean Mint Green
  final Color backgroundColor = const Color(
    0xFFF5F9FA,
  ); // Ultra-light background
  final Color cardColor = Colors.white;

  @override
  void initState() {
    super.initState();

    loadOwnerId();
    loadAmenities();

    if (widget.room != null) {
      _titleController.text = widget.room!.title;
      _descriptionController.text = widget.room!.description;
      _rentController.text = widget.room!.rent.toString();
      _depositController.text = widget.room!.deposit.toString();
      _addressController.text = widget.room!.address;
      _cityController.text = widget.room!.city;
      _localityController.text = widget.room!.locality;
      selectedRoomType = widget.room!.roomType;
    }
  }

  Future<void> loadAmenities() async {
    try {
      final data = await _apiService.getAmenities();

      print("Amenities received: ${data.length}");
      print(data);

      if (!mounted) return;

      setState(() {
        amenities = data;

        if (widget.room != null) {
          selectedAmenityIds = widget.room!.amenities.map((e) => e.id).toList();
        }
      });
    } catch (e) {
      print("Amenities Error: $e");
    }
  }

  Future<void> loadOwnerId() async {
    ownerId = await _tokenService.getUserId();
    debugPrint("LOADED OWNER ID = $ownerId");
    setState(() {});
  }

  Future<void> createRoom() async {
    if (ownerId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please login again")));
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      final room = RoomRequest(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        rent: double.parse(_rentController.text),
        deposit: double.parse(_depositController.text),
        address: _addressController.text.trim(),
        city: _cityController.text.trim(),
        locality: _localityController.text.trim(),
        roomType: selectedRoomType,
        ownerId: ownerId!,
        amenityIds: selectedAmenityIds,
      );

      final createdRoom = await _apiService.createRoom(room);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => UploadImagesScreen(roomId: createdRoom.id),
          ),
        );
      }
    } catch (e) {
      if (e is DioException) {
        debugPrint("STATUS CODE: ${e.response?.statusCode}");
        debugPrint("RESPONSE BODY: ${e.response?.data}");
      }
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> updateRoom() async {
    try {
      setState(() {
        isLoading = true;
      });

      final roomRequest = RoomRequest(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        rent: double.parse(_rentController.text),
        deposit: double.parse(_depositController.text),
        address: _addressController.text.trim(),
        city: _cityController.text.trim(),
        locality: _localityController.text.trim(),
        roomType: selectedRoomType,
        ownerId: ownerId!,
        amenityIds: selectedAmenityIds,
      );

      await _apiService.updateRoom(widget.room!.id, roomRequest);

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _rentController.dispose();
    _depositController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _localityController.dispose();
    super.dispose();
  }

  // Refactored helper with modern input decorations
  Widget buildField(
    TextEditingController controller,
    String label, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: GoogleFonts.poppins(
          fontSize: 15,
          color: primaryColor,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(
            color: Colors.grey.shade500,
            fontSize: 14,
          ),
          floatingLabelStyle: GoogleFonts.poppins(
            color: primaryColor,
            fontWeight: FontWeight.w600,
          ),
          filled: true,
          fillColor: cardColor,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: accentColor, width: 2),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          "List a Property",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: primaryColor,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildField(_titleController, "Property Title"),
            buildField(_descriptionController, "Detailed Description"),

            Row(
              children: [
                Expanded(
                  child: buildField(
                    _rentController,
                    "Monthly Rent (₹)",
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: buildField(
                    _depositController,
                    "Security Deposit (₹)",
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),

            buildField(_addressController, "Full Street Address"),

            Row(
              children: [
                Expanded(
                  child: buildField(_localityController, "Locality / Sector"),
                ),
                const SizedBox(width: 16),
                Expanded(child: buildField(_cityController, "City")),
              ],
            ),

            // Dropdown component styled to match inputs
            DropdownButtonFormField<String>(
              initialValue: selectedRoomType,
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: primaryColor,
                fontWeight: FontWeight.w500,
              ),
              dropdownColor: cardColor,
              decoration: InputDecoration(
                labelText: "Property Category",
                labelStyle: GoogleFonts.poppins(
                  color: Colors.grey.shade500,
                  fontSize: 14,
                ),
                floatingLabelStyle: GoogleFonts.poppins(
                  color: primaryColor,
                  fontWeight: FontWeight.w600,
                ),
                filled: true,
                fillColor: cardColor,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.grey.shade200,
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: accentColor, width: 2),
                ),
              ),
              items: const [
                DropdownMenuItem(value: "ROOM", child: Text("Room")),
                DropdownMenuItem(value: "PG", child: Text("PG")),
                DropdownMenuItem(value: "HOSTEL", child: Text("Hostel")),
                DropdownMenuItem(value: "FLAT", child: Text("Flat")),
              ],
              onChanged: (value) {
                setState(() {
                  selectedRoomType = value!;
                });
              },
            ),

            const SizedBox(height: 24),

            Text(
              "Amenities",
              style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 12),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: amenities.map((amenity) {
                final selected = selectedAmenityIds.contains(amenity.id);

                return FilterChip(
                  checkmarkColor: Colors.teal,
                  backgroundColor: Colors.teal[50],
                  label: Text(amenity.name),
                  selected: selected,
                  onSelected: (value) {
                    setState(() {
                      if (value) {
                        selectedAmenityIds.add(amenity.id);
                      } else {
                        selectedAmenityIds.remove(amenity.id);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 36),

            // Elevated Dynamic Action Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: isLoading
                    ? null
                    : widget.room == null
                    ? createRoom
                    : updateRoom,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: primaryColor.withOpacity(0.6),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: isLoading
                    ? SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(cardColor),
                        ),
                      )
                    : Text(
                        widget.room == null
                            ? "Continue to Images"
                            : "Update Property",
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
    );
  }
}
