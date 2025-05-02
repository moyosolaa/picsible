import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<bool> requestPermission(BuildContext context, ImageSource source) async {
    Permission permission = source == ImageSource.camera ? Permission.camera : Permission.storage;

    PermissionStatus status = await permission.status;
    if (status.isDenied) {
      status = await permission.request();
    }

    if (status.isPermanentlyDenied) {
      if (context.mounted) {
        await showCupertinoDialog(
          context: context,
          builder:
              (BuildContext context) => CupertinoAlertDialog(
                title: const Text('Permission Required'),
                content: Text(
                  'Please enable ${source == ImageSource.camera ? "Camera" : "Storage"} access in app settings to continue.',
                ),
                actions: <Widget>[
                  CupertinoDialogAction(child: const Text('Cancel'), onPressed: () => Navigator.of(context).pop()),
                  CupertinoDialogAction(
                    child: const Text('Open Settings'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      openAppSettings();
                    },
                  ),
                ],
              ),
        );
      }
      return false;
    }

    if (!status.isGranted) {
      if (context.mounted) {
        await showCupertinoDialog(
          context: context,
          builder:
              (BuildContext context) => CupertinoAlertDialog(
                title: const Text('Permission Denied'),
                content: Text(
                  '${source == ImageSource.camera ? "Camera" : "Storage"} permission is required to continue.',
                ),
                actions: <Widget>[
                  CupertinoDialogAction(
                    child: const Text('OK'),
                    onPressed: () async {
                      await permission.request();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
        );
      }
      return false;
    }

    return true;
  }
}
