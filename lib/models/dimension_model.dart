import 'char_log_model.dart';

/// Dimension model matching Laravel `dimensions` table.
class DimensionModel {
  const DimensionModel({
    required this.id,
    required this.userId,
    required this.name,
    this.createdAt,
    this.updatedAt,
    this.charLogs = const [],
    this.charLogsCount,
  });

  final int id;
  final int userId;
  final String name;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<CharLogModel> charLogs;
  final int? charLogsCount;

  int get logCount => charLogsCount ?? charLogs.length;

  factory DimensionModel.fromJson(Map<String, dynamic> json) {
    final rawLogs = json['char_logs'];
    final parsedLogs = rawLogs is List
        ? rawLogs
            .whereType<Map<String, dynamic>>()
            .map(CharLogModel.fromJson)
            .toList()
        : const <CharLogModel>[];

    return DimensionModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      userId: (json['user_id'] as num?)?.toInt() ?? 0,
      name: (json['name'] ?? '').toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
      charLogs: parsedLogs,
      charLogsCount: (json['char_logs_count'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'name': name,
      };
}
