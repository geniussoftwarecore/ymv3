class AppConstants {
  // App Information
  static const String appName = 'يمن هايبرد';
  static const String appNameEn = 'Yaman Hybrid';
  static const String appVersion = '1.0.0';
  
  // API Configuration
  static const String baseUrl = 'http://localhost:8000'; // Change to your backend URL
  static const String apiVersion = '/api/v1';
  
  // Microservices URLs
  static const String userManagementServiceUrl = 'http://localhost:8001/api/v1';
  static const String serviceCatalogServiceUrl = 'http://localhost:8002/api/v1';
  static const String workOrderManagementServiceUrl = 'http://localhost:8003/api/v1';
  static const String chatServiceUrl = 'http://localhost:8004/api/v1';
  static const String aiChatbotServiceUrl = 'http://localhost:8005/api/v1';
  static const String reportingServiceUrl = 'http://localhost:8006/api/v1';
  
  // WebSocket URLs
    static const String chatWebSocketUrl = 'ws://localhost:8004/api/v1/chat/ws';
  
  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String languageKey = 'app_language';
  static const String themeKey = 'app_theme';
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);
  
  // File Upload
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'gif'];
  static const List<String> allowedDocumentTypes = ['pdf', 'doc', 'docx', 'txt'];
}
