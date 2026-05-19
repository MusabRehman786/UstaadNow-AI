enum UserRole { customer, provider }

class UserModel {
  final String id;
  final String name;
  final String phone;
  final String address;
  final UserRole role;
  final String? avatarUrl;
  final bool isOnline;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    required this.role,
    this.avatarUrl,
    this.isOnline = true,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        name: json['name'] as String,
        phone: json['phone'] as String,
        address: json['address'] as String,
        role: UserRole.values.firstWhere(
          (r) => r.name == json['role'],
          orElse: () => UserRole.customer,
        ),
        avatarUrl: json['avatar_url'] as String?,
        isOnline: json['is_online'] as bool? ?? true,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'address': address,
        'role': role.name,
        'avatar_url': avatarUrl,
        'is_online': isOnline,
        'created_at': createdAt.toIso8601String(),
      };

  UserModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? address,
    UserRole? role,
    String? avatarUrl,
    bool? isOnline,
    DateTime? createdAt,
  }) =>
      UserModel(
        id: id ?? this.id,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        address: address ?? this.address,
        role: role ?? this.role,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        isOnline: isOnline ?? this.isOnline,
        createdAt: createdAt ?? this.createdAt,
      );

  /// Mock user for development
  static UserModel get mock => UserModel(
        id: 'usr_001',
        name: 'Ahmed Khan',
        phone: '+92 300 1234567',
        address: 'G-13, Islamabad',
        role: UserRole.customer,
        isOnline: true,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      );

  static UserModel get mockProvider => UserModel(
        id: 'prv_001',
        name: 'Ustad Hamid',
        phone: '+92 301 9876543',
        address: 'I-8, Islamabad',
        role: UserRole.provider,
        isOnline: true,
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
      );
}
