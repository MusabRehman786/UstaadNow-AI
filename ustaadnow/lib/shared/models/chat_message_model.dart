enum MessageRole { user, ai }

class ChatMessageModel {
  final String id;
  final String content;
  final MessageRole role;
  final DateTime timestamp;
  final bool isLoading;
  final String? audioPath;
  final Map<String, dynamic>? metadata;

  const ChatMessageModel({
    required this.id,
    required this.content,
    required this.role,
    required this.timestamp,
    this.isLoading = false,
    this.audioPath,
    this.metadata,
  });

  bool get isUser => role == MessageRole.user;
  bool get isAI => role == MessageRole.ai;

  factory ChatMessageModel.userMessage({
    required String id,
    required String content,
    String? audioPath,
  }) =>
      ChatMessageModel(
        id: id,
        content: content,
        role: MessageRole.user,
        timestamp: DateTime.now(),
        audioPath: audioPath,
      );

  factory ChatMessageModel.aiMessage({
    required String id,
    required String content,
    Map<String, dynamic>? metadata,
  }) =>
      ChatMessageModel(
        id: id,
        content: content,
        role: MessageRole.ai,
        timestamp: DateTime.now(),
        metadata: metadata,
      );

  factory ChatMessageModel.loadingMessage() => ChatMessageModel(
        id: 'loading',
        content: '',
        role: MessageRole.ai,
        timestamp: DateTime.now(),
        isLoading: true,
      );

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) =>
      ChatMessageModel(
        id: json['id'] as String,
        content: json['content'] as String,
        role: MessageRole.values.firstWhere(
          (r) => r.name == json['role'],
          orElse: () => MessageRole.ai,
        ),
        timestamp: DateTime.parse(json['timestamp'] as String),
        isLoading: json['is_loading'] as bool? ?? false,
        audioPath: json['audio_path'] as String?,
        metadata: json['metadata'] as Map<String, dynamic>?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'content': content,
        'role': role.name,
        'timestamp': timestamp.toIso8601String(),
        'is_loading': isLoading,
        'audio_path': audioPath,
        'metadata': metadata,
      };

  ChatMessageModel copyWith({
    String? id,
    String? content,
    MessageRole? role,
    DateTime? timestamp,
    bool? isLoading,
    String? audioPath,
    Map<String, dynamic>? metadata,
  }) =>
      ChatMessageModel(
        id: id ?? this.id,
        content: content ?? this.content,
        role: role ?? this.role,
        timestamp: timestamp ?? this.timestamp,
        isLoading: isLoading ?? this.isLoading,
        audioPath: audioPath ?? this.audioPath,
        metadata: metadata ?? this.metadata,
      );
}
