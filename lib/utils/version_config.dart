class VersionConfig {
  static const String appVersion = '1.0.0';
  static const int buildNumber = 1;

  // Semantic versioning: MAJOR.MINOR.PATCH
  // MAJOR: Breaking changes
  // MINOR: New features (backwards compatible)
  // PATCH: Bug fixes

  static String get fullVersion => '$appVersion+$buildNumber';
}
