class ProviderModel {
  final String id;
  final String name;
  final String phone;
  final String address;
  final List<String> serviceTypes;
  final double rating;
  final int totalJobs;
  final int completedJobs;
  final double totalEarnings;
  final bool isAvailable;
  final String? avatarUrl;
  final String? bio;
  final DateTime createdAt;

  const ProviderModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    required this.serviceTypes,
    required this.rating,
    required this.totalJobs,
    required this.completedJobs,
    required this.totalEarnings,
    required this.isAvailable,
    this.avatarUrl,
    this.bio,
    required this.createdAt,
  });

  factory ProviderModel.fromJson(Map<String, dynamic> json) => ProviderModel(
        id: json['id'] as String,
        name: json['name'] as String,
        phone: json['phone'] as String,
        address: json['address'] as String,
        serviceTypes: List<String>.from(json['service_types'] as List),
        rating: (json['rating'] as num).toDouble(),
        totalJobs: json['total_jobs'] as int,
        completedJobs: json['completed_jobs'] as int,
        totalEarnings: (json['total_earnings'] as num).toDouble(),
        isAvailable: json['is_available'] as bool,
        avatarUrl: json['avatar_url'] as String?,
        bio: json['bio'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'address': address,
        'service_types': serviceTypes,
        'rating': rating,
        'total_jobs': totalJobs,
        'completed_jobs': completedJobs,
        'total_earnings': totalEarnings,
        'is_available': isAvailable,
        'avatar_url': avatarUrl,
        'bio': bio,
        'created_at': createdAt.toIso8601String(),
      };

  ProviderModel copyWith({
    bool? isAvailable,
    double? totalEarnings,
    int? totalJobs,
    int? completedJobs,
  }) =>
      ProviderModel(
        id: id,
        name: name,
        phone: phone,
        address: address,
        serviceTypes: serviceTypes,
        rating: rating,
        totalJobs: totalJobs ?? this.totalJobs,
        completedJobs: completedJobs ?? this.completedJobs,
        totalEarnings: totalEarnings ?? this.totalEarnings,
        isAvailable: isAvailable ?? this.isAvailable,
        avatarUrl: avatarUrl,
        bio: bio,
        createdAt: createdAt,
      );

  static ProviderModel get mock => ProviderModel(
        id: 'prv_001',
        name: 'Ustad Hamid',
        phone: '+92 301 9876543',
        address: 'I-8, Islamabad',
        serviceTypes: ['AC Technician', 'Refrigerator Repair'],
        rating: 4.8,
        totalJobs: 127,
        completedJobs: 122,
        totalEarnings: 385000,
        isAvailable: true,
        bio: '10+ years experience in AC & cooling systems',
        createdAt: DateTime.now().subtract(const Duration(days: 365)),
      );
}
