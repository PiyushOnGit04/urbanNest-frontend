import 'package:dio/dio.dart';
import 'package:urban_nest/models/DeleteAccountRequest.dart';
import 'package:urban_nest/models/amenity.dart';
import 'package:urban_nest/models/auth_response.dart';
import 'package:urban_nest/models/inquiry.dart';
import 'package:urban_nest/models/inquiry_payload.dart';
import 'package:urban_nest/models/login_request.dart';
import 'package:urban_nest/models/register_request.dart';
import 'package:urban_nest/models/room.dart';
import 'package:urban_nest/models/room_request.dart';
import 'package:urban_nest/models/update_profile_request.dart';
import 'package:urban_nest/models/user.dart';
import 'package:urban_nest/models/wishlist_payload.dart';

import '../utils/constants.dart';
import 'token_service.dart';

class ApiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: Constants.baseUrl,
      headers: {"Content-Type": "application/json"},
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
    ),
  );

  final TokenService _tokenService = TokenService();

  ApiService() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokenService.getToken();
          if (token != null) {
            options.headers["Authorization"] = "Bearer $token";
          }
          return handler.next(options);
        },
      ),
    );
  }

  Future<void> register(RegisterRequest request) async {
    await _dio.post(Constants.register, data: request.toJson());
  }

  // Uses the shared _dio instance so the Authorization interceptor above
  // attaches the JWT automatically — fixes uploads failing after
  // SecurityConfig started requiring authentication on this endpoint.
  Future<void> uploadRoomImages(int roomId, List<String> filePaths) async {
    final formData = FormData();
    for (final path in filePaths) {
      formData.files.add(MapEntry("files", await MultipartFile.fromFile(path)));
    }
    await _dio.post("/api/rooms/$roomId/images", data: formData);
  }

  Future<AuthResponse> login(LoginRequest request) async {
    try {
      print("BASE URL = ${Constants.baseUrl}");
      print("LOGIN URL = ${Constants.baseUrl}${Constants.login}");

      final response = await _dio.post(Constants.login, data: request.toJson());

      print("LOGIN RESPONSE = ${response.data}");

      final authResponse = AuthResponse.fromJson(response.data);

      // ADD THESE PRINTS
      print("========== LOGIN SUCCESS ==========");
      print("TOKEN RECEIVED:");
      print(authResponse.token);
      print("USER ID: ${authResponse.userId}");
      print("ROLE: ${authResponse.role}");
      print("===================================");

      await _tokenService.saveToken(authResponse.token);
      await _tokenService.saveUserId(authResponse.userId);

      return authResponse;
    } on DioException catch (e) {
      print("========== LOGIN ERROR ==========");
      print("TYPE: ${e.type}");
      print("MESSAGE: ${e.message}");
      print("ERROR: ${e.error}");
      print("RESPONSE: ${e.response?.data}");
      print("=================================");

      rethrow;
    }
  }

  Future<Room> createRoom(RoomRequest room) async {
    final response = await _dio.post(Constants.rooms, data: room.toJson());

    return Room.fromJson(response.data);
  }

  Future<List<Room>> getRooms({
    String? search,
    double? minRent,
    double? maxRent,
    String? roomType,
    bool? available,
    String? sortBy,
    String? order,
  }) async {
    final tenantId = await _tokenService.getUserId();

    final queryParameters = <String, dynamic>{};

    if (search != null && search.isNotEmpty) {
      queryParameters["search"] = search;
    }
    if (available != null) {
      queryParameters["available"] = available;
    }

    if (minRent != null) {
      queryParameters["minRent"] = minRent;
    }

    if (maxRent != null) {
      queryParameters["maxRent"] = maxRent;
    }

    if (roomType != null) {
      queryParameters["roomType"] = roomType;
    }

    if (sortBy != null) {
      queryParameters["sortBy"] = sortBy;
    }

    if (order != null) {
      queryParameters["order"] = order;
    }

    // Send logged-in tenant's id to backend
    if (tenantId != null) {
      queryParameters["tenantId"] = tenantId;
    }

    final response = await _dio.get(
      Constants.rooms,
      queryParameters: queryParameters,
    );

    return (response.data as List).map((room) => Room.fromJson(room)).toList();
  }

  Future<List<Room>> searchRooms(String city) async {
    final response = await _dio.get(
      "${Constants.rooms}/search",
      queryParameters: {"city": city},
    );

    return (response.data as List).map((room) => Room.fromJson(room)).toList();
  }

  Future<List<Room>> filterRooms(double minRent, double maxRent) async {
    final response = await _dio.get(
      "${Constants.rooms}/filter",
      queryParameters: {"minRent": minRent, "maxRent": maxRent},
    );

    return (response.data as List).map((room) => Room.fromJson(room)).toList();
  }

  Future<User> getUserById(int id) async {
    final response = await _dio.get("/api/users/$id");

    return User.fromJson(response.data);
  }

  Future<void> deleteAccount(DeleteAccountRequest request) async {
    await _dio.delete("${Constants.users}/me", data: request.toJson());
  }

  Future<User> updateProfile(String? name, String? phoneNumber) async {
    final response = await _dio.put(
      "/api/users/me",
      data: UpdateProfileRequest(name: name, phoneNumber: phoneNumber).toJson(),
    );

    return User.fromJson(response.data);
  }

  Future<List<Room>> getOwnerRooms(int ownerId) async {
    final response = await _dio.get("/api/rooms/owner/$ownerId");

    return (response.data as List).map((e) => Room.fromJson(e)).toList();
  }

  Future<Room> getRoomById(int roomId) async {
    final tenantId = await _tokenService.getUserId();

    final response = await _dio.get(
      "/api/rooms/$roomId",
      queryParameters: {"tenantId": ?tenantId},
    );

    return Room.fromJson(response.data);
  }

  Future<void> sendInquiry(InquiryPayload payload) async {
    await _dio.post("/api/inquiries", data: payload.toJson());
  }

  Future<void> deleteRoom(int roomId) async {
    await _dio.delete("/api/rooms/$roomId");
  }

  Future<List<Inquiry>> getRoomInquiries(int roomId) async {
    final response = await _dio.get("/api/inquiries/room/$roomId");

    print("INQUIRIES RESPONSE:");
    print(response.data);

    return (response.data as List).map((e) => Inquiry.fromJson(e)).toList();
  }

  Future<void> addToWishlist(WishlistPayload payload) async {
    await _dio.post("/api/wishlist", data: payload.toJson());
  }

  Future<void> removeFromWishlist(int tenantId, int roomId) async {
    await _dio.delete(
      "/api/wishlist",
      queryParameters: {"tenantId": tenantId, "roomId": roomId},
    );
  }

  Future<void> updateInquiryStatus(int inquiryId, String status) async {
    await _dio.put(
      "/api/inquiries/$inquiryId/status",
      queryParameters: {"status": status},
    );
  }

  Future<bool> isRoomWishlisted(int tenantId, int roomId) async {
    final response = await _dio.get("/api/wishlist/$tenantId");

    final List<dynamic> wishlist = response.data;

    return wishlist.any((item) => item["room"]["id"] == roomId);
  }

  Future<List<Room>> getWishlistRooms(int tenantId) async {
    final response = await _dio.get("/api/wishlist/$tenantId");

    return (response.data as List)
        .map((e) => Room.fromJson(e["room"]))
        .toList();
  }

  Future<bool> hasInquiry(int tenantId, int roomId) async {
    final response = await _dio.get(
      "/api/inquiries/exists",
      queryParameters: {"tenantId": tenantId, "roomId": roomId},
    );

    return response.data as bool;
  }

  Future<Room> updateRoom(int roomId, RoomRequest room) async {
    final response = await _dio.put("/api/rooms/$roomId", data: room.toJson());

    return Room.fromJson(response.data);
  }

  Future<void> updateRoomAvailability(int roomId, bool available) async {
    await _dio.put(
      "/api/rooms/$roomId/availability",
      queryParameters: {"available": available},
    );
  }

  Future<List<Amenity>> getAmenities() async {
    final response = await _dio.get("/api/amenities");

    return (response.data as List).map((e) => Amenity.fromJson(e)).toList();
  }
}
