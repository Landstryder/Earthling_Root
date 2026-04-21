import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();
  await StorageService.initializeDefaultsIfNeeded();
  runApp(const EarthlingRootApp());
}

// Models, storage, and UI implemented for v0.2

class UserProfile {
  String name;
  double acreage;
  String biome; // temperate, tropical, desert, boreal, grassland
  String urbanStatus; // urban, suburban, rural
  DateTime createdAt;

  UserProfile({
    required this.name,
    this.acreage = 0.0,
    this.biome = 'temperate',
    this.urbanStatus = 'suburban',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'name': name,
    'acreage': acreage,
    'biome': biome,
    'urbanStatus': urbanStatus,
    'createdAt': createdAt.toIso8601String(),
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    name: json['name'] ?? 'Earthling',
    acreage: (json['acreage'] as num?)?.toDouble() ?? 0.0,
    biome: json['biome'] ?? 'temperate',
    urbanStatus: json['urbanStatus'] ?? 'suburban',
    createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
  );
}

// Default tasks for earthling way followers
List<BalanceTask> _getDefaultTasks() {
  return [
    // Daily tasks
    BalanceTask(
      id: 'daily_1',
      title: 'Water plants & garden',
      domainIds: ['land', 'mind'],
      impactValue: 15,
    ),
    BalanceTask(
      id: 'daily_2',
      title: 'Move your body (walk, stretch, yoga)',
      domainIds: ['body', 'joy'],
      impactValue: 12,
    ),
    BalanceTask(
      id: 'daily_3',
      title: 'Eat locally/seasonally',
      domainIds: ['body', 'land'],
      impactValue: 10,
    ),
    BalanceTask(
      id: 'daily_4',
      title: 'Meditate or reflect',
      domainIds: ['mind', 'joy'],
      impactValue: 10,
    ),
    BalanceTask(
      id: 'daily_5',
      title: 'Spend time in nature',
      domainIds: ['land', 'body', 'joy'],
      impactValue: 15,
    ),
    BalanceTask(
      id: 'daily_6',
      title: 'Connect with community',
      domainIds: ['community', 'joy'],
      impactValue: 12,
    ),
    // Weekly tasks
    BalanceTask(
      id: 'weekly_1',
      title: 'Composting & waste reduction',
      domainIds: ['land'],
      impactValue: 8,
    ),
    BalanceTask(
      id: 'weekly_2',
      title: 'Study sustainable practices',
      domainIds: ['mind', 'land'],
      impactValue: 10,
    ),
    BalanceTask(
      id: 'weekly_3',
      title: 'Community service or gathering',
      domainIds: ['community', 'land'],
      impactValue: 12,
    ),
  ];
}

class Domain {
  final String id;
  final String name;
  Color color;
  final IconData icon;
  double value; // 0-100

  Domain({
    required this.id,
    required this.name,
    required this.color,
    required this.icon,
    this.value = 50.0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'value': value,
        'colorValue': color.value,
      };

  factory Domain.fromJson(Map<String, dynamic> json) {
    final domains = _getDomainDefinitions();
    final domain = domains.firstWhere((d) => d.id == json['id']);
    return Domain(
      id: domain.id,
      name: domain.name,
      color: json['colorValue'] != null 
        ? Color(json['colorValue'] as int)
        : domain.color,
      icon: domain.icon,
      value: (json['value'] as num?)?.toDouble() ?? 50.0,
    );
  }
}

List<Domain> _getDomainDefinitions() {
  return [
    Domain(
      id: 'land',
      name: 'Land',
      color: const Color(0xFF4CAF50),
      icon: Icons.nature,
      value: 50.0,
    ),
    Domain(
      id: 'mind',
      name: 'Mind',
      color: const Color(0xFF2196F3),
      icon: Icons.lightbulb,
      value: 50.0,
    ),
    Domain(
      id: 'body',
      name: 'Body',
      color: const Color(0xFFFF5722),
      icon: Icons.favorite,
      value: 50.0,
    ),
    Domain(
      id: 'community',
      name: 'Community',
      color: const Color(0xFF9C27B0),
      icon: Icons.people,
      value: 50.0,
    ),
    Domain(
      id: 'joy',
      name: 'Joy',
      color: const Color(0xFFFFC107),
      icon: Icons.star,
      value: 50.0,
    ),
  ];
}

class BalanceTask {
  final String id;
  final String title;
  final List<String> domainIds;
  final int impactValue;
  bool completed;
  final DateTime createdAt;

