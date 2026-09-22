class AppVersion {
  static const String version = '1.0.0';
  static const String releaseName = 'Release 1';
  static const String displayString = 'v1.0.0 Release';

  static String getDisplayVersion({required bool isArabic}) {
    return isArabic ? 'الإصدار 1.0.0 (Release 1)' : 'v1.0.0 (Release 1)';
  }
}
