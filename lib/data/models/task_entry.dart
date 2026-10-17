class TaskEntry {
  const TaskEntry({
    required this.title,
    required this.tag,
    required this.description,
    required this.duration,
    required this.completedAt,
  });

  final String title;
  final String tag;
  final String description;
  final Duration duration;
  final DateTime completedAt;

  Map<String, Object?> toJson() => {
        'title': title,
        'tag': tag,
        'description': description,
        'durationSeconds': duration.inSeconds,
        'completedAt': completedAt.toIso8601String(),
      };

  factory TaskEntry.fromJson(Map<String, Object?> json) => TaskEntry(
        title: json['title']! as String,
        tag: json['tag']! as String,
        description: json['description']! as String,
        duration: Duration(seconds: json['durationSeconds']! as int),
        completedAt: DateTime.parse(json['completedAt']! as String),
      );
}
