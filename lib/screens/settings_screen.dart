import 'package:chalk/models/workout_program.dart';
import 'package:chalk/screens/program_editor_screen.dart';
import 'package:chalk/services/import_export_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/workout_provider.dart';

class SettingsScreen extends StatefulWidget {
  // Change to StatefulWidget
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Move these here and remove 'static'
  final Set<String> _selectedProgramIds = {};
  bool _isSelectMode = false;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WorkoutProvider>(context);

    return Scaffold(
      appBar: AppBar(
        // Toggle title based on selection mode
        title: Text(
          _isSelectMode
              ? '${_selectedProgramIds.length} SELECTED'
              : 'MANAGE PROGRAMS',
        ),
        leading: _isSelectMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => setState(() {
                  _isSelectMode = false;
                  _selectedProgramIds.clear();
                }),
              )
            : null,
        actions: [
          if (_isSelectMode)
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () {
                final toExport = provider.programs
                    .where((p) => _selectedProgramIds.contains(p.id))
                    .toList();
                ImportExportService.exportMultiplePrograms(toExport);
                setState(() {
                  _isSelectMode = false;
                  _selectedProgramIds.clear();
                });
              },
            )
          else // Show the Import button when NOT in selection mode
            IconButton(
              icon: const Icon(Icons.file_download_outlined),
              onPressed: () async {
                final String? errorMessage =
                    await ImportExportService.importPrograms(provider);

                if (!mounted) return;

                if (errorMessage != null) {
                  // ERROR SNACKBAR
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        errorMessage,
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.redAccent,
                      behavior: SnackBarBehavior.floating,
                      margin: const EdgeInsets.all(20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  );
                } else {
                  // SUCCESS SNACKBAR
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('IMPORT COMPLETE'),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                      margin: const EdgeInsets.all(20),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        child: const Icon(Icons.add, color: Colors.black),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProgramEditorScreen()),
        ),
      ),
      body: ListView.builder(
        itemCount: provider.programs.length,
        itemBuilder: (context, index) {
          final program = provider.programs[index];
          final isSelected = _selectedProgramIds.contains(program.id);

          return ListTile(
            // Show Checkbox if in select mode
            leading: _isSelectMode
                ? Checkbox(
                    value: isSelected,
                    activeColor: Colors.white,
                    checkColor: Colors.black,
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          _selectedProgramIds.add(program.id);
                        } else {
                          _selectedProgramIds.remove(program.id);
                        }
                      });
                    },
                  )
                : null,
            title: Text(program.name.toUpperCase()),
            subtitle: Text('${program.exercises.length} EXERCISES'),
            onLongPress: () {
              if (!_isSelectMode) {
                setState(() {
                  _isSelectMode = true;
                  _selectedProgramIds.add(program.id);
                });
              }
            },
            onTap: () {
              if (_isSelectMode) {
                setState(() {
                  if (isSelected) {
                    _selectedProgramIds.remove(program.id);
                  } else {
                    _selectedProgramIds.add(program.id);
                  }
                });
              }
            },
            trailing: _isSelectMode
                ? null // Hide regular actions during selection
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_note, color: Colors.grey),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ProgramEditorScreen(program: program),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.share,
                          color: Colors.grey,
                          size: 18,
                        ),
                        onPressed: () =>
                            ImportExportService.exportProgram(program),
                      ),
                      IconButton(
                        onPressed: () =>
                            _showDeleteDialog(context, provider, program),
                        icon: const Icon(Icons.close, color: Colors.red),
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    WorkoutProvider provider,
    Program program,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text(
          'DELETE ${program.name.toUpperCase()}?',
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () {
              provider.deleteProgram(program.id);
              Navigator.pop(ctx);
            },
            child: const Text('DELETE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
