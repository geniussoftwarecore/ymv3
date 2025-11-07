import 'package:dio/dio.dart';
import '../api_constants.dart';

class CustomerModel {
  final int id;
  final String uuid;
  final String name;
  final String email;
  final String phone;
  final String? address;
  final String? city;
  final String? country;
  final String? idNumber;
  final String? idType;
  final String? companyName;
  final String? companyTaxId;
  final String? website;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  CustomerModel({
    required this.id,
    required this.uuid,
    required this.name,
    required this.email,
    required this.phone,
    this.address,
    this.city,
    this.country,
    this.idNumber,
    this.idType,
    this.companyName,
    this.companyTaxId,
    this.website,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'] as int,
      uuid: json['uuid'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      address: json['address'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String?,
      idNumber: json['id_number'] as String?,
      idType: json['id_type'] as String?,
      companyName: json['company_name'] as String?,
      companyTaxId: json['company_tax_id'] as String?,
      website: json['website'] as String?,
      status: json['status'] as String? ?? 'active',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'uuid': uuid,
        'name': name,
        'email': email,
        'phone': phone,
        'address': address,
        'city': city,
        'country': country,
        'id_number': idNumber,
        'id_type': idType,
        'company_name': companyName,
        'company_tax_id': companyTaxId,
        'website': website,
        'status': status,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}

class CreateCustomerRequest {
  final String name;
  final String email;
  final String phone;
  final String? address;
  final String? city;
  final String? country;
  final String? idNumber;
  final String? idType;
  final String? companyName;
  final String? companyTaxId;
  final String? website;

  CreateCustomerRequest({
    required this.name,
    required this.email,
    required this.phone,
    this.address,
    this.city,
    this.country,
    this.idNumber,
    this.idType,
    this.companyName,
    this.companyTaxId,
    this.website,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'phone': phone,
        'address': address,
        'city': city,
        'country': country,
        'id_number': idNumber,
        'id_type': idType,
        'company_name': companyName,
        'company_tax_id': companyTaxId,
        'website': website,
      };
}

class CustomerRepository {
  final Dio _dio;

  CustomerRepository(this._dio);

  Future<List<CustomerModel>> getCustomers({
    String? searchQuery,
    String? status,
    int skip = 0,
    int limit = 100,
  }) async {
    try {
      final params = {
        'skip': skip,
        'limit': limit,
        if (searchQuery != null) 'search': searchQuery,
        if (status != null) 'status': status,
      };

      final response = await _dio.get(
        '${APIConstants.userManagementServiceUrl}${APIEndpoints.customers}',
        queryParameters: params,
      );

      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) => CustomerModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<CustomerModel> getCustomer(int id) async {
    try {
      final response = await _dio.get(
        '${APIConstants.userManagementServiceUrl}${APIEndpoints.customers}/$id',
      );

      return CustomerModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<CustomerModel> createCustomer(CreateCustomerRequest request) async {
    try {
      final response = await _dio.post(
        '${APIConstants.userManagementServiceUrl}${APIEndpoints.customers}',
        data: request.toJson(),
      );

      return CustomerModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<CustomerModel> updateCustomer(
      int id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put(
        '${APIConstants.userManagementServiceUrl}${APIEndpoints.customers}/$id',
        data: data,
      );

      return CustomerModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException e) {
    if (e.response?.statusCode == 404) {
      return 'العميل غير موجود';
    } else if (e.type == DioExceptionType.connectionTimeout) {
      return 'انتهت مهلة الاتصال';
    }
    return e.message ?? 'خطأ غير معروف';
  }
}
