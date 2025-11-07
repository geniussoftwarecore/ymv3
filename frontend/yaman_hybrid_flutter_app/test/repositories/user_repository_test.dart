import 'package:flutter_test/flutter_test.dart';
import 'package:yaman_hybrid_flutter_app/core/api/repositories/user_repository.dart';

void main() {
  group('UserModel Tests', () {
    group('Model Creation', () {
      test('UserModel should be created with all parameters', () {
        final model = UserModel(
          id: 1,
          uuid: 'uuid-123',
          username: 'ahmed_user',
          email: 'ahmed@example.com',
          fullName: 'Ahmed Mohammed',
          phone: '+966501234567',
          roles: ['admin', 'manager'],
          isActive: true,
          createdAt: DateTime.now(),
        );

        expect(model.id, equals(1));
        expect(model.username, equals('ahmed_user'));
        expect(model.email, equals('ahmed@example.com'));
      });

      test('UserModel should handle nullable fields', () {
        final model = UserModel(
          id: 1,
          uuid: 'uuid-123',
          username: 'john_user',
          email: 'john@example.com',
          fullName: null,
          phone: null,
          roles: [],
          isActive: true,
          createdAt: DateTime.now(),
        );

        expect(model.fullName, isNull);
        expect(model.phone, isNull);
        expect(model.roles, isEmpty);
      });
    });

    group('JSON Serialization', () {
      test('UserModel.fromJson should deserialize correctly', () {
        final json = {
          'id': 1,
          'uuid': 'uuid-123',
          'username': 'ahmed_user',
          'email': 'ahmed@example.com',
          'full_name': 'Ahmed Mohammed',
          'phone': '+966501234567',
          'roles': ['admin', 'manager'],
          'is_active': true,
          'created_at': '2024-01-15T10:00:00.000Z',
        };

        final model = UserModel.fromJson(json);

        expect(model.id, equals(1));
        expect(model.username, equals('ahmed_user'));
        expect(model.email, equals('ahmed@example.com'));
        expect(model.roles.length, equals(2));
      });

      test('UserModel.fromJson should handle null fields', () {
        final json = {
          'id': 1,
          'uuid': 'uuid-123',
          'username': 'john_user',
          'email': 'john@example.com',
          'full_name': null,
          'phone': null,
          'roles': [],
          'is_active': true,
          'created_at': '2024-01-15T10:00:00.000Z',
        };

        final model = UserModel.fromJson(json);

        expect(model.fullName, isNull);
        expect(model.phone, isNull);
      });

      test('UserModel.fromJson should use default isActive', () {
        final json = {
          'id': 1,
          'uuid': 'uuid-123',
          'username': 'john_user',
          'email': 'john@example.com',
          'created_at': '2024-01-15T10:00:00.000Z',
        };

        final model = UserModel.fromJson(json);

        expect(model.isActive, isTrue);
      });

      test('UserModel.toJson should serialize correctly', () {
        final now = DateTime(2024, 1, 15, 10, 0, 0);
        final model = UserModel(
          id: 1,
          uuid: 'uuid-123',
          username: 'ahmed_user',
          email: 'ahmed@example.com',
          fullName: 'Ahmed Mohammed',
          phone: '+966501234567',
          roles: ['admin', 'manager'],
          isActive: true,
          createdAt: now,
        );

        final json = model.toJson();

        expect(json['id'], equals(1));
        expect(json['username'], equals('ahmed_user'));
        expect(json['email'], equals('ahmed@example.com'));
        expect(json['is_active'], isTrue);
      });

      test('UserModel round-trip serialization should work', () {
        final original = UserModel(
          id: 1,
          uuid: 'uuid-123',
          username: 'ahmed_user',
          email: 'ahmed@example.com',
          fullName: 'Ahmed Mohammed',
          phone: '+966501234567',
          roles: ['admin', 'manager'],
          isActive: true,
          createdAt: DateTime.parse('2024-01-15T10:00:00.000Z'),
        );

        final json = original.toJson();
        final deserialized = UserModel.fromJson(json);

        expect(deserialized.id, equals(original.id));
        expect(deserialized.username, equals(original.username));
        expect(deserialized.email, equals(original.email));
      });
    });

    group('Role Management', () {
      test('UserModel should support multiple roles', () {
        final roles = ['admin', 'manager', 'technician'];

        final model = UserModel(
          id: 1,
          uuid: 'uuid-123',
          username: 'multi_role_user',
          email: 'multi@example.com',
          roles: roles,
          isActive: true,
          createdAt: DateTime.now(),
        );

        expect(model.roles.length, equals(3));
        expect(model.roles.contains('admin'), isTrue);
      });

      test('UserModel should handle single role', () {
        final model = UserModel(
          id: 1,
          uuid: 'uuid-123',
          username: 'user_user',
          email: 'user@example.com',
          roles: ['user'],
          isActive: true,
          createdAt: DateTime.now(),
        );

        expect(model.roles.length, equals(1));
        expect(model.roles.first, equals('user'));
      });

      test('UserModel should handle no roles', () {
        final model = UserModel(
          id: 1,
          uuid: 'uuid-123',
          username: 'no_role_user',
          email: 'norole@example.com',
          roles: [],
          isActive: true,
          createdAt: DateTime.now(),
        );

        expect(model.roles, isEmpty);
      });

      test('UserModel should support different role types', () {
        final roleTypes = ['admin', 'manager', 'technician', 'user', 'guest'];

        for (final role in roleTypes) {
          final model = UserModel(
            id: 1,
            uuid: 'uuid-123',
            username: 'test_user',
            email: 'test@example.com',
            roles: [role],
            isActive: true,
            createdAt: DateTime.now(),
          );

          expect(model.roles.contains(role), isTrue);
        }
      });
    });

    group('Active Status', () {
      test('UserModel should track active status', () {
        final activeModel = UserModel(
          id: 1,
          uuid: 'uuid-123',
          username: 'active_user',
          email: 'active@example.com',
          roles: ['user'],
          isActive: true,
          createdAt: DateTime.now(),
        );

        final inactiveModel = UserModel(
          id: 2,
          uuid: 'uuid-456',
          username: 'inactive_user',
          email: 'inactive@example.com',
          roles: ['user'],
          isActive: false,
          createdAt: DateTime.now(),
        );

        expect(activeModel.isActive, isTrue);
        expect(inactiveModel.isActive, isFalse);
      });
    });

    group('Contact Information', () {
      test('UserModel should store email and phone', () {
        const email = 'test@example.com';
        const phone = '+966501234567';

        final model = UserModel(
          id: 1,
          uuid: 'uuid-123',
          username: 'test_user',
          email: email,
          phone: phone,
          roles: ['user'],
          isActive: true,
          createdAt: DateTime.now(),
        );

        expect(model.email, equals(email));
        expect(model.phone, equals(phone));
      });
    });

    group('Username', () {
      test('UserModel should store username', () {
        const username = 'ahmed_user';

        final model = UserModel(
          id: 1,
          uuid: 'uuid-123',
          username: username,
          email: 'ahmed@example.com',
          roles: ['user'],
          isActive: true,
          createdAt: DateTime.now(),
        );

        expect(model.username, equals(username));
      });

      test('UserModel should support various username formats', () {
        final usernames = ['user123', 'test.user', 'admin_user', 'user-name'];

        for (final username in usernames) {
          final model = UserModel(
            id: 1,
            uuid: 'uuid-123',
            username: username,
            email: 'test@example.com',
            roles: ['user'],
            isActive: true,
            createdAt: DateTime.now(),
          );

          expect(model.username, equals(username));
        }
      });
    });

    group('Full Name', () {
      test('UserModel should store full name', () {
        const fullName = 'Ahmed Mohammed Abdullah';

        final model = UserModel(
          id: 1,
          uuid: 'uuid-123',
          username: 'ahmed_user',
          email: 'ahmed@example.com',
          fullName: fullName,
          roles: ['user'],
          isActive: true,
          createdAt: DateTime.now(),
        );

        expect(model.fullName, equals(fullName));
      });

      test('UserModel should handle null full name', () {
        final model = UserModel(
          id: 1,
          uuid: 'uuid-123',
          username: 'user',
          email: 'user@example.com',
          fullName: null,
          roles: ['user'],
          isActive: true,
          createdAt: DateTime.now(),
        );

        expect(model.fullName, isNull);
      });
    });

    group('UUID Handling', () {
      test('UserModel should preserve UUID', () {
        const uuid = 'f47ac10b-58cc-4372-a567-0e02b2c3d479';

        final model = UserModel(
          id: 1,
          uuid: uuid,
          username: 'test_user',
          email: 'test@example.com',
          roles: ['user'],
          isActive: true,
          createdAt: DateTime.now(),
        );

        expect(model.uuid, equals(uuid));
      });
    });

    group('Timestamp Handling', () {
      test('UserModel should store creation date', () {
        final createdAt = DateTime(2024, 1, 15, 10, 0, 0);

        final model = UserModel(
          id: 1,
          uuid: 'uuid-123',
          username: 'test_user',
          email: 'test@example.com',
          roles: ['user'],
          isActive: true,
          createdAt: createdAt,
        );

        expect(model.createdAt, equals(createdAt));
      });
    });
  });

  group('TokenResponse Tests', () {
    group('Model Creation', () {
      test('TokenResponse should be created with all parameters', () {
        final user = UserModel(
          id: 1,
          uuid: 'uuid-123',
          username: 'test_user',
          email: 'test@example.com',
          roles: ['user'],
          isActive: true,
          createdAt: DateTime.now(),
        );

        final response = TokenResponse(
          accessToken: 'access-token-123',
          refreshToken: 'refresh-token-456',
          user: user,
          expiresIn: 3600,
        );

        expect(response.accessToken, equals('access-token-123'));
        expect(response.refreshToken, equals('refresh-token-456'));
        expect(response.expiresIn, equals(3600));
      });
    });

    group('JSON Serialization', () {
      test('TokenResponse.fromJson should deserialize correctly', () {
        final json = {
          'access_token': 'access-token-123',
          'refresh_token': 'refresh-token-456',
          'user': {
            'id': 1,
            'uuid': 'uuid-123',
            'username': 'test_user',
            'email': 'test@example.com',
            'roles': ['user'],
            'is_active': true,
            'created_at': '2024-01-15T10:00:00.000Z',
          },
          'expires_in': 3600,
        };

        final response = TokenResponse.fromJson(json);

        expect(response.accessToken, equals('access-token-123'));
        expect(response.refreshToken, equals('refresh-token-456'));
        expect(response.expiresIn, equals(3600));
        expect(response.user.username, equals('test_user'));
      });

      test('TokenResponse should properly deserialize user', () {
        final json = {
          'access_token': 'token',
          'refresh_token': 'refresh',
          'user': {
            'id': 1,
            'uuid': 'uuid-123',
            'username': 'ahmed_user',
            'email': 'ahmed@example.com',
            'full_name': 'Ahmed Mohammed',
            'phone': '+966501234567',
            'roles': ['admin', 'manager'],
            'is_active': true,
            'created_at': '2024-01-15T10:00:00.000Z',
          },
          'expires_in': 7200,
        };

        final response = TokenResponse.fromJson(json);

        expect(response.user.id, equals(1));
        expect(response.user.username, equals('ahmed_user'));
        expect(response.user.email, equals('ahmed@example.com'));
        expect(response.user.roles.length, equals(2));
      });

      test('TokenResponse should handle different expiration times', () {
        final expirations = [300, 3600, 86400, 604800];

        for (final expiry in expirations) {
          final json = {
            'access_token': 'token',
            'refresh_token': 'refresh',
            'user': {
              'id': 1,
              'uuid': 'uuid-123',
              'username': 'user',
              'email': 'user@example.com',
              'roles': [],
              'is_active': true,
              'created_at': '2024-01-15T10:00:00.000Z',
            },
            'expires_in': expiry,
          };

          final response = TokenResponse.fromJson(json);
          expect(response.expiresIn, equals(expiry));
        }
      });
    });

    group('Token Storage', () {
      test('TokenResponse should store access token', () {
        final user = UserModel(
          id: 1,
          uuid: 'uuid-123',
          username: 'test_user',
          email: 'test@example.com',
          roles: ['user'],
          isActive: true,
          createdAt: DateTime.now(),
        );

        final response = TokenResponse(
          accessToken: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
          refreshToken: 'refresh-token',
          user: user,
          expiresIn: 3600,
        );

        expect(response.accessToken.startsWith('eyJ'), isTrue);
      });

      test('TokenResponse should store refresh token', () {
        final user = UserModel(
          id: 1,
          uuid: 'uuid-123',
          username: 'test_user',
          email: 'test@example.com',
          roles: ['user'],
          isActive: true,
          createdAt: DateTime.now(),
        );

        final response = TokenResponse(
          accessToken: 'access-token',
          refreshToken: 'refresh-token-xyz',
          user: user,
          expiresIn: 3600,
        );

        expect(response.refreshToken, equals('refresh-token-xyz'));
      });
    });

    group('Expiration Handling', () {
      test('TokenResponse should track expiration time', () {
        final user = UserModel(
          id: 1,
          uuid: 'uuid-123',
          username: 'test_user',
          email: 'test@example.com',
          roles: ['user'],
          isActive: true,
          createdAt: DateTime.now(),
        );

        final response = TokenResponse(
          accessToken: 'token',
          refreshToken: 'refresh',
          user: user,
          expiresIn: 3600,
        );

        expect(response.expiresIn, equals(3600));
      });

      test('TokenResponse should handle short expiration', () {
        final user = UserModel(
          id: 1,
          uuid: 'uuid-123',
          username: 'test_user',
          email: 'test@example.com',
          roles: ['user'],
          isActive: true,
          createdAt: DateTime.now(),
        );

        final response = TokenResponse(
          accessToken: 'token',
          refreshToken: 'refresh',
          user: user,
          expiresIn: 300, // 5 minutes
        );

        expect(response.expiresIn, equals(300));
      });

      test('TokenResponse should handle long expiration', () {
        final user = UserModel(
          id: 1,
          uuid: 'uuid-123',
          username: 'test_user',
          email: 'test@example.com',
          roles: ['user'],
          isActive: true,
          createdAt: DateTime.now(),
        );

        final response = TokenResponse(
          accessToken: 'token',
          refreshToken: 'refresh',
          user: user,
          expiresIn: 604800, // 1 week
        );

        expect(response.expiresIn, equals(604800));
      });
    });

    group('User Association', () {
      test('TokenResponse should contain user information', () {
        final user = UserModel(
          id: 100,
          uuid: 'uuid-user-100',
          username: 'admin_user',
          email: 'admin@example.com',
          fullName: 'Admin User',
          phone: '+966501234567',
          roles: ['admin'],
          isActive: true,
          createdAt: DateTime.now(),
        );

        final response = TokenResponse(
          accessToken: 'token',
          refreshToken: 'refresh',
          user: user,
          expiresIn: 3600,
        );

        expect(response.user.id, equals(100));
        expect(response.user.username, equals('admin_user'));
        expect(response.user.email, equals('admin@example.com'));
      });

      test('TokenResponse user should preserve all properties', () {
        final user = UserModel(
          id: 1,
          uuid: 'uuid-123',
          username: 'test_user',
          email: 'test@example.com',
          fullName: 'Test Full Name',
          phone: '+1234567890',
          roles: ['user', 'manager'],
          isActive: true,
          createdAt: DateTime.parse('2024-01-15T10:00:00.000Z'),
        );

        final response = TokenResponse(
          accessToken: 'token',
          refreshToken: 'refresh',
          user: user,
          expiresIn: 3600,
        );

        expect(response.user.fullName, equals('Test Full Name'));
        expect(response.user.phone, equals('+1234567890'));
        expect(response.user.roles.length, equals(2));
      });
    });

    group('Multiple User Types', () {
      test('TokenResponse should support different user roles', () {
        final roles = ['admin', 'manager', 'technician', 'customer'];

        for (final role in roles) {
          final user = UserModel(
            id: 1,
            uuid: 'uuid-123',
            username: 'test_user',
            email: 'test@example.com',
            roles: [role],
            isActive: true,
            createdAt: DateTime.now(),
          );

          final response = TokenResponse(
            accessToken: 'token',
            refreshToken: 'refresh',
            user: user,
            expiresIn: 3600,
          );

          expect(response.user.roles.contains(role), isTrue);
        }
      });

      test('TokenResponse should handle admin user', () {
        final user = UserModel(
          id: 1,
          uuid: 'uuid-123',
          username: 'admin',
          email: 'admin@example.com',
          fullName: 'Administrator',
          roles: ['admin'],
          isActive: true,
          createdAt: DateTime.now(),
        );

        final response = TokenResponse(
          accessToken: 'admin-token',
          refreshToken: 'admin-refresh',
          user: user,
          expiresIn: 3600,
        );

        expect(response.user.username, equals('admin'));
        expect(response.user.roles.first, equals('admin'));
      });
    });
  });
}
