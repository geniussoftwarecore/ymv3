import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/work_orders/presentation/pages/work_order_list_page.dart';
import '../../features/work_orders/presentation/pages/work_orders_page.dart';
import '../../features/work_orders/presentation/pages/task_list_page.dart';
import '../../features/work_orders/presentation/pages/supervisor_dashboard_page.dart';
import '../../features/work_orders/presentation/pages/delivery_page.dart';
import '../../features/inspections/presentation/pages/inspections_list_page_production.dart';
import '../../features/inspections/presentation/pages/create_inspection_page.dart';
import '../../features/quotes/presentation/pages/create_quote_page.dart';
import '../../features/quotes/presentation/pages/electronic_signature_page.dart';
import '../../features/customers/presentation/pages/customers_list_page_production.dart';
import '../../features/customers/presentation/pages/customers_page.dart';
import '../../features/vehicles/presentation/pages/vehicle_list_page.dart';
import '../../features/vehicles/presentation/pages/vehicles_page.dart';
import '../../features/chat/presentation/pages/chat_page.dart';
import '../../features/chat/presentation/pages/enhanced_chat_page.dart';
import '../../features/ai_assistant/presentation/pages/ai_assistant_page.dart';
import '../../features/reports/presentation/pages/reports_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/services/presentation/pages/services_management_page.dart';
import '../../features/engineers/presentation/pages/engineers_management_page.dart';
import '../../features/sales/presentation/pages/sales_dashboard_page.dart';
import '../../features/work_orders/presentation/pages/quality_check_page.dart';
import '../../features/work_orders/presentation/pages/advanced_work_order_page.dart';
import '../../features/admin/presentation/pages/admin_dashboard_page.dart';
import '../../features/inventory/presentation/pages/inventory_management_page.dart';
import '../../features/warranty/presentation/pages/warranty_management_page.dart';
import '../../features/notifications/presentation/pages/notifications_center_page.dart';
import '../../features/analytics/presentation/pages/analytics_dashboard_page.dart';
import '../../features/service_history/presentation/pages/service_history_page.dart';

