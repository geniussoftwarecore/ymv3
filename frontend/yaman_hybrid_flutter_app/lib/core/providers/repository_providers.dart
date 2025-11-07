import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/repositories/user_repository.dart';
import '../api/repositories/work_order_repository.dart';
import '../api/repositories/inspection_repository.dart';
import '../api/repositories/quote_repository.dart';
import '../api/repositories/customer_repository.dart';

// Shared Preferences Provider
final sharedPreferencesProvider =
    FutureProvider<SharedPreferences>((ref) async {
  return SharedPreferences.getInstance();
});

// Dio Provider with Token Interceptor
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  // Add interceptor for token handling
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Get token from SharedPreferences synchronously if available
        try {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('access_token');
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
        } catch (e) {
          // Silently fail if SharedPreferences not available
        }
        return handler.next(options);
      },
      onError: (error, handler) {
        if (error.response?.statusCode == 401) {
          // Handle token refresh or logout
        }
        return handler.next(error);
      },
    ),
  );

  return dio;
});

// User Repository Provider
final userRepositoryProvider = FutureProvider<UserRepository>((ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  final dio = ref.watch(dioProvider);
  return UserRepository(dio, prefs);
});

// Work Order Repository Provider
final workOrderRepositoryProvider = Provider<WorkOrderRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return WorkOrderRepository(dio);
});

// Inspection Repository Provider
final inspectionRepositoryProvider = Provider<InspectionRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return InspectionRepository(dio);
});

// Quote Repository Provider
final quoteRepositoryProvider = Provider<QuoteRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return QuoteRepository(dio);
});

// Customer Repository Provider
final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return CustomerRepository(dio);
});

// Auth State Provider
class AuthState {
  final UserModel? user;
  final String? accessToken;
  final bool isLoading;
  final String? error;