  BalanceTask({
    required this.id,
    required this.title,
    required this.domainIds,
    required this.impactValue,
    this.completed = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'domainIds': domainIds,
        'impactValue': impactValue,
        'completed': completed,
        'createdAt': createdAt.toIso8601String(),
      };

  factory BalanceTask.fromJson(Map<String, dynamic> json) => BalanceTask(
        id: json['id'],
        title: json['title'],
        domainIds: List<String>.from(json['domainIds']),
        impactValue: json['impactValue'],
        completed: json['completed'] ?? false,
        createdAt: DateTime.parse(json['createdAt']),
      );
}

class Goal {
  final String id;
  final String title;
  final bool isInfinite;
  int currentProgress;
  final int? targetProgress;
  bool completed;
  final DateTime createdAt;

  Goal({
    required this.id,
    required this.title,
    required this.isInfinite,
    this.currentProgress = 0,
    this.targetProgress,
    this.completed = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  double getPercentage() {
    if (isInfinite || targetProgress == null) return 0;
    if (targetProgress == 0) return 0;
    return (currentProgress / targetProgress!) * 100;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'isInfinite': isInfinite,
        'currentProgress': currentProgress,
        'targetProgress': targetProgress,
        'completed': completed,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Goal.fromJson(Map<String, dynamic> json) => Goal(
        id: json['id'],
        title: json['title'],
        isInfinite: json['isInfinite'],
        currentProgress: json['currentProgress'] ?? 0,
        targetProgress: json['targetProgress'],
        completed: json['completed'] ?? false,
        createdAt: DateTime.parse(json['createdAt']),
      );
}

class StorageService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> initializeDefaultsIfNeeded() async {
    final hasProfile = _prefs?.getString('userProfile') != null;
    if (!hasProfile) {
      // First time user - save default profile
      final defaultProfile = UserProfile(name: 'Earthling');
      await saveUserProfile(defaultProfile);
      
      // Add default tasks
      final defaultTasks = _getDefaultTasks();
      await saveTasks(defaultTasks);
    }
  }

  // User Profile
  static Future<void> saveUserProfile(UserProfile profile) async {
    if (_prefs == null) return;
    await _prefs!.setString('userProfile', jsonEncode(profile.toJson()));
  }

  static UserProfile getUserProfile() {
    if (_prefs == null) return UserProfile(name: 'Earthling');
    final json = _prefs!.getString('userProfile');
    if (json == null) return UserProfile(name: 'Earthling');
    return UserProfile.fromJson(jsonDecode(json) as Map<String, dynamic>);
  }

  // Custom Domain Colors
  static Future<void> saveDomainColors(Map<String, int> colorMap) async {
    if (_prefs == null) return;
    await _prefs!.setString('domainColors', jsonEncode(colorMap));
  }

  static Map<String, Color> getDomainColors() {
    if (_prefs == null) return {};
    final json = _prefs!.getString('domainColors');
    if (json == null) return {};
    final Map<String, dynamic> colorMap = jsonDecode(json);
    return colorMap.map((key, value) => MapEntry(key, Color(value as int)));
  }

  static Future<void> saveDomains(List<Domain> domains) async {
    if (_prefs == null) return;
    final json = domains.map((d) => d.toJson()).toList();
    await _prefs!.setString('domains', jsonEncode(json));
    
    // Also save custom colors
    final colorMap = <String, int>{};
    for (var d in domains) {
      colorMap[d.id] = d.color.value;
    }
    await saveDomainColors(colorMap);
  }

  static List<Domain> getDomains() {
    if (_prefs == null) {
      return _getDomainDefinitions();
    }
    final json = _prefs!.getString('domains');
    if (json == null) {
      return _getDomainDefinitions();
    }
    final List<dynamic> data = jsonDecode(json);
    return data
        .map((d) => Domain.fromJson(d as Map<String, dynamic>))
        .toList();
  }

  static Future<void> saveTasks(List<BalanceTask> tasks) async {
    if (_prefs == null) return;
    final json = tasks.map((t) => t.toJson()).toList();
    await _prefs!.setString('tasks', jsonEncode(json));
  }

  static List<BalanceTask> getTasks() {
    if (_prefs == null) return [];
    final json = _prefs!.getString('tasks');
    if (json == null) return [];
    final List<dynamic> data = jsonDecode(json);
    return data
        .map((t) => BalanceTask.fromJson(t as Map<String, dynamic>))
        .toList();
  }

  static Future<void> saveGoals(List<Goal> goals) async {
    if (_prefs == null) return;
    final json = goals.map((g) => g.toJson()).toList();
    await _prefs!.setString('goals', jsonEncode(json));
  }

  static List<Goal> getGoals() {
    if (_prefs == null) return [];
    final json = _prefs!.getString('goals');
    if (json == null) return [];
    final List<dynamic> data = jsonDecode(json);
    return data.map((g) => Goal.fromJson(g as Map<String, dynamic>)).toList();
  }

  static Future<void> clearAll() async {
    if (_prefs == null) return;
    await _prefs!.clear();
  }
}

class EarthlingRootApp extends StatefulWidget {
  const EarthlingRootApp({super.key});

  @override
  State<EarthlingRootApp> createState() => _EarthlingRootAppState();
}

class _EarthlingRootAppState extends State<EarthlingRootApp> {
  late List<Domain> domains;

  @override
  void initState() {
    super.initState();
    domains = StorageService.getDomains();
  }

  Color _getPrimaryColor() {
    final landDomain = domains.firstWhere((d) => d.id == 'land');
    return landDomain.color;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Earthling Root v0.3',
      theme: ThemeData(
        primaryColor: _getPrimaryColor(),
        useMaterial3: true,
      ),
      home: MainNavigator(onDomainsChanged: () {
        setState(() {
          domains = StorageService.getDomains();
        });
      }),
    );
  }
}

class MainNavigator extends StatefulWidget {
  final VoidCallback? onDomainsChanged;
  
