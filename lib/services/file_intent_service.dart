import 'dart:async';
import 'dart:io';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import '../providers/workout_provider.dart';
import 'import_export_service.dart';

class FileIntentService {
  static final _appLinks = AppLinks();
  static StreamSubscription<Uri>? _sub;

  static Future<void> init(BuildContext context, WorkoutProvider provider) async {
    // Cold start — app opened by tapping a .chalk file
    final initial = await _appLinks.getInitialLink();
    if (initial != null) {
      await _handleUri(initial, context, provider);
    }

    // Warm start — app already running, file opened
    _sub = _appLinks.uriLinkStream.listen((uri) {
      _handleUri(uri, context, provider);
    });
  }

  static void dispose() {
    _sub?.cancel();
  }

  static Future<void> _handleUri(
    Uri uri,
    BuildContext context,
    WorkoutProvider provider,
  ) async {
    try {
      final path = uri.toFilePath();
      if (!path.toLowerCase().endsWith('.chalk')) return;

      final content = await File(path).readAsString();
      final error = await ImportExportService.importProgramsFromContent(
        content,
        provider,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error == null
                ? 'Workout imported successfully!'
                : 'Import failed: $error'),
            backgroundColor: error == null ? Colors.green[700] : Colors.red[700],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not read .chalk file'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}