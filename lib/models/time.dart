class Time {
  final int Id;
  final String DefinedTime;
  final String AccumulatedTime;
  final DateTime? StartedAt;
  final DateTime ServerNow;
  final bool GoalReached;

  Time({
    required this.Id,
    required this.DefinedTime,
    required this.AccumulatedTime,
    this.StartedAt,
    required this.ServerNow,
    this.GoalReached = false,
  });

  Duration get definedDuration => _parseHms(DefinedTime);
  Duration get accumulatedDuration => _parseHms(AccumulatedTime);

  factory Time.fromJson(Map<String, dynamic> json) {
    final startedAt = json['startedAt'];
    return Time(
      Id: json['id'] ?? 0,
      DefinedTime: json['definedTime'] ?? '',
      AccumulatedTime: json['accumulatedTime'] ?? '',
      StartedAt: (startedAt is String && startedAt.isNotEmpty)
          ? DateTime.tryParse(startedAt)
          : null,
      ServerNow: DateTime.tryParse(json['serverNow'] ?? '') ?? DateTime.now(),
      GoalReached: json['goalReached'] ?? false,
    );
  }

  static Duration _parseHms(String value) {
    final parts = value.split(':');
    if (parts.length >= 3) {
      return Duration(
        hours: int.tryParse(parts[0]) ?? 0,
        minutes: int.tryParse(parts[1]) ?? 0,
        seconds: int.tryParse(parts[2]) ?? 0,
      );
    }
    if (parts.length == 2) {
      return Duration(
        hours: int.tryParse(parts[0]) ?? 0,
        minutes: int.tryParse(parts[1]) ?? 0,
      );
    }
    return Duration.zero;
  }
}