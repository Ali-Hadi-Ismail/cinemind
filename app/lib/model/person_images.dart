import 'profile.dart';

class PersonImages {
  final int id;
  final List<Profile> profiles;

  PersonImages({required this.id, required this.profiles});

  factory PersonImages.fromJson(Map<String, dynamic> json) {
    return PersonImages(
      id: json['id'],
      profiles: json['profiles'] != null
          ? List<Profile>.from(json['profiles'].map((x) => Profile.fromJson(x)))
          : [],
    );
  }
}
