// Sir wala po ako flutter naka dartpad lang po kaya isahang file napo

import 'package:flutter/material.dart';

void main() {
  runApp(const MiniTaskTrackerApp());
}

class MiniTaskTrackerApp extends StatelessWidget {
  const MiniTaskTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mini Task Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          centerTitle: true,
        ),
      ),
      home: const HomeScreen(),
      routes: {
        TaskDetailScreen.routeName: (context) => const TaskDetailScreen(),
        MarkStatusScreen.routeName: (context) => const MarkStatusScreen(),
      },
    );
  }
}

class Task {
  final String title;
  final String status;

  const Task({
    required this.title,
    this.status = 'Pending',
  });

  Task copyWith({String? status}) {
    return Task(
      title: title,
      status: status ?? this.status,
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Task> _tasks = [
    const Task(title: 'Buy groceries', status: 'Pending'),
    const Task(title: 'Submit report', status: 'Pending'),
    const Task(title: 'Call client', status: 'Complete'),
  ];

  Future<void> _openAddTask() async {
    final selectedTask = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => const AddTaskScreen(),
      ),
    );

    if (selectedTask == null) {
      return;
    }

    setState(() {
      _tasks.add(
        Task(title: selectedTask, status: 'Pending'),
      );
    });
  }

  Future<void> _openTaskDetail(Task task) async {
    final updatedTask = await Navigator.pushNamed(
      context,
      TaskDetailScreen.routeName,
      arguments: task,
    ) as Task?;

    if (updatedTask == null) {
      return;
    }

    setState(() {
      final index = _tasks.indexWhere(
        (item) => item.title == updatedTask.title,
      );

      if (index != -1) {
        _tasks[index] = updatedTask;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mini Task Tracker',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: _tasks.isEmpty
          ? const Center(
              child: Text(
                'No tasks yet.',
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                final task = _tasks[index];
                final isComplete = task.status == 'Complete';

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: InkWell(
                    onTap: () {
                      _openTaskDetail(task);
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                task.title,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                task.status,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          isComplete
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: isComplete ? Colors.green : Colors.grey[400],
                          size: 26,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFEDE0FF),
        foregroundColor: const Color(0xFF4A148C),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        onPressed: _openAddTask,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddTaskScreen extends StatelessWidget {
  const AddTaskScreen({super.key});

  static const List<String> presetTasks = [
    'Buy groceries',
    'Submit report',
    'Call client',
  ];

  void _selectTask(BuildContext context, String task) {
    Navigator.pop(context, task);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Task',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: presetTasks.length,
        separatorBuilder: (context, index) {
          return const SizedBox(height: 15);
        },
        itemBuilder: (context, index) {
          final task = presetTasks[index];

          return SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFEDE0FF),
                foregroundColor: const Color(0xFF4A148C),
                padding: const EdgeInsets.symmetric(vertical: 17),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: () {
                _selectTask(context, task);
              },
              child: Text(
                task,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class TaskDetailScreen extends StatefulWidget {
  const TaskDetailScreen({super.key});

  static const String routeName = '/detail';

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late Task _task;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_initialized) {
      _task = ModalRoute.of(context)!.settings.arguments as Task;
      _initialized = true;
    }
  }

  Future<void> _openMarkStatus() async {
    final newStatus = await Navigator.pushNamed(
      context,
      MarkStatusScreen.routeName,
      arguments: _task,
    ) as String?;

    if (newStatus == null) {
      return;
    }

    final updatedTask = _task.copyWith(status: newStatus);

    setState(() {
      _task = updatedTask;
    });

    if (mounted) {
      Navigator.pop(context, updatedTask);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isComplete = _task.status == 'Complete';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Task Detail',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _task.title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Status: ${_task.status}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isComplete ? Colors.green : Colors.orange,
              ),
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFEDE0FF),
                  foregroundColor: const Color(0xFF4A148C),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: _openMarkStatus,
                child: const Text(
                  'Update Status',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MarkStatusScreen extends StatelessWidget {
  const MarkStatusScreen({super.key});

  static const String routeName = '/markStatus';

  void _setStatus(BuildContext context, String status) {
    Navigator.pop(context, status);
  }

  @override
  Widget build(BuildContext context) {
    final task = ModalRoute.of(context)!.settings.arguments as Task;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Update Status',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task.title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFEDE0FF),
                  foregroundColor: const Color(0xFF4A148C),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: () {
                  _setStatus(context, 'Complete');
                },
                child: const Text(
                  'Mark Complete',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFEDE0FF),
                  foregroundColor: const Color(0xFF4A148C),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: () {
                  _setStatus(context, 'Pending');
                },
                child: const Text(
                  'Mark Pending',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
