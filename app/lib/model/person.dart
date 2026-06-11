class Person {
  final int id;
  final String name;
  final String? biography;
  final String? birthday;
  final String? deathday;
  final int gender; // 0 = not set, 1 = female, 2 = male, 3 = non-binary
  final String? knownForDepartment;
  final List<String>? alsoKnownAs;
  final String? placeOfBirth;
  final String? profilePath;
  final bool adult;
  final String? homepage;
  final String? imdbId;

  Person({
    required this.id,
    required this.name,
    this.biography,
    this.birthday,
    this.deathday,
    required this.gender,
    this.knownForDepartment,
    this.alsoKnownAs,
    this.placeOfBirth,
    this.profilePath,
    required this.adult,
    this.homepage,
    this.imdbId,
  });

  // Factory constructor to parse from JSON
  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      id: json['id'],
      name: json['name'],
      biography: json['biography'],
      birthday: json['birthday'],
      deathday: json['deathday'],
      gender: json['gender'] ?? 0,
      knownForDepartment: json['known_for_department'],
      alsoKnownAs: json['also_known_as'] != null
          ? List<String>.from(json['also_known_as'])
          : null,
      placeOfBirth: json['place_of_birth'],
      profilePath: json['profile_path'],
      adult: json['adult'] ?? false,
      homepage: json['homepage'],
      imdbId: json['imdb_id'],
    );
  }

  // Converts the object back to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'biography': biography,
      'birthday': birthday,
      'deathday': deathday,
      'gender': gender,
      'known_for_department': knownForDepartment,
      'also_known_as': alsoKnownAs,
      'place_of_birth': placeOfBirth,
      'profile_path': profilePath,
      'adult': adult,
      'homepage': homepage,
      'imdb_id': imdbId,
    };
  }
}
