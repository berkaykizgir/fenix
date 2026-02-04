import 'package:dartz/dartz.dart';
import 'package:fenix/core/error/failures.dart';
import 'package:fenix/core/network/api_client.dart';
import 'package:fenix/core/network/network_info.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late ApiClientImpl apiClient;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockNetworkInfo = MockNetworkInfo();
    apiClient = ApiClientImpl(mockNetworkInfo);
  });

  group('ApiClient', () {
    test('should return NetworkFailure when device is offline', () async {
      // Arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);

      // Act
      final result = await apiClient.get(
        path: '/test',
        parser: (json) => json,
      );

      // Assert
      expect(result, const Left<Failure, dynamic>(NetworkFailure()));
      verify(() => mockNetworkInfo.isConnected).called(1);
    });
  });
}
