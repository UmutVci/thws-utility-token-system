import 'package:permission_handler/permission_handler.dart';

class CameraPermissionResult {
  final bool granted;
  final bool permanentlyDenied;

  const CameraPermissionResult({
    required this.granted,
    required this.permanentlyDenied,
  });
}

class PaymentPermissionHelper {
  static Future<CameraPermissionResult> requestCameraPermission() async {
    final current = await Permission.camera.status;

    if (current.isGranted) {
      return const CameraPermissionResult(
        granted: true,
        permanentlyDenied: false,
      );
    }

    if (current.isPermanentlyDenied || current.isRestricted) {
      return const CameraPermissionResult(
        granted: false,
        permanentlyDenied: true,
      );
    }

    final requested = await Permission.camera.request();

    return CameraPermissionResult(
      granted: requested.isGranted,
      permanentlyDenied: requested.isPermanentlyDenied || requested.isRestricted,
    );
  }

  static Future<bool> openSettings() => openAppSettings();
}
