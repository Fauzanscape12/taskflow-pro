import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_constants.dart';
import '../../services/update_service.dart';

/// Dialog untuk check dan download update
class UpdateCheckDialog extends StatefulWidget {
  const UpdateCheckDialog({super.key});

  @override
  State<UpdateCheckDialog> createState() => _UpdateCheckDialogState();
}

class _UpdateCheckDialogState extends State<UpdateCheckDialog> {
  final UpdateService _updateService = UpdateService();
  bool _isLoading = false;
  bool _hasUpdate = false;
  bool _isDownloading = false;
  UpdateService.ReleaseInfo? _releaseInfo;
  int _downloadProgress = 0;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkForUpdates();
  }

  Future<void> _checkForUpdates() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final releaseInfo = await _updateService.checkForUpdates();

    setState(() {
      _isLoading = false;
      _releaseInfo = releaseInfo;

      if (releaseInfo == null) {
        _errorMessage = 'Gagal mengecek update. Periksa koneksi internet.';
      } else if (releaseInfo.isNewer) {
        _hasUpdate = true;
      }
    });
  }

  Future<void> _downloadAndUpdate() async {
    if (_releaseInfo?.apkDownloadUrl == null) {
      setState(() {
        _errorMessage = 'Link download tidak tersedia.';
      });
      return;
    }

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0;
      _errorMessage = null;
    });

    HapticFeedback.mediumImpact();

    final success = await _updateService.downloadAndInstallUpdate(
      apkUrl: _releaseInfo!.apkDownloadUrl!,
      onProgress: (status, progress) {
        setState(() {
          _downloadProgress = progress;
        });
      },
    );

    if (!success) {
      setState(() {
        _errorMessage = 'Gagal menginstall update. Coba lagi.';
        _isDownloading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Row(
        children: [
          Icon(
            _isLoading ? Icons.sync : _hasUpdate ? Icons.system_update : Icons.check_circle,
            color: _isLoading
                ? AppConstants.primaryColor
                : _hasUpdate
                    ? AppConstants.primaryColor
                    : AppConstants.successColor,
          ),
          const SizedBox(width: 12),
          Text(
            _isLoading ? 'Mengecek Update...' : _hasUpdate ? 'Update Tersedia!' : 'Aplikasi Terkini',
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: _buildContent(),
      ),
      actions: _buildActions(),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 24),
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Mengecek versi terbaru...',
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    if (_errorMessage != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: AppConstants.errorColor,
          ),
          const SizedBox(height: 16),
          Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppConstants.errorColor,
            ),
          ),
        ],
      );
    }

    if (_isDownloading) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 24),
          CircularProgressIndicator(
            value: _downloadProgress > 0 ? _downloadProgress / 100 : null,
          ),
          const SizedBox(height: 16),
          Text(
            _downloadProgress > 0
                ? 'Downloading... $_downloadProgress%'
                : 'Preparing download...',
            textAlign: TextAlign.center,
          ),
          if (_downloadProgress == 100) ...[
            const SizedBox(height: 8),
            const Text(
              'Installing...',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ],
      );
    }

    if (_hasUpdate && _releaseInfo != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppConstants.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppConstants.primaryColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Versi Terbaru',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'v${_releaseInfo!.version}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_releaseInfo!.releaseNotes != null) ...[
            const SizedBox(height: 16),
            const Text(
              'Release Notes:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                ),
              ),
              child: Text(
                _releaseInfo!.releaseNotes!,
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ),
          ],
        ],
      );
    }

    // No update available
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.check_circle,
          size: 48,
          color: AppConstants.successColor,
        ),
        const SizedBox(height: 16),
        const Text(
          'Aplikasi sudah dalam versi terbaru!',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Versi saat ini: ${AppConstants.appVersion}',
          style: TextStyle(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildActions() {
    if (_isLoading || _isDownloading) {
      return [];
    }

    if (_errorMessage != null) {
      return [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Tutup'),
        ),
        ElevatedButton.icon(
          onPressed: _checkForUpdates,
          icon: const Icon(Icons.refresh),
          label: const Text('Coba Lagi'),
        ),
      ];
    }

    if (_hasUpdate) {
      return [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Nanti'),
        ),
        ElevatedButton.icon(
          onPressed: _downloadAndUpdate,
          icon: const Icon(Icons.download),
          label: const Text('Update Sekarang'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppConstants.primaryColor,
            foregroundColor: Colors.white,
          ),
        ),
      ];
    }

    return [
      ElevatedButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('OK'),
      ),
    ];
  }
}

/// Fungsi helper untuk menampilkan dialog check update
Future<void> showUpdateCheckDialog(BuildContext context) {
  return showDialog(
    context: context,
    builder: (context) => const UpdateCheckDialog(),
  );
}
