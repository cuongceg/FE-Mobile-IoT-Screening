class Lecture {
  final String id;
  final String title;
  final String content;
  final String description;
  final String userId;
  final List<String> isPublicTo;
  final DateTime created;
  final DateTime updated;

  Lecture({
    required this.id,
    required this.title,
    required this.content,
    required this.description,
    required this.userId,
    required this.isPublicTo,
    required this.created,
    required this.updated,
  });

  factory Lecture.fromJson(Map<String, dynamic> json) {
    return Lecture(
      id: json["_id"],
      title: json["title"],
      content: json["content"],
      description: json["description"],
      userId: json["userId"],
      isPublicTo: List<String>.from(json["isPublicTo"]),
      created: DateTime.parse(json["created"]),
      updated: DateTime.parse(json["updated"]),
    );
  }

  static List<Lecture> listFromJson(List<dynamic> list) {
    return list.map((item) => Lecture.fromJson(item)).toList();
  }
}
