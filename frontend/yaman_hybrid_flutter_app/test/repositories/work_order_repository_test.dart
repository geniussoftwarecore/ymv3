import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:dio/dio.dart';
import 'package:yaman_hybrid_flutter_app/core/api/repositories/work_order_repository.dart';

class MockDio extends Mock implements Dio {}

void main() {
  group('WorkOrderModel Tests', () {
    group('Model Creation', () {
      test('WorkOrderModel should be created with all parameters', () {
        final model = WorkOrderModel(
          id: 1,
          uuid: 'uuid-123',
          workOrderNumber: '#WO001',
          customerId: 100,
          customerName: 'John Doe',
          customerPhone: '0501234567',
          customerAddress: '123 Main St',
          vehicleId: 50,
          vehicleInfo: 'Toyota Camry 2020',
          status: 'pending',
          scheduledDate: DateTime.now(),
          completedDate: null,
          totalCost: 500.0,
          specialInstructions: 'Handle with care',
          services: ['Oil Change', 'Filter Replacement'],
          notes: 'Customer prefers morning appointment',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(model.id, equals(1));
        expect(model.workOrderNumber, equals('#WO001'));
        expect(model.customerName, equals('John Doe'));
      });

      test('WorkOrderModel should handle nullable fields', () {
        final model = WorkOrderModel(
          id: 1,
          uuid: 'uuid-123',
          workOrderNumber: '#WO001',
          customerId: 100,
          customerName: 'John Doe',
          customerPhone: null,
          customerAddress: null,
          vehicleId: 50,
          vehicleInfo: 'Toyota Camry 2020',
          status: 'pending',
          scheduledDate: DateTime.now(),
          completedDate: null,
          totalCost: 500.0,
          specialInstructions: null,
          services: [],
          notes: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(model.customerPhone, isNull);
        expect(model.specialInstructions, isNull);
        expect(model.services, isEmpty);
      });
    });

    group('JSON Serialization', () {
      test('WorkOrderModel.fromJson should deserialize correctly', () {
        final json = {
          'id': 1,
          'uuid': 'uuid-123',
          'work_order_number': '#WO001',
          'customer_id': 100,
          'customer_name': 'John Doe',
          'customer_phone': '0501234567',
          'customer_address': '123 Main St',
          'vehicle_id': 50,
          'vehicle_info': 'Toyota Camry 2020',
          'status': 'completed',
          'scheduled_date': '2024-01-15T10:00:00.000Z',
          'completed_date': '2024-01-15T14:00:00.000Z',
          'total_cost': 500.0,
          'special_instructions': 'Handle with care',
          'services': ['Oil Change', 'Filter Replacement'],
          'notes': 'Work completed successfully',
          'created_at': '2024-01-15T10:00:00.000Z',
          'updated_at': '2024-01-15T14:00:00.000Z',
        };

        final model = WorkOrderModel.fromJson(json);

        expect(model.id, equals(1));
        expect(model.workOrderNumber, equals('#WO001'));
        expect(model.customerName, equals('John Doe'));
        expect(model.status, equals('completed'));
        expect(model.services.length, equals(2));
      });

      test('WorkOrderModel.fromJson should handle null fields', () {
        final json = {
          'id': 1,
          'uuid': 'uuid-123',
          'work_order_number': '#WO001',
          'customer_id': 100,
          'customer_name': 'John Doe',
          'customer_phone': null,
          'customer_address': null,
          'vehicle_id': 50,
          'vehicle_info': 'Toyota Camry 2020',
          'status': 'pending',
          'scheduled_date': '2024-01-15T10:00:00.000Z',
          'completed_date': null,
          'total_cost': 500.0,
          'special_instructions': null,
          'services': [],
          'notes': null,
          'created_at': '2024-01-15T10:00:00.000Z',
          'updated_at': '2024-01-15T10:00:00.000Z',
        };

        final model = WorkOrderModel.fromJson(json);

        expect(model.customerPhone, isNull);
        expect(model.completedDate, isNull);
        expect(model.services, isEmpty);
      });

      test('WorkOrderModel.toJson should serialize correctly', () {
        final now = DateTime(2024, 1, 15, 10, 0, 0);
        final model = WorkOrderModel(
          id: 1,
          uuid: 'uuid-123',
          workOrderNumber: '#WO001',
          customerId: 100,
          customerName: 'John Doe',
          customerPhone: '0501234567',
          customerAddress: '123 Main St',
          vehicleId: 50,
          vehicleInfo: 'Toyota Camry 2020',
          status: 'pending',
          scheduledDate: now,
          completedDate: null,
          totalCost: 500.0,
          specialInstructions: 'Handle with care',
          services: ['Oil Change'],
          notes: 'Test notes',
          createdAt: now,
          updatedAt: now,
        );

        final json = model.toJson();

        expect(json['id'], equals(1));
        expect(json['work_order_number'], equals('#WO001'));
        expect(json['customer_name'], equals('John Doe'));
        expect(json['total_cost'], equals(500.0));
      });

      test('WorkOrderModel round-trip serialization should work', () {
        final original = WorkOrderModel(
          id: 1,
          uuid: 'uuid-123',
          workOrderNumber: '#WO001',
          customerId: 100,
          customerName: 'John Doe',
          customerPhone: '0501234567',
          customerAddress: '123 Main St',
          vehicleId: 50,
          vehicleInfo: 'Toyota Camry 2020',
          status: 'pending',
          scheduledDate: DateTime.parse('2024-01-15T10:00:00.000Z'),
          completedDate: null,
          totalCost: 500.0,
          specialInstructions: 'Handle with care',
          services: ['Oil Change', 'Filter Replacement'],
          notes: 'Test notes',
          createdAt: DateTime.parse('2024-01-15T10:00:00.000Z'),
          updatedAt: DateTime.parse('2024-01-15T10:00:00.000Z'),
        );

        final json = original.toJson();
        final deserialized = WorkOrderModel.fromJson(json);

        expect(deserialized.id, equals(original.id));
        expect(deserialized.workOrderNumber, equals(original.workOrderNumber));
        expect(deserialized.customerName, equals(original.customerName));
      });
    });

    group('Status Handling', () {
      test('WorkOrderModel should support different status values', () {
        final statuses = ['pending', 'in_progress', 'completed', 'cancelled'];

        for (final status in statuses) {
          final model = WorkOrderModel(
            id: 1,
            uuid: 'uuid-123',
            workOrderNumber: '#WO001',
            customerId: 100,
            customerName: 'John Doe',
            vehicleId: 50,
            vehicleInfo: 'Toyota Camry 2020',
            status: status,
            scheduledDate: DateTime.now(),
            totalCost: 500.0,
            services: [],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          expect(model.status, equals(status));
        }
      });
    });

    group('Service List Handling', () {
      test('WorkOrderModel should handle multiple services', () {
        final services = [
          'Oil Change',
          'Filter Replacement',
          'Brake Service',
          'Suspension Check'
        ];

        final model = WorkOrderModel(
          id: 1,
          uuid: 'uuid-123',
          workOrderNumber: '#WO001',
          customerId: 100,
          customerName: 'John Doe',
          vehicleId: 50,
          vehicleInfo: 'Toyota Camry 2020',
          status: 'pending',
          scheduledDate: DateTime.now(),
          totalCost: 1500.0,
          services: services,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(model.services.length, equals(4));
        expect(model.services.contains('Oil Change'), isTrue);
      });

      test('WorkOrderModel should handle empty service list', () {
        final model = WorkOrderModel(
          id: 1,
          uuid: 'uuid-123',
          workOrderNumber: '#WO001',
          customerId: 100,
          customerName: 'John Doe',
          vehicleId: 50,
          vehicleInfo: 'Toyota Camry 2020',
          status: 'pending',
          scheduledDate: DateTime.now(),
          totalCost: 0.0,
          services: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(model.services, isEmpty);
      });
    });

    group('Cost Calculations', () {
      test('WorkOrderModel should handle various cost amounts', () {
        final costs = [0.0, 100.0, 500.0, 1000.0, 5000.0];

        for (final cost in costs) {
          final model = WorkOrderModel(
            id: 1,
            uuid: 'uuid-123',
            workOrderNumber: '#WO001',
            customerId: 100,
            customerName: 'John Doe',
            vehicleId: 50,
            vehicleInfo: 'Toyota Camry 2020',
            status: 'pending',
            scheduledDate: DateTime.now(),
            totalCost: cost,
            services: [],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          expect(model.totalCost, equals(cost));
        }
      });

      test('WorkOrderModel should handle decimal cost values', () {
        final model = WorkOrderModel(
          id: 1,
          uuid: 'uuid-123',
          workOrderNumber: '#WO001',
          customerId: 100,
          customerName: 'John Doe',
          vehicleId: 50,
          vehicleInfo: 'Toyota Camry 2020',
          status: 'pending',
          scheduledDate: DateTime.now(),
          totalCost: 599.99,
          services: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(model.totalCost, equals(599.99));
      });
    });

    group('Date Handling', () {
      test('WorkOrderModel should handle scheduled and completed dates', () {
        final scheduledDate = DateTime(2024, 2, 1, 10, 0);
        final completedDate = DateTime(2024, 2, 1, 15, 0);

        final model = WorkOrderModel(
          id: 1,
          uuid: 'uuid-123',
          workOrderNumber: '#WO001',
          customerId: 100,
          customerName: 'John Doe',
          vehicleId: 50,
          vehicleInfo: 'Toyota Camry 2020',
          status: 'completed',
          scheduledDate: scheduledDate,
          completedDate: completedDate,
          totalCost: 500.0,
          services: [],
          createdAt: DateTime(2024, 1, 15),
          updatedAt: DateTime(2024, 2, 1),
        );

        expect(model.scheduledDate, equals(scheduledDate));
        expect(model.completedDate, equals(completedDate));
      });

      test('WorkOrderModel should handle null completedDate', () {
        final model = WorkOrderModel(
          id: 1,
          uuid: 'uuid-123',
          workOrderNumber: '#WO001',
          customerId: 100,
          customerName: 'John Doe',
          vehicleId: 50,
          vehicleInfo: 'Toyota Camry 2020',
          status: 'pending',
          scheduledDate: DateTime.now(),
          completedDate: null,
          totalCost: 500.0,
          services: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(model.completedDate, isNull);
      });
    });

    group('UUID Handling', () {
      test('WorkOrderModel should preserve UUID', () {
        const uuid = 'f47ac10b-58cc-4372-a567-0e02b2c3d479';

        final model = WorkOrderModel(
          id: 1,
          uuid: uuid,
          workOrderNumber: '#WO001',
          customerId: 100,
          customerName: 'John Doe',
          vehicleId: 50,
          vehicleInfo: 'Toyota Camry 2020',
          status: 'pending',
          scheduledDate: DateTime.now(),
          totalCost: 500.0,
          services: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(model.uuid, equals(uuid));
      });
    });

    group('Customer Information', () {
      test('WorkOrderModel should store customer details', () {
        final model = WorkOrderModel(
          id: 1,
          uuid: 'uuid-123',
          workOrderNumber: '#WO001',
          customerId: 100,
          customerName: 'Ahmed Mohammed',
          customerPhone: '+966501234567',
          customerAddress: 'Riyadh, Saudi Arabia',
          vehicleId: 50,
          vehicleInfo: 'Toyota Camry 2020 Black',
          status: 'pending',
          scheduledDate: DateTime.now(),
          totalCost: 500.0,
          services: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(model.customerId, equals(100));
        expect(model.customerName, equals('Ahmed Mohammed'));
        expect(model.customerPhone, equals('+966501234567'));
      });
    });

    group('Vehicle Information', () {
      test('WorkOrderModel should store vehicle details', () {
        final model = WorkOrderModel(
          id: 1,
          uuid: 'uuid-123',
          workOrderNumber: '#WO001',
          customerId: 100,
          customerName: 'John Doe',
          vehicleId: 50,
          vehicleInfo: 'Toyota Camry 2020 Hybrid Silver',
          status: 'pending',
          scheduledDate: DateTime.now(),
          totalCost: 500.0,
          services: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(model.vehicleId, equals(50));
        expect(model.vehicleInfo, contains('Toyota'));
      });
    });

    group('Special Instructions', () {
      test('WorkOrderModel should handle special instructions', () {
        const instructions =
            'Handle with care, customer sensitive about repairs';

        final model = WorkOrderModel(
          id: 1,
          uuid: 'uuid-123',
          workOrderNumber: '#WO001',
          customerId: 100,
          customerName: 'John Doe',
          vehicleId: 50,
          vehicleInfo: 'Toyota Camry 2020',
          status: 'pending',
          scheduledDate: DateTime.now(),
          totalCost: 500.0,
          specialInstructions: instructions,
          services: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(model.specialInstructions, equals(instructions));
      });

      test('WorkOrderModel should handle null special instructions', () {
        final model = WorkOrderModel(
          id: 1,
          uuid: 'uuid-123',
          workOrderNumber: '#WO001',
          customerId: 100,
          customerName: 'John Doe',
          vehicleId: 50,
          vehicleInfo: 'Toyota Camry 2020',
          status: 'pending',
          scheduledDate: DateTime.now(),
          totalCost: 500.0,
          specialInstructions: null,
          services: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(model.specialInstructions, isNull);
      });
    });

    group('Notes Handling', () {
      test('WorkOrderModel should handle notes', () {
        const notes = 'Customer called to confirm appointment for tomorrow';

        final model = WorkOrderModel(
          id: 1,
          uuid: 'uuid-123',
          workOrderNumber: '#WO001',
          customerId: 100,
          customerName: 'John Doe',
          vehicleId: 50,
          vehicleInfo: 'Toyota Camry 2020',
          status: 'pending',
          scheduledDate: DateTime.now(),
          totalCost: 500.0,
          notes: notes,
          services: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(model.notes, equals(notes));
      });
    });
  });
}
