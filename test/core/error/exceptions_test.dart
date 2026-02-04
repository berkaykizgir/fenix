import 'package:fenix/core/error/exceptions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Exceptions', () {
    test('ServerException should have correct message', () {
      const exception = ServerException('API failed');

      expect(exception.message, 'API failed');
      expect(exception, isA<AppException>());
      expect(exception.toString(), 'API failed');
    });

    test('ServerException should use default message', () {
      const exception = ServerException();

      expect(exception.message, 'Server error occurred');
    });

    test('NetworkException should have correct message', () {
      const exception = NetworkException();

      expect(exception.message, 'No internet connection');
    });

    test('CacheException should have correct message', () {
      const exception = CacheException();

      expect(exception.message, 'Cache error occurred');
    });

    test('ParsingException should have correct message', () {
      const exception = ParsingException();

      expect(exception.message, 'Failed to parse data');
    });

    test('Exception should implement Exception interface', () {
      const exception = ServerException();

      expect(exception, isA<Exception>());
    });
  });
}
