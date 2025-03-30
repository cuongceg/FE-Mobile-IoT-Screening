import 'package:flutter/material.dart';
import 'package:speech_to_text_iot_screen/model/classes.dart';
import 'package:speech_to_text_iot_screen/services/auth_service.dart';

class ClassesProvider extends ChangeNotifier{
  List<Classes> _classes = [];
  final Map<String, bool> _selectedClasses = {}; // Tracks selected classes
  final Set<String> _selectedStudents ={};

  ClassesProvider(){
    getClasses();
  }

  List<Classes> get classes => _classes;
  Map<String, bool> get selectedClasses => _selectedClasses;
  Set<String> get selectedStudents => _selectedStudents;

  Future<void> getClasses() async{
    final response = await AuthService().getAllClasses();
    if(response != null){
      _classes = response;
      notifyListeners();
    }
  }

  void toggleClassSelection(String classId){
    if(_selectedClasses.containsKey(classId)){
      _selectedClasses[classId] = !_selectedClasses[classId]!;
    }else{
      _selectedClasses[classId] = true;
    }
    if(_selectedClasses[classId]!) {
      _selectedStudents.addAll(_classes
          .firstWhere((element) => element.id == classId)
          .students.toSet());
    }else{
      _selectedStudents.removeWhere((element) => _classes
          .firstWhere((element) => element.id == classId)
          .students.contains(element));
    }
    notifyListeners();
  }

  void addStudentToSelected(String student){
    _selectedStudents.add(student);
    for (var cl in _classes) {
      bool allStudentsSelected = cl.students.isNotEmpty &&
          cl.students.every((s) => _selectedStudents.contains(s));
      _selectedClasses[cl.id] = allStudentsSelected;
    }
    notifyListeners();
  }

  void addStudentsToSelected(List<String> student){
    _selectedStudents.clear();
    _selectedStudents.addAll(student);
    _selectedClasses.clear();
    for (var cl in _classes) {
      bool allStudentsSelected = cl.students.isNotEmpty &&
          cl.students.every((s) => _selectedStudents.contains(s));
      _selectedClasses[cl.id] = allStudentsSelected;
    }
    notifyListeners();
  }

  void removeStudentFromSelected(String student){
    _selectedStudents.remove(student);
    for (var cl in _classes) {
      bool allStudentsSelected = cl.students.isNotEmpty &&
          cl.students.every((s) => _selectedStudents.contains(s));
      _selectedClasses[cl.id] = allStudentsSelected;
    }
    notifyListeners();
  }
}