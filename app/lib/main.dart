import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/navigation_provider.dart';
import 'providers/journal_provider.dart';
import 'screens/home_screen.dart';
import 'screens/mood_tracker_screen.dart';
import 'screens/meditation_screen.dart';
import 'screens/diary_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Add global navigation key
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');
  } catch (e) {
    print('Firebase initialization error: $e');
  }

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final journalProvider = JournalProvider();
  await journalProvider.init();

  runApp(MentalHealthApp(journalProvider: journalProvider));
}

class MentalHealthApp extends StatelessWidget {
  final JournalProvider journalProvider;

  const MentalHealthApp({Key? key, required this.journalProvider}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider.value(value: journalProvider),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'Mind Garden',
        theme: ThemeData(
          primaryColor: Colors.blue,
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            centerTitle: true,
            elevation: 0,
            systemOverlayStyle: SystemUiOverlayStyle.light,
          ),
          cardTheme: CardTheme(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            selectedItemColor: Colors.blue,
            unselectedItemColor: Colors.grey,
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
          ),
        ),
        home: const MainNavigationScreen(),
      ),
    );
  }
}

class MainNavigationScreen extends StatelessWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          body: IndexedStack(
            index: provider.currentIndex,
            children: const [
              HomeScreen(),
              MoodTrackerScreen(),
              MeditationScreen(),
              DiaryScreen(),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: provider.currentIndex,
            onTap: provider.setIndex,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.mood_outlined),
                activeIcon: Icon(Icons.mood),
                label: 'Mood Tracker',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.self_improvement_outlined),
                activeIcon: Icon(Icons.self_improvement),
                label: 'Meditation',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.book_outlined),
                activeIcon: Icon(Icons.book),
                label: 'Diary',
              ),
            ],
          ),
        );
      },
    );
  }
}
