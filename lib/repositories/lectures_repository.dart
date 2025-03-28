import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:speech_to_text_iot_screen/model/lecture.dart';
import '../network/api_urls.dart';

class LectureRepository {
  Future<List<Lecture>> getAllLecturesByUserId(String uid, String accessToken) async {
    try {
      final response = await http.get(
        Uri.parse(getAllLecturesByUserIdURL(uid)),
        headers: {
          "Authorization": "Bearer $accessToken",
          "Content-Type": "application/json",
        },
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return Lecture.listFromJson(responseData["Lectures"]);
      } else {
        throw Exception("Failed to fetch lectures");
      }
    } catch (e) {
      throw Exception("Error fetching lectures: $e");
    }
  }
  Future<bool> updateLecture({
    required String id,
    required String title,
    required String content,
    required String description,
    required String accessToken,
  }) async {
    final url = updateLectureURL(id);

    try {
      final response = await http.patch(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'title': title,
          'content': content,
          'description': description,
        }),
      );

      if (response.statusCode == 200) {
        return true; // Successfully updated
      } else {
        print("Failed to update lecture: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error updating lecture: $e");
      return false;
    }
  }

  Future<bool> deleteLecture({required String lectureId,required String accessToken}) async {
    final String url = deleteLectureURL(lectureId);

    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $accessToken",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print("Error deleting lecture: $e");
      return false;
    }
  }

  Future<Lecture?> createLecture({
    required String title,
    required String description,
    required String content,
    required String userId,
    required String accessToken,
  }) async {

    try {
      final response = await http.post(
        Uri.parse(createLectureURL),
        headers: {
          "Authorization": "Bearer $accessToken",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "title": title,
          "description": description,
          "content": content,
          "userId": userId,
          "isPublicTo": [],
        }),
      );
      print("RESPONSE: ${response.body}");
      if (response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return Lecture.fromJson(responseData["lecture"]);
      } else {
        throw Exception("Failed to create lecture");
      }
    } catch (e) {
      print("Error creating lecture: $e");
    }
    return null;
  }

}