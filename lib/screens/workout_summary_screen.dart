import 'package:flutter/material.dart';

class WorkoutSummaryScreen extends StatefulWidget {
  final String programName;
  final Duration duration;
  final double totalVolume;
  final int completedSets;
  final int currentStreak;

  const WorkoutSummaryScreen({
    super.key,
    required this.programName,
    required this.duration,
    required this.totalVolume,
    required this.completedSets,
    required this.currentStreak,
  });

  @override
  State<WorkoutSummaryScreen> createState() => _WorkoutSummaryScreenState();
}

class _WorkoutSummaryScreenState extends State<WorkoutSummaryScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  final Color chalkOrange = const Color.fromARGB(255, 255, 180, 41);

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000), // Total duration of the pop
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.bounceOut,
    );

    // 3. The Delay: Wait 500ms before starting the sequence
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 60),
              const Icon(Icons.fitness_center, color: Color.fromARGB(255, 255, 255, 255), size: 100),
              const SizedBox(height: 20),
              Text(
                "WORKOUT COMPLETE",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: 2),
              ),
              Text(
                widget.programName.toUpperCase(),
                style: TextStyle(color: Colors.grey, fontSize: 18),
              ),
              const SizedBox(height: 50),

              // Match Home Screen Streak Section
              Center(
                child: Column(
                  children: [
                    const Text(
                      'CURRENT STREAK',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: Text(
                        '${widget.currentStreak}',
                        style: TextStyle(
                          fontSize: 100,
                          fontWeight: FontWeight.bold,
                          color: widget.currentStreak > 0 ? chalkOrange : Colors.white,
                        ),
                      ),
                    ),
                    const Text(
                      'DAYS',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                        letterSpacing: 4,
                      ),
                    ),
                  ],
                ),
              ),
              
              
              const SizedBox(height: 50),

              // Summary Stats Section
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'SESSION SUMMARY',
                  style: TextStyle(
                    color: Color.fromARGB(255, 201, 201, 201),
                    fontSize: 14,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Stats Card (Matches the "Today's Program" card style)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStat("TIME", "${widget.duration.inMinutes}M"),
                    _buildStat("VOLUME", "${widget.totalVolume.toInt()}KG"),
                    _buildStat("SETS", "${widget.completedSets}"),
                  ],
                ),
              ),


              const Spacer(),

              // Complete Button (Matches the minimalist Chalk style)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "DONE",
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 10,
            letterSpacing: 1.5,
            fontWeight: FontWeight.bold
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w900
          ),
        ),
      ],
    );
  }
}