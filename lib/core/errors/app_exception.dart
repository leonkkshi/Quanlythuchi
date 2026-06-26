class AppException implements Exception {
  final String message;
  final String? prefix;

  AppException([this.message = 'An unknown error occurred', this.prefix]);

  @override
  String toString() {
    return '${prefix ?? ""}$message';
  }
}

class ServerException extends AppException {
  ServerException([String message = 'Server error occurred']) 
      : super(message, 'Server Error: ');
}

class NetworkException extends AppException {
  NetworkException([String message = 'No internet connection']) 
      : super(message, 'Network Error: ');
}

class CacheException extends AppException {
  CacheException([String message = 'Failed to load local data']) 
      : super(message, 'Cache Error: ');
}

class UnauthorizedException extends AppException {
  UnauthorizedException([String message = 'Unauthorized access']) 
      : super(message, 'Unauthorized: ');
}

class InvalidInputException extends AppException {
  InvalidInputException([String message = 'Invalid input credentials']) 
      : super(message, 'Invalid Input: ');
}
