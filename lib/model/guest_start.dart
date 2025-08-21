class GuestStar {
  final int id;
  final String name;
  final String character;
  final int order;
  final String? profilePath;

  GuestStar({
    required this.id,
    required this.name,
    required this.character,
    required this.order,
    this.profilePath,
  });

  factory GuestStar.fromJson(Map<String, dynamic> json) {
    return GuestStar(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      character: json['character'] ?? '',
      order: json['order'] ?? 0,
      profilePath: json['profile_path'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'character': character,
      'order': order,
      'profile_path': profilePath,
    };
  }
}
