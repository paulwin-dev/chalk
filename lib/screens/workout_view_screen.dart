import 'dart:async';
import 'package:chalk/screens/workout_summary_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/workout_program.dart';
import '../providers/workout_provider.dart';

class WorkoutViewScreen extends StatefulWidget {
  final Program program;
  const WorkoutViewScreen({super.key, required this.program});

  @override
  State<WorkoutViewScreen> createState() => _WorkoutViewScreenState();
}

class _WorkoutViewScreenState extends State<WorkoutViewScreen> {
  int _currentExerciseIndex = 0;

  // Rest timer
  Timer? _restTimer;
  int _secondsRemaining = 0;

  // Elapsed workout timer
  Timer? _elapsedTimer;
  int _elapsedSeconds = 0;

  DateTime? _startTime;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _startElapsedTimer();
  }

  void _startElapsedTimer() {
    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _elapsedSeconds++);
    });
  }

  String get _formattedElapsed {
    final h = _elapsedSeconds ~/ 3600;
    final m = (_elapsedSeconds % 3600) ~/ 60;
    final s = _elapsedSeconds % 60;
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _startRest(int seconds) {
    setState(() => _secondsRemaining = seconds);
    _restTimer?.cancel();
    _restTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        t.cancel();
        _showRestComplete();
      }
    });
  }

  void _showRestComplete() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Rest Over! Get to work.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// Opens a bottom sheet to edit the exercise. Controllers are owned by
  /// _ExerciseEditSheet (a StatefulWidget) and disposed only when that widget
  /// actually leaves the tree — not during the dismiss animation — which
  /// prevents the "TextEditingController used after dispose" assertion.
  void _openEditSheet(Exercise exercise) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _ExerciseEditSheet(
        exercise: exercise,
        program: widget.program,
        onSaved: () => setState(() {}),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final exercise = widget.program.exercises[_currentExerciseIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.timer_outlined, size: 14, color: Colors.white54),
                  const SizedBox(width: 6),
                  Text(
                    _formattedElapsed,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      fontFeatures: [FontFeature.tabularFigures()],
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '${_currentExerciseIndex + 1} / ${widget.program.exercises.length}',
              style: const TextStyle(fontSize: 14, color: Colors.white54),
            ),
          ],
        ),
        actions: [
          if (_secondsRemaining > 0)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Text(
                  'REST: ${_secondsRemaining}s',
                  style: const TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Top Exercise Preview
          Expanded(
            flex: 3,
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Icon(Icons.fitness_center, size: 80, color: Colors.white24),
              ),
            ),
          ),

          // Exercise Details
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Exercise name + edit icon
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          exercise.name.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _openEditSheet(exercise),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.edit_outlined,
                            size: 18,
                            color: Colors.white54,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${exercise.weight} KG',
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Sets list
                  Expanded(
                    child: ListView.builder(
                      itemCount: exercise.sets,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemBuilder: (context, index) {
                        final isDone = index < exercise.completedSets.length
                            ? exercise.completedSets[index]
                            : false;

                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: isDone ? Colors.white10 : Colors.grey[900],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDone
                                  ? Colors.white.withOpacity(0.1)
                                  : Colors.transparent,
                              width: 1,
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            leading: CircleAvatar(
                              backgroundColor:
                                  isDone ? Colors.white : Colors.white24,
                              radius: 14,
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              '${exercise.reps} REPS',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: isDone ? Colors.grey : Colors.white,
                              ),
                            ),
                            trailing: Transform.scale(
                              scale: 1.4,
                              child: Checkbox(
                                value: isDone,
                                activeColor: Colors.white,
                                checkColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                side: const BorderSide(
                                  color: Colors.white24,
                                  width: 2,
                                ),
                                onChanged: (val) {
                                  setState(() {
                                    while (exercise.completedSets.length <= index) {
                                      exercise.completedSets.add(false);
                                    }
                                    exercise.completedSets[index] = val!;
                                  });
                                  if (val!) _startRest(exercise.restSeconds);
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Footer Navigation
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                if (_currentExerciseIndex > 0)
                  IconButton(
                    onPressed: () => setState(() => _currentExerciseIndex--),
                    icon: const Icon(Icons.arrow_back),
                  ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.all(16),
                    ),
                    onPressed: () {
                      if (_currentExerciseIndex <
                          widget.program.exercises.length - 1) {
                        setState(() => _currentExerciseIndex++);
                      } else {
                        final endTime = DateTime.now();
                        final duration = endTime.difference(_startTime!);

                        double totalVolume = 0;
                        int completedSetsCount = 0;

                        for (var ex in widget.program.exercises) {
                          for (int i = 0; i < ex.sets; i++) {
                            if (i < ex.completedSets.length && ex.completedSets[i]) {
                              totalVolume += (ex.reps * ex.weight);
                              completedSetsCount++;
                            }
                          }
                        }

                        context.read<WorkoutProvider>().completeWorkout();

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WorkoutSummaryScreen(
                              programName: widget.program.name,
                              duration: duration,
                              totalVolume: totalVolume,
                              completedSets: completedSetsCount,
                              currentStreak:
                                  context.read<WorkoutProvider>().streak,
                            ),
                          ),
                        );
                      }
                    },
                    child: Text(
                      _currentExerciseIndex == widget.program.exercises.length - 1
                          ? 'FINISH'
                          : 'NEXT EXERCISE',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _restTimer?.cancel();
    _elapsedTimer?.cancel();
    super.dispose();
  }
}

// ---------------------------------------------------------------------------
// Bottom sheet content as a proper StatefulWidget so that
// TextEditingControllers are disposed by Flutter's widget lifecycle —
// i.e. when the sheet widget is actually removed from the tree — rather than
// via a .whenComplete() callback that fires during the dismiss animation.
// ---------------------------------------------------------------------------

class _ExerciseEditSheet extends StatefulWidget {
  final Exercise exercise;
  final Program program;
  final VoidCallback onSaved;

  const _ExerciseEditSheet({
    required this.exercise,
    required this.program,
    required this.onSaved,
  });

  @override
  State<_ExerciseEditSheet> createState() => _ExerciseEditSheetState();
}

class _ExerciseEditSheetState extends State<_ExerciseEditSheet> {
  late final TextEditingController _setsCtrl;
  late final TextEditingController _repsCtrl;
  late final TextEditingController _weightCtrl;
  late final TextEditingController _restCtrl;

  @override
  void initState() {
    super.initState();
    _setsCtrl   = TextEditingController(text: widget.exercise.sets.toString());
    _repsCtrl   = TextEditingController(text: widget.exercise.reps.toString());
    _weightCtrl = TextEditingController(text: widget.exercise.weight.toString());
    _restCtrl   = TextEditingController(text: widget.exercise.restSeconds.toString());
  }

  @override
  void dispose() {
    _setsCtrl.dispose();
    _repsCtrl.dispose();
    _weightCtrl.dispose();
    _restCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final newSets   = int.tryParse(_setsCtrl.text)      ?? widget.exercise.sets;
    final newReps   = int.tryParse(_repsCtrl.text)      ?? widget.exercise.reps;
    final newWeight = double.tryParse(_weightCtrl.text) ?? widget.exercise.weight;
    final newRest   = int.tryParse(_restCtrl.text)      ?? widget.exercise.restSeconds;

    final ex = widget.exercise;
    ex.sets        = newSets;
    ex.reps        = newReps;
    ex.weight      = newWeight;
    ex.restSeconds = newRest;

    // Rebuild completedSets as a growable list, preserving ticks already logged.
    final old = ex.completedSets;
    ex.completedSets = List<bool>.generate(
      newSets,
      (i) => i < old.length ? old[i] : false,
      growable: true,
    );

    // Persist via provider.
    context.read<WorkoutProvider>().addOrUpdateProgram(widget.program);

    // Tell the parent screen to rebuild so weight badge etc. refresh.
    widget.onSaved();

    Navigator.pop(context);
  }

  Widget _field(String label, TextEditingController ctrl, {bool decimal = false}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: Colors.grey, letterSpacing: 1.5),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: ctrl,
            keyboardType: TextInputType.numberWithOptions(decimal: decimal),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white10,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.edit, size: 16, color: Colors.white54),
              const SizedBox(width: 8),
              Text(
                widget.exercise.name.toUpperCase(),
                style: const TextStyle(
                  fontSize: 14,
                  letterSpacing: 2,
                  color: Colors.white54,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _field('SETS', _setsCtrl),
              const SizedBox(width: 16),
              _field('REPS', _repsCtrl),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _field('WEIGHT (kg)', _weightCtrl, decimal: true),
              const SizedBox(width: 16),
              _field('REST (s)', _restCtrl),
            ],
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _save,
              child: const Text(
                'SAVE',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }
}