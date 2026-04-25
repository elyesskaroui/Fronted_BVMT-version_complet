import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import '../pages/pdf_viewer_page.dart';

/// Service de téléchargement de PDF avec progression et ouverture
class PdfDownloadService {
  // Backend proxy URL pour télécharger les PDFs via le serveur
  static const String _backendBase = 'http://localhost:3000';
  
  static Dio? _dio;

  static Dio get _client {
    if (_dio == null) {
      _dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 60),
      ));
    }
    return _dio!;
  }

  /// Construit l'URL proxy : le backend télécharge le PDF depuis BVMT et le stream
  static String _proxyUrl(String originalUrl) {
    return '$_backendBase/api/publications/proxy-pdf?url=${Uri.encodeComponent(originalUrl)}';
  }

  /// Télécharge un PDF et l'ouvre
  static Future<void> downloadAndOpen(
    String url,
    BuildContext context,
  ) async {
    final fileName = _extractFileName(url);

    // Utiliser le cache interne de l'app (pas besoin de permission)
    final dir = await getApplicationCacheDirectory();
    final bvmtDir = Directory('${dir.path}/bvmt_pdfs');
    if (!bvmtDir.existsSync()) {
      bvmtDir.createSync(recursive: true);
    }
    final filePath = '${bvmtDir.path}/$fileName';

    // Si déjà téléchargé, ouvrir directement
    if (File(filePath).existsSync()) {
      if (!context.mounted) return;
      _showSuccessAndOpen(filePath, fileName, context);
      return;
    }

    if (!context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    final progressNotifier = ValueNotifier<double>(0);

    // Afficher la barre de progression
    messenger.showSnackBar(
      SnackBar(
        duration: const Duration(minutes: 5),
        backgroundColor: const Color(0xFF1A2332),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: _DownloadProgress(
          notifier: progressNotifier,
          fileName: fileName,
        ),
      ),
    );

    try {
      final proxyUrl = _proxyUrl(url);
      print('📥 [PDF] Downloading via proxy: $proxyUrl');
      print('📥 [PDF] Original: $url');
      print('📥 [PDF] To: $filePath');

      await _client.download(
        proxyUrl,
        filePath,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            progressNotifier.value = received / total;
          }
        },
      );

      final file = File(filePath);
      final fileSize = await file.length();
      print('📥 [PDF] Downloaded! Size: $fileSize bytes');

      if (fileSize < 100) {
        // Fichier trop petit = probablement une erreur
        await file.delete();
        throw Exception('Fichier PDF invalide ($fileSize bytes)');
      }

      messenger.hideCurrentSnackBar();
      if (!context.mounted) return;

      _showSuccessAndOpen(filePath, fileName, context);
    } catch (e) {
      print('❌ [PDF] Download error: $e');
      messenger.hideCurrentSnackBar();

      // Supprimer le fichier partiel
      try {
        final f = File(filePath);
        if (f.existsSync()) f.deleteSync();
      } catch (_) {}

      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 4),
          backgroundColor: Colors.red.shade800,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Row(
            children: [
              const Icon(Icons.error_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Erreur: ${e.toString().length > 60 ? '${e.toString().substring(0, 60)}...' : e}',
                  style: const TextStyle(color: Colors.white, fontSize: 11),
                  maxLines: 2,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  static void _showSuccessAndOpen(
      String filePath, String fileName, BuildContext context) {
    // Ouvrir directement dans le viewer intégré
    _openInAppViewer(filePath, fileName, context);
  }

  static void _openInAppViewer(
      String filePath, String fileName, BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PdfViewerPage(
          filePath: filePath,
          title: fileName,
        ),
      ),
    );
  }

  static String _extractFileName(String url) {
    try {
      final uri = Uri.parse(url);
      final segments = uri.pathSegments;
      if (segments.isNotEmpty) {
        return Uri.decodeComponent(segments.last);
      }
    } catch (_) {}
    return 'publication_${DateTime.now().millisecondsSinceEpoch}.pdf';
  }
}

/// Widget séparé pour la barre de progression (évite le problème ValueNotifier disposed)
class _DownloadProgress extends StatelessWidget {
  final ValueNotifier<double> notifier;
  final String fileName;

  const _DownloadProgress({required this.notifier, required this.fileName});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: notifier,
      builder: (_, progress, __) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.download_rounded,
                    color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    fileName,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: const TextStyle(
                      color: Color(0xFFFF8C00),
                      fontSize: 12,
                      fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white.withValues(alpha: 0.1),
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Color(0xFFFF8C00)),
                minHeight: 4,
              ),
            ),
          ],
        );
      },
    );
  }
}
