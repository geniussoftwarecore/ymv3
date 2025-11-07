class APIConstants {
  static const String baseUrl = 'http://localhost';
  static const String apiGateway = '$baseUrl:80/api/v1';

  static const String userManagementServiceUrl = '$baseUrl:8001/api/v1';
  static const String serviceCatalogServiceUrl = '$baseUrl:8002/api/v1';
  static const String workOrderManagementServiceUrl = '$baseUrl:8003/api/v1';
  static const String chatServiceUrl = '$baseUrl:8004/api/v1';
  static const String aiChatbotServiceUrl = '$baseUrl:8005/api/v1';
  static const String reportingServiceUrl = '$baseUrl:8006/api/v1';

  static const String databaseUrl = '$baseUrl:5433';

  static const String connectTimeout = '30000';
  static const String receiveTimeout = '30000';
}

class APIEndpoints {
  static const String userManagement = '/users';
  static const String login = '$userManagement/login';
  static const String logout = '$userManagement/logout';
  static const String profile = '$userManagement/profile';
  static const String roles = '$userManagement/roles';
  static const String permissions = '$userManagement/permissions';

  static const String customers = '/customers';
  static const String vehicles = '/vehicles';
  static const String inspections = '/inspections';
  static const String workOrders = '/work-orders';
  static const String services = '/services';
  static const String quotes = '/quotes';
  static const String tasks = '/tasks';
  static const String chats = '/chats';
  static const String reports = '/reports';

  static const String inspectionInitial = '$inspections/initial';
  static const String inspectionDetails = '$inspections/{id}';
  static const String inspectionFaults = '$inspections/{id}/faults';
  static const String inspectionServices = '$inspections/{id}/services';

  static const String workOrderCreate = '$workOrders/create';
  static const String workOrderList = '$workOrders/list';
  static const String workOrderDetail = '$workOrders/{id}';
  static const String workOrderStatus = '$workOrders/{id}/status';
  static const String workOrderTasks = '$workOrders/{id}/tasks';

  static const String taskUpdate = '$tasks/{id}/update';
  static const String taskPhoto = '$tasks/{id}/photo';
  static const String taskComplete = '$tasks/{id}/complete';

  static const String quoteGenerate = '$quotes/generate';
  static const String quoteSend = '$quotes/{id}/send';
  static const String quoteApprove = '$quotes/{id}/approve';
  static const String quoteSignature = '$quotes/{id}/signature';

  static const String supervisorInspect = '/supervisor/inspect';
  static const String supervisorApprove = '/supervisor/approve/{id}';
  static const String supervisorReject = '/supervisor/reject/{id}';

  static const String deliveryReady = '$workOrders/{id}/ready-delivery';
  static const String deliveryComplete = '$workOrders/{id}/complete-delivery';

  static const String chatMessages = '$chats/{id}/messages';
  static const String chatSend = '$chats/{id}/send';

  static const String analyticsVehicles = '$reports/vehicles';
  static const String analyticsRevenue = '$reports/revenue';
  static const String analyticsEngineer = '$reports/engineer-performance';
  static const String analyticsReturnRate = '$reports/return-rate';

  static const String aiChatbotAsk = '/ai/ask';
  static const String aiChatbotContext = '/ai/context';
}