  AuthState({
    this.user,
    this.accessToken,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    UserModel? user,
    String? accessToken,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      accessToken: accessToken ?? this.accessToken,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  bool get isAuthenticated => user != null && accessToken != null;
}

class AuthNotifier extends StateNotifier<AuthState> {
  final UserRepository _userRepository;

  AuthNotifier(this._userRepository) : super(AuthState()) {
    _initializeAuth();
  }

  void _initializeAuth() async {
    final token = _userRepository.getStoredToken();
    if (token != null) {
      state = state.copyWith(accessToken: token);
      try {
        final user = await _userRepository.getProfile();
        state = state.copyWith(user: user, accessToken: token);
      } catch (e) {
        state = state.copyWith(error: 'Failed to load profile');
      }
    }
  }

  Future<void> login(String username, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final tokenResponse = await _userRepository.login(username, password);
      state = AuthState(
        user: tokenResponse.user,
        accessToken: tokenResponse.accessToken,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> register(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final tokenResponse = await _userRepository.register(data);
      state = AuthState(
        user: tokenResponse.user,
        accessToken: tokenResponse.accessToken,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> logout() async {
    await _userRepository.logout();
    state = AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(userRepositoryProvider).asData?.value ??
      UserRepository(ref.watch(dioProvider),
          SharedPreferences.getInstance() as SharedPreferences));
});

// Work Orders State Management
class WorkOrdersState {
  final List<WorkOrderModel> workOrders;
  final bool isLoading;
  final String? error;
  final int totalCount;

  WorkOrdersState({
    this.workOrders = const [],
    this.isLoading = false,
    this.error,
    this.totalCount = 0,
  });

  WorkOrdersState copyWith({
    List<WorkOrderModel>? workOrders,
    bool? isLoading,
    String? error,
    int? totalCount,
  }) {
    return WorkOrdersState(
      workOrders: workOrders ?? this.workOrders,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      totalCount: totalCount ?? this.totalCount,
    );
  }
}

class WorkOrdersNotifier extends StateNotifier<WorkOrdersState> {
  final WorkOrderRepository _repository;

  WorkOrdersNotifier(this._repository) : super(WorkOrdersState());

  Future<void> fetchWorkOrders({
    String? status,
    int? customerId,
    int skip = 0,
    int limit = 100,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final workOrders = await _repository.getWorkOrders(
        status: status,
        customerId: customerId,
        skip: skip,
        limit: limit,
      );
      state = state.copyWith(
        workOrders: workOrders,
        isLoading: false,
        totalCount: workOrders.length,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<WorkOrderModel?> getWorkOrder(int id) async {
    try {
      return await _repository.getWorkOrderDetail(id);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  Future<void> createWorkOrder(CreateWorkOrderRequest request) async {
    try {
      final newOrder = await _repository.createWorkOrder(request);
      state = state.copyWith(
        workOrders: [...state.workOrders, newOrder],
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateWorkOrderStatus(int id, String newStatus) async {
    try {
      final updated = await _repository.updateWorkOrderStatus(id, newStatus);
      final index = state.workOrders.indexWhere((wo) => wo.id == id);
      if (index >= 0) {
        final updatedList = state.workOrders.toList()
          ..replaceRange(index, index + 1, [updated]);
        state = state.copyWith(workOrders: updatedList);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final workOrdersProvider =
    StateNotifierProvider<WorkOrdersNotifier, WorkOrdersState>((ref) {
  final repository = ref.watch(workOrderRepositoryProvider);
  return WorkOrdersNotifier(repository);
});

// Inspections State Management
class InspectionsState {
  final List<InspectionModel> inspections;
  final bool isLoading;
  final String? error;

  InspectionsState({
    this.inspections = const [],
    this.isLoading = false,
    this.error,
  });

  InspectionsState copyWith({
    List<InspectionModel>? inspections,
    bool? isLoading,
    String? error,
  }) {
    return InspectionsState(
      inspections: inspections ?? this.inspections,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class InspectionsNotifier extends StateNotifier<InspectionsState> {
  final InspectionRepository _repository;

  InspectionsNotifier(this._repository) : super(InspectionsState());

  Future<void> fetchInspections({
    int? customerId,
    String? status,
    int skip = 0,
    int limit = 100,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final inspections = await _repository.getInspections(
        customerId: customerId,
        status: status,
        skip: skip,
        limit: limit,
      );
      state = state.copyWith(inspections: inspections, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> createInspection(CreateInspectionRequest request) async {
    try {
      final inspection = await _repository.createInspection(request);
      state = state.copyWith(
        inspections: [...state.inspections, inspection],
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final inspectionsProvider =
    StateNotifierProvider<InspectionsNotifier, InspectionsState>((ref) {
  final repository = ref.watch(inspectionRepositoryProvider);
  return InspectionsNotifier(repository);
});

// Quotes State Management
class QuotesState {
  final List<QuoteModel> quotes;
  final bool isLoading;
  final String? error;

  QuotesState({
    this.quotes = const [],
    this.isLoading = false,
    this.error,
  });

  QuotesState copyWith({
    List<QuoteModel>? quotes,
    bool? isLoading,
    String? error,
  }) {
    return QuotesState(
      quotes: quotes ?? this.quotes,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class QuotesNotifier extends StateNotifier<QuotesState> {
  final QuoteRepository _repository;

  QuotesNotifier(this._repository) : super(QuotesState());

  Future<void> fetchQuotes({
    int? customerId,
    String? status,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final quotes =
          await _repository.getQuotes(customerId: customerId, status: status);
      state = state.copyWith(quotes: quotes, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> createQuote(CreateQuoteRequest request) async {
    try {
      final quote = await _repository.createQuote(request);
      state = state.copyWith(
        quotes: [...state.quotes, quote],
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final quotesProvider =
    StateNotifierProvider<QuotesNotifier, QuotesState>((ref) {
  final repository = ref.watch(quoteRepositoryProvider);
  return QuotesNotifier(repository);
});

// Customers State Management
class CustomersState {
  final List<CustomerModel> customers;
  final bool isLoading;
  final String? error;

  CustomersState({
    this.customers = const [],
    this.isLoading = false,
    this.error,
  });

  CustomersState copyWith({
    List<CustomerModel>? customers,
    bool? isLoading,
    String? error,
  }) {
    return CustomersState(
      customers: customers ?? this.customers,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class CustomersNotifier extends StateNotifier<CustomersState> {
  final CustomerRepository _repository;

  CustomersNotifier(this._repository) : super(CustomersState());

  Future<void> fetchCustomers({String? searchQuery}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final customers =
          await _repository.getCustomers(searchQuery: searchQuery);
      state = state.copyWith(customers: customers, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> createCustomer(CreateCustomerRequest request) async {
    try {
      final customer = await _repository.createCustomer(request);
      state = state.copyWith(
        customers: [...state.customers, customer],
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final customersProvider =
    StateNotifierProvider<CustomersNotifier, CustomersState>((ref) {
  final repository = ref.watch(customerRepositoryProvider);
  return CustomersNotifier(repository);
});
