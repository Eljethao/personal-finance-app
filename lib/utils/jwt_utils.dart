import 'dart:convert';

class JwtUtils {
  static Map<String, dynamic> parseJwt(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('Invalid token');
    }

    final payload = _decodeBase64(parts[1]);
    final payloadMap = json.decode(payload);
    if (payloadMap is! Map<String, dynamic>) {
      throw Exception('Invalid payload');
    }

    return payloadMap;
  }

  static String _decodeBase64(String str) {
    String output = str.replaceAll('-', '+').replaceAll('_', '/');
    switch (output.length % 4) {
      case 0:
        break;
      case 2:
        output += '==';
        break;
      case 3:
        output += '=';
        break;
      default:
        throw Exception('Illegal base64url string!');
    }
    return utf8.decode(base64Url.decode(output));
  }

  static bool isTokenExpired(String token) {
    try {
      final payload = parseJwt(token);
      if (payload.containsKey('exp')) {
        final exp = payload['exp'] as int;
        // JWT exp is in seconds, DateTime uses milliseconds
        final expirationDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
        return DateTime.now().isAfter(expirationDate);
      }
      return false; // If there's no expiration, treat as valid forever (or handle differently based on backend)
    } catch (e) {
      return true; // If parsing fails, treat as expired
    }
  }
}