  const MainNavigator({super.key, this.onDomainsChanged});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _selectedIndex = 0;

  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const HomeScreen(),
      const GoalsScreen(),
      SettingsScreen(onSettingsChanged: () {
        widget.onDomainsChanged?.call();
        setState(() {});
      }),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Balance'),
          BottomNavigationBarItem(icon: Icon(Icons.flag), label: 'Goals'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<Domain> domains;
  late List<BalanceTask> tasks;

  @override
  void initState() {
    super.initState();
    domains = StorageService.getDomains();
    tasks = StorageService.getTasks();
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

  String _getBalanceMessage() {
    double avg = domains.fold(0.0, (sum, d) => sum + d.value) / domains.length;
    double maxDiff = 0;
    for (var d in domains) {
      maxDiff = maxDiff > (d.value - avg).abs() ? maxDiff : (d.value - avg).abs();
    }

    if (avg < 30) {
      return '🌙 You seem depleted. Rest and nurture yourself.';
    } else if (maxDiff > 40) {
      final lowest = domains.reduce((a, b) => a.value < b.value ? a : b);
      return '⚠️ ${lowest.name} is being neglected.';
    } else if (maxDiff < 15) {
      return '✨ You are in harmony.';
    } else {
      return '⚡ Working towards balance.';
    }
  }

  void _toggleTask(int index) {
    setState(() {
      tasks[index].completed = !tasks[index].completed;
      if (tasks[index].completed) {
        for (var domainId in tasks[index].domainIds) {
          final domain = domains.firstWhere((d) => d.id == domainId);
          domain.value = (domain.value + tasks[index].impactValue).clamp(0, 100).toDouble();
        }
      } else {
        for (var domainId in tasks[index].domainIds) {
          final domain = domains.firstWhere((d) => d.id == domainId);
          domain.value = (domain.value - tasks[index].impactValue).clamp(0, 100).toDouble();
        }
      }
    });
    StorageService.saveTasks(tasks);
    StorageService.saveDomains(domains);
  }

  void _addTask() {
    showDialog(
      context: context,
      builder: (context) => _AddTaskDialog(
        domains: domains,
        onAdd: (title, selectedDomainIds, impactValue) {
          setState(() {
            tasks.add(BalanceTask(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              title: title,
              domainIds: selectedDomainIds,
              impactValue: impactValue,
            ));
          });
          StorageService.saveTasks(tasks);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _resetDay() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Day'),
        content: const Text('This will uncheck all tasks and reset domain values to 50.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              setState(() {
                for (var task in tasks) {
                  task.completed = false;
                }
                for (var domain in domains) {
                  domain.value = 50.0;
                }
              });
              StorageService.saveTasks(tasks);
              StorageService.saveDomains(domains);
              Navigator.pop(context);
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Earthling Root')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(8.0)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Today: ${_getTodayTheme()}', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8.0),
                Text(_getBalanceMessage(), style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.green[700])),
              ]),
            ),
            const SizedBox(height: 20.0),
            Text('Life Balance', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12.0),
            ...domains.map((d) => _buildDomainBar(d)),
            const SizedBox(height: 20.0),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Daily Tasks', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              IconButton(icon: const Icon(Icons.add), onPressed: _addTask),
            ]),
            const SizedBox(height: 12.0),
            if (tasks.isEmpty)
              Padding(padding: const EdgeInsets.symmetric(vertical: 24.0), child: Center(child: Text('No tasks yet. Add one to get started!', style: TextStyle(color: Colors.grey[500]))))
            else
              ListView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: tasks.length, itemBuilder: (context, index) => _buildTaskTile(index, tasks[index])),
            const SizedBox(height: 24.0),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _resetDay,
                icon: const Icon(Icons.refresh),
                label: const Text('Reset Day'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red[400]),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildDomainBar(Domain domain) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Icon(domain.icon, color: domain.color, size: 20), const SizedBox(width: 8.0), Text(domain.name, style: const TextStyle(fontWeight: FontWeight.w600)), const Spacer(), Text(domain.value.toStringAsFixed(0), style: TextStyle(fontWeight: FontWeight.bold, color: domain.color))]),
        const SizedBox(height: 8.0),
        ClipRRect(borderRadius: BorderRadius.circular(4.0), child: LinearProgressIndicator(value: domain.value / 100, minHeight: 12.0, backgroundColor: domain.color.withOpacity(0.1), valueColor: AlwaysStoppedAnimation<Color>(domain.color))),
      ]),
    );
  }

  Widget _buildTaskTile(int index, BalanceTask task) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      child: CheckboxListTile(
        title: Text(task.title),
        subtitle: Text(task.domainIds.map((id) => domains.firstWhere((d) => d.id == id).name).join(', ')),
        value: task.completed,
        onChanged: (_) => _toggleTask(index),
        secondary: Container(padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0), decoration: BoxDecoration(color: task.completed ? Colors.green[200] : Colors.grey[200], borderRadius: BorderRadius.circular(4.0)), child: Text(task.completed ? '✓' : '○')),
      ),
    );
  }
}

