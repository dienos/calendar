import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

enum PermissionResult { granted, denied, permanentlyDenied }

class PermissionHelper {
  static Future<bool> openSettings() async {
    return await openAppSettings();
  }

  static Future<PermissionResult> requestPhotoPermission() async {
    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      if (sdkInt >= 33) {
        return _requestAndroidPhotoPermission();
      }
    }
    // iOS 및 Android 12 이하 처리는 기존 로직 유지 (필요 시 sdkInt 전달 가능)
    if (Platform.isAndroid) return _requestAndroidPhotoPermission();
    return _requestIOSPhotoPermission();
  }

  static Future<PermissionResult> requestStoragePermission() async {
    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      // Android 11 (API 30) 이상은 Scoped Storage가 적용되어
      // SAF(Storage Access Framework)를 통한 파일 접근 시 별도의 전역 저장소 권한이 불필요합니다.
      if (sdkInt >= 30) {
        return PermissionResult.granted;
      }
      return _requestAndroidStoragePermission();
    }
    return PermissionResult.granted;
  }

  static Future<PermissionResult> _requestAndroidStoragePermission() async {
    final status = await Permission.storage.request();
    if (status.isGranted) return PermissionResult.granted;
    if (status.isPermanentlyDenied) return PermissionResult.permanentlyDenied;
    return PermissionResult.denied;
  }

  static Future<PermissionResult> _requestAndroidPhotoPermission() async {
    // 1. 사진 권한 요청 (Android 13+)
    var status = await Permission.photos.request();
    if (status.isGranted || status.isLimited) return PermissionResult.granted;
    if (status.isPermanentlyDenied) return PermissionResult.permanentlyDenied;

    // 2. 실패 시 저장소 권한으로 시도 (Android 12 이하 대응)
    status = await Permission.storage.request();
    if (status.isGranted) return PermissionResult.granted;
    if (status.isPermanentlyDenied) return PermissionResult.permanentlyDenied;

    return PermissionResult.denied;
  }

  static Future<PermissionResult> _requestIOSPhotoPermission() async {
    final status = await Permission.photos.request();
    if (status.isGranted || status.isLimited) return PermissionResult.granted;
    if (status.isPermanentlyDenied) return PermissionResult.permanentlyDenied;
    return PermissionResult.denied;
  }
}
