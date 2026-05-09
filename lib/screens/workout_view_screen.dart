import 'dart:async';
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
  Timer? _timer;
  int _secondsRemaining = 0;

  void _startRest(int seconds) {
    setState(() => _secondsRemaining = seconds);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
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
        title: Text(
          '${_currentExerciseIndex + 1} / ${widget.program.exercises.length}',
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
                      '${exercise.weight} KG', // Or LB based on your preference
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
                      itemBuilder: (context, index) => CheckboxListTile(
                        title: Text('SET ${index + 1}: ${exercise.reps} REPS'),
                        value: exercise.completedSets[index],
                        activeColor: Colors.white,
                        checkColor: Colors.black,
                        onChanged: (val) {
                          setState(() => exercise.completedSets[index] = val!);
                          if (val!) _startRest(exercise.restSeconds);
                        },
                      ),
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
                        context.read<WorkoutProvider>().completeWorkout();
                        Navigator.pop(context);
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
    _timer?.cancel();
    super.dispose();
  }
}
