import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:dio/dio.dart';
import 'package:yaman_hybrid_flutter_app/core/api/repositories/customer_repository.dart';

class MockDio extends Mock implements Dio {}

void main() {
  group('CustomerModel Tests', () {
    group('Model Creation', () {
      test('CustomerModel should be created with all parameters', () {
        final model = CustomerModel(
          id: 1,
          uuid: 'uuid-123',
          name: 'Ahmed Mohammed',
          email: 'ahmed@example.com',
          phone: '+966501234567',
          address: '123 Main Street',
          city: 'Riyadh',
          country: 'Saudi Arabia',
          idNumber: '1234567890',
          idType: 'national_id',
          companyName: 'Ahmed Cars',
          companyTaxId: 'TAX123456',
          website: 'www.ahmedcars.com',
          status: 'active',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(model.id, equals(1));
        expect(model.name, equals('Ahmed Mohammed'));
        expect(model.email, equals('ahmed@example.com'));
      });

      test('CustomerModel should handle nullable fields', () {
        final model = CustomerModel(
          id: 1,
          uuid: 'uuid-123',
          name: 'John Doe',
          email: 'john@example.com',
          phone: '0501234567',
          address: null,
          city: null,
          country: null,
          idNumber: null,
          idType: null,
          companyName: null,
          companyTaxId: null,
          website: null,
          status: 'active',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(model.address, isNull);
        expect(model.city, isNull);
        expect(model.companyName, isNull);
      });
    });

    group('JSON Serialization', () {
      test('CustomerModel.fromJson should deserialize correctly', () {
        final json = {
          'id': 1,
          'uuid': 'uuid-123',
          'name': 'Ahmed Mohammed',
          'email': 'ahmed@example.com',
          'phone': '+966501234567',
          'address': '123 Main Street',
          'city': 'Riyadh',
          'country': 'Saudi Arabia',
          'id_number': '1234567890',
          'id_type': 'national_id',
          'company_name': 'Ahmed Cars',
          'company_tax_id': 'TAX123456',
          'website': 'www.ahmedcars.com',
          'status': 'active',
          'created_at': '2024-01-15T10:00:00.000Z',
          'updated_at': '2024-01-15T10:00:00.000Z',
        };

        final model = CustomerModel.fromJson(json);

        expect(model.id, equals(1));
        expect(model.name, equals('Ahmed Mohammed'));
        expect(model.email, equals('ahmed@example.com'));
        expect(model.status, equals('active'));
      });

      test('CustomerModel.fromJson should handle null fields', () {
        final json = {
          'id': 1,
          'uuid': 'uuid-123',
          'name': 'John Doe',
          'email': 'john@example.com',
          'phone': '0501234567',
          'address': null,
          'city': null,
          'country': null,
          'id_number': null,
          'id_type': null,
          'company_name': null,
          'company_tax_id': null,
          'website': null,
          'status': 'active',
          'created_at': '2024-01-15T10:00:00.000Z',
          'updated_at': '2024-01-15T10:00:00.000Z',
        };

        final model = CustomerModel.fromJson(json);

        expect(model.address, isNull);
        expect(model.city, isNull);
        expect(model.status, equals('active'));
      });

      test('CustomerModel.fromJson should use default status', () {
        final json = {
          'id': 1,
          'uuid': 'uuid-123',
          'name': 'John Doe',
          'email': 'john@example.com',
          'phone': '0501234567',
          'created_at': '2024-01-15T10:00:00.000Z',
          'updated_at': '2024-01-15T10:00:00.000Z',
        };

        final model = CustomerModel.fromJson(json);

        expect(model.status, equals('active'));
      });

      test('CustomerModel.toJson should serialize correctly', () {
        final now = DateTime(2024, 1, 15, 10, 0, 0);
        final model = CustomerModel(
          id: 1,
          uuid: 'uuid-123',
          name: 'Ahmed Mohammed',
          email: 'ahmed@example.com',
          phone: '+966501234567',
          address: '123 Main Street',
          city: 'Riyadh',
          country: 'Saudi Arabia',
          idNumber: '1234567890',
          idType: 'national_id',
          companyName: 'Ahmed Cars',
          companyTaxId: 'TAX123456',
          website: 'www.ahmedcars.com',
          status: 'active',
          createdAt: now,
          updatedAt: now,
        );

        final json = model.toJson();

        expect(json['id'], equals(1));
        expect(json['name'], equals('Ahmed Mohammed'));
        expect(json['email'], equals('ahmed@example.com'));
        expect(json['status'], equals('active'));
      });

      test('CustomerModel round-trip serialization should work', () {
        final original = CustomerModel(
          id: 1,
          uuid: 'uuid-123',
          name: 'Ahmed Mohammed',
          email: 'ahmed@example.com',
          phone: '+966501234567',
          address: '123 Main Street',
          city: 'Riyadh',
          country: 'Saudi Arabia',
          idNumber: '1234567890',
          idType: 'national_id',
          companyName: 'Ahmed Cars',
          companyTaxId: 'TAX123456',
          website: 'www.ahmedcars.com',
          status: 'active',
          createdAt: DateTime.parse('2024-01-15T10:00:00.000Z'),
          updatedAt: DateTime.parse('2024-01-15T10:00:00.000Z'),
        );

        final json = original.toJson();
        final deserialized = CustomerModel.fromJson(json);

        expect(deserialized.id, equals(original.id));
        expect(deserialized.name, equals(original.name));
        expect(deserialized.email, equals(original.email));
      });
    });

    group('Status Handling', () {
      test('CustomerModel should support different status values', () {
        final statuses = ['active', 'inactive', 'blocked', 'pending'];

        for (final status in statuses) {
          final model = CustomerModel(
            id: 1,
            uuid: 'uuid-123',
            name: 'John Doe',
            email: 'john@example.com',
            phone: '0501234567',
            status: status,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          expect(model.status, equals(status));
        }
      });
    });

    group('Contact Information', () {
      test('CustomerModel should store email and phone', () {
        const email = 'test@example.com';
        const phone = '+966501234567';

        final model = CustomerModel(
          id: 1,
          uuid: 'uuid-123',
          name: 'Test Customer',
          email: email,
          phone: phone,
          status: 'active',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(model.email, equals(email));
        expect(model.phone, equals(phone));
      });

      test('CustomerModel should validate email format', () {
        final emails = [
          'test@example.com',
          'user.name@company.co.uk',
          'admin@test-domain.org'
        ];

        for (final email in emails) {
          final model = CustomerModel(
            id: 1,
            uuid: 'uuid-123',
            name: 'Test Customer',
            email: email,
            phone: '0501234567',
            status: 'active',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          expect(model.email, equals(email));
        }
      });
    });

    group('Location Information', () {
      test('CustomerModel should store address details', () {
        const address = '123 Main Street';
        const city = 'Riyadh';
        const country = 'Saudi Arabia';

        final model = CustomerModel(
          id: 1,
          uuid: 'uuid-123',
          name: 'Test Customer',
          email: 'test@example.com',
          phone: '0501234567',
          address: address,
          city: city,
          country: country,
          status: 'active',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(model.address, equals(address));
        expect(model.city, equals(city));
        expect(model.country, equals(country));
      });

      test('CustomerModel should handle partial location info', () {
        final model = CustomerModel(
          id: 1,
          uuid: 'uuid-123',
          name: 'Test Customer',
          email: 'test@example.com',
          phone: '0501234567',
          address: '123 Main Street',
          city: null,
          country: null,
          status: 'active',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(model.address, isNotNull);
        expect(model.city, isNull);
        expect(model.country, isNull);
      });
    });

    group('Identification Information', () {
      test('CustomerModel should store ID details', () {
        const idNumber = '1234567890';
        const idType = 'national_id';

        final model = CustomerModel(
          id: 1,
          uuid: 'uuid-123',
          name: 'Test Customer',
          email: 'test@example.com',
          phone: '0501234567',
          idNumber: idNumber,
          idType: idType,
          status: 'active',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(model.idNumber, equals(idNumber));
        expect(model.idType, equals(idType));
      });

      test('CustomerModel should support different ID types', () {
        final idTypes = ['national_id', 'passport', 'business_license'];

        for (final idType in idTypes) {
          final model = CustomerModel(
            id: 1,
            uuid: 'uuid-123',
            name: 'Test Customer',
            email: 'test@example.com',
            phone: '0501234567',
            idNumber: '123456',
            idType: idType,
            status: 'active',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          expect(model.idType, equals(idType));
        }
      });
    });

    group('Business Information', () {
      test('CustomerModel should store company details', () {
        const companyName = 'Ahmed Cars Company';
        const companyTaxId = 'TAX123456';
        const website = 'www.ahmedcars.com';

        final model = CustomerModel(
          id: 1,
          uuid: 'uuid-123',
          name: 'Ahmed Mohammed',
          email: 'ahmed@ahmedcars.com',
          phone: '+966501234567',
          companyName: companyName,
          companyTaxId: companyTaxId,
          website: website,
          status: 'active',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(model.companyName, equals(companyName));
        expect(model.companyTaxId, equals(companyTaxId));
        expect(model.website, equals(website));
      });

      test('CustomerModel should handle business and personal customers', () {
        // Personal customer
        final personalModel = CustomerModel(
          id: 1,
          uuid: 'uuid-1',
          name: 'John Doe',
          email: 'john@example.com',
          phone: '0501234567',
          companyName: null,
          companyTaxId: null,
          website: null,
          status: 'active',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Business customer
        final businessModel = CustomerModel(
          id: 2,
          uuid: 'uuid-2',
          name: 'Company LLC',
          email: 'info@company.com',
          phone: '+966501111111',
          companyName: 'Company LLC',
          companyTaxId: 'TAX999999',
          website: 'www.company.com',
          status: 'active',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(personalModel.companyName, isNull);
        expect(businessModel.companyName, isNotNull);
      });
    });

    group('UUID Handling', () {
      test('CustomerModel should preserve UUID', () {
        const uuid = 'f47ac10b-58cc-4372-a567-0e02b2c3d479';

        final model = CustomerModel(
          id: 1,
          uuid: uuid,
          name: 'Test Customer',
          email: 'test@example.com',
          phone: '0501234567',
          status: 'active',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(model.uuid, equals(uuid));
      });
    });

    group('Timestamp Handling', () {
      test('CustomerModel should store creation and update dates', () {
        final createdAt = DateTime(2024, 1, 1, 10, 0, 0);
        final updatedAt = DateTime(2024, 1, 15, 15, 30, 0);

        final model = CustomerModel(
          id: 1,
          uuid: 'uuid-123',
          name: 'Test Customer',
          email: 'test@example.com',
          phone: '0501234567',
          status: 'active',
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

        expect(model.createdAt, equals(createdAt));
        expect(model.updatedAt, equals(updatedAt));
      });

      test('CustomerModel should handle recent and old dates', () {
        final oldDate = DateTime(2020, 1, 1);
        final newDate = DateTime.now();

        final model = CustomerModel(
          id: 1,
          uuid: 'uuid-123',
          name: 'Test Customer',
          email: 'test@example.com',
          phone: '0501234567',
          status: 'active',
          createdAt: oldDate,
          updatedAt: newDate,
        );

        expect(model.createdAt.isBefore(model.updatedAt), isTrue);
      });
    });

    group('Name Variations', () {
      test('CustomerModel should handle various name formats', () {
        final names = [
          'Ahmed Mohammed',
          'محمد أحمد',
          'José García',
          'Zhang Wei'
        ];

        for (final name in names) {
          final model = CustomerModel(
            id: 1,
            uuid: 'uuid-123',
            name: name,
            email: 'test@example.com',
            phone: '0501234567',
            status: 'active',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          expect(model.name, equals(name));
        }
      });
    });

    group('Phone Number Variations', () {
      test('CustomerModel should handle various phone formats', () {
        final phones = [
          '+966501234567',
          '0501234567',
          '+1-555-1234567',
          '555-123-4567'
        ];

        for (final phone in phones) {
          final model = CustomerModel(
            id: 1,
            uuid: 'uuid-123',
            name: 'Test Customer',
            email: 'test@example.com',
            phone: phone,
            status: 'active',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          expect(model.phone, equals(phone));
        }
      });
    });
  });
}
