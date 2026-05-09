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

  @override
  Widget build(BuildContext context) {
    final exercise = widget.program.exercises[_currentExerciseIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Elapsed workout timer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.timer_outlined,
                    size: 14,
                    color: Colors.white54,
                  ),
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
            // Exercise progress
            Text(
              '${_currentExerciseIndex + 1} / ${widget.program.exercises.length}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white54,
              ),
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
                child: Icon(
                  Icons.fitness_center,
                  size: 80,
                  color: Colors.white24,
                ),
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
                  Text(
                    exercise.name.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
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
                  Expanded(
                    child: ListView.builder(
                      itemCount: exercise.sets,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemBuilder: (context, index) {
                        final isDone = exercise.completedSets[index];
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
                                  setState(
                                    () => exercise.completedSets[index] = val!,
                                  );
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
                            if (ex.completedSets[i]) {
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
                      _currentExerciseIndex ==
                              widget.program.exercises.length - 1
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