import 'package:flutter/material.dart';
import '../model/lecture.dart';
import '../repositories/lectures_repository.dart';
import 'auth_provider.dart';

class LectureProvider extends ChangeNotifier {
  final LectureRepository repository;
  final AuthProvider authProvider; // Add AuthProvider dependency

  List<Lecture> _lectures = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Lecture> get lectures => _lectures;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  LectureProvider({required this.repository, required this.authProvider});

  Future<void> fetchLectures() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final String? token = authProvider.accessToken;
    final String? userId = authProvider.userId;

    if (token == null || userId == null) {
      _errorMessage = "Unauthorized: Please log in";
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      _lectures = await repository.getAllLecturesByUserId(userId, token);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateLecture(String id, String title, String content, String description) async {
    final accessToken = authProvider.accessToken;
    if (accessToken == null) return false;

    bool success = await repository.updateLecture(
      id: id,
      title: title,
      content: content,
      description: description,
      accessToken: accessToken,
    );

    if (success) {
      int index = _lectures.indexWhere((lecture) => lecture.id == id);
      if (index != -1) {
        _lectures[index] = Lecture(
            id: id, title: title, content: content, description: description,
        created: _lectures[index].created, updated: DateTime.now(),
        isPublicTo: _lectures[index].isPublicTo,
        userId: _lectures[index].userId);
        notifyListeners();
      }
    }

    return success;
  }

  Future<bool> deleteLecture(String id) async {
    final accessToken = authProvider.accessToken;
    if (accessToken == null) return false;

    bool success = await repository.deleteLecture(lectureId: id, accessToken: accessToken);

    if (success) {
      _lectures.removeWhere((lecture) => lecture.id == id);
      notifyListeners();
    }

    return success;
  }
  
  Future<bool>createLecture({
    required String title,
    required String content,
    required String description,
  }) async {
    final accessToken = authProvider.accessToken;
    final userId = authProvider.userId;
    if (accessToken == null || userId == null) return false;

    final Lecture? lecture= await repository.createLecture(
      title: title,
      content: content,
      description: description,
      accessToken: accessToken,
      userId: userId,
    );

    if (lecture != null) {
      _lectures.add(lecture);
      notifyListeners();
      return true;
    }

    return false;
  }
}