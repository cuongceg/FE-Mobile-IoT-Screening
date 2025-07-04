import 'dart:convert';

import 'package:flutter/material.dart';
import '../model/lecture.dart';
import '../repositories/lectures_repository.dart';
import 'auth_provider.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

class LectureProvider extends ChangeNotifier {
  final LectureRepository repository;
  final AuthProvider authProvider; // Add AuthProvider dependency

  List<Lecture> _lectures = [];
  bool _isLoading = false;
  String? _errorMessage;
  Lecture? _currentLecture;
  quill.QuillController _controller = quill.QuillController.basic();

  List<Lecture> get lectures => _lectures;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  quill.QuillController get controller => _controller;
  Lecture? get currentLecture => _currentLecture;

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

  Future<bool> updateLecture({required String id,required String title,required String description}) async {
    final accessToken = authProvider.accessToken;
    if (accessToken == null) return false;

    bool success = await repository.updateLecture(
      id: id,
      title: title,
      description: description,
      accessToken: accessToken,
    );

    if (success) {
      int index = _lectures.indexWhere((lecture) => lecture.id == id);
      if (index != -1) {
        _lectures[index] = _lectures[index].copyWith(
          title: title,
          description: description,
        );
        notifyListeners();
      }
    }

    return success;
  }

  Future<bool> updateLectureContent({required String id,required String content}) async {
    final accessToken = authProvider.accessToken;
    if (accessToken == null) return false;

    bool success = await repository.updateLectureContent(
      id: id,
      content: content,
      accessToken: accessToken,
    );

    if (success) {
      int index = _lectures.indexWhere((lecture) => lecture.id == id);
      if (index != -1) {
        _lectures[index] = _lectures[index].copyWith(
          content: content,
        );
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

  Future<bool> addStudentToLecture({
    required String lectureId,
    required List<String> studentIds})async{
    final accessToken = authProvider.accessToken;
    if (accessToken == null) return false;

    final Lecture? lecture = await repository.addStudentToLecture(
      lectureId: lectureId,
      studentIds: studentIds,
      accessToken: accessToken,
    );

    if (lecture != null) {
      int index = _lectures.indexWhere((lecture) => lecture.id == lectureId);
      if (index != -1) {
        _lectures[index].isPublicTo.clear();
        _lectures[index].isPublicTo.addAll(lecture.isPublicTo);
        notifyListeners();
      }
      return true;
    }
    return false;
  }

  void getLectureById(String id) {
    final lecture = _lectures.firstWhere((lecture) => lecture.id == id);
    _currentLecture = lecture;
    _controller = quill.QuillController(
      document: quill.Document.fromJson(jsonDecode(lecture.content)),
      selection: const TextSelection.collapsed(offset: 0),
    );
    notifyListeners();
    return ;
  }
}