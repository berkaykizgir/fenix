import 'package:dartz/dartz.dart';
import 'package:fenix/core/error/failures.dart';
import 'package:fenix/core/usecases/usecase.dart';
import 'package:flutter_test/flutter_test.dart';

// Mock use case for testing
class MockUseCase extends UseCase<String, int> {
  @override
  Future<Either<Failure, String>> call(int params) async {
    if (params > 0) {
      return Right<Failure, String>('Success: $params');
    }
    return const Left<Failure, String>(UnexpectedFailure('Invalid input'));
  }
}

void main() {
  group('UseCase', () {
    late MockUseCase useCase;

    setUp(() {
      useCase = MockUseCase();
    });

    test('should return Right when use case succeeds', () async {
      final result = await useCase(5);

      expect(result, const Right<Failure, String>('Success: 5'));
    });

    test('should return Left when use case fails', () async {
      final result = await useCase(-1);

      expect(result, const Left<Failure, String>(UnexpectedFailure('Invalid input')));
    });

    test('should be callable as a function', () async {
      final result = await useCase.call(10);

      expect(result.isRight(), true);
    });
  });
}
