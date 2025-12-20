import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart';
import 'package:daily_planner/services/api_service.dart';

// **Feature: daily-planner-app, Property 9: ApiService singleton consistency**
void main() {
  group('ApiService Singleton Tests', () {
    test('ApiService returns same instance', () {
      final instance1 = ApiService();
      final instance2 = ApiService();
      final instance3 = ApiService();

      expect(identical(instance1, instance2), isTrue);
      expect(identical(instance2, instance3), isTrue);
      expect(identical(instance1, instance3), isTrue);
    });

    Glados<int>().test('ApiService singleton returns same instance for any number of instantiations', (count) {
      final actualCount = (count.abs() % 100) + 1;
      final instances = List.generate(actualCount, (_) => ApiService());
      
      for (var i = 1; i < instances.length; i++) {
        expect(identical(instances[0], instances[i]), isTrue);
      }
    });

    test('ApiService dio instance is consistent', () {
      final instance1 = ApiService();
      final instance2 = ApiService();

      expect(identical(instance1.dio, instance2.dio), isTrue);
    });
  });

  // **Feature: daily-planner-app, Property 10: JWT token auto-attachment**
  group('JWT Token Tests', () {
    test('Token is initially null', () {
      final apiService = ApiService();
      expect(apiService.hasToken, isFalse);
      expect(apiService.token, isNull);
    });
  });
}
