class Classes{
  String id;
  List<String> students;

  Classes({
    required this.id,
    required this.students,
  });

  factory Classes.fromJson(Map<String, dynamic> json) {
    return Classes(
      id: json['class_id'],
      students: List<String>.from(json['students']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'class_id': id,
      'students': students,
    };
  }
}