class _AddTaskDialog extends StatefulWidget {
  final List<Domain> domains;
  final Function(String title, List<String> domainIds, int impact) onAdd;

  const _AddTaskDialog({required this.domains, required this.onAdd});

  @override
  State<_AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<_AddTaskDialog> {
  late TextEditingController titleController;
  late TextEditingController impactController;
  List<String> selectedDomainIds = [];

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController();
    impactController = TextEditingController(text: '10');
  }

  @override
  void dispose() {
    titleController.dispose();
    impactController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Task'),
      content: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Task Title', hintText: 'e.g., Water plants')),
          const SizedBox(height: 12.0),
          const Text('Affects:'),
          const SizedBox(height: 8.0),
          ...widget.domains.map((domain) => CheckboxListTile(title: Text(domain.name), value: selectedDomainIds.contains(domain.id), onChanged: (value) {
                setState(() {
                  if (value == true) {
                    selectedDomainIds.add(domain.id);
                  } else {
                    selectedDomainIds.remove(domain.id);
                  }
                });
              })),
          const SizedBox(height: 8.0),
          TextField(controller: impactController, decoration: const InputDecoration(labelText: 'Impact Value', hintText: '5-20'), keyboardType: TextInputType.number),
        ]),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(onPressed: () {
          if (titleController.text.isNotEmpty && selectedDomainIds.isNotEmpty && int.tryParse(impactController.text) != null) {
            widget.onAdd(titleController.text, selectedDomainIds, int.parse(impactController.text));
          }
        }, child: const Text('Add')),
      ],
    );
  }
}

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  late List<Goal> goals;

  @override
  void initState() {
    super.initState();
    goals = StorageService.getGoals();
  }

  void _addGoal() {
    showDialog(context: context, builder: (context) => _AddGoalDialog(onAdd: (title, isInfinite, target) {
          setState(() {
            goals.add(Goal(id: DateTime.now().millisecondsSinceEpoch.toString(), title: title, isInfinite: isInfinite, targetProgress: isInfinite ? null : target));
          });
          StorageService.saveGoals(goals);
          Navigator.pop(context);
        }));
  }

  void _incrementGoal(int index) {
    setState(() {
      goals[index].currentProgress++;
      if (!goals[index].isInfinite && goals[index].currentProgress >= (goals[index].targetProgress ?? 0)) goals[index].completed = true;
    });
    StorageService.saveGoals(goals);
  }

  void _deleteGoal(int index) {
    setState(() {
      goals.removeAt(index);
    });
    StorageService.saveGoals(goals);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Goals & Aspirations')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Finite Goals', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)), IconButton(icon: const Icon(Icons.add), onPressed: _addGoal)]),
            const SizedBox(height: 12.0),
            ...goals.where((g) => !g.isInfinite).map((g) => _buildGoalTile(goals.indexOf(g), g)),
            const SizedBox(height: 24.0),
            Text('Infinite Goals', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12.0),
            ...goals.where((g) => g.isInfinite).map((g) => _buildGoalTile(goals.indexOf(g), g)),
          ]),
        ),
      ),
    );
  }

  Widget _buildGoalTile(int index, Goal goal) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(goal.title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, decoration: goal.completed ? TextDecoration.lineThrough : null)), const SizedBox(height: 8.0), if (!goal.isInfinite) LinearProgressIndicator(value: goal.getPercentage() / 100, minHeight: 8.0) else Text('Progress: ${goal.currentProgress}', style: TextStyle(fontSize: 14, color: Colors.grey[600]))])), if (!goal.isInfinite) Padding(padding: const EdgeInsets.only(left: 8.0), child: Text('${goal.currentProgress}/${goal.targetProgress}', style: const TextStyle(fontWeight: FontWeight.bold)))]),
          if (goal.completed) const Padding(padding: EdgeInsets.only(top: 8.0), child: Text('✓ Completed!', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))),
          const SizedBox(height: 12.0),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [ElevatedButton.icon(onPressed: () => _incrementGoal(index), icon: const Icon(Icons.add), label: const Text('Progress')), const SizedBox(width: 8.0), IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteGoal(index))]),
        ]),
      ),
    );
  }
}

