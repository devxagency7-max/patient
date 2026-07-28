abstract class TelemetryRemoteDataSource {
  Future<void> sendTelemetry({required String feature, String? details});
}
