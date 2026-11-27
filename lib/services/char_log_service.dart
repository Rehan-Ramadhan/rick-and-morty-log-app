import '../constants/api_constant.dart';
import '../models/char_log_model.dart';
import 'api_service.dart';

/// CRUD service for saved character logs stored in the Laravel backend.
class CharLogService {
  CharLogService({ApiService? apiService})
      : _api = apiService ?? ApiService.instance;

  final ApiService _api;

  Future<List<CharLogModel>> fetchCharLogs() async {
    try {
      final response = await _api.backendDio.get(ApiConstant.charLogs);
      final list = _api.unwrapList(
        response.data,
        keys: const ['char_logs', 'charLogs', 'data'],
      );
      return list
          .whereType<Map<String, dynamic>>()
          .map(CharLogModel.fromJson)
          .toList();
    } catch (e) {
      throw _api.parseError(e);
    }
  }

  Future<CharLogModel> createCharLog({
    required int dimensionId,
    required String title,
    required String species,
    required String imageUrl,
    String? notes,
  }) async {
    try {
      final response = await _api.backendDio.post(
        ApiConstant.charLogs,
        data: {
          'dimension_id': dimensionId,
          'title': title.trim(),
          'species': species.trim(),
          'image_url': imageUrl.trim(),
          if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
        },
      );
      final map = _api.unwrapObject(
        response.data,
        keys: const ['char_log', 'charLog', 'data'],
      );
      return CharLogModel.fromJson(map);
    } catch (e) {
      throw _api.parseError(e);
    }
  }

  Future<CharLogModel> fetchCharLogById(int id) async {
    try {
      final response = await _api.backendDio.get(ApiConstant.charLogDetail(id));
      final map = _api.unwrapObject(
        response.data,
        keys: const ['char_log', 'charLog', 'data'],
      );
      return CharLogModel.fromJson(map);
    } catch (e) {
      throw _api.parseError(e);
    }
  }

  Future<CharLogModel> updateCharLog({
    required int id,
    required int dimensionId,
    required String title,
    required String species,
    required String imageUrl,
    String? notes,
  }) async {
    try {
      final response = await _api.backendDio.put(
        ApiConstant.charLogDetail(id),
        data: {
          'dimension_id': dimensionId,
          'title': title.trim(),
          'species': species.trim(),
          'image_url': imageUrl.trim(),
          'notes': (notes != null && notes.trim().isNotEmpty)
              ? notes.trim()
              : null,
        },
      );
      final map = _api.unwrapObject(
        response.data,
        keys: const ['char_log', 'charLog', 'data'],
      );
      return CharLogModel.fromJson(map);
    } catch (e) {
      throw _api.parseError(e);
    }
  }

  Future<void> deleteCharLog(int id) async {
    try {
      await _api.backendDio.delete(ApiConstant.charLogDetail(id));
    } catch (e) {
      throw _api.parseError(e);
    }
  }
}
