class AccountSyncMetadata {
  const AccountSyncMetadata({
    this.networkConfigContent = '',
    this.configuredAt,
    this.lastProbeAt,
    this.lastSuccessfulSyncAt,
    this.pendingLocalChanges = false,
    this.lastError,
  });

  final String networkConfigContent;
  final DateTime? configuredAt;
  final DateTime? lastProbeAt;
  final DateTime? lastSuccessfulSyncAt;
  final bool pendingLocalChanges;
  final String? lastError;

  bool get isConfigured => networkConfigContent.trim().isNotEmpty;

  AccountSyncMetadata copyWith({
    String? networkConfigContent,
    Object? configuredAt = _preserve,
    Object? lastProbeAt = _preserve,
    Object? lastSuccessfulSyncAt = _preserve,
    bool? pendingLocalChanges,
    Object? lastError = _preserve,
  }) {
    return AccountSyncMetadata(
      networkConfigContent: networkConfigContent ?? this.networkConfigContent,
      configuredAt: configuredAt == _preserve
          ? this.configuredAt
          : configuredAt as DateTime?,
      lastProbeAt: lastProbeAt == _preserve
          ? this.lastProbeAt
          : lastProbeAt as DateTime?,
      lastSuccessfulSyncAt: lastSuccessfulSyncAt == _preserve
          ? this.lastSuccessfulSyncAt
          : lastSuccessfulSyncAt as DateTime?,
      pendingLocalChanges: pendingLocalChanges ?? this.pendingLocalChanges,
      lastError: lastError == _preserve ? this.lastError : lastError as String?,
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
        'networkConfigContent': networkConfigContent,
        if (configuredAt != null)
          'configuredAt': configuredAt!.toUtc().toIso8601String(),
        if (lastProbeAt != null)
          'lastProbeAt': lastProbeAt!.toUtc().toIso8601String(),
        if (lastSuccessfulSyncAt != null)
          'lastSuccessfulSyncAt':
              lastSuccessfulSyncAt!.toUtc().toIso8601String(),
        if (pendingLocalChanges) 'pendingLocalChanges': true,
        if (lastError != null) 'lastError': lastError,
      };

  static AccountSyncMetadata fromJson(Map<String, Object?> json) {
    return AccountSyncMetadata(
      networkConfigContent: json['networkConfigContent'] as String? ?? '',
      configuredAt: _parseDate(json['configuredAt']),
      lastProbeAt: _parseDate(json['lastProbeAt']),
      lastSuccessfulSyncAt: _parseDate(json['lastSuccessfulSyncAt']),
      pendingLocalChanges: json['pendingLocalChanges'] as bool? ?? false,
      lastError: json['lastError'] as String?,
    );
  }

  static DateTime? _parseDate(Object? value) {
    if (value is! String || value.isEmpty) return null;
    return DateTime.parse(value).toUtc();
  }
}

const Object _preserve = Object();
