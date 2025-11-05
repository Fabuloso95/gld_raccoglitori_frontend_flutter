class CookieConsentRequestModel
{
  final bool necessary;
  final bool analytics;
  final bool marketing;
  final bool preferences;
  final DateTime timestamp;
  final String version;
  final String ipAddress;
  final String userAgent;
  final DateTime createdAt;

  CookieConsentRequestModel({
    required this.necessary,
    required this.analytics,
    required this.marketing,
    required this.preferences,
    required this.timestamp,
    required this.version,
    required this.ipAddress,
    required this.userAgent,
    required this.createdAt,
  });

  Map<String, dynamic> toJson()
  {
    return 
    {
      'necessary': necessary,
      'analytics': analytics,
      'marketing': marketing,
      'preferences': preferences,
      'timestamp': timestamp,
      'version': version,
      'ipAddress': ipAddress,
      'userAgent': userAgent,
      'createdAt': createdAt,
    };
  }
}