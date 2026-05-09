import 'dart:async';
import 'dart:io';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../providers/workout_provider.dart';
import 'import_export_service.dart';

class FileIntentService {
  static final _appLinks = AppLinks();
  static StreamSubscription<Uri>? _sub;

  // Must match the channel name in MainActivity.kt
  static const _channel = MethodChannel('com.chalkapp.chalk/file_reader');

  static String? _lastHandledUri;

  static Future<void> init(
    BuildContext context,
    WorkoutProvider provider,
  ) async {
    // 1. Handle the link that opened the app
    final initial = await _appLinks.getInitialLink();
    if (initial != null) {
      await _handleUri(initial, context, provider);
    }

    // 2. Handle subsequent links while app is open
    _sub = _appLinks.uriLinkStream.listen((uri) {
      _handleUri(uri, context, provider);
    });
  }

  static void dispose() {
    _sub?.cancel();
  }

  static Future<String> _readUri(Uri uri) async {
    try {
      if (uri.scheme == 'file') {
        return await File(uri.toFilePath()).readAsString();
      } else {
        final String? content = await _channel.invokeMethod<String>(
          'readContentUri',
          uri.toString(),
        );
        return content ?? '';
      }
    } catch (e) {
      debugPrint("Native Channel Error: $e");
      return '';
    }
  }

  static Future<void> _handleUri(
    Uri uri,
    BuildContext context,
    WorkoutProvider provider,
  ) async {
    // PREVENT DOUBLE IMPORT:
    // Check if we just processed this exact URI string
    if (_lastHandledUri == uri.toString()) return;
    _lastHandledUri = uri.toString();

    // Reset the guard after a short delay so the user can import the same
    // file again later if they actually intended to.
    Future.delayed(const Duration(seconds: 2), () => _lastHandledUri = null);

    try {
      final content = await _readUri(uri);
      if (content.isEmpty) return;

      final error = await ImportExportService.importProgramsFromContent(
        content,
        provider,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error == null
                  ? 'Workout imported successfully!'
                  : 'Import failed: $error',
            ),
            backgroundColor: error == null
                ? Colors.green[700]
                : Colors.red[700],
          ),
        );
      }
    } catch (e) {
      debugPrint("Handler Error: $e");
    }
  }
}
