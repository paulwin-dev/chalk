import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/services.dart';
import '../models/workout_program.dart';
import '../providers/workout_provider.dart';

class ProgramEditorScreen extends StatefulWidget {
  final Program? program;

  const ProgramEditorScreen({super.key, this.program});

  @override
  State<ProgramEditorScreen> createState() => _ProgramEditorScreenState();
}

class _ProgramEditorScreenState extends State<ProgramEditorScreen> {
  late TextEditingController _nameController;
  late List<Exercise> _exercises;
  late List<int> _scheduledDays;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.program?.name ?? '');
    _exercises = widget.program != null
        ? List.from(widget.program!.exercises)
        : [];
    // Load existing days or start with an empty list
    _scheduledDays = widget.program != null
        ? List.from(widget.program!.scheduledDays)
        : [];
  }

  void _addNewExercise() {
    setState(() {
      _exercises.add(Exercise(name: 'New Exercise', imageUrl: ''));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.program == null ? 'NEW PROGRAM' : 'EDIT PROGRAM'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.white),
            onPressed: () {
              if (_nameController.text.isNotEmpty) {
                final newProgram = Program(
                  id: widget.program?.id ?? const Uuid().v4(),
                  name: _nameController.text,
                  exercises: _exercises,
                  scheduledDays:
                      _scheduledDays, // <--- Pass the local list here
                );
                context.read<WorkoutProvider>().addOrUpdateProgram(newProgram);
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'PROGRAM NAME',
                labelStyle: TextStyle(color: Colors.grey),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24),
                ),
              ),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            _buildDayPicker(),
            const SizedBox(height: 30),
            Expanded(
              child: ReorderableListView.builder(
                buildDefaultDragHandles: false,
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) {
                      newIndex -= 1;
                    }
                    final Exercise item = _exercises.removeAt(oldIndex);
                    _exercises.insert(newIndex, item);
                  });
                },
                itemCount: _exercises.length,
                itemBuilder: (context, index) {
                  final exercise = _exercises[index];
                  return _ExerciseEditTile(
                    key: ValueKey(exercise),
                    index: index,
                    exercise: exercise,
                    onDelete: () => setState(() => _exercises.removeAt(index)),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: _addNewExercise,
              icon: const Icon(Icons.add),
              label: const Text('ADD EXERCISE'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white24),
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayPicker() {
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'SCHEDULE',
          style: TextStyle(fontSize: 12, color: Colors.grey, letterSpacing: 2),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(7, (index) {
            final dayNum = index + 1;
            final isSelected = _scheduledDays.contains(dayNum);
            return GestureDetector(
              onTap: () {
                setState(() {
                  isSelected
                      ? _scheduledDays.remove(dayNum)
                      : _scheduledDays.add(dayNum);
                });
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  border: Border.all(color: Colors.white24),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    days[index],
                    style: TextStyle(
                      color: isSelected ? Colors.black : Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _ExerciseEditTile extends StatelessWidget {
  final Exercise exercise;
  final VoidCallback onDelete;
  final int index;

  const _ExerciseEditTile({super.key, required this.exercise, required this.onDelete, required this.index});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1A1A1A),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12.0).subtract(EdgeInsets.only(top: 12)),
        child: Column(
          children: [
            Row(
              children: [
                ReorderableDragStartListener(
                  index: index,
                  child: Listener(
                    onPointerDown: (_) {
                      HapticFeedback.lightImpact();
                    },
                    child: const Padding(
                      padding: EdgeInsets.fromLTRB(0, 12, 5, 12),
                      child: Icon(Icons.drag_indicator, color: Colors.white54),
                    ),
                  ),
                ),
                Expanded(
                  child: TextFormField(
                    initialValue: exercise.name,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Exercise Name',
                    ),
                    onChanged: (val) => exercise.name = val,
                  ),
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.close, color: Colors.red),
                ),
              ],
            ),
            Row(
              children: [
                _counterField(
                  'SETS',
                  exercise.sets.toDouble(),
                  (v) => exercise.sets = v as int,
                ),
                const SizedBox(width: 20),
                _counterField(
                  'REPS',
                  exercise.reps.toDouble(),
                  (v) => exercise.reps = v as int,
                ),
                const SizedBox(width: 10),
                _counterField(
                  'WEIGHT (kg/lb)',
                  exercise.weight,
                  (v) => exercise.weight = v.toDouble(),
                ),
                const SizedBox(width: 20),
                _counterField(
                  'REST(s)',
                  exercise.restSeconds.toDouble(),
                  (v) => exercise.restSeconds = v as int,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _counterField(String label, double initial, Function(num) onChanged) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          TextFormField(
            initialValue: initial.toString(),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (val) => onChanged(num.tryParse(val) ?? 0),
          ),
        ],
      ),
    );
  }
}
