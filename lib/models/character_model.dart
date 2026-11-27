/// Character model from the public Rick and Morty REST API.
class CharacterModel {
  const CharacterModel({
    required this.id,
    required this.name,
    required this.status,
    required this.species,
    required this.gender,
    required this.image,
    required this.originName,
    required this.locationName,
    this.type = '',
    this.episodeCount = 0,
  });

  final int id;
  final String name;
  final String status;
  final String species;
  final String gender;
  final String image;
  final String originName;
  final String locationName;
  final String type;
  final int episodeCount;

  factory CharacterModel.fromJson(Map<String, dynamic> json) {
    final origin = json['origin'];
    final location = json['location'];
    final episodes = json['episode'];

    return CharacterModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] ?? 'Unknown Entity').toString(),
      status: (json['status'] ?? 'unknown').toString(),
      species: (json['species'] ?? 'Unknown').toString(),
      gender: (json['gender'] ?? 'unknown').toString(),
      image: (json['image'] ?? '').toString(),
      originName: origin is Map<String, dynamic>
          ? (origin['name'] ?? 'unknown').toString()
          : 'unknown',
      locationName: location is Map<String, dynamic>
          ? (location['name'] ?? 'unknown').toString()
          : 'unknown',
      type: (json['type'] ?? '').toString(),
      episodeCount: episodes is List ? episodes.length : 0,
    );
  }
}

/// Paginated response wrapper for Rick and Morty API `/character`.
class CharacterPageResponse {
  const CharacterPageResponse({
    required this.characters,
    required this.currentPage,
    required this.totalPages,
    required this.totalCount,
    required this.hasNextPage,
  });

  final List<CharacterModel> characters;
  final int currentPage;
  final int totalPages;
  final int totalCount;
  final bool hasNextPage;

  factory CharacterPageResponse.fromJson(
    Map<String, dynamic> json,
    int requestedPage,
  ) {
    final info = json['info'] as Map<String, dynamic>? ?? const {};
    final rawResults = json['results'] as List<dynamic>? ?? const [];

    return CharacterPageResponse(
      characters: rawResults
          .whereType<Map<String, dynamic>>()
          .map(CharacterModel.fromJson)
          .toList(),
      currentPage: requestedPage,
      totalPages: (info['pages'] as num?)?.toInt() ?? 1,
      totalCount: (info['count'] as num?)?.toInt() ?? rawResults.length,
      hasNextPage: info['next'] != null,
    );
  }
}
