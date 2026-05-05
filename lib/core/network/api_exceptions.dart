/// Base class for all API exceptions
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException(this.message, [this.statusCode, this.data]);

  @override
  String toString() {
    return 'ApiException: $message (Status: $statusCode)';
  }
}

/// Thrown when the server returns a 400 Bad Request
class BadRequestException extends ApiException {
  BadRequestException(String message, [dynamic data])
      : super(message, 400, data);
}

/// Thrown when the server returns a 401 Unauthorized
class UnauthorizedException extends ApiException {
  UnauthorizedException([String message = 'Unauthorized']) : super(message, 401);
}

/// Thrown when the server returns a 403 Forbidden
class ForbiddenException extends ApiException {
  ForbiddenException([String message = 'Forbidden']) : super(message, 403);
}

/// Thrown when the server returns a 404 Not Found
class NotFoundException extends ApiException {
  NotFoundException([String message = 'Not Found']) : super(message, 404);
}

/// Thrown when the server returns a 500 Internal Server Error
class ServerException extends ApiException {
  ServerException([String message = 'Internal Server Error']) : super(message, 500);
}

/// Thrown when there is no internet connection or network error
class NetworkException extends ApiException {
  NetworkException([String message = 'Network connection error']) : super(message);
}
