import 'package:flutter_test/flutter_test.dart';
import 'package:kindred_chatbot/services/auth_service.dart';

void main() {
  group('AuthService Tests', () {
    test('AuthService can be instantiated', () {
      expect(AuthService, isNotNull);
    });
  });
}
