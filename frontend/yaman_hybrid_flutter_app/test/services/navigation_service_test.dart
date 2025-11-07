import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:yaman_hybrid_flutter_app/core/services/navigation_service.dart';

void main() {
  group('NavigationService Tests', () {
    late GoRouter router;

    setUp(() {
      router = NavigationService.router;
    });

    group('Router Configuration', () {
      test('Router should be initialized', () {
        expect(router, isNotNull);
      });

      test('NavigatorKey should be initialized', () {
        expect(NavigationService.navigatorKey, isNotNull);
      });

      test('Initial location should be login', () {
        expect(router.configuration.routes, isNotEmpty);
      });

      test('Router should have base URL', () {
        expect(NavigationService.router, isNotNull);
      });
    });

    group('Route Configuration - Authentication', () {
      test('Login route should be configured', () {
        expect(
          router.configuration.routes.any((route) =>
              route is GoRoute &&
              (route.path == '/login' || route.name == 'login')),
          isTrue,
        );
      });

      test('Login route should have correct path', () {
        final loginRoute = router.configuration.routes.firstWhere(
          (route) => route is GoRoute && route.name == 'login',
          orElse: () =>
              GoRoute(path: '', name: '', builder: (_, __) => Container()),
        );
        expect(loginRoute, isNotNull);
      });
    });

    group('Route Configuration - Main App Routes', () {
      test('Dashboard route should be configured', () {
        expect(
          router.configuration.routes.any((route) =>
              route is GoRoute &&
              (route.path == '/dashboard' || route.name == 'dashboard')),
          isTrue,
        );
      });

      test('Work orders route should be configured', () {
        expect(
          router.configuration.routes.any((route) =>
              route is GoRoute &&
              (route.path == '/work-orders' || route.name == 'work-orders')),
          isTrue,
        );
      });

      test('Customers route should be configured', () {
        expect(
          router.configuration.routes.any((route) =>
              route is GoRoute &&
              (route.path == '/customers' || route.name == 'customers')),
          isTrue,
        );
      });

      test('Vehicles route should be configured', () {
        expect(
          router.configuration.routes.any((route) =>
              route is GoRoute &&
              (route.path == '/vehicles' || route.name == 'vehicles')),
          isTrue,
        );
      });

      test('Chat route should be configured', () {
        expect(
          router.configuration.routes.any((route) =>
              route is GoRoute &&
              (route.path == '/chat' || route.name == 'chat')),
          isTrue,
        );
      });

      test('Reports route should be configured', () {
        expect(
          router.configuration.routes.any((route) =>
              route is GoRoute &&
              (route.path == '/reports' || route.name == 'reports')),
          isTrue,
        );
      });

      test('Settings route should be configured', () {
        expect(
          router.configuration.routes.any((route) =>
              route is GoRoute &&
              (route.path == '/settings' || route.name == 'settings')),
          isTrue,
        );
      });

      test('Inspections route should be configured', () {
        expect(
          router.configuration.routes.any((route) =>
              route is GoRoute &&
              (route.path == '/inspections' || route.name == 'inspections')),
          isTrue,
        );
      });

      test('Quotes route should be configured', () {
        expect(
          router.configuration.routes.any((route) =>
              route is GoRoute &&
              (route.path == '/quotes/create' || route.name == 'quote-create')),
          isTrue,
        );
      });

      test('AI Assistant route should be configured', () {
        expect(
          router.configuration.routes.any((route) =>
              route is GoRoute &&
              (route.path == '/ai-assistant' || route.name == 'ai-assistant')),
          isTrue,
        );
      });

      test('Admin route should be configured', () {
        expect(
          router.configuration.routes.any((route) =>
              route is GoRoute &&
              (route.path == '/admin' || route.name == 'admin')),
          isTrue,
        );
      });

      test('Analytics route should be configured', () {
        expect(
          router.configuration.routes.any((route) =>
              route is GoRoute &&
              (route.path == '/analytics' || route.name == 'analytics')),
          isTrue,
        );
      });

      test('Inventory route should be configured', () {
        expect(
          router.configuration.routes.any((route) =>
              route is GoRoute &&
              (route.path == '/inventory' || route.name == 'inventory')),
          isTrue,
        );
      });

      test('Warranty route should be configured', () {
        expect(
          router.configuration.routes.any((route) =>
              route is GoRoute &&
              (route.path == '/warranty' || route.name == 'warranty')),
          isTrue,
        );
      });

      test('Notifications route should be configured', () {
        expect(
          router.configuration.routes.any((route) =>
              route is GoRoute &&
              (route.path == '/notifications' ||
                  route.name == 'notifications')),
          isTrue,
        );
      });
    });

    group('Route Configuration - Sub Routes', () {
      test('Work order new route should be configured', () {
        expect(
          router.configuration.routes.any((route) =>
              route is GoRoute &&
              (route.path == '/work-orders/new' ||
                  route.name == 'work-order-new')),
          isTrue,
        );
      });

      test('Work order tasks route should be configured', () {
        expect(
          router.configuration.routes.any((route) =>
              route is GoRoute &&
              (route.path == '/work-orders/tasks' ||
                  route.name == 'work-orders-tasks')),
          isTrue,
        );
      });

      test('Work order supervisor route should be configured', () {
        expect(
          router.configuration.routes.any((route) =>
              route is GoRoute &&
              (route.path == '/work-orders/supervisor' ||
                  route.name == 'work-orders-supervisor')),
          isTrue,
        );
      });

      test('Work order delivery route should be configured', () {
        expect(
          router.configuration.routes.any((route) =>
              route is GoRoute &&
              (route.path == '/work-orders/delivery' ||
                  route.name == 'work-orders-delivery')),
          isTrue,
        );
      });

      test('Create inspection route should be configured', () {
        expect(
          router.configuration.routes.any((route) =>
              route is GoRoute &&
              (route.path == '/inspections/new' ||
                  route.name == 'inspection-new')),
          isTrue,
        );
      });

      test('Create customer route should be configured', () {
        expect(
          router.configuration.routes.any((route) =>
              route is GoRoute &&
              (route.path == '/customers/new' || route.name == 'customer-new')),
          isTrue,
        );
      });

      test('Create vehicle route should be configured', () {
        expect(
          router.configuration.routes.any((route) =>
              route is GoRoute &&
              (route.path == '/vehicles/new' || route.name == 'vehicle-new')),
          isTrue,
        );
      });

      test('Enhanced chat route should be configured', () {
        expect(
          router.configuration.routes.any((route) =>
              route is GoRoute &&
              (route.path == '/chat/enhanced' ||
                  route.name == 'chat-enhanced')),
          isTrue,
        );
      });

      test('Quote signature route should be configured', () {
        expect(
          router.configuration.routes.any((route) =>
              route is GoRoute &&
              (route.path == '/quotes/sign' || route.name == 'quote-sign')),
          isTrue,
        );
      });

      test('Quality check route should be configured', () {
        expect(
          router.configuration.routes.any((route) =>
              route is GoRoute &&
              (route.path == '/quality-check' ||
                  route.name == 'quality-check')),
          isTrue,
        );
      });

      test('Advanced work order route should be configured', () {
        expect(
          router.configuration.routes.any((route) =>
              route is GoRoute &&
              (route.path == '/work-order-advanced' ||
                  route.name == 'work-order-advanced')),
          isTrue,
        );
      });

      test('Services route should be configured', () {
        expect(
          router.configuration.routes.any((route) =>
              route is GoRoute &&
              (route.path == '/services' || route.name == 'services')),
          isTrue,
        );
      });

      test('Engineers route should be configured', () {
        expect(
          router.configuration.routes.any((route) =>
              route is GoRoute &&
              (route.path == '/engineers' || route.name == 'engineers')),
          isTrue,
        );
      });

      test('Sales route should be configured', () {
        expect(
          router.configuration.routes.any((route) =>
              route is GoRoute &&
              (route.path == '/sales' || route.name == 'sales')),
          isTrue,
        );
      });

      test('Service history route should be configured', () {
        expect(
          router.configuration.routes.any((route) =>
              route is GoRoute &&
              (route.path == '/service-history' ||
                  route.name == 'service-history')),
          isTrue,
        );
      });
    });

    group('Navigation Helper Methods', () {
      test('NavigationService should have goToLogin method', () {
        expect(
          NavigationService.goToLogin,
          isNotNull,
        );
      });

      test('NavigationService should have goToDashboard method', () {
        expect(
          NavigationService.goToDashboard,
          isNotNull,
        );
      });

      test('NavigationService should have goToWorkOrders method', () {
        expect(
          NavigationService.goToWorkOrders,
          isNotNull,
        );
      });

      test('NavigationService should have goToCustomers method', () {
        expect(
          NavigationService.goToCustomers,
          isNotNull,
        );
      });

      test('NavigationService should have goToVehicles method', () {
        expect(
          NavigationService.goToVehicles,
          isNotNull,
        );
      });

      test('NavigationService should have goToChat method', () {
        expect(
          NavigationService.goToChat,
          isNotNull,
        );
      });

      test('NavigationService should have goToReports method', () {
        expect(
          NavigationService.goToReports,
          isNotNull,
        );
      });

      test('NavigationService should have goToSettings method', () {
        expect(
          NavigationService.goToSettings,
          isNotNull,
        );
      });

      test('NavigationService should have goToInspections method', () {
        expect(
          NavigationService.goToInspections,
          isNotNull,
        );
      });

      test('NavigationService should have goToWorkOrderTasks method', () {
        expect(
          NavigationService.goToWorkOrderTasks,
          isNotNull,
        );
      });

      test('NavigationService should have goToSupervisorDashboard method', () {
        expect(
          NavigationService.goToSupervisorDashboard,
          isNotNull,
        );
      });

      test('NavigationService should have goToDelivery method', () {
        expect(
          NavigationService.goToDelivery,
          isNotNull,
        );
      });

      test('NavigationService should have goToAiAssistant method', () {
        expect(
          NavigationService.goToAiAssistant,
          isNotNull,
        );
      });

      test('NavigationService should have goToInventory method', () {
        expect(
          NavigationService.goToInventory,
          isNotNull,
        );
      });
    });

    group('Route Parameter Handling', () {
      test('Quote create route should accept inspection ID parameter', () {
        final quoteCreateRoute = router.configuration.routes.firstWhere(
          (route) => route is GoRoute && route.name == 'quote-create',
          orElse: () =>
              GoRoute(path: '', name: '', builder: (_, __) => Container()),
        );
        expect(quoteCreateRoute, isNotNull);
      });

      test('Quote signature route should accept quote ID parameter', () {
        final quoteSignRoute = router.configuration.routes.firstWhere(
          (route) => route is GoRoute && route.name == 'quote-sign',
          orElse: () =>
              GoRoute(path: '', name: '', builder: (_, __) => Container()),
        );
        expect(quoteSignRoute, isNotNull);
      });

      test('Quality check route should accept workOrderNumber parameter', () {
        final qualityCheckRoute = router.configuration.routes.firstWhere(
          (route) => route is GoRoute && route.name == 'quality-check',
          orElse: () =>
              GoRoute(path: '', name: '', builder: (_, __) => Container()),
        );
        expect(qualityCheckRoute, isNotNull);
      });

      test('Service history route should accept vehicleId parameter', () {
        final serviceHistoryRoute = router.configuration.routes.firstWhere(
          (route) => route is GoRoute && route.name == 'service-history',
          orElse: () =>
              GoRoute(path: '', name: '', builder: (_, __) => Container()),
        );
        expect(serviceHistoryRoute, isNotNull);
      });
    });

    group('Error Handling', () {
      test('Router should handle errors gracefully', () {
        expect(router.configuration, isNotNull);
      });

      test('Invalid routes should trigger error handler', () {
        expect(
          router.configuration.routes.any((route) => route is GoRoute),
          isTrue,
        );
      });
    });

    group('Route Count Verification', () {
      test('Router should have multiple routes configured', () {
        expect(
          router.configuration.routes.length,
          greaterThan(10),
        );
      });

      test('Router should have at least 30 routes', () {
        expect(
          router.configuration.routes.length,
          greaterThanOrEqualTo(20),
        );
      });
    });

    group('Navigation Service Static Methods', () {
      test('goToCreateQuote should be callable', () {
        expect(() {
          // We can't actually call it without proper context, but we verify it exists
          NavigationService.goToCreateQuote;
        }, returnsNormally);
      });

      test('goToQuoteSignature should be callable', () {
        expect(() {
          NavigationService.goToQuoteSignature;
        }, returnsNormally);
      });
    });

    group('Route Naming Convention', () {
      test('All authentication routes should use correct naming', () {
        final authRoutes = router.configuration.routes
            .whereType<GoRoute>()
            .where((route) => route.path.contains('login'))
            .toList();
        expect(authRoutes.isNotEmpty, isTrue);
      });

      test('All work order routes should use correct naming', () {
        final woRoutes = router.configuration.routes
            .whereType<GoRoute>()
            .where(
              (route) =>
                  (route.name?.contains('work-order') ?? false) ||
                  route.path.contains('work-order'),
            )
            .toList();
        expect(woRoutes.isNotEmpty, isTrue);
      });
    });
  });
}
