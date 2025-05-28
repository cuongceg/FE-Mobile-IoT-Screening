class Classes{
  String id;
  List<Student> students;

  Classes({
    required this.id,
    required this.students,
  });

  factory Classes.fromJson(Map<String, dynamic> json) {
    return Classes(
      id: json['class_id'],
      students: (json['students'] as List)
          .map((student) => Student.fromJson(student))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'class_id': id,
      'students': students,
    };
  }
}

class Student{
  String id;
  String name;

  Student({
    required this.id,
    required this.name,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['user_id'],
      name: json['username'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'user_id': id,
      'username': name,
    };
  }
}