class RecentItem {
  final String baseUrl;
  final DateTime lastOpenedAt;

  RecentItem({
    required this.baseUrl,
    required this.lastOpenedAt,
  });

  factory RecentItem.fromJson(Map<String, dynamic> json) {
    return RecentItem(
      baseUrl: json['baseUrl'] as String,
      lastOpenedAt: DateTime.parse(json['lastOpenedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'baseUrl': baseUrl,
      'lastOpenedAt': lastOpenedAt.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RecentItem && other.baseUrl == baseUrl;
  }

  @override
  int get hashCode => baseUrl.hashCode;
}