class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: '/login',
    routes: [
      // Authentication Routes
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),

      // Main App Routes
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const DashboardPage(),
      ),

      // Work Orders Routes
      GoRoute(
        path: '/work-orders',
        name: 'work-orders',
        builder: (context, state) => const WorkOrderListPage(),
      ),
      GoRoute(
        path: '/work-orders/new',
        name: 'work-order-new',
        builder: (context, state) => const WorkOrdersPage(),
      ),
      GoRoute(
        path: '/work-orders/tasks',
        name: 'work-orders-tasks',
        builder: (context, state) => const TaskListPage(),
      ),
      GoRoute(
        path: '/work-orders/supervisor',
        name: 'work-orders-supervisor',
        builder: (context, state) => const SupervisorDashboardPage(),
      ),
      GoRoute(
        path: '/work-orders/delivery',
        name: 'work-orders-delivery',
        builder: (context, state) => const DeliveryPage(),
      ),

      // Inspections Routes
      GoRoute(
        path: '/inspections',
        name: 'inspections',
        builder: (context, state) => const InspectionsListPageProduction(),
      ),
      GoRoute(
        path: '/inspections/new',
        name: 'inspection-new',
        builder: (context, state) => const CreateInspectionPage(),
      ),

      // Quotes Routes
      GoRoute(
        path: '/quotes/create',
        name: 'quote-create',
        builder: (context, state) {
          // Extract parameters from state
          final inspectionId = state.uri.queryParameters['inspectionId'];
          final inspectionServices = state.extra as List<Map<String, dynamic>>?;
          final customerInfo = state.extra as Map<String, dynamic>?;
          final vehicleInfo = state.extra as Map<String, dynamic>?;

          return CreateQuotePage(
            inspectionId: int.tryParse(inspectionId ?? '') ?? 0,
            inspectionServices: inspectionServices ?? [],
            customerInfo: customerInfo ?? {},
            vehicleInfo: vehicleInfo ?? {},
          );
        },
      ),
      GoRoute(
        path: '/quotes/sign',
        name: 'quote-sign',
        builder: (context, state) {
          final quoteId = state.uri.queryParameters['quoteId'];
          final quoteNumber = state.uri.queryParameters['quoteNumber'];
          final totalAmount = state.uri.queryParameters['totalAmount'];
          final items = state.extra as List<Map<String, dynamic>>?;

          return ElectronicSignaturePage(
            quoteId: int.tryParse(quoteId ?? '') ?? 0,
            quoteNumber: quoteNumber ?? '',
            totalAmount: double.tryParse(totalAmount ?? '') ?? 0.0,
            items: items ?? [],
          );
        },
      ),

      // Customers Routes
      GoRoute(
        path: '/customers',
        name: 'customers',
        builder: (context, state) => const CustomersListPageProduction(),
      ),
      GoRoute(
        path: '/customers/new',
        name: 'customer-new',
        builder: (context, state) => const CustomersPage(),
      ),

      // Vehicles Routes
      GoRoute(
        path: '/vehicles',
        name: 'vehicles',
        builder: (context, state) => const VehicleListPage(),
      ),
      GoRoute(
        path: '/vehicles/new',
        name: 'vehicle-new',
        builder: (context, state) => const VehiclesPage(),
      ),

      // Chat Routes
      GoRoute(
        path: '/chat',
        name: 'chat',
        builder: (context, state) => const ChatPage(),
      ),
      GoRoute(
        path: '/chat/enhanced',
        name: 'chat-enhanced',
        builder: (context, state) => const EnhancedChatPage(),
      ),

      // Reports Routes
      GoRoute(
        path: '/reports',
        name: 'reports',
        builder: (context, state) => const ReportsPage(),
      ),

      // Settings Routes
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsPage(),
      ),

      // Services Management Route
      GoRoute(
        path: '/services',
        name: 'services',
        builder: (context, state) => const ServicesManagementPage(),
      ),

      // Engineers Management Route
      GoRoute(
        path: '/engineers',
        name: 'engineers',
        builder: (context, state) => const EngineersManagementPage(),
      ),

      // Sales Dashboard Route
      GoRoute(
        path: '/sales',
        name: 'sales',
        builder: (context, state) => const SalesDashboardPage(),
      ),

      // Quality Check Route
      GoRoute(
        path: '/quality-check',
        name: 'quality-check',
        builder: (context, state) {
          final workOrderNumber =
              state.uri.queryParameters['workOrderNumber'] ?? '#WO001';
          return QualityCheckPage(workOrderNumber: workOrderNumber);
        },
      ),

      // Advanced Work Order Route
      GoRoute(
        path: '/work-order-advanced',
        name: 'work-order-advanced',
        builder: (context, state) {
          final workOrderNumber =
              state.uri.queryParameters['workOrderNumber'] ?? '#WO001';
          return AdvancedWorkOrderPage(workOrderNumber: workOrderNumber);
        },
      ),

      // Admin Dashboard Route
      GoRoute(
        path: '/admin',
        name: 'admin',
        builder: (context, state) => const AdminDashboardPage(),
      ),

      // AI Assistant Route
      GoRoute(
        path: '/ai-assistant',
        name: 'ai-assistant',
        builder: (context, state) => const AiAssistantPage(),
      ),

      // Inventory Management Route
      GoRoute(
        path: '/inventory',
        name: 'inventory',
        builder: (context, state) => const InventoryManagementPage(),
      ),

      // Warranty Management Route
      GoRoute(
        path: '/warranty',
        name: 'warranty',
        builder: (context, state) => const WarrantyManagementPage(),
      ),

      // Notifications Center Route
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) => const NotificationsCenterPage(),
      ),

      // Analytics Dashboard Route
      GoRoute(
        path: '/analytics',
        name: 'analytics',
        builder: (context, state) => const AnalyticsDashboardPage(),
      ),

      // Service History Route
      GoRoute(
        path: '/service-history',
        name: 'service-history',
        builder: (context, state) {
          final vehicleId = state.uri.queryParameters['vehicleId'];
          return ServiceHistoryPage(vehicleId: vehicleId ?? '');
        },
      ),
    ],

    // Error handling
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(
        title: const Text('خطأ'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'الصفحة غير موجودة',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              state.error.toString(),
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/dashboard'),
              child: const Text('العودة للرئيسية'),
            ),
          ],
        ),
      ),
    ),
  );

  // Navigation helper methods
  static void goToLogin() {
    router.go('/login');
  }

  static void goToDashboard() {
    router.go('/dashboard');
  }

  static void goToWorkOrders() {
    router.go('/work-orders');
  }

  static void goToCustomers() {
    router.go('/customers');
  }

  static void goToVehicles() {
    router.go('/vehicles');
  }

  static void goToChat() {
    router.go('/chat');
  }

  static void goToReports() {
    router.go('/reports');
  }

  static void goToSettings() {
    router.go('/settings');
  }

  static void goToInspections() {
    router.go('/inspections');
  }

  static void goToWorkOrderTasks() {
    router.go('/work-orders/tasks');
  }

  static void goToSupervisorDashboard() {
    router.go('/work-orders/supervisor');
  }

  static void goToDelivery() {
    router.go('/work-orders/delivery');
  }

  static void goToCreateQuote({
    required int inspectionId,
    required List<Map<String, dynamic>> inspectionServices,
    required Map<String, dynamic> customerInfo,
    required Map<String, dynamic> vehicleInfo,
  }) {
    router.go(
      '/quotes/create?inspectionId=$inspectionId',
      extra: {
        'inspectionServices': inspectionServices,
        'customerInfo': customerInfo,
        'vehicleInfo': vehicleInfo,
      },
    );
  }

  static void goToQuoteSignature({
    required int quoteId,
    required String quoteNumber,
    required double totalAmount,
    required List<Map<String, dynamic>> items,
  }) {
    router.go(
      '/quotes/sign?quoteId=$quoteId&quoteNumber=$quoteNumber&totalAmount=$totalAmount',
      extra: items,
    );
  }

  static void goToAiAssistant() {
    router.go('/ai-assistant');
  }

  static void goToInventory() {
    router.go('/inventory');
  }

  static void goToWarranty() {
    router.go('/warranty');
  }

  static void goToNotifications() {
    router.go('/notifications');
  }

  static void goToAnalytics() {
    router.go('/analytics');
  }

  static void goToServiceHistory({required String vehicleId}) {
    router.go('/service-history?vehicleId=$vehicleId');
  }

  static void goToCreateInspection() {
    router.go('/inspections/new');
  }

  static void goBack() {
    if (router.canPop()) {
      router.pop();
    }
  }
}
