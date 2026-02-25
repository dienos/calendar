import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

enum PermissionResult { granted, denied, permanentlyDenied }

class PermissionHelper {
  static Future<bool> openSettings() async {
    return await openAppSettings();
  }

  static Future<PermissionResult> requestPhotoPermission() async {
    if (Platform.isAndroid) {
      return _requestAndroidPhotoPermission();
    }
    return _requestIOSPhotoPermission();
  }

  static Future<PermissionResult> requestStoragePermission() async {
    if (Platform.isAndroid) {
      return _requestAndroidStoragePermission();
    }
    return PermissionResult.granted;
  }

  static Future<PermissionResult> _requestAndroidStoragePermission() async {
    final status = await Permission.storage.status;
    if (status.isGranted) return PermissionResult.granted;
    if (status.isPermanentlyDenied) return PermissionResult.permanentlyDenied;

    final result = await Permission.storage.request();
    if (result.isGranted) return PermissionResult.granted;
    if (result.isPermanentlyDenied) return PermissionResult.permanentlyDenied;

    return PermissionResult.denied;
  }

  static Future<PermissionResult> _requestAndroidPhotoPermission() async {
    final status = await Permission.photos.status;
    if (status.isGranted || status.isLimited) {
      return PermissionResult.granted;
    }

    if (status.isPermanentlyDenied) {
      return PermissionResult.permanentlyDenied;
    }

    final result = await Permission.photos.request();
    if (result.isGranted || result.isLimited) {
      return PermissionResult.granted;
    }

    if (result.isPermanentlyDenied) {
      return PermissionResult.permanentlyDenied;
    }

    final storageStatus = await Permission.storage.status;
    if (storageStatus.isGranted) {
      return PermissionResult.granted;
    }

    if (storageStatus.isPermanentlyDenied) {
      return PermissionResult.permanentlyDenied;
    }

    final storageResult = await Permission.storage.request();
    if (storageResult.isGranted) {
      return PermissionResult.granted;
    }

    if (storageResult.isPermanentlyDenied) {
      return PermissionResult.permanentlyDenied;
    }

    return PermissionResult.denied;
  }

  static Future<PermissionResult> _requestIOSPhotoPermission() async {
    final status = await Permission.photos.status;
    if (status.isGranted || status.isLimited) {
      return PermissionResult.granted;
    }

    if (status.isPermanentlyDenied) {
      return PermissionResult.permanentlyDenied;
    }

    final result = await Permission.photos.request();
    if (result.isGranted || result.isLimited) {
      return PermissionResult.granted;
    }

    if (result.isPermanentlyDenied) {
      return PermissionResult.permanentlyDenied;
    }

    return PermissionResult.denied;
  }
}
