enum BookingStatus {
  pending,
  confirmed,
  inProgress,
  completed,
  cancelled,
}

extension BookingStatusX on BookingStatus {
  String get label {
    switch (this) {
      case BookingStatus.pending: return 'Pending';
      case BookingStatus.confirmed: return 'Confirmed';
      case BookingStatus.inProgress: return 'In Progress';
      case BookingStatus.completed: return 'Completed';
      case BookingStatus.cancelled: return 'Cancelled';
    }
  }
}

class BookingModel {
  final String id;
  final String serviceType;
  final String description;
  final String customerName;
  final String customerPhone;
  final String location;
  final DateTime scheduledAt;
  final BookingStatus status;
  final ProviderSummary? assignedProvider;
  final double? estimatedCost;
  final double? finalCost;
  final String? originalRequest;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const BookingModel({
    required this.id,
    required this.serviceType,
    required this.description,
    required this.customerName,
    required this.customerPhone,
    required this.location,
    required this.scheduledAt,
    required this.status,
    this.assignedProvider,
    this.estimatedCost,
    this.finalCost,
    this.originalRequest,
    required this.createdAt,
    this.updatedAt,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) => BookingModel(
        id: json['id'] as String,
        serviceType: json['service_type'] as String,
        description: json['description'] as String,
        customerName: json['customer_name'] as String,
        customerPhone: json['customer_phone'] as String,
        location: json['location'] as String,
        scheduledAt: DateTime.parse(json['scheduled_at'] as String),
        status: BookingStatus.values.firstWhere(
          (s) => s.name.toLowerCase() == (json['status'] as String? ?? '').toLowerCase(),
          orElse: () => BookingStatus.pending,
        ),
        assignedProvider: json['assigned_provider'] != null
            ? ProviderSummary.fromJson(
                json['assigned_provider'] as Map<String, dynamic>)
            : null,
        estimatedCost: (json['estimated_cost'] as num?)?.toDouble(),
        finalCost: (json['final_cost'] as num?)?.toDouble(),
        originalRequest: json['original_request'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'service_type': serviceType,
        'description': description,
        'customer_name': customerName,
        'customer_phone': customerPhone,
        'location': location,
        'scheduled_at': scheduledAt.toIso8601String(),
        'status': status.name,
        'assigned_provider': assignedProvider?.toJson(),
        'estimated_cost': estimatedCost,
        'final_cost': finalCost,
        'original_request': originalRequest,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };

  BookingModel copyWith({
    String? id,
    String? serviceType,
    String? description,
    String? customerName,
    String? customerPhone,
    String? location,
    DateTime? scheduledAt,
    BookingStatus? status,
    ProviderSummary? assignedProvider,
    double? estimatedCost,
    double? finalCost,
    String? originalRequest,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      BookingModel(
        id: id ?? this.id,
        serviceType: serviceType ?? this.serviceType,
        description: description ?? this.description,
        customerName: customerName ?? this.customerName,
        customerPhone: customerPhone ?? this.customerPhone,
        location: location ?? this.location,
        scheduledAt: scheduledAt ?? this.scheduledAt,
        status: status ?? this.status,
        assignedProvider: assignedProvider ?? this.assignedProvider,
        estimatedCost: estimatedCost ?? this.estimatedCost,
        finalCost: finalCost ?? this.finalCost,
        originalRequest: originalRequest ?? this.originalRequest,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  // Mock data
  static List<BookingModel> get mockList => [
        BookingModel(
          id: 'BK-001',
          serviceType: 'AC Technician',
          description: 'AC service and gas refill required',
          customerName: 'Ahmed Khan',
          customerPhone: '+92 300 1234567',
          location: 'G-13, Islamabad',
          scheduledAt: DateTime.now().add(const Duration(hours: 3)),
          status: BookingStatus.confirmed,
          assignedProvider: ProviderSummary.mock,
          estimatedCost: 3500,
          originalRequest: 'Mujhe kal subah G-13 mein AC technician chahiye',
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        ),
        BookingModel(
          id: 'BK-002',
          serviceType: 'Plumber',
          description: 'Kitchen tap leaking fix',
          customerName: 'Ahmed Khan',
          customerPhone: '+92 300 1234567',
          location: 'F-10, Islamabad',
          scheduledAt: DateTime.now().subtract(const Duration(days: 2)),
          status: BookingStatus.completed,
          estimatedCost: 1500,
          finalCost: 1800,
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
        BookingModel(
          id: 'BK-003',
          serviceType: 'Electrician',
          description: 'Wiring issue in bedroom',
          customerName: 'Ahmed Khan',
          customerPhone: '+92 300 1234567',
          location: 'G-13, Islamabad',
          scheduledAt: DateTime.now().add(const Duration(days: 1)),
          status: BookingStatus.pending,
          estimatedCost: 2000,
          createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
        ),
      ];
}

class ProviderSummary {
  final String id;
  final String name;
  final String phone;
  final String serviceType;
  final double rating;
  final int totalJobs;
  final String? avatarUrl;

  const ProviderSummary({
    required this.id,
    required this.name,
    required this.phone,
    required this.serviceType,
    required this.rating,
    required this.totalJobs,
    this.avatarUrl,
  });

  factory ProviderSummary.fromJson(Map<String, dynamic> json) => ProviderSummary(
        id: json['id'] as String,
        name: json['name'] as String,
        phone: json['phone'] as String,
        serviceType: json['service_type'] as String,
        rating: (json['rating'] as num).toDouble(),
        totalJobs: json['total_jobs'] as int,
        avatarUrl: json['avatar_url'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'service_type': serviceType,
        'rating': rating,
        'total_jobs': totalJobs,
        'avatar_url': avatarUrl,
      };

  static ProviderSummary get mock => const ProviderSummary(
        id: 'prv_001',
        name: 'Ustad Hamid',
        phone: '+92 301 9876543',
        serviceType: 'AC Technician',
        rating: 4.8,
        totalJobs: 127,
      );
}
