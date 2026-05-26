import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:provider/provider.dart';
import 'package:task_manager/task_controller.dart';
import 'package:task_manager/task_view.dart';

void main() async {
  // Ensure Flutter bindings are initialized before accessing plugins
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the task controller and load data
  final taskController = TaskController();
  await taskController.initialize();

  runApp(
    // Provide the controller to the widget tree
    ChangeNotifierProvider.value(
      value: taskController,
      child: const TaskManagerApp(),
    ),
  );
}

class TaskManagerApp extends StatelessWidget {
  const TaskManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager',
      localizationsDelegates: [FlutterQuillLocalizations.delegate],
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        fontFamily: 'Segoe UI',

        // Notion-inspired color scheme
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF2F2F2F), // Dark gray for primary elements
          primaryContainer: Color(0xFFE8E8E8), // Light gray for containers
          secondary: Color(0xFF37352F), // Notion's dark text color
          secondaryContainer: Color(0xFFF1F1EF), // Notion's background gray
          surface: Color(0xFFFFFFFF), // Pure white for surfaces
          surfaceContainerHighest: Color(
            0xFFF7F6F3,
          ), // Subtle gray for hover states
          error: Color(0xFFE03E3E), // Soft red for errors
          onPrimary: Color(0xFFFFFFFF), // White text on primary
          onSecondary: Color(0xFFFFFFFF), // White text on secondary
          onSurface: Color(0xFF37352F), // Dark gray text
          onSurfaceVariant: Color(0xFF787774), // Medium gray for secondary text
          outline: Color(0xFFE3E2E0), // Light border color
        ),

        // Dialog theme with Notion-like rounded corners
        dialogTheme: DialogThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          backgroundColor: Colors.white,
          titleTextStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF37352F),
            letterSpacing: -0.3,
          ),
          contentTextStyle: const TextStyle(
            fontSize: 14,
            color: Color(0xFF787774),
          ),
        ),

        // Card theme
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: Colors.white,
          surfaceTintColor: Colors.transparent,
        ),

        // Input decoration theme
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF7F6F3),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF2F2F2F), width: 1),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFE03E3E), width: 1),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          hintStyle: const TextStyle(color: Color(0xFF9B9A97)),
          labelStyle: const TextStyle(color: Color(0xFF787774)),
        ),

        // Button themes
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2F2F2F),
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF2F2F2F),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),

        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF37352F),
            side: const BorderSide(color: Color(0xFFE3E2E0)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),

        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF787774),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),

        // Divider theme
        dividerTheme: const DividerThemeData(
          color: Color(0xFFE3E2E0),
          thickness: 1,
          space: 1,
        ),

        // Popup menu theme
        popupMenuTheme: PopupMenuThemeData(
          color: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 14, color: Color(0xFF37352F)),
        ),

        // Scaffold background color
        scaffoldBackgroundColor: Colors.white,

        // Highlight color for selection
        highlightColor: const Color(0xFFF7F6F3),
        splashColor: const Color(0xFFE8E8E8),
        hoverColor: const Color(0xFFF7F6F3),
      ),

      themeMode: ThemeMode.light,
      home: const TaskManagerHome(),
    );
  }
}
