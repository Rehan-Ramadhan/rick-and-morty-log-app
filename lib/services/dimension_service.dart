import '../constants/api_constant.dart';
import '../models/dimension_model.dart';
import 'api_service.dart';

/// CRUD service for user dimensions stored in the Laravel backend.
class DimensionService {
  DimensionService({ApiService? apiService})
      : _api = apiService ?? ApiService.instance;

  final ApiService _api;

  Future<List<DimensionModel>> fetchDimensions() async {
    try {
      final response = await _api.backendDio.get(ApiConstant.dimensions);
      final list = _api.unwrapList(
        response.data,
        keys: const ['dimensions', 'data'],
      );
      return list
          .whereType<Map<String, dynamic>>()
          .map(DimensionModel.fromJson)
          .toList();
    } catch (e) {
      throw _api.parseError(e);
    }
  }

  Future<DimensionModel> createDimension(String name) async {
    try {
      final response = await _api.backendDio.post(
        ApiConstant.dimensions,
        data: {'name': name.trim()},
      );
      final map = _api.unwrapObject(
        response.data,
        keys: const ['dimension', 'data'],
      );
      return DimensionModel.fromJson(map);
    } catch (e) {
      throw _api.parseError(e);
    }
  }

  Future<DimensionModel> fetchDimensionById(int id) async {
    try {
      final response = await _api.backendDio.get(
        ApiConstant.dimensionDetail(id),
      );
      final map = _api.unwrapObject(
        response.data,
        keys: const ['dimension', 'data'],
      );
      return DimensionModel.fromJson(map);
    } catch (e) {
      throw _api.parseError(e);
    }
  }

  Future<DimensionModel> updateDimension(int id, String name) async {
    try {
      final response = await _api.backendDio.put(
        ApiConstant.dimensionDetail(id),
        data: {'name': name.trim()},
      );
      final map = _api.unwrapObject(
        response.data,
        keys: const ['dimension', 'data'],
      );
      return DimensionModel.fromJson(map);
    } catch (e) {
      throw _api.parseError(e);
    }
  }

  Future<void> deleteDimension(int id) async {
    try {
      await _api.backendDio.delete(ApiConstant.dimensionDetail(id));
    } catch (e) {
      throw _api.parseError(e);
    }
  }
}