class _AddGoalDialog extends StatefulWidget {
  final Function(String title, bool isInfinite, int? target) onAdd;
  const _AddGoalDialog({required this.onAdd});

  @override
  State<_AddGoalDialog> createState() => _AddGoalDialogState();
}

class _AddGoalDialogState extends State<_AddGoalDialog> {
  late TextEditingController titleController;
  late TextEditingController targetController;
  bool isInfinite = false;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController();
    targetController = TextEditingController(text: '3');
  }

  @override
  void dispose() {
    titleController.dispose();
    targetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Goal'),
      content: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Goal Title', hintText: 'e.g., Build 3 garden beds')),
          const SizedBox(height: 12.0),
          CheckboxListTile(title: const Text('Infinite Goal'), subtitle: const Text('Accumulates forever'), value: isInfinite, onChanged: (v) => setState(() => isInfinite = v ?? false)),
          if (!isInfinite) TextField(controller: targetController, decoration: const InputDecoration(labelText: 'Target Progress', hintText: '3'), keyboardType: TextInputType.number),
        ]),
      ),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')), ElevatedButton(onPressed: () {
        if (titleController.text.isNotEmpty) {
          final target = isInfinite ? null : int.tryParse(targetController.text);
          widget.onAdd(titleController.text, isInfinite, target);
        }
      }, child: const Text('Add'))],
    );
  }
}

// Settings Screen
class SettingsScreen extends StatefulWidget {
  final VoidCallback? onSettingsChanged;
  
  const SettingsScreen({super.key, this.onSettingsChanged});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late UserProfile profile;
  late List<Domain> domains;
  late TextEditingController nameController;
  late TextEditingController acreageController;

