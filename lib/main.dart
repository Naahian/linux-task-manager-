import 'package:flutter/material.dart';
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
      theme: ThemeData(
        useMaterial3: true,
        dialogTheme: const DialogThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.light,
          seedColor: Colors.deepPurpleAccent,
        ),
        fontFamily: 'Segoe UI',
      ),

      themeMode: ThemeMode.light,
      home: const TaskManagerHome(),
    );
  }
}
