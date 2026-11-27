import 'package:dio/dio.dart';
import '../constants/api_constant.dart';
import '../models/character_model.dart';
import 'api_service.dart';

/// Service for querying the public Rick and Morty character archive API.
class CharacterService {
  CharacterService({ApiService? apiService})
      : _api = apiService ?? ApiService.instance;

  final ApiService _api;

  Future<CharacterPageResponse> fetchCharacters({
    int page = 1,
    String? name,
    String? status,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        if (name != null && name.trim().isNotEmpty) 'name': name.trim(),
        if (status != null && status.trim().isNotEmpty && status != 'All')
          'status': status.toLowerCase(),
      };

      final response = await _api.publicDio.get(
        ApiConstant.characters,
        queryParameters: queryParams,
      );

      if (response.data is! Map<String, dynamic>) {
        throw ApiException('Unexpected character archive format.');
      }

      return CharacterPageResponse.fromJson(
        response.data as Map<String, dynamic>,
        page,
      );
    } on DioException catch (e) {
      // Rick and Morty API returns 404 when search/filter matches no characters.
      if (e.response?.statusCode == 404) {
        return CharacterPageResponse(
          characters: const [],
          currentPage: page,
          totalPages: 0,
          totalCount: 0,
          hasNextPage: false,
        );
      }
      throw _api.parseError(e);
    } catch (e) {
      throw _api.parseError(e);
    }
  }

  Future<CharacterModel> fetchCharacterById(int id) async {
    try {
      final response = await _api.publicDio.get(
        ApiConstant.characterDetail(id),
      );
      if (response.data is! Map<String, dynamic>) {
        throw ApiException('Invalid character detail payload.');
      }
      return CharacterModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw _api.parseError(e);
    }
  }
}
