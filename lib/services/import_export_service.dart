import 'dart:convert';
import 'dart:io';
import 'package:chalk/providers/workout_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import '../models/workout_program.dart';

class ImportExportService {
  static Future<void> exportProgram(Program program) async {
    final String jsonData = jsonEncode(program.toJson());
    final directory = await getTemporaryDirectory();
    final file = File(
      '${directory.path}/${program.name.replaceAll(' ', '_')}.chalk',
    );

    await file.writeAsString(jsonData);

    await Share.shareXFiles([
      XFile(file.path),
    ], text: 'Check out my ${program.name} workout!');
  }

  static Future<Program?> importProgram() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      String content = await file.readAsString();
      Map<String, dynamic> json = jsonDecode(content);
      return Program.fromJson(json);
    }
    return null;
  }

  static Future<void> exportMultiplePrograms(List<Program> programs) async {
    // Wrap the list in a Map so it's a valid JSON object
    final Map<String, dynamic> exportData = {
      'type': 'chalk_bulk_export',
      'programs': programs.map((p) => p.toJson()).toList(),
    };

    final String jsonData = jsonEncode(exportData);
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/Chalk_Backup.chalk');

    await file.writeAsString(jsonData);
    await Share.shareXFiles([
      XFile(file.path),
    ], text: 'My Chalk Program Backup');
  }

  static Future<String?> importPrograms(WorkoutProvider provider) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result == null) return null; // User canceled the picker

      File file = File(result.files.single.path!);
      String content = await file.readAsString();

      // Attempt to decode
      Map<String, dynamic> data;
      try {
        data = jsonDecode(content);
      } catch (e) {
        return "INVALID FILE FORMAT";
      }

      if (data.containsKey('type') && data['type'] == 'chalk_bulk_export') {
        List programsJson = data['programs'];
        for (var pJson in programsJson) {
          provider.addOrUpdateProgram(
            Program.fromJson(pJson).copyWith(
              id: 'import_${DateTime.now().millisecondsSinceEpoch}_${pJson['name']}',
            ),
          );
        }
      } else {
        provider.addOrUpdateProgram(
          Program.fromJson(data).copyWith(
            id: 'import_${DateTime.now().millisecondsSinceEpoch}_${data['name']}',
          ),
        );
      }

      return null; // Success
    } catch (e) {
      return "CORRUPTED OR INCOMPATIBLE FILE";
    }
  }

  static Future<String?> importProgramsFromContent(
    String content,
    WorkoutProvider provider,
  ) async {
    try {
      if (content.trim().isEmpty) return "FILE IS EMPTY";

      // Debug print to see what is actually coming in
      print("Importing Content: $content");

      final dynamic decoded = jsonDecode(content);

      // Ensure it's a Map
      if (decoded is! Map<String, dynamic>) {
        return "INVALID DATA STRUCTURE";
      }

      if (decoded.containsKey('type') &&
          decoded['type'] == 'chalk_bulk_export') {
        List programsJson = decoded['programs'];
        for (var pJson in programsJson) {
          provider.addOrUpdateProgram(
            Program.fromJson(pJson).copyWith(
              id: 'shared_${DateTime.now().millisecondsSinceEpoch}_${pJson['name']}',
            ),
          );
        }
      } else {
        provider.addOrUpdateProgram(
          Program.fromJson(decoded).copyWith(
            id: 'shared_${DateTime.now().millisecondsSinceEpoch}_${decoded['name']}',
          ),
        );
      }
      return null;
    } catch (e) {
      print("Import Error: $e"); // Check console for the specific error
      return "INVALID CHALK FILE: $e";
    }
  }
}
