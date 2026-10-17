enum AlertSeverity {
  info,
  success,
  warning,
  danger;

  static AlertSeverity fromString(String val) {
    switch (val.toUpperCase()) {
      case 'SUCCESS':
        return AlertSeverity.success;
      case 'WARNING':
        return AlertSeverity.warning;
      case 'DANGER':
        return AlertSeverity.danger;
      default:
        return AlertSeverity.info;
    }
  }
}

enum AlertType {
  nvScore,
  portfolioRisk,
  priceAlert,
  newsCatalyst,
  system;

  static AlertType fromString(String val) {
    switch (val.toUpperCase()) {
      case 'NV_SCORE':
        return AlertType.nvScore;
      case 'PORTFOLIO_RISK':
        return AlertType.portfolioRisk;
      case 'PRICE_ALERT':
        return AlertType.priceAlert;
      case 'NEWS_CATALYST':
        return AlertType.newsCatalyst;
      default:
        return AlertType.system;
    }
  }
}

class UserAlert {
  final String id;
  final String title;
  final String message;
  final AlertType type;
  final AlertSeverity severity;
  final String? symbol;
  final bool isRead;
  final DateTime createdAt;

  const UserAlert({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.severity,
    this.symbol,
    required this.isRead,
    required this.createdAt,
  });

  factory UserAlert.fromJson(Map<String, dynamic> json) {
    return UserAlert(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Alert',
      message: json['message']?.toString() ?? '',
      type: AlertType.fromString(json['type']?.toString() ?? 'SYSTEM'),
      severity: AlertSeverity.fromString(json['severity']?.toString() ?? 'INFO'),
      symbol: json['symbol']?.toString(),
      isRead: json['is_read'] == true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  UserAlert copyWith({
    bool? isRead,
  }) {
    return UserAlert(
      id: id,
      title: title,
      message: message,
      type: type,
      severity: severity,
      symbol: symbol,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }
}
