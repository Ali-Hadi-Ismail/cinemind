import 'cast.dart';
import 'crew.dart';

class CreditResponse {
  final int id;
  final List<Cast> cast;
  final List<Crew> crew;

  CreditResponse({
    required this.id,
    required this.cast,
    required this.crew,
  });

  factory CreditResponse.fromJson(Map<String, dynamic> json) {
    return CreditResponse(
      id: json['id'] ?? 0,
      cast: (json['cast'] as List<dynamic>?)
              ?.map((e) => Cast.fromJson(e))
              .toList() ??
          [],
      crew: (json['crew'] as List<dynamic>?)
              ?.map((e) => Crew.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cast': cast.map((e) => e.toJson()).toList(),
      'crew': crew.map((e) => e.toJson()).toList(),
    };
  }
}
