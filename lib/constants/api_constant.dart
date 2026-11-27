/// Centralized API configuration for Laravel backend and Rick & Morty Public API.
class ApiConstant {
  ApiConstant._();

  static const String baseUrl = 'http://10.10.11.27:8000/api';
  static const String rickAndMortyBaseUrl = 'https://rickandmortyapi.com/api';

  // Auth endpoints
  static const String register = '/register';
  static const String login = '/login';
  static const String user = '/user';
  static const String logout = '/logout';

  // Dimension endpoints
  static const String dimensions = '/dimensions';
  static String dimensionDetail(int id) => '/dimensions/$id';

  // Char Log endpoints
  static const String charLogs = '/char-logs';
  static String charLogDetail(int id) => '/char-logs/$id';

  // Public Rick & Morty API endpoints
  static const String characters = '$rickAndMortyBaseUrl/character';
  static String characterDetail(int id) => '$rickAndMortyBaseUrl/character/$id';
}
