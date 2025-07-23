class DashboardSummaryResponse {
  final String countGFI;
  final String countReached;
  final String target;

  DashboardSummaryResponse({
    required this.countGFI,
    required this.countReached,
    required this.target,
  });

  // Factory constructor to create from JSON
  factory DashboardSummaryResponse.fromJson(Map<String, dynamic> json) {
    return DashboardSummaryResponse(
      countGFI: json['countGFI'] as String? ?? '0',
      countReached: json['countReached'] as String? ?? '0',
      target: json['target'] as String? ?? '0',
    );
  }

  // To JSON (if needed)
  Map<String, dynamic> toJson() {
    return {
      'countGFI': countGFI,
      'countReached': countReached,
      'target': target,
    };
  }
}
