import 'dart:io';
import 'package:dio/dio.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:install_plugin/install_plugin.dart';
import 'package:flutter/foundation.dart';
import '../core/constants/app_constants.dart';

/// Service untuk menangani OTA (Over-the-Air) update
class UpdateService {
  static const String _githubRepo = 'Fauzanscape12/taskflow-pro';
  static const String _githubApiUrl = 'https://api.github.com/repos/$_githubRepo/releases/latest';

  final Dio _dio = Dio();

  /// Model untuk release info dari GitHub
  class ReleaseInfo {
    final String version;
    final String? releaseNotes;
    final String? apkDownloadUrl;
    final bool isNewer;

    ReleaseInfo({
      required this.version,
      this.releaseNotes,
      this.apkDownloadUrl,
      required this.isNewer,
    });

    factory ReleaseInfo.fromJson(Map<String, dynamic> json, String currentVersion) {
      final tagName = json['tag_name'] as String? ?? 'v0.0.0';
      final version = tagName.startsWith('v') ? tagName.substring(1) : tagName;

      // Cari asset APK
      String? apkUrl;
      if (json['assets'] != null) {
        for (var asset in json['assets']) {
          if (asset['name'] != null && asset['name'].toString().endsWith('.apk')) {
            apkUrl = asset['browser_download_url'] as String?;
            break;
          }
        }
      }

      return ReleaseInfo(
        version: version,
        releaseNotes: json['body'] as String?,
        apkDownloadUrl: apkUrl,
        isNewer: _isNewerVersion(version, currentVersion),
      );
    }

    static bool _isNewerVersion(String latest, String current) {
      final latestParts = latest.split('.').map(int.parse).toList();
      final currentParts = current.split('.').map(int.parse).toList();

      for (int i = 0; i < 3; i++) {
        final latestPart = i < latestParts.length ? latestParts[i] : 0;
        final currentPart = i < currentParts.length ? currentParts[i] : 0;

        if (latestPart > currentPart) return true;
        if (latestPart < currentPart) return false;
      }

      return false;
    }
  }

  /// Cek update dari GitHub Releases
  Future<ReleaseInfo?> checkForUpdates() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      debugPrint('Checking for updates... Current version: $currentVersion');

      final response = await _dio.get(_githubApiUrl);
      final releaseInfo = ReleaseInfo.fromJson(response.data, currentVersion);

      debugPrint('Latest version: ${releaseInfo.version}, Is newer: ${releaseInfo.isNewer}');

      return releaseInfo;
    } catch (e) {
      debugPrint('Error checking for updates: $e');
      return null;
    }
  }

  /// Download APK dari URL
  Future<String?> downloadApk({
    required String url,
    required Function(int received, int total) onProgress,
  }) async {
    try {
      debugPrint('Downloading APK from: $url');

      // Get temporary directory
      final tempDir = await getTemporaryDirectory();
      final apkPath = '${tempDir.path}/taskflow_pro_update.apk';

      // Download file
      await _dio.download(
        url,
        apkPath,
        onReceiveProgress: onProgress,
      );

      debugPrint('APK downloaded to: $apkPath');

      // Verify file exists
      final file = File(apkPath);
      if (await file.exists()) {
        final fileSize = await file.length();
        debugPrint('APK file size: $fileSize bytes');
        return apkPath;
      }

      return null;
    } catch (e) {
      debugPrint('Error downloading APK: $e');
      return null;
    }
  }

  /// Install APK
  Future<bool> installApk(String apkPath) async {
    try {
      debugPrint('Installing APK: $apkPath');

      // Cek apakah file ada
      final file = File(apkPath);
      if (!await file.exists()) {
        debugPrint('APK file does not exist: $apkPath');
        return false;
      }

      // Install APK
      await InstallPlugin.installApk(apkPath, AppConstants.appName);

      debugPrint('APK installation initiated');
      return true;
    } catch (e) {
      debugPrint('Error installing APK: $e');
      return false;
    }
  }

  /// Download dan install update secara otomatis
  Future<bool> downloadAndInstallUpdate({
    required String apkUrl,
    required Function(String status, int progress) onProgress,
  }) async {
    try {
      // Download APK
      onProgress('Downloading update...', 0);

      String? apkPath = await downloadApk(
        url: apkUrl,
        onProgress: (received, total) {
          final progress = total > 0 ? ((received / total) * 100).round() : 0;
          onProgress('Downloading update...', progress);
        },
      );

      if (apkPath == null) {
        onProgress('Download failed', -1);
        return false;
      }

      onProgress('Installing update...', 100);

      // Install APK
      final success = await installApk(apkPath);

      if (success) {
        onProgress('Installing update...', 100);
        return true;
      } else {
        onProgress('Installation failed', -1);
        return false;
      }
    } catch (e) {
      debugPrint('Error in downloadAndInstallUpdate: $e');
      onProgress('Update failed', -1);
      return false;
    }
  }
}
