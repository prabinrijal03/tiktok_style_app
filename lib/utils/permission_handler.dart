import 'package:permission_handler/permission_handler.dart';

Future<bool> checkAndRequestStoragePermission() async {
  PermissionStatus status;

  if (await Permission.storage.isGranted) {
    return true;
  } else {
    status = await Permission.storage.request();
  }

  if (status.isDenied) {
    return false;
  } else if (status.isPermanentlyDenied) {
    await openAppSettings();
    return false;
  }

  return status.isGranted;
}
