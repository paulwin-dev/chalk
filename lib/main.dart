import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/workout_provider.dart';
import 'package:chalk/screens/home_screen.dart';

void main() async {
  // Required for SharedPreferences to initialize before runApp
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(
    ChangeNotifierProvider(
      create: (_) => WorkoutProvider(),
      child: const ChalkApp(),
    ),
  );
}

class ChalkApp extends StatelessWidget {
  const ChalkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WorkoutProvider(),
      child: MaterialApp(
        title: 'Chalk',
        debugShowCheckedModeBanner: false,
        
        // Define the "Chalk" Aesthetic
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: Colors.black,
          
          // Customizing the AppBar to be invisible/minimal
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.black,
            elevation: 0,
            centerTitle: true,
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: 4,
            ),
          ),
          
          // Monochrome Text Theme
          textTheme: const TextTheme(
            displayLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            bodyLarge: TextStyle(color: Colors.white),
            bodyMedium: TextStyle(color: Colors.grey),
          ),

          // Styling buttons to match the "Inverse" look
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),

          // Chip theme for the scheduling screen
          chipTheme: ChipThemeData(
            backgroundColor: Colors.black,
            selectedColor: Colors.white,
            secondaryLabelStyle: const TextStyle(color: Colors.black),
            labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        
        home: const HomeScreen(),
      ),
    );
  }
}