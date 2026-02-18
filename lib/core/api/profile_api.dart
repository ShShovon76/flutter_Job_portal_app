import 'dart:io';
import 'api_client.dart'; // your ApiClient

class ProfileApi {
  /// Uploads a profile picture for a user
  static Future<String> uploadProfilePicture({
    required int userId,
    required File file,
  }) async {
    try {
      // Using your ApiClient multipart method
      final streamedResponse = await ApiClient.multipart(
        'POST',
        '/users/$userId/profile-picture',
        files: {'file': file},
      );

      // Convert StreamedResponse to String
      final responseStr = await streamedResponse.stream.bytesToString();

      if (streamedResponse.statusCode == 200) {
        return responseStr; // Returns updated user JSON
      } else {
        throw Exception(
          'Failed to upload profile picture: ${streamedResponse.statusCode} \n$responseStr',
        );
      }
    } catch (e) {
      throw Exception('Profile picture upload error: $e');
    }
  }
}
