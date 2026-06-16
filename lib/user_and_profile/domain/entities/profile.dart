class Profile {
  final int id;
  final String name;
  final int userId;
  final int savingPercentage;
  final bool allowMlAnalysis;
  final bool allowPushNotifications;
  final bool useBiometrics;

  const Profile({
    required this.id,
    required this.name,
    required this.userId,
    required this.savingPercentage,
    required this.allowMlAnalysis,
    required this.allowPushNotifications,
    required this.useBiometrics,
  });
}