  @override
  void initState() {
    super.initState();
    profile = StorageService.getUserProfile();
    domains = StorageService.getDomains();
    nameController = TextEditingController(text: profile.name);
    acreageController = TextEditingController(text: profile.acreage.toStringAsFixed(1));
  }

  @override
  void dispose() {
    nameController.dispose();
    acreageController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    profile.name = nameController.text.isNotEmpty ? nameController.text : 'Earthling';
    profile.acreage = double.tryParse(acreageController.text) ?? 0.0;
    StorageService.saveUserProfile(profile);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile saved!')),
    );
  }

  void _showColorPicker(Domain domain) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Choose color for ${domain.name}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildColorOption(domain, const Color(0xFF4CAF50), 'Green'),
              _buildColorOption(domain, const Color(0xFF2196F3), 'Blue'),
              _buildColorOption(domain, const Color(0xFFFF5722), 'Red'),
              _buildColorOption(domain, const Color(0xFF9C27B0), 'Purple'),
              _buildColorOption(domain, const Color(0xFFFFC107), 'Yellow'),
              _buildColorOption(domain, const Color(0xFF00BCD4), 'Cyan'),
              _buildColorOption(domain, const Color(0xFFFF9800), 'Orange'),
              _buildColorOption(domain, const Color(0xFF795548), 'Brown'),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Done')),
        ],
      ),
    );
  }

  Widget _buildColorOption(Domain domain, Color color, String name) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      title: Text(name),
      onTap: () {
        setState(() {
          domain.color = color;
        });
        StorageService.saveDomains(domains);
        Navigator.pop(context);
        widget.onSettingsChanged?.call();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Profile Section
              Text('User Profile', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16.0),
              
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  hintText: 'Enter your name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12.0),
              
              // Biome Selection
              Text('Biome', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8.0),
              DropdownButton<String>(
                isExpanded: true,
                value: profile.biome,
                items: const [
                  DropdownMenuItem(value: 'temperate', child: Text('🌲 Temperate')),
                  DropdownMenuItem(value: 'tropical', child: Text('🌴 Tropical')),
                  DropdownMenuItem(value: 'desert', child: Text('🏜️ Desert')),
                  DropdownMenuItem(value: 'boreal', child: Text('❄️ Boreal')),
                  DropdownMenuItem(value: 'grassland', child: Text('🌾 Grassland')),
                  DropdownMenuItem(value: 'coastal', child: Text('🌊 Coastal')),
                  DropdownMenuItem(value: 'mountain', child: Text('⛰️ Mountain')),
                ],
                onChanged: (value) {
                  setState(() {
                    profile.biome = value ?? 'temperate';
                  });
                },
              ),
              const SizedBox(height: 16.0),
              
              // Urban Status
              Text('Urban Status', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8.0),
              DropdownButton<String>(
                isExpanded: true,
                value: profile.urbanStatus,
                items: const [
                  DropdownMenuItem(value: 'urban', child: Text('🏙️ Urban')),
                  DropdownMenuItem(value: 'suburban', child: Text('🏘️ Suburban')),
                  DropdownMenuItem(value: 'rural', child: Text('🏞️ Rural')),
                ],
                onChanged: (value) {
                  setState(() {
                    profile.urbanStatus = value ?? 'suburban';
                  });
                },
              ),
              const SizedBox(height: 12.0),
              
              // Acreage
              TextField(
                controller: acreageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Acreage (optional)',
                  hintText: 'Land size in acres',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20.0),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  child: const Text('Save Profile'),
                ),
              ),
              const SizedBox(height: 32.0),
              
              // Domain Customization
              Text('Domain Colors', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16.0),
              ...domains.map((domain) => ListTile(
                leading: Icon(domain.icon, color: domain.color, size: 28),
                title: Text(domain.name),
                trailing: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: domain.color,
                    shape: BoxShape.circle,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _showColorPicker(domain),
                      customBorder: const CircleBorder(),
                    ),
                  ),
                ),
              )),
              const SizedBox(height: 32.0),
              
              // About Section
              Text('About', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12.0),
              Text(
                'Earthling Root v0.3\n\nA life balance tracker inspired by the Earthling Way philosophy. Balance your five life domains: Land, Mind, Body, Community, and Joy.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
