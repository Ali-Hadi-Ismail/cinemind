class Profile {
  final double aspectRatio;
  final int height;
  final int width;
  final String? iso6391;
  final String filePath;
  final double voteAverage;
  final int voteCount;

  Profile({
    required this.aspectRatio,
    required this.height,
    required this.width,
    this.iso6391,
    required this.filePath,
    required this.voteAverage,
    required this.voteCount,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      aspectRatio: (json['aspect_ratio'] ?? 0).toDouble(),
      height: json['height'] ?? 0,
      width: json['width'] ?? 0,
      iso6391: json['iso_639_1'],
      filePath: json['file_path'],
      voteAverage: (json['vote_average'] ?? 0).toDouble(),
      voteCount: json['vote_count'] ?? 0,
    );
  }
}
