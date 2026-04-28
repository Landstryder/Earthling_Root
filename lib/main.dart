import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';
import 'goals_factory.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();
  // Don't initialize defaults here - let SetupScreen handle it
  runApp(const EarthlingRootApp());
}

// ============================================================================
// GOAL MODEL - UNIFIED SYSTEM
// ============================================================================
class Goal {
  final String id;
  final String title;
  final String? description;
  final List<String> domains;
  final Map<String, int> domainImpacts; // Map of domain -> impact value (can be +/-)
  final double cooldownDurationHours;
  DateTime? lastCompletedTime;
  final bool isRepeatable;
  int currentProgress;
  final int? targetProgress;
  bool completed;
  final DateTime createdAt;

  Goal({
    required this.id,
    required this.title,
    this.description,
    required this.domains,
    required this.domainImpacts,
    required this.cooldownDurationHours,
    this.lastCompletedTime,
    this.isRepeatable = true,
    this.currentProgress = 0,
    this.targetProgress,
    this.completed = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Check if goal is available now (not on cooldown)
  bool isAvailable() {
    if (lastCompletedTime == null) return true;
    final hoursSinceCompletion = DateTime.now().difference(lastCompletedTime!).inHours;
    return hoursSinceCompletion >= cooldownDurationHours;
  }

  /// Get hours remaining on cooldown
  double getHoursUntilAvailable() {
    if (lastCompletedTime == null) return 0;
    final hoursSinceCompletion = DateTime.now().difference(lastCompletedTime!).inHours.toDouble();
    return max(0, cooldownDurationHours - hoursSinceCompletion);
  }

  /// Get cooldown status for display
  String getCooldownStatus() {
    if (isAvailable()) return 'Ready';
    final hoursRemaining = getHoursUntilAvailable();
    if (hoursRemaining > 24) {
      final days = (hoursRemaining / 24).ceil();
      return 'Available in $days day${days > 1 ? 's' : ''}';
    }
    return 'Available in ${hoursRemaining.ceil()}h';
  }

  /// Get total impact across all domains (for display)
  int getTotalImpact() {
    return domainImpacts.values.fold(0, (sum, value) => sum + value);
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'domains': domains,
    'domainImpacts': domainImpacts,
    'cooldownDurationHours': cooldownDurationHours,
    'lastCompletedTime': lastCompletedTime?.toIso8601String(),
    'isRepeatable': isRepeatable,
    'currentProgress': currentProgress,
    'targetProgress': targetProgress,
    'completed': completed,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Goal.fromJson(Map<String, dynamic> json) {
    // Handle backward compatibility: if domainImpacts doesn't exist, use impactValue
    Map<String, int> impacts = {};
    if (json['domainImpacts'] != null) {
      impacts = Map<String, int>.from(json['domainImpacts']);
    } else if (json['impactValue'] != null) {
      // Legacy format: distribute same impact to all domains
      final legacyValue = json['impactValue'] as int;
      for (final domain in (json['domains'] as List).cast<String>()) {
        impacts[domain] = legacyValue;
      }
    }
    
    return Goal(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      domains: List<String>.from(json['domains'] ?? []),
      domainImpacts: impacts,
      cooldownDurationHours: (json['cooldownDurationHours'] as num).toDouble(),
      lastCompletedTime: json['lastCompletedTime'] != null ? DateTime.parse(json['lastCompletedTime']) : null,
      isRepeatable: json['isRepeatable'] ?? true,
      currentProgress: json['currentProgress'] ?? 0,
      targetProgress: json['targetProgress'],
      completed: json['completed'] ?? false,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }
}

// ============================================================================
// USER PROFILE MODEL
// ============================================================================
class UserProfile {
  String name;
  double acreage;
  String biome;
  String urbanStatus;
  String growingZone;
  String appTheme;
  bool initialized; // Flag for first-launch setup completion
  DateTime createdAt;

  UserProfile({
    required this.name,
    this.acreage = 0.0,
    this.biome = 'temperate',
    this.urbanStatus = 'suburban',
    this.growingZone = '5',
    this.appTheme = 'light',
    this.initialized = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'name': name,
    'acreage': acreage,
    'biome': biome,
    'urbanStatus': urbanStatus,
    'growingZone': growingZone,
    'appTheme': appTheme,
    'initialized': initialized,
    'createdAt': createdAt.toIso8601String(),
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    name: json['name'] ?? 'Earthling',
    acreage: (json['acreage'] as num?)?.toDouble() ?? 0.0,
    biome: json['biome'] ?? 'temperate',
    urbanStatus: json['urbanStatus'] ?? 'suburban',
    growingZone: json['growingZone'] ?? '5',
    appTheme: json['appTheme'] ?? 'light',
    initialized: json['initialized'] ?? false,
    createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
  );
}

/// Generate default goals for new users from goals_factory
/// These are fully editable and deletable
List<Goal> _getDefaultGoals() {
  final goalDataList = getDefaultGoalsData();
  return goalDataList.map((data) {
    return Goal(
      id: data['id'],
      title: data['title'],
      description: data['description'],
      domains: List<String>.from(data['domains']),
      domainImpacts: Map<String, int>.from(data['domainImpacts']),
      cooldownDurationHours: data['cooldown'],
      isRepeatable: true,
    );
  }).toList();
}

/// Add context-aware goals based on user settings
List<Goal> _getContextAwareGoals(UserProfile profile) {
  final contextGoals = <Goal>[];
  
  // Desert climate adaptations
  if (profile.biome == 'desert') {
    contextGoals.addAll([
      Goal(
        id: 'goal_water_retention',
        title: 'Check water systems',
        description: 'Inspect irrigation, drip lines, and mulch coverage to minimize evaporation.',
        domains: ['land', 'mind'],
        domainImpacts: {'land': 5, 'mind': 2},
        cooldownDurationHours: 168,
        isRepeatable: true,
      ),
      Goal(
        id: 'goal_shade',
        title: 'Provide shade protection',
        description: 'Shade cloth or plant companions for vulnerable crops in extreme heat.',
        domains: ['land'],
        domainImpacts: {'land': 4},
        cooldownDurationHours: 168,
        isRepeatable: true,
      ),
    ]);
  }
  
  // Cold climate adaptations
  if (profile.growingZone.contains(RegExp(r'[1-4]'))) {
    contextGoals.addAll([
      Goal(
        id: 'goal_frost_protect',
        title: 'Prepare frost protection',
        description: 'Gather row covers, cold frames, or cloches for tender plants.',
        domains: ['land', 'mind'],
        domainImpacts: {'land': 4, 'mind': 2},
        cooldownDurationHours: 168,
        isRepeatable: true,
      ),
      Goal(
        id: 'goal_storage',
        title: 'Check stored food',
        description: 'Inspect preserved foods, stored vegetables, and emergency supplies.',
        domains: ['body', 'mind'],
        domainImpacts: {'body': 1, 'mind': 3},
        cooldownDurationHours: 168,
        isRepeatable: true,
      ),
    ]);
  }
  
  // Large acreage
  if (profile.acreage > 2) {
    contextGoals.add(
      Goal(
        id: 'goal_perimeter',
        title: 'Walk perimeter',
        description: 'Check fencing, gates, and boundaries. Look for damage or intrusions.',
        domains: ['land', 'body'],
        domainImpacts: {'land': 3, 'body': 2},
        cooldownDurationHours: 168,
        isRepeatable: true,
      ),
    );
  }
  
  // Rural context
  if (profile.urbanStatus == 'rural') {
    contextGoals.add(
      Goal(
        id: 'goal_neighbor_check',
        title: 'Connect with neighbors',
        description: 'Check in with nearby properties. Share knowledge or resources.',
        domains: ['community', 'joy'],
        domainImpacts: {'community': 2, 'joy': 2},
        cooldownDurationHours: 168,
        isRepeatable: true,
      ),
    );
  }
  
  return contextGoals;
}

// ============================================================================
// DOMAIN MODEL
// ============================================================================
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

// ============================================================================
// STORAGE SERVICE
// ============================================================================
class StorageService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> initializeDefaultsIfNeeded() async {
    final hasProfile = _prefs?.getString('userProfile') != null;
    if (!hasProfile) {
      // First time user - create uninitialized profile
      final defaultProfile = UserProfile(name: 'Earthling', initialized: false);
      await saveUserProfile(defaultProfile);
      await saveLastScoreDecay(DateTime.now());
    }
  }
  
  /// Load default goals based on user profile
  static Future<void> loadDefaultGoalsForProfile(UserProfile profile) async {
    final goals = getGoals();
    if (goals.isEmpty) {
      final defaultGoals = _getDefaultGoals();
      final contextGoals = _getContextAwareGoals(profile);
      final allGoals = [...defaultGoals, ...contextGoals];
      await saveGoals(allGoals);
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

  // Score decay tracking
  static Future<void> saveLastScoreDecay(DateTime time) async {
    if (_prefs == null) return;
    await _prefs!.setString('lastScoreDecay', time.toIso8601String());
  }

  static DateTime getLastScoreDecay() {
    if (_prefs == null) return DateTime.now();
    final json = _prefs!.getString('lastScoreDecay');
    if (json == null) return DateTime.now();
    return DateTime.parse(json);
  }

  /// Apply score decay to all domains
  /// 2 points per hour of inactivity
  static Future<void> applyScoreDecay(List<Domain> domains) async {
    final hoursElapsed = DateTime.now().difference(getLastScoreDecay()).inMinutes / 60.0;
    if (hoursElapsed < 1) return; // Only decay if at least 1 hour has passed
    
    const decayRate = 2.0; // points per hour
    final decayAmount = hoursElapsed * decayRate;
    
    for (var domain in domains) {
      domain.value = max(0.0, domain.value - decayAmount);
    }
    
    await saveLastScoreDecay(DateTime.now());
  }
}

class EarthlingRootApp extends StatefulWidget {
  const EarthlingRootApp({super.key});

  @override
  State<EarthlingRootApp> createState() => _EarthlingRootAppState();
}

class _EarthlingRootAppState extends State<EarthlingRootApp> {
  late List<Domain> domains;
  late UserProfile profile;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // First ensure defaults are set up
    await StorageService.initializeDefaultsIfNeeded();
    
    domains = StorageService.getDomains();
    profile = StorageService.getUserProfile();
    
    if (mounted) {
      setState(() {
        _initialized = true;
      });
    }
  }

  Color _getPrimaryColor() {
    final landDomain = domains.firstWhere((d) => d.id == 'land');
    return landDomain.color;
  }

  ThemeData _buildThemeData() {
    final baseTheme = ThemeData(
      primaryColor: _getPrimaryColor(),
      useMaterial3: true,
    );

    final Color primaryColor;
    final Color backgroundColor;
    final Brightness brightness;

    switch (profile.appTheme) {
      case 'dark':
        primaryColor = const Color(0xFF2196F3);
        backgroundColor = Colors.grey[900]!;
        brightness = Brightness.dark;
        break;
      case 'land':
        primaryColor = const Color(0xFF4CAF50);
        backgroundColor = const Color(0xFFF1F8E9);
        brightness = Brightness.light;
        break;
      case 'mind':
        primaryColor = const Color(0xFF2196F3);
        backgroundColor = const Color(0xFFE3F2FD);
        brightness = Brightness.light;
        break;
      case 'body':
        primaryColor = const Color(0xFFFF5722);
        backgroundColor = const Color(0xFFFFEBEE);
        brightness = Brightness.light;
        break;
      case 'community':
        primaryColor = const Color(0xFF9C27B0);
        backgroundColor = const Color(0xFFF3E5F5);
        brightness = Brightness.light;
        break;
      case 'joy':
        primaryColor = const Color(0xFFFFC107);
        backgroundColor = const Color(0xFFFFFDE7);
        brightness = Brightness.light;
        break;
      case 'light':
      default:
        primaryColor = _getPrimaryColor();
        backgroundColor = Colors.white;
        brightness = Brightness.light;
    }

    if (profile.appTheme == 'dark') {
      return ThemeData.dark(useMaterial3: true).copyWith(
        primaryColor: primaryColor,
        scaffoldBackgroundColor: backgroundColor,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[800],
          elevation: 0,
        ),
      );
    } else {
      return ThemeData(
        useMaterial3: true,
        brightness: brightness,
        primaryColor: primaryColor,
        scaffoldBackgroundColor: backgroundColor,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    // Show settings gate if not initialized
    if (!profile.initialized) {
      return MaterialApp(
        title: 'Earthling Root v0.5',
        theme: _buildThemeData(),
        home: SettingsGateScreen(
          profile: profile,
          onConfirm: (updatedProfile) async {
            profile = updatedProfile;
            profile.initialized = true;
            await StorageService.saveUserProfile(profile);
            
            // Load default goals based on profile
            await StorageService.loadDefaultGoalsForProfile(profile);
            
            if (mounted) {
              setState(() {});
            }
          },
        ),
      );
    }

    return MaterialApp(
      title: 'Earthling Root v0.5',
      theme: _buildThemeData(),
      home: MainNavigator(
        onDomainsChanged: () {
          setState(() {
            domains = StorageService.getDomains();
          });
        },
        onThemeChanged: () {
          setState(() {
            profile = StorageService.getUserProfile();
          });
        },
      ),
    );
  }
}

class MainNavigator extends StatefulWidget {
  final VoidCallback? onDomainsChanged;
  final VoidCallback? onThemeChanged;
  
  const MainNavigator({
    super.key,
    this.onDomainsChanged,
    this.onThemeChanged,
  });

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

// Radar Chart Painter for balance visualization
class RadarChartPainter extends CustomPainter {
  final List<Domain> domains;
  final List<double> values; // 0-100 for each domain

  RadarChartPainter({required this.domains, required this.values});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 20;
    final numDomains = domains.length;
    final angleSlice = (2 * 3.14159) / numDomains;

    // Draw concentric circles (background grid)
    for (int i = 1; i <= 5; i++) {
      final r = radius * (i / 5);
      canvas.drawCircle(
        center,
        r,
        Paint()
          ..color = Colors.grey[200]!
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.5,
      );
    }

    // Draw axes and labels
    for (int i = 0; i < numDomains; i++) {
      final angle = angleSlice * i - 3.14159 / 2;
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);

      // Draw axis line
      canvas.drawLine(center, Offset(x, y), Paint()..color = Colors.grey[300]!);

      // Draw label
      final labelOffset = Offset(
        center.dx + (radius + 30) * cos(angle),
        center.dy + (radius + 30) * sin(angle),
      );
      final textPainter = TextPainter(
        text: TextSpan(text: domains[i].name, style: const TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold)),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, labelOffset - Offset(textPainter.width / 2, textPainter.height / 2));
    }

    // Draw the balance polygon
    final pathPoints = <Offset>[];
    for (int i = 0; i < numDomains; i++) {
      final angle = angleSlice * i - 3.14159 / 2;
      final value = values[i] / 100; // Normalize to 0-1
      final r = radius * value;
      final x = center.dx + r * cos(angle);
      final y = center.dy + r * sin(angle);
      pathPoints.add(Offset(x, y));
    }

    // Draw polygon
    if (pathPoints.isNotEmpty) {
      final path = Path();
      path.moveTo(pathPoints[0].dx, pathPoints[0].dy);
      for (int i = 1; i < pathPoints.length; i++) {
        path.lineTo(pathPoints[i].dx, pathPoints[i].dy);
      }
      path.close();

      canvas.drawPath(
        path,
        Paint()
          ..color = Colors.green.withOpacity(0.3)
          ..style = PaintingStyle.fill,
      );
      canvas.drawPath(
        path,
        Paint()
          ..color = Colors.green
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );

      // Draw points on polygon
      for (final point in pathPoints) {
        canvas.drawCircle(
          point,
          5,
          Paint()
            ..color = Colors.green
            ..style = PaintingStyle.fill,
        );
      }
    }

    // Draw center balance dot
    final avgValue = values.fold(0.0, (a, b) => a + b) / numDomains;
    final balanceRadius = radius * (avgValue / 100);
    canvas.drawCircle(
      center,
      8,
      Paint()
        ..color = Colors.amber
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      center,
      8,
      Paint()
        ..color = Colors.amber[700]!
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Draw center circle (for reference)
    canvas.drawCircle(center, 3, Paint()..color = Colors.grey[600]!);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
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
      SettingsScreen(
        onSettingsChanged: () {
          widget.onDomainsChanged?.call();
          widget.onThemeChanged?.call();
          setState(() {});
        },
      ),
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

// ============================================================================
// SETTINGS GATE SCREEN - First-time setup
// ============================================================================
class SettingsGateScreen extends StatefulWidget {
  final UserProfile profile;
  final Function(UserProfile) onConfirm;
  
  const SettingsGateScreen({
    super.key,
    required this.profile,
    required this.onConfirm,
  });

  @override
  State<SettingsGateScreen> createState() => _SettingsGateScreenState();
}

class _SettingsGateScreenState extends State<SettingsGateScreen> {
  late TextEditingController nameController;
  late TextEditingController acreageController;
  late String selectedBiome;
  late String selectedUrbanStatus;
  late String selectedGrowingZone;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.profile.name);
    acreageController = TextEditingController(text: widget.profile.acreage.toStringAsFixed(1));
    selectedBiome = widget.profile.biome;
    selectedUrbanStatus = widget.profile.urbanStatus;
    selectedGrowingZone = widget.profile.growingZone;
  }

  @override
  void dispose() {
    nameController.dispose();
    acreageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome to Earthling Root'),
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Let\'s get to know your situation',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8.0),
              Center(
                child: Text(
                  'These settings help us suggest relevant goals for your unique context.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                ),
              ),
              const SizedBox(height: 28.0),

              // Name
              Text('Your Name', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8.0),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  hintText: 'Your name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20.0),

              // Biome
              Text('Climate / Biome', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8.0),
              DropdownButtonFormField<String>(
                value: selectedBiome,
                items: const [
                  DropdownMenuItem(value: 'temperate', child: Text('Temperate')),
                  DropdownMenuItem(value: 'tropical', child: Text('Tropical')),
                  DropdownMenuItem(value: 'desert', child: Text('Desert')),
                  DropdownMenuItem(value: 'boreal', child: Text('Boreal')),
                  DropdownMenuItem(value: 'grassland', child: Text('Grassland')),
                  DropdownMenuItem(value: 'coastal', child: Text('Coastal')),
                  DropdownMenuItem(value: 'mountain', child: Text('Mountain')),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedBiome = value ?? 'temperate';
                  });
                },
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              const SizedBox(height: 20.0),

              // Urban Status
              Text('Urban Status', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8.0),
              DropdownButtonFormField<String>(
                value: selectedUrbanStatus,
                items: const [
                  DropdownMenuItem(value: 'urban', child: Text('Urban')),
                  DropdownMenuItem(value: 'suburban', child: Text('Suburban')),
                  DropdownMenuItem(value: 'rural', child: Text('Rural')),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedUrbanStatus = value ?? 'suburban';
                  });
                },
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              const SizedBox(height: 20.0),

              // Growing Zone
              Text('Growing Zone (USDA)', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8.0),
              DropdownButtonFormField<String>(
                value: selectedGrowingZone,
                items: const [
                  DropdownMenuItem(value: '1', child: Text('Zone 1')),
                  DropdownMenuItem(value: '5', child: Text('Zone 5')),
                  DropdownMenuItem(value: '10', child: Text('Zone 10')),
                  DropdownMenuItem(value: '13', child: Text('Zone 13')),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedGrowingZone = value ?? '5';
                  });
                },
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              const SizedBox(height: 20.0),

              // Acreage
              Text('Acreage (optional)', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8.0),
              TextField(
                controller: acreageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: '0.0',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 32.0),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final updatedProfile = UserProfile(
                      name: nameController.text.isNotEmpty ? nameController.text : 'Earthling',
                      acreage: double.tryParse(acreageController.text) ?? 0.0,
                      biome: selectedBiome,
                      urbanStatus: selectedUrbanStatus,
                      growingZone: selectedGrowingZone,
                      appTheme: widget.profile.appTheme,
                      initialized: false,
                      createdAt: widget.profile.createdAt,
                    );
                    widget.onConfirm(updatedProfile);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Confirm & Continue',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// SUGGESTION ALGORITHM
// ============================================================================
class SuggestionEngine {
  static List<Goal> getSuggestedGoals(List<Goal> allGoals, List<Domain> domains) {
    // Filter to only available goals (not on cooldown)
    final availableGoals = allGoals.where((g) => g.isAvailable()).toList();
    
    if (availableGoals.isEmpty) return [];

    // Sort by priority:
    // 1. Prioritize goals that benefit lowest-balance domains
    // 2. Prefer shorter cooldown goals
    
    final domainValues = {for (var d in domains) d.id: d.value};
    
    availableGoals.sort((a, b) {
      // Get average domain value for each goal
      final avgA = a.domains.isEmpty 
        ? 50.0 
        : a.domains.fold(0.0, (sum, id) => sum + (domainValues[id] ?? 50.0)) / a.domains.length;
      final avgB = b.domains.isEmpty 
        ? 50.0 
        : b.domains.fold(0.0, (sum, id) => sum + (domainValues[id] ?? 50.0)) / b.domains.length;
      
      // Lower average domain value = higher priority (rank first)
      if ((avgA - avgB).abs() > 5) return avgA.compareTo(avgB);
      
      // Tiebreaker: prefer shorter cooldown
      return a.cooldownDurationHours.compareTo(b.cooldownDurationHours);
    });

    // Select top 3, ensuring diversity of domains when possible
    final selected = <Goal>[];
    final usedDomains = <String>{};
    
    for (var goal in availableGoals) {
      if (selected.length >= 3) break;
      
      // Prefer goals with domains not yet represented
      final newDomains = goal.domains.where((d) => !usedDomains.contains(d)).toList();
      if (newDomains.isNotEmpty || selected.length < 2) {
        selected.add(goal);
        usedDomains.addAll(goal.domains);
      }
    }
    
    // If we don't have 3, add remaining available goals
    for (var goal in availableGoals) {
      if (selected.length >= 3) break;
      if (!selected.contains(goal)) {
        selected.add(goal);
      }
    }
    
    return selected;
  }
}

// ============================================================================
// HOME SCREEN
// ============================================================================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<Domain> domains;
  late List<Goal> goals;
  late List<Goal> suggestedGoals;
  late UserProfile profile;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    domains = StorageService.getDomains();
    goals = StorageService.getGoals();
    profile = StorageService.getUserProfile();
    
    // Apply score decay
    await StorageService.applyScoreDecay(domains);
    await StorageService.saveDomains(domains);
    
    suggestedGoals = SuggestionEngine.getSuggestedGoals(goals, domains);
    
    if (mounted) {
      setState(() {
        _initialized = true;
      });
    }
  }

  String _getSimpleFeedback() {
    double avg = domains.fold(0.0, (sum, d) => sum + d.value) / domains.length;
    final sortedDomains = [...domains];
    sortedDomains.sort((a, b) => a.value.compareTo(b.value));
    
    final lowestDomain = sortedDomains.first;
    final maxDiff = (sortedDomains.last.value - sortedDomains.first.value).abs();
    
    // Context-aware feedback based on user settings
    if (avg < 25) {
      return 'You are depleted. Rest and nurture yourself.';
    } else if (avg < 40) {
      // Customize by biome
      if (profile.biome == 'desert') {
        return 'Water systems need attention in dry climates.';
      } else if (profile.biome == 'boreal' || profile.biome == 'mountain') {
        return 'Cold climate prep is important right now.';
      }
      return '${lowestDomain.name} needs your attention.';
    } else if (maxDiff > 50) {
      // Customize by acreage
      if (profile.acreage > 2) {
        return 'Land maintenance is falling behind.';
      } else if (profile.acreage <= 0.25) {
        return 'Focus on efficient use of limited space.';
      }
      return 'Drift detected in ${lowestDomain.name}.';
    } else if (maxDiff < 15) {
      return 'You are in balance.';
    } else {
      // Customize by urban status
      if (profile.urbanStatus == 'rural') {
        return 'Check in with nearby community.';
      }
      return 'Working towards harmony.';
    }
  }

  Widget _buildSuggestedGoalCard(Goal goal) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10.0),
      elevation: 0,
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.title,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      const SizedBox(height: 4.0),
                      Row(
                        children: goal.domains.map((domainId) {
                          final domain = domains.firstWhere((d) => d.id == domainId);
                          return Padding(
                            padding: const EdgeInsets.only(right: 6.0),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: domain.color.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                domain.name,
                                style: TextStyle(fontSize: 11, color: domain.color, fontWeight: FontWeight.w600),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _completeGoal(goal),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[300],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  child: const Text('Done', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
            if (goal.description != null) ...[
              const SizedBox(height: 8.0),
              GestureDetector(
                onTap: () => _showGoalDescription(goal),
                child: Text(
                  goal.description!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Center(
                child: Text(
                  'Tap to expand',
                  style: TextStyle(fontSize: 10, color: Colors.blue[400]),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showGoalDescription(Goal goal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(goal.title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (goal.description != null) ...[
                Text(goal.description!, style: const TextStyle(height: 1.5)),
                const SizedBox(height: 16.0),
              ],
              Text(
                'Domains: ${goal.domains.map((id) => domains.firstWhere((d) => d.id == id).name).join(', ')}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8.0),
              const Text('Impact by domain:'),
              ...goal.domainImpacts.entries.map((e) {
                final domain = domains.firstWhere((d) => d.id == e.key);
                final value = e.value;
                final sign = value > 0 ? '+' : '';
                return Text('  ${domain.name}: $sign$value');
              }),
              const SizedBox(height: 8.0),
              Text('Cooldown: ${goal.getCooldownStatus()}'),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  void _completeGoal(Goal goal) {
    setState(() {
      goal.lastCompletedTime = DateTime.now();
      
      // Award points based on domain-specific impacts
      for (final domain in domains) {
        if (goal.domainImpacts.containsKey(domain.id)) {
          final impact = goal.domainImpacts[domain.id]!.toDouble();
          domain.value = (domain.value + impact).clamp(0.0, 100.0);
        }
      }
    });

    StorageService.saveGoals(goals);
    StorageService.saveDomains(domains);
    
    // Refresh suggestions
    setState(() {
      suggestedGoals = SuggestionEngine.getSuggestedGoals(goals, domains);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Completed: ${goal.title}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return Scaffold(
        appBar: AppBar(title: const Text('Earthling Root')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final values = domains.map((d) => d.value).toList();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Earthling Root'),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Feedback Message (TOP - CENTERED)
              Center(
                child: Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: Colors.green[200]!, width: 1),
                  ),
                  child: Text(
                    _getSimpleFeedback(),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.green[800],
                      height: 1.4,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20.0),

              // Radar Chart (PRIMARY)
              Center(
                child: SizedBox(
                  width: 280,
                  height: 280,
                  child: CustomPaint(
                    painter: RadarChartPainter(domains: domains, values: values),
                  ),
                ),
              ),
              const SizedBox(height: 20.0),

              // Balance Bars (SECONDARY)
              Text('Your Balance', style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600, color: Colors.grey[600])),
              const SizedBox(height: 12.0),
              ...domains.map((d) => Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(d.icon, color: d.color, size: 18),
                            const SizedBox(width: 8.0),
                            Text(d.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                          ],
                        ),
                        Text(d.value.toStringAsFixed(0), style: TextStyle(fontWeight: FontWeight.bold, color: d.color, fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 4.0),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3.0),
                      child: LinearProgressIndicator(
                        value: d.value / 100,
                        minHeight: 6.0,
                        backgroundColor: d.color.withOpacity(0.15),
                        valueColor: AlwaysStoppedAnimation<Color>(d.color),
                      ),
                    ),
                  ],
                ),
              )),
              const SizedBox(height: 24.0),

              // Suggested Goals
              Text(
                'What to tend next',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600, color: Colors.grey[600]),
              ),
              const SizedBox(height: 12.0),
              if (suggestedGoals.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    child: Text(
                      'All goals on cooldown. Rest well!',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
                    ),
                  ),
                )
              else
                ...suggestedGoals.map((goal) => _buildSuggestedGoalCard(goal)),
              const SizedBox(height: 12.0),
            ],
          ),
        ),
      ),
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
  late List<Domain> domains;

  @override
  void initState() {
    super.initState();
    goals = StorageService.getGoals();
    domains = StorageService.getDomains();
  }

  void _addGoal() {
    showDialog(
      context: context,
      builder: (context) => _AddGoalDialog(
        domains: domains,
        onAdd: (title, selectedDomains, impactValue, cooldownHours, isRepeatable) {
          setState(() {
            goals.add(Goal(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              title: title,
              domains: selectedDomains,
              domainImpacts: {for (final domain in selectedDomains) domain: impactValue},
              cooldownDurationHours: cooldownHours,
              isRepeatable: isRepeatable,
            ));
          });
          StorageService.saveGoals(goals);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _editGoal(int index, Goal goal) {
    showDialog(
      context: context,
      builder: (context) => _EditGoalDialog(
        goal: goal,
        domains: domains,
        onEdit: (updatedGoal) {
          setState(() {
            goals[index] = updatedGoal;
          });
          StorageService.saveGoals(goals);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _deleteGoal(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Goal'),
        content: const Text('Delete permanently? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                goals.removeAt(index);
              });
              StorageService.saveGoals(goals);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final repeatableGoals = goals.where((g) => g.isRepeatable).toList();
    final finiteGoals = goals.where((g) => !g.isRepeatable).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Goals & Aspirations')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (finiteGoals.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Finite Goals',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    IconButton(icon: const Icon(Icons.add), onPressed: _addGoal),
                  ],
                ),
                const SizedBox(height: 12.0),
                ...finiteGoals.map((g) => _buildGoalTile(goals.indexOf(g), g)),
                const SizedBox(height: 24.0),
              ],
              if (repeatableGoals.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Repeating Goals',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    if (finiteGoals.isEmpty)
                      IconButton(icon: const Icon(Icons.add), onPressed: _addGoal),
                  ],
                ),
                const SizedBox(height: 12.0),
                ...repeatableGoals.map((g) => _buildGoalTile(goals.indexOf(g), g)),
              ],
              if (goals.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.flag_outlined, size: 48, color: Colors.grey[400]),
                        const SizedBox(height: 12.0),
                        Text('No goals yet',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: Colors.grey[500])),
                        const SizedBox(height: 12.0),
                        ElevatedButton.icon(
                          onPressed: _addGoal,
                          icon: const Icon(Icons.add),
                          label: const Text('Add Goal'),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: goals.isNotEmpty
          ? FloatingActionButton(
              onPressed: _addGoal,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildGoalTile(int index, Goal goal) {
    final cooldownStatus = goal.getCooldownStatus();
    final isOnCooldown = !goal.isAvailable();

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 0,
      color: isOnCooldown ? Colors.grey[100] : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => _showGoalDetails(goal),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(goal.title,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isOnCooldown ? Colors.grey[500] : Colors.black,
                                )),
                        const SizedBox(height: 6.0),
                        Wrap(
                          spacing: 6,
                          children: goal.domains.map((domainId) {
                            final domain =
                                domains.firstWhere((d) => d.id == domainId);
                            return Chip(
                              label: Text(domain.name,
                                  style:
                                      const TextStyle(fontSize: 11, color: Colors.white)),
                              backgroundColor: domain.color,
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('${goal.getTotalImpact()} pts',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 12)),
                      const SizedBox(height: 4.0),
                      Text(cooldownStatus,
                          style: TextStyle(
                              fontSize: 11,
                              color: isOnCooldown ? Colors.grey[500] : Colors.blue)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: isOnCooldown ? null : () => _completeGoal(goal),
                  icon: const Icon(Icons.check),
                  label: const Text('Complete'),
                ),
                ElevatedButton.icon(
                  onPressed: () => _editGoal(index, goal),
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[700],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteGoal(index),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showGoalDetails(Goal goal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(goal.title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (goal.description != null) ...[
                Text(goal.description!, style: const TextStyle(height: 1.5)),
                const SizedBox(height: 16.0),
              ],
              Text(
                'Domains: ${goal.domains.map((id) => domains.firstWhere((d) => d.id == id).name).join(', ')}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8.0),
              const Text('Impact by domain:'),
              ...goal.domainImpacts.entries.map((e) {
                final domain = domains.firstWhere((d) => d.id == e.key);
                final value = e.value;
                final sign = value > 0 ? '+' : '';
                return Text('  ${domain.name}: $sign$value');
              }),
              const SizedBox(height: 8.0),
              Text('Cooldown: ${goal.getCooldownStatus()}'),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  void _completeGoal(Goal goal) {
    setState(() {
      goal.lastCompletedTime = DateTime.now();
      
      for (final domain in domains) {
        if (goal.domainImpacts.containsKey(domain.id)) {
          final impact = goal.domainImpacts[domain.id]!.toDouble();
          domain.value = (domain.value + impact).clamp(0.0, 100.0);
        }
      }
    });
    StorageService.saveGoals(goals);
    StorageService.saveDomains(domains);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Completed: ${goal.title}')),
    );
  }
}

class _AddGoalDialog extends StatefulWidget {
  final List<Domain> domains;
  final Function(String, List<String>, int, double, bool) onAdd;
  const _AddGoalDialog({required this.domains, required this.onAdd});

  @override
  State<_AddGoalDialog> createState() => _AddGoalDialogState();
}

class _AddGoalDialogState extends State<_AddGoalDialog> {
  late TextEditingController titleController;
  late TextEditingController impactController;
  late TextEditingController cooldownController;
  late Set<String> selectedDomains;
  bool isRepeatable = true;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController();
    impactController = TextEditingController(text: '15');
    cooldownController = TextEditingController(text: '24');
    selectedDomains = {};
  }

  @override
  void dispose() {
    titleController.dispose();
    impactController.dispose();
    cooldownController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Goal'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Goal Title',
                hintText: 'e.g., Water the garden',
              ),
            ),
            const SizedBox(height: 16.0),
            Text('Domains', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8.0),
            Wrap(
              spacing: 8,
              children: widget.domains.map((domain) {
                final isSelected = selectedDomains.contains(domain.id);
                return FilterChip(
                  label: Text(domain.name),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        selectedDomains.add(domain.id);
                      } else {
                        selectedDomains.remove(domain.id);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: impactController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Impact Points',
                hintText: '15',
              ),
            ),
            const SizedBox(height: 12.0),
            TextField(
              controller: cooldownController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Cooldown (hours)',
                hintText: '24',
              ),
            ),
            const SizedBox(height: 12.0),
            CheckboxListTile(
              title: const Text('Repeating Goal'),
              value: isRepeatable,
              onChanged: (v) => setState(() => isRepeatable = v ?? true),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            if (titleController.text.isNotEmpty && selectedDomains.isNotEmpty) {
              final impact = int.tryParse(impactController.text) ?? 15;
              final cooldown = double.tryParse(cooldownController.text) ?? 24;
              widget.onAdd(titleController.text, selectedDomains.toList(), impact, cooldown, isRepeatable);
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}

// Edit Goal Dialog
class _EditGoalDialog extends StatefulWidget {
  final Goal goal;
  final List<Domain> domains;
  final Function(Goal) onEdit;

  const _EditGoalDialog({
    required this.goal,
    required this.domains,
    required this.onEdit,
  });

  @override
  State<_EditGoalDialog> createState() => _EditGoalDialogState();
}

class _EditGoalDialogState extends State<_EditGoalDialog> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController cooldownController;
  late Set<String> selectedDomains;
  late Map<String, int> domainImpacts;
  bool isRepeatable = true;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.goal.title);
    descriptionController = TextEditingController(text: widget.goal.description ?? '');
    cooldownController = TextEditingController(text: widget.goal.cooldownDurationHours.toStringAsFixed(1));
    selectedDomains = Set.from(widget.goal.domains);
    domainImpacts = Map.from(widget.goal.domainImpacts);
    isRepeatable = widget.goal.isRepeatable;
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    cooldownController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Goal'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Goal Title',
                hintText: 'e.g., Water the garden',
              ),
            ),
            const SizedBox(height: 12.0),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                hintText: 'Add more details...',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16.0),
            Text('Domains', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8.0),
            Wrap(
              spacing: 8,
              children: widget.domains.map((domain) {
                final isSelected = selectedDomains.contains(domain.id);
                return FilterChip(
                  label: Text(domain.name),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        selectedDomains.add(domain.id);
                        domainImpacts[domain.id] = 5; // Default impact
                      } else {
                        selectedDomains.remove(domain.id);
                        domainImpacts.remove(domain.id);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16.0),
            Text('Impact per Domain', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8.0),
            ...selectedDomains.map((domainId) {
              final domain = widget.domains.firstWhere((d) => d.id == domainId);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(domain.name),
                    ),
                    SizedBox(
                      width: 60,
                      child: TextField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: '${domainImpacts[domainId] ?? 5}',
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
                        ),
                        onChanged: (value) {
                          final impact = int.tryParse(value);
                          if (impact != null) {
                            domainImpacts[domainId] = impact;
                          }
                        },
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            const SizedBox(height: 12.0),
            TextField(
              controller: cooldownController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Cooldown (hours)',
                hintText: '24',
              ),
            ),
            const SizedBox(height: 12.0),
            CheckboxListTile(
              title: const Text('Repeating Goal'),
              value: isRepeatable,
              onChanged: (v) => setState(() => isRepeatable = v ?? true),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            if (titleController.text.isNotEmpty && selectedDomains.isNotEmpty) {
              final updatedGoal = Goal(
                id: widget.goal.id,
                title: titleController.text,
                description: descriptionController.text.isNotEmpty ? descriptionController.text : null,
                domains: selectedDomains.toList(),
                domainImpacts: domainImpacts,
                cooldownDurationHours: double.tryParse(cooldownController.text) ?? 24,
                isRepeatable: isRepeatable,
                lastCompletedTime: widget.goal.lastCompletedTime,
              );
              widget.onEdit(updatedGoal);
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange[700]),
          child: const Text('Save'),
        ),
      ],
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

  Widget _buildThemeSelector() {
    final themes = {
      'light': {'label': '☀️ Light', 'color': Colors.white},
      'dark': {'label': '🌙 Dark', 'color': Colors.grey[900]},
      'land': {'label': '🌱 Land', 'color': const Color(0xFF4CAF50)},
      'mind': {'label': '💡 Mind', 'color': const Color(0xFF2196F3)},
      'body': {'label': '❤️ Body', 'color': const Color(0xFFFF5722)},
      'community': {'label': '👥 Community', 'color': const Color(0xFF9C27B0)},
      'joy': {'label': '⭐ Joy', 'color': const Color(0xFFFFC107)},
    };

    return Column(
      children: themes.entries.map((entry) {
        final themeId = entry.key;
        final themeData = entry.value;
        final isSelected = profile.appTheme == themeId;

        return Card(
          margin: const EdgeInsets.only(bottom: 8.0),
          elevation: isSelected ? 4 : 0,
          color: isSelected ? Colors.blue[50] : Colors.white,
          child: ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: themeData['color'] as Color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.blue : Colors.transparent,
                  width: 3,
                ),
              ),
            ),
            title: Text(
              themeData['label'] as String,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.blue : Colors.black,
              ),
            ),
            trailing: isSelected ? const Icon(Icons.check_circle, color: Colors.blue) : null,
            onTap: () {
              setState(() {
                profile.appTheme = themeId;
              });
              StorageService.saveUserProfile(profile);
              widget.onSettingsChanged?.call();
            },
          ),
        );
      }).toList(),
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
              
              // Growing Zone
              Text('Growing Zone (USDA)', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8.0),
              DropdownButton<String>(
                isExpanded: true,
                value: profile.growingZone,
                items: const [
                  DropdownMenuItem(value: '1', child: Text('Zone 1 (-50°F and below)')),
                  DropdownMenuItem(value: '2', child: Text('Zone 2 (-40°F to -50°F)')),
                  DropdownMenuItem(value: '3', child: Text('Zone 3 (-30°F to -40°F)')),
                  DropdownMenuItem(value: '4', child: Text('Zone 4 (-20°F to -30°F)')),
                  DropdownMenuItem(value: '5', child: Text('Zone 5 (-10°F to -20°F)')),
                  DropdownMenuItem(value: '6', child: Text('Zone 6 (0°F to -10°F)')),
                  DropdownMenuItem(value: '7', child: Text('Zone 7 (10°F to 0°F)')),
                  DropdownMenuItem(value: '8', child: Text('Zone 8 (20°F to 10°F)')),
                  DropdownMenuItem(value: '9', child: Text('Zone 9 (30°F to 20°F)')),
                  DropdownMenuItem(value: '10', child: Text('Zone 10 (40°F to 30°F)')),
                  DropdownMenuItem(value: '11', child: Text('Zone 11 (45°F to 40°F)')),
                  DropdownMenuItem(value: '12', child: Text('Zone 12 (50°F to 45°F)')),
                  DropdownMenuItem(value: '13', child: Text('Zone 13 (60°F and above)')),
                ],
                onChanged: (value) {
                  setState(() {
                    profile.growingZone = value ?? '5';
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
              
              // App Theme Selection
              Text('App Theme', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16.0),
              _buildThemeSelector(),
              const SizedBox(height: 32.0),
              
              // About Section
              Text('About', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12.0),
              Text(
                'Earthling Root v0.5\n\nA life balance tracker inspired by the Earthling Way philosophy. Balance your five life domains: Land, Mind, Body, Community, and Joy.\n\nWeekly themes guide your daily rituals.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
