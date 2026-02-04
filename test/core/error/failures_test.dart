import 'package:fenix/core/error/failures.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Failure', () {
    test('ServerFailure should have correct message', () {
      // Arrange
      const failure = ServerFailure('Server is down');

      // Assert
      expect(failure.message, 'Server is down');
      expect(failure, isA<Failure>());
    });

    test('ServerFailure should use default message', () {
      // Arrange
      const failure = ServerFailure();

      // Assert
      expect(failure.message, 'Server error occurred');
    });

    test('NetworkFailure should have correct message', () {
      // Arrange
      const failure = NetworkFailure();

      // Assert
      expect(failure.message, 'No internet connection');
    });

    test('CacheFailure should have correct message', () {
      // Arrange
      const failure = CacheFailure();

      // Assert
      expect(failure.message, 'Cache error occurred');
    });

    test('Two ServerFailures with same message should be equal', () {
      // Arrange
      const failure1 = ServerFailure('Error');
      const failure2 = ServerFailure('Error');

      // Assert
      expect(failure1, equals(failure2));
    });

    test('Two ServerFailures with different messages should not be equal', () {
      // Arrange
      const failure1 = ServerFailure('Error 1');
      const failure2 = ServerFailure('Error 2');

      // Assert
      expect(failure1, isNot(equals(failure2)));
    });
  });
}
