class TraceLogModel {
  final String bookingId;
  final List<TraceStep> steps;
  final DateTime generatedAt;

  const TraceLogModel({
    required this.bookingId,
    required this.steps,
    required this.generatedAt,
  });

  factory TraceLogModel.fromJson(Map<String, dynamic> json) => TraceLogModel(
        bookingId: json['booking_id'] as String,
        steps: (json['steps'] as List)
            .map((s) => TraceStep.fromJson(s as Map<String, dynamic>))
            .toList(),
        generatedAt: DateTime.parse(json['generated_at'] as String),
      );
}

class TraceStep {
  final String agentName;
  final String action;
  final String result;
  final Duration duration;
  final bool success;
  final DateTime timestamp;

  const TraceStep({
    required this.agentName,
    required this.action,
    required this.result,
    required this.duration,
    required this.success,
    required this.timestamp,
  });

  factory TraceStep.fromJson(Map<String, dynamic> json) => TraceStep(
        agentName: json['agent_name'] as String,
        action: json['action'] as String,
        result: json['result'] as String,
        duration: Duration(milliseconds: json['duration_ms'] as int),
        success: json['success'] as bool,
        timestamp: DateTime.parse(json['timestamp'] as String),
      );

  static List<TraceStep> get mockSteps => [
        TraceStep(
          agentName: 'Intent Detector',
          action: 'Analyze user request',
          result: 'Service: AC Technician | Location: G-13 | Time: Tomorrow 9am',
          duration: const Duration(milliseconds: 320),
          success: true,
          timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        ),
        TraceStep(
          agentName: 'Provider Discovery',
          action: 'Find nearby providers',
          result: 'Found 8 AC technicians in G-13 area',
          duration: const Duration(milliseconds: 540),
          success: true,
          timestamp: DateTime.now().subtract(const Duration(minutes: 4, seconds: 55)),
        ),
        TraceStep(
          agentName: 'Provider Ranker',
          action: 'Rank by rating, availability, distance',
          result: 'Top provider: Ustad Hamid (4.8★, 2.3km away)',
          duration: const Duration(milliseconds: 210),
          success: true,
          timestamp: DateTime.now().subtract(const Duration(minutes: 4, seconds: 50)),
        ),
        TraceStep(
          agentName: 'Booking Agent',
          action: 'Create booking record',
          result: 'Booking BK-001 created successfully',
          duration: const Duration(milliseconds: 180),
          success: true,
          timestamp: DateTime.now().subtract(const Duration(minutes: 4, seconds: 45)),
        ),
      ];
}
