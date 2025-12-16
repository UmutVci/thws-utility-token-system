import 'package:permission_handler/permission_handler.dart';

class PaymentPermissionHelper {
  static Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }
}
