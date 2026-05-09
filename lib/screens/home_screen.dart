import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/workout_provider.dart';
import 'workout_view_screen.dart';
import 'settings_screen.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final workoutProvider = Provider.of<WorkoutProvider>(context);
    final todayProgram = workoutProvider.todayProgram;
    final hasWorkedOutToday = workoutProvider.history.contains(
      workoutProvider.formatDate(DateTime.now()),
    );
    final bool isRestDay = todayProgram?.id == '0';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'CHALK',
          style: TextStyle(letterSpacing: 8, fontWeight: FontWeight.w900),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.grey),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),

            // Streak Section
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
                  Text(
                    '${workoutProvider.streak}',
                    style: TextStyle(
                      fontSize: 80,
                      fontWeight: FontWeight.bold,
                      color: workoutProvider.streak > 0
                          ? Color.fromARGB(255, 255, 180, 41)
                          : Colors.white,
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

            const SizedBox(height: 60),

            // Activity Calendar Snippet (Text-based for now)
            const Text(
              'YOUR ACTIVITY',
              style: TextStyle(
                color: Color.fromARGB(255, 201, 201, 201),
                fontSize: 14,
                letterSpacing: 2,
                fontWeight: FontWeight.w800,
              ),
            ),
            const MonthTracker(),

            const Spacer(),

            // Today's Program Card
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'UP NEXT',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    letterSpacing: 2,
                  ),
                ),
                TextButton(
                  onPressed: () => _showProgramPicker(context, workoutProvider),
                  child: const Text(
                    'ALL PROGRAMS',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 0),
            Column(
              children: [
                if (hasWorkedOutToday)
                  _buildCompletedCard(context)
                else
                  _buildWorkoutCard(context, todayProgram, isRestDay)
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05), // Subtle dark card
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          const Icon(Icons.check_circle_outline, color: Colors.green, size: 40),
          const SizedBox(height: 16),
          Text(
            'WORKOUT COMPLETE',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "You've already crushed your session today. Get some rest and fuel up.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutCard(
    BuildContext context,
    dynamic program,
    bool isRestDay,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isRestDay ? 'REST DAY' : program.name.toUpperCase(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isRestDay
                    ? 'Recovery is gain'
                    : '${program.exercises.length} Exercises',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
          if (!isRestDay)
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => WorkoutViewScreen(program: program),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(16),
              ),
              child: const Icon(Icons.play_arrow_rounded, size: 30),
            ),
        ],
      ),
    );
  }

  void _showProgramPicker(BuildContext context, WorkoutProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      // This allows the sheet to wrap its height to the content
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        // Important for handling keyboards or notches
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom,
        ).subtract(EdgeInsetsGeometry.only(bottom: 20)),
        child: ListView.builder(
          // This is the magic line: it tells the list to only be as tall as its items
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: provider.programs.length,
          itemBuilder: (context, i) => ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 8,
            ),
            title: Text(
              provider.programs[i].name.toUpperCase(),
              style: const TextStyle(
                fontWeight: FontWeight.w400,
                letterSpacing: 1,
                color: Colors.grey,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      WorkoutViewScreen(program: provider.programs[i]),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class MonthTracker extends StatefulWidget {
  const MonthTracker({super.key});

  @override
  State<MonthTracker> createState() => _MonthTrackerState();
}

class _MonthTrackerState extends State<MonthTracker> {
  DateTime _focusedMonth = DateTime.now();
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    // Start at a large index so we can swipe "back" into the past
    _pageController = PageController(initialPage: 1200);
  }

  @override
  Widget build(BuildContext context) {
    final workoutProvider = Provider.of<WorkoutProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              DateFormat('MMMM yyyy').format(_focusedMonth).toUpperCase(),
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
                letterSpacing: 2,
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.chevron_left,
                    size: 20,
                    color: Colors.grey,
                  ),
                  onPressed: () => _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: Colors.grey,
                  ),
                  onPressed: () => _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(
          height: 220, // Adjust based on your screen size
          child: PageView.builder(
            physics: const BouncingScrollPhysics(),
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _focusedMonth = DateTime(
                  DateTime.now().year,
                  DateTime.now().month + (index - 1200),
                );
              });
            },
            itemBuilder: (context, index) {
              final month = DateTime(
                DateTime.now().year,
                DateTime.now().month + (index - 1200),
              );
              return _buildCalendarGrid(month, workoutProvider);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarGrid(DateTime month, WorkoutProvider provider) {
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    final firstDayOffset = DateTime(month.year, month.month, 1).weekday - 1;

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: 42, // Standard 6-week grid
      itemBuilder: (context, index) {
        final dayNumber = index - firstDayOffset + 1;
        if (dayNumber <= 0 || dayNumber > daysInMonth)
          return const SizedBox.shrink();

        final date = DateTime(month.year, month.month, dayNumber);
        final dateKey = "${date.year}-${date.month}-${date.day}";
        final isCompleted = provider.history.contains(dateKey);
        final isToday = DateUtils.isSameDay(date, DateTime.now());

        return Container(
          decoration: BoxDecoration(
            color: isCompleted ? Colors.white : Colors.transparent,
            border: Border.all(color: isToday ? Colors.white : Colors.white10),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: Text(
              '$dayNumber',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isCompleted ? Colors.black : Colors.white38,
              ),
            ),
          ),
        );
      },
    );
  }
}
