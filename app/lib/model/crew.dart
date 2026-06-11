class Crew {
  final int id;
  final String name;
  final String department;
  final String job;
  final String? profilePath;

  Crew({
    required this.id,
    required this.name,
    required this.department,
    required this.job,
    this.profilePath,
  });

  factory Crew.fromJson(Map<String, dynamic> json) {
    return Crew(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      department: json['department'] ?? '',
      job: json['job'] ?? '',
      profilePath: json['profile_path'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'department': department,
      'job': job,
      'profile_path': profilePath,
    };
  }
}
