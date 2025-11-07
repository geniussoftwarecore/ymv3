import 'package:equatable/equatable.dart';

class QuoteModel extends Equatable {
  final int? id;
  final String? uuid;
  final String? quoteNumber;
  final int? inspectionId;
  final int? workOrderId;
  final int customerId;
  final double totalAmount;
  final String currency;
  final DateTime? validUntil;
  final String? notes;
  final String status;
  final DateTime? sentAt;
  final DateTime? acceptedAt;
  final DateTime? rejectedAt;
  final int createdBy;
  final int? acceptedBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const QuoteModel({
    this.id,
    this.uuid,
    this.quoteNumber,
    this.inspectionId,
    this.workOrderId,
    required this.customerId,
    required this.totalAmount,
    this.currency = 'YER',
    this.validUntil,
    this.notes,
    this.status = 'Draft',
    this.sentAt,
    this.acceptedAt,
    this.rejectedAt,
    required this.createdBy,
    this.acceptedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory QuoteModel.fromJson(Map<String, dynamic> json) {
    return QuoteModel(
      id: json['id'],
      uuid: json['uuid'],
      quoteNumber: json['quote_number'],
      inspectionId: json['inspection_id'],
      workOrderId: json['work_order_id'],
      customerId: json['customer_id'],
      totalAmount: json['total_amount']?.toDouble() ?? 0.0,
      currency: json['currency'] ?? 'YER',
      validUntil: json['valid_until'] != null
          ? DateTime.parse(json['valid_until'])
          : null,
      notes: json['notes'],
      status: json['status'] ?? 'Draft',
      sentAt: json['sent_at'] != null
          ? DateTime.parse(json['sent_at'])
          : null,
      acceptedAt: json['accepted_at'] != null
          ? DateTime.parse(json['accepted_at'])
          : null,
      rejectedAt: json['rejected_at'] != null
          ? DateTime.parse(json['rejected_at'])
          : null,
      createdBy: json['created_by'],
      acceptedBy: json['accepted_by'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'quote_number': quoteNumber,
      'inspection_id': inspectionId,
      'work_order_id': workOrderId,
      'customer_id': customerId,
      'total_amount': totalAmount,
      'currency': currency,
      'valid_until': validUntil?.toIso8601String(),
      'notes': notes,
      'status': status,
      'sent_at': sentAt?.toIso8601String(),
      'accepted_at': acceptedAt?.toIso8601String(),
      'rejected_at': rejectedAt?.toIso8601String(),
      'created_by': createdBy,
      'accepted_by': acceptedBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  QuoteModel copyWith({
    int? id,
    String? uuid,
    String? quoteNumber,
    int? inspectionId,
    int? workOrderId,
    int? customerId,
    double? totalAmount,
    String? currency,
    DateTime? validUntil,
    String? notes,
    String? status,
    DateTime? sentAt,
    DateTime? acceptedAt,
    DateTime? rejectedAt,
    int? createdBy,
    int? acceptedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return QuoteModel(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      quoteNumber: quoteNumber ?? this.quoteNumber,
      inspectionId: inspectionId ?? this.inspectionId,
      workOrderId: workOrderId ?? this.workOrderId,
      customerId: customerId ?? this.customerId,
      totalAmount: totalAmount ?? this.totalAmount,
      currency: currency ?? this.currency,
      validUntil: validUntil ?? this.validUntil,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      sentAt: sentAt ?? this.sentAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      rejectedAt: rejectedAt ?? this.rejectedAt,
      createdBy: createdBy ?? this.createdBy,
      acceptedBy: acceptedBy ?? this.acceptedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        uuid,
        quoteNumber,
        inspectionId,
        workOrderId,
        customerId,
        totalAmount,
        currency,
        validUntil,
        notes,
        status,
        sentAt,
        acceptedAt,
        rejectedAt,
        createdBy,
        acceptedBy,
        createdAt,
        updatedAt,
      ];
}

class QuoteItemModel extends Equatable {
  final int? id;
  final int quoteId;
  final String serviceName;
  final String? description;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final int? estimatedDuration;
  final String? notes;
  final DateTime createdAt;

  const QuoteItemModel({
    this.id,
    required this.quoteId,
    required this.serviceName,
    this.description,
    this.quantity = 1,
    required this.unitPrice,
    required this.totalPrice,
    this.estimatedDuration,
    this.notes,
    required this.createdAt,
  });

  factory QuoteItemModel.fromJson(Map<String, dynamic> json) {
    return QuoteItemModel(
      id: json['id'],
      quoteId: json['quote_id'],
      serviceName: json['service_name'],
      description: json['description'],
      quantity: json['quantity'] ?? 1,
      unitPrice: json['unit_price']?.toDouble() ?? 0.0,
      totalPrice: json['total_price']?.toDouble() ?? 0.0,
      estimatedDuration: json['estimated_duration'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quote_id': quoteId,
      'service_name': serviceName,
      'description': description,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_price': totalPrice,
      'estimated_duration': estimatedDuration,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  QuoteItemModel copyWith({
    int? id,
    int? quoteId,
    String? serviceName,
    String? description,
    int? quantity,
    double? unitPrice,
    double? totalPrice,
    int? estimatedDuration,
    String? notes,
    DateTime? createdAt,
  }) {
    return QuoteItemModel(
      id: id ?? this.id,
      quoteId: quoteId ?? this.quoteId,
      serviceName: serviceName ?? this.serviceName,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        quoteId,
        serviceName,
        description,
        quantity,
        unitPrice,
        totalPrice,
        estimatedDuration,
        notes,
        createdAt,
      ];
}