import 'package:flutter/material.dart';

void main() {
  runApp(const EarthlingRootApp());
}

class EarthlingRootApp extends StatelessWidget {
  const EarthlingRootApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Earthling Root',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class Task {
  final String name;
  final int points;
  bool completed;

  Task({
    required this.name,
    required this.points,
    this.completed = false,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<Task> tasks;
  int totalPoints = 0;

  @override
  void initState() {
    super.initState();
    _initializeTasks();
  }

  void _initializeTasks() {
    tasks = [
      Task(name: 'Check chickens', points: 10),
      Task(name: 'Water plants', points: 10),
      Task(name: 'Walk the land', points: 5),
      Task(name: 'Deep work build', points: 20),
      Task(name: 'Learn / study', points: 10),
      Task(name: 'Reflection', points: 5),
    ];
  }

  String _getTodayTheme() {
    final now = DateTime.now();
    final weekday = now.weekday;

    final themes = [
      'Monday Momentum',
      'Tuesday Growth',
      'Wednesday Harmony',
      'Thursday Gratitude',
      'Friday Freedom',
      'Saturday Celebration',
      'Sunday Stillness',
    ];

    return themes[weekday - 1];
  }

  void _toggleTask(int index) {
    setState(() {
      tasks[index].completed = !tasks[index].completed;
      _updateTotalPoints();
    });
  }

  void _updateTotalPoints() {
    totalPoints = tasks.fold(
      0,
      (sum, task) => sum + (task.completed ? task.points : 0),
    );
  }

  void _resetDay() {
    setState(() {
      for (var task in tasks) {
        task.completed = false;
      }
      totalPoints = 0;
    });
  }

  int get currentLevel => totalPoints ~/ 100;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Earthling Root'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Theme of the day
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  'Today\'s Theme: ${_getTodayTheme()}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.green[900],
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              const SizedBox(height: 24.0),

              // Points and Level display
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatCard(
                    context,
                    'Points',
                    totalPoints.toString(),
                    Colors.blue,
                  ),
                  _buildStatCard(
                    context,
                    'Level',
                    currentLevel.toString(),
                    Colors.purple,
                  ),
                ],
              ),
              const SizedBox(height: 24.0),

              // Task list title
              Text(
                'Daily Tasks',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12.0),

              // Tasks
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return _buildTaskTile(index, task);
                },
              ),
              const SizedBox(height: 24.0),

              // Reset button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _resetDay,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset Day'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    backgroundColor: Colors.red[400],
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: color.withOpacity(0.7),
              fontWeight: FontWeight.w500,
              fontSize: 14.0,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            value,
            style: TextStyle(
              color: color.withOpacity(0.9),
              fontSize: 32.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskTile(int index, Task task) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      child: CheckboxListTile(
        title: Text(task.name),
        subtitle: Text('${task.points} pts'),
        value: task.completed,
        onChanged: (_) => _toggleTask(index),
        secondary: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          decoration: BoxDecoration(
            color: task.completed ? Colors.green[200] : Colors.grey[200],
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: Text(
            task.completed ? '+${task.points}' : '${task.points}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: task.completed ? Colors.green[700] : Colors.grey[700],
            ),
          ),
        ),
      ),
    );
  }
}
