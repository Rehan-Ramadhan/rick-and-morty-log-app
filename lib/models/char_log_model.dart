import 'dimension_model.dart';

/// Character log model matching Laravel `char_logs` table.
class CharLogModel {
  const CharLogModel({
    required this.id,
    required this.userId,
    required this.dimensionId,
    required this.title,
    required this.species,
    required this.imageUrl,
    this.notes,
    this.createdAt,
    this.updatedAt,
    this.dimension,
  });

  final int id;
  final int userId;
  final int dimensionId;
  final String title;
  final String species;
  final String imageUrl;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DimensionModel? dimension;

  factory CharLogModel.fromJson(Map<String, dynamic> json) {
    final rawDimension = json['dimension'];

    return CharLogModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      userId: (json['user_id'] as num?)?.toInt() ?? 0,
      dimensionId: (json['dimension_id'] as num?)?.toInt() ?? 0,
      title: (json['title'] ?? '').toString(),
      species: (json['species'] ?? '').toString(),
      imageUrl: (json['image_url'] ?? '').toString(),
      notes: json['notes']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
      dimension: rawDimension is Map<String, dynamic>
          ? DimensionModel.fromJson(rawDimension)
          : null,
    );
  }

  Map<String, dynamic> toPayload() => {
        'dimension_id': dimensionId,
        'title': title,
        'species': species,
        'image_url': imageUrl,
        'notes': (notes != null && notes!.trim().isNotEmpty)
            ? notes!.trim()
            : null,
      };
}
