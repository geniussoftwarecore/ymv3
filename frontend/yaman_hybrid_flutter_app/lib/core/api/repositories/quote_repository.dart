import 'package:dio/dio.dart';
import '../api_constants.dart';

class QuoteItemModel {
  final String serviceName;
  final String? description;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final int? estimatedDuration;
  final String? notes;

  QuoteItemModel({
    required this.serviceName,
    this.description,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.estimatedDuration,
    this.notes,
  });

  factory QuoteItemModel.fromJson(Map<String, dynamic> json) {
    return QuoteItemModel(
      serviceName: json['service_name'] as String,
      description: json['description'] as String?,
      quantity: json['quantity'] as int? ?? 1,
      unitPrice: (json['unit_price'] as num).toDouble(),
      totalPrice: (json['total_price'] as num).toDouble(),
      estimatedDuration: json['estimated_duration'] as int?,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'service_name': serviceName,
        'description': description,
        'quantity': quantity,
        'unit_price': unitPrice,
        'total_price': totalPrice,
        'estimated_duration': estimatedDuration,
        'notes': notes,
      };
}

class QuoteModel {
  final int id;
  final String uuid;
  final String quoteNumber;
  final int? inspectionId;
  final int? workOrderId;
  final int customerId;
  final List<QuoteItemModel> items;
  final double totalAmount;
  final String currency;
  final String status;
  final DateTime? validUntil;
  final DateTime? sentAt;
  final DateTime? acceptedAt;
  final DateTime? rejectedAt;
  final String? notes;
  final int createdBy;
  final int? acceptedBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  QuoteModel({
    required this.id,
    required this.uuid,
    required this.quoteNumber,
    this.inspectionId,
    this.workOrderId,
    required this.customerId,
    required this.items,
    required this.totalAmount,
    required this.currency,
    required this.status,
    this.validUntil,
    this.sentAt,
    this.acceptedAt,
    this.rejectedAt,
    this.notes,
    required this.createdBy,
    this.acceptedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory QuoteModel.fromJson(Map<String, dynamic> json) {
    return QuoteModel(
      id: json['id'] as int,
      uuid: json['uuid'] as String,
      quoteNumber: json['quote_number'] as String,
      inspectionId: json['inspection_id'] as int?,
      workOrderId: json['work_order_id'] as int?,
      customerId: json['customer_id'] as int,
      items: (json['items'] as List<dynamic>? ?? [])
          .map((item) => QuoteItemModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      totalAmount: (json['total_amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'YER',
      status: json['status'] as String,
      validUntil: json['valid_until'] != null
          ? DateTime.parse(json['valid_until'] as String)
          : null,
      sentAt: json['sent_at'] != null
          ? DateTime.parse(json['sent_at'] as String)
          : null,
      acceptedAt: json['accepted_at'] != null
          ? DateTime.parse(json['accepted_at'] as String)
          : null,
      rejectedAt: json['rejected_at'] != null
          ? DateTime.parse(json['rejected_at'] as String)
          : null,
      notes: json['notes'] as String?,
      createdBy: json['created_by'] as int,
      acceptedBy: json['accepted_by'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}

class CreateQuoteRequest {
  final int? inspectionId;
  final int? workOrderId;
  final int customerId;
  final List<Map<String, dynamic>> items;
  final double totalAmount;
  final String currency;
  final DateTime? validUntil;
  final String? notes;
  final int createdBy;

  CreateQuoteRequest({
    this.inspectionId,
    this.workOrderId,
    required this.customerId,
    required this.items,
    required this.totalAmount,
    required this.currency,
    this.validUntil,
    this.notes,
    required this.createdBy,
  });

  Map<String, dynamic> toJson() => {
        'inspection_id': inspectionId,
        'work_order_id': workOrderId,
        'customer_id': customerId,
        'items': items,
        'total_amount': totalAmount,
        'currency': currency,
        'valid_until': validUntil?.toIso8601String(),
        'notes': notes,
        'created_by': createdBy,
      };
}

class QuoteRepository {
  final Dio _dio;

  QuoteRepository(this._dio);

  Future<List<QuoteModel>> getQuotes({
    int? customerId,
    int? inspectionId,
    int? workOrderId,
    String? status,
    int skip = 0,
    int limit = 100,
  }) async {
    try {
      final params = {
        'skip': skip,
        'limit': limit,
        if (customerId != null) 'customer_id': customerId,
        if (inspectionId != null) 'inspection_id': inspectionId,
        if (workOrderId != null) 'work_order_id': workOrderId,
        if (status != null) 'status': status,
      };

      final response = await _dio.get(
        '${APIConstants.workOrderManagementServiceUrl}${APIEndpoints.quotes}',
        queryParameters: params,
      );

      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) => QuoteModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<QuoteModel> getQuote(int id) async {
    try {
      final response = await _dio.get(
        '${APIConstants.workOrderManagementServiceUrl}${APIEndpoints.quotes}/$id',
      );

      return QuoteModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<QuoteModel> createQuote(CreateQuoteRequest request) async {
    try {
      final response = await _dio.post(
        '${APIConstants.workOrderManagementServiceUrl}${APIEndpoints.quoteGenerate}',
        data: request.toJson(),
      );

      return QuoteModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> sendQuote(int quoteId) async {
    try {
      await _dio.post(
        '${APIConstants.workOrderManagementServiceUrl}${APIEndpoints.quoteSend.replaceFirst('{id}', quoteId.toString())}',
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> approveQuote(int quoteId, int approvedBy) async {
    try {
      await _dio.post(
        '${APIConstants.workOrderManagementServiceUrl}${APIEndpoints.quoteApprove.replaceFirst('{id}', quoteId.toString())}',
        data: {'approved_by': approvedBy},
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException e) {
    if (e.response?.statusCode == 404) {
      return 'العرض غير موجود';
    } else if (e.type == DioExceptionType.connectionTimeout) {
      return 'انتهت مهلة الاتصال';
    }
    return e.message ?? 'خطأ غير معروف';
  }
}
