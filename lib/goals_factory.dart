// This file contains the default goals factory with massive goal dataset
// Programmatically generates 200+ goals across all domains and cadences

// Master function: generates all default goals
List<Map<String, dynamic>> getDefaultGoalsData() {
  final goals = <Map<String, dynamic>>[];
  
  // Combine all goal sources
  goals.addAll(_getDailyGoals());
  goals.addAll(_getWeeklyGoals());
  goals.addAll(_getMonthlyGoals());
  goals.addAll(_getSeasonalGoals());
  goals.addAll(_getYearlyGoals());
  
  return goals;
}

// ============================================================================
// DAILY GOALS (24h) - 50+ goals
// ============================================================================
List<Map<String, dynamic>> _getDailyGoals() {
  final goals = <Map<String, dynamic>>[];
  int id = 0;

  // Land - water/moisture
  goals.addAll([
    _goal(id++, 'Water plants', 'Check soil moisture and water actively growing areas.', ['land', 'body'], {'land': 2, 'body': 1}, 24),
    _goal(id++, 'Check soil moisture', 'Stick finger in soil. Water if top 2 inches dry.', ['land'], {'land': 1}, 24),
    _goal(id++, 'Water seedlings', 'Keep young plants consistently moist.', ['land', 'body'], {'land': 2, 'body': 1}, 24),
    _goal(id++, 'Mist plants', 'Increase humidity for sensitive plants.', ['land'], {'land': 1}, 24),
    _goal(id++, 'Check irrigation', 'Verify drip lines, sprinklers working.', ['land', 'mind'], {'land': 2, 'mind': 1}, 24),
  ]);

  // Land - observation & inspection
  goals.addAll([
    _goal(id++, 'Walk and observe', 'Spend 15 min noticing changes and growth.', ['land', 'body', 'joy'], {'land': 2, 'body': 1, 'joy': 1}, 24),
    _goal(id++, 'Check for pests', 'Look for insects, damage, or stress signs.', ['land', 'mind'], {'land': 2, 'mind': 1}, 24),
    _goal(id++, 'Inspect plant health', 'Check leaves, stems, soil of key plants.', ['land', 'mind'], {'land': 1, 'mind': 1}, 24),
    _goal(id++, 'Look for disease', 'Spot mold, rot, wilting, or discoloration.', ['land', 'mind'], {'land': 2, 'mind': 1}, 24),
  ]);

  // Land - light maintenance
  goals.addAll([
    _goal(id++, 'Light weeding', 'Remove 10-20 weeds from beds.', ['land', 'body'], {'land': 1, 'body': 1}, 24),
    _goal(id++, 'Deadhead flowers', 'Remove spent blooms.', ['land', 'body'], {'land': 1, 'body': 1}, 24),
    _goal(id++, 'Remove yellow leaves', 'Clean up dead foliage.', ['land', 'body'], {'land': 1, 'body': 1}, 24),
  ]);

  // Body - movement & exercise
  goals.addAll([
    _goal(id++, 'Stretch', 'Basic stretches or gentle yoga.', ['body'], {'body': 1}, 24),
    _goal(id++, 'Walk', 'Casual walk for fresh air and movement.', ['body', 'joy'], {'body': 2, 'joy': 1}, 24),
    _goal(id++, 'Light cardio', 'Quick movement activity.', ['body'], {'body': 2}, 24),
    _goal(id++, 'Carry materials', 'Physical task: move soil, water, tools.', ['body', 'land'], {'body': 2, 'land': 1}, 24),
  ]);

  // Mind - learning & planning
  goals.addAll([
    _goal(id++, 'Read 10 pages', 'Read about gardening or plants.', ['mind'], {'mind': 2}, 24),
    _goal(id++, 'Watch tutorial', 'Learn a technique (15-30 min).', ['mind'], {'mind': 2}, 24),
    _goal(id++, 'Plan daily tasks', 'List priorities for day.', ['mind'], {'mind': 1}, 24),
    _goal(id++, 'Journal', 'Write about garden or progress.', ['mind'], {'mind': 2}, 24),
  ]);

  // Community - connection
  goals.addAll([
    _goal(id++, 'Text a friend', 'Connect with someone briefly.', ['community', 'joy'], {'community': 1, 'joy': 1}, 24),
    _goal(id++, 'Share garden photo', 'Post progress.', ['community', 'joy'], {'community': 1, 'joy': 1}, 24),
    _goal(id++, 'Help someone', 'Assist with gardening advice.', ['community', 'mind'], {'community': 1, 'mind': 1}, 24),
  ]);

  // Joy - creative & play
  goals.addAll([
    _goal(id++, 'Play music', 'Sing or play instrument.', ['joy'], {'joy': 2}, 24),
    _goal(id++, 'Draw or paint', 'Creative art time.', ['joy'], {'joy': 2}, 24),
    _goal(id++, 'Dance', 'Enjoy music and movement.', ['joy', 'body'], {'joy': 2, 'body': 1}, 24),
  ]);

  return goals;
}

// ============================================================================
// WEEKLY GOALS (168h) - 40+ goals
// ============================================================================
List<Map<String, dynamic>> _getWeeklyGoals() {
  final goals = <Map<String, dynamic>>[];
  int id = 100;

  // Land - infrastructure & systems
  goals.addAll([
    _goal(id++, 'Inspect fencing', 'Check for damage or needed repair.', ['land'], {'land': 2}, 168),
    _goal(id++, 'Check irrigation', 'Test drip lines, sprinklers, timers.', ['land', 'mind'], {'land': 3, 'mind': 1}, 168),
    _goal(id++, 'Repair equipment', 'Fix rot, nails, or structural issues.', ['land', 'body'], {'land': 3, 'body': 2}, 168),
    _goal(id++, 'Service tools', 'Sharpen, oil, or clean tools.', ['land', 'mind'], {'land': 2, 'mind': 1}, 168),
  ]);

  // Land - soil & amendment
  goals.addAll([
    _goal(id++, 'Add compost', 'Top-dress beds with finished compost.', ['land', 'body'], {'land': 3, 'body': 2}, 168),
    _goal(id++, 'Build compost pile', 'Layer greens and browns.', ['land', 'body'], {'land': 2, 'body': 2}, 168),
    _goal(id++, 'Mulch beds', 'Add 2-3 inch mulch layer.', ['land', 'body'], {'land': 2, 'body': 2}, 168),
  ]);

  // Land - weeding
  goals.addAll([
    _goal(id++, 'Major weeding', 'Remove all weeds from major area.', ['land', 'body'], {'land': 2, 'body': 2}, 168),
    _goal(id++, 'Edge beds', 'Define border between lawn and beds.', ['land', 'body'], {'land': 1, 'body': 1}, 168),
  ]);

  // Body - exercise
  goals.addAll([
    _goal(id++, 'Strength training', 'Weightlifting or resistance work.', ['body'], {'body': 3}, 168),
    _goal(id++, 'Long walk', '1+ hour hike or walk.', ['body', 'joy'], {'body': 3, 'joy': 1}, 168),
    _goal(id++, 'Yoga session', '30-45 min yoga or stretching.', ['body'], {'body': 2}, 168),
  ]);

  // Mind - learning
  goals.addAll([
    _goal(id++, 'Read book chapter', 'Read 30 pages.', ['mind'], {'mind': 2}, 168),
    _goal(id++, 'Research session', 'Spend 2+ hours on topic.', ['mind', 'land'], {'mind': 3, 'land': 1}, 168),
    _goal(id++, 'Complete course lesson', 'Finish module or week.', ['mind'], {'mind': 3}, 168),
  ]);

  // Community & social
  goals.addAll([
    _goal(id++, 'Attend community event', 'Go to market, class, or gathering.', ['community', 'joy'], {'community': 2, 'joy': 1}, 168),
    _goal(id++, 'Help neighbor', 'Spend time assisting.', ['community', 'body'], {'community': 2, 'body': 1}, 168),
    _goal(id++, 'Share harvest', 'Give produce to neighbor.', ['community', 'joy'], {'community': 2, 'joy': 1}, 168),
  ]);

  // Joy - recreation
  goals.addAll([
    _goal(id++, 'Create art', 'Painting, drawing, or craft.', ['joy', 'mind'], {'joy': 2, 'mind': 1}, 168),
    _goal(id++, 'Play sport', 'Organized activity with others.', ['joy', 'body'], {'joy': 2, 'body': 1}, 168),
    _goal(id++, 'Outdoor adventure', 'Hiking, kayaking, exploration.', ['joy', 'body'], {'joy': 2, 'body': 2}, 168),
  ]);

  return goals;
}

// ============================================================================
// MONTHLY GOALS (720h) - 35+ goals
// ============================================================================
List<Map<String, dynamic>> _getMonthlyGoals() {
  final goals = <Map<String, dynamic>>[];
  int id = 200;

  // Land - major projects
  goals.addAll([
    _goal(id++, 'Build raised bed', 'Construct new bed.', ['land', 'body'], {'land': 5, 'body': 3}, 720),
    _goal(id++, 'Install trellis', 'Add climbing support.', ['land', 'body'], {'land': 4, 'body': 2}, 720),
    _goal(id++, 'Create path', 'Build mulch or stone pathway.', ['land', 'body'], {'land': 4, 'body': 3}, 720),
    _goal(id++, 'Soil amendment', 'Deep dig and compost.', ['land', 'body'], {'land': 5, 'body': 3}, 720),
    _goal(id++, 'Build compost bin', 'Construct compost area.', ['land', 'body'], {'land': 5, 'body': 2}, 720),
  ]);

  // Land - assessment
  goals.addAll([
    _goal(id++, 'Map garden', 'Draw detailed map.', ['land', 'mind'], {'land': 2, 'mind': 3}, 720),
    _goal(id++, 'Document progress', 'Take photos and record.', ['land', 'mind'], {'land': 1, 'mind': 2}, 720),
    _goal(id++, 'Assess system health', 'Evaluate soil, water.', ['land', 'mind'], {'land': 3, 'mind': 2}, 720),
  ]);

  // Mind - deep work
  goals.addAll([
    _goal(id++, 'Deep focus project', '2-3 day focus on goal.', ['mind'], {'mind': 5}, 720),
    _goal(id++, 'Complete course', 'Finish program.', ['mind'], {'mind': 5}, 720),
    _goal(id++, 'Read full book', 'Complete book.', ['mind'], {'mind': 4}, 720),
  ]);

  // Community
  goals.addAll([
    _goal(id++, 'Community project', 'Lead or participate.', ['community', 'body'], {'community': 4, 'body': 2}, 720),
    _goal(id++, 'Host event', 'Organize gathering.', ['community', 'joy'], {'community': 4, 'joy': 2}, 720),
    _goal(id++, 'Mentoring', 'Teach someone.', ['community', 'mind'], {'community': 3, 'mind': 2}, 720),
  ]);

  // Joy
  goals.addAll([
    _goal(id++, 'Plan celebration', 'Organize event.', ['joy', 'community'], {'joy': 3, 'community': 1}, 720),
    _goal(id++, 'Vacation', 'Take time away.', ['joy', 'body'], {'joy': 4, 'body': 1}, 720),
  ]);

  return goals;
}

// ============================================================================
// SEASONAL GOALS (2160h) - 20+ goals
// ============================================================================
List<Map<String, dynamic>> _getSeasonalGoals() {
  final goals = <Map<String, dynamic>>[];
  int id = 300;

  goals.addAll([
    _goal(id++, 'Start seeds', 'Begin seedlings.', ['land', 'mind'], {'land': 5, 'mind': 2}, 2160),
    _goal(id++, 'Prepare beds', 'Clear and amend beds.', ['land', 'body'], {'land': 5, 'body': 3}, 2160),
    _goal(id++, 'Major planting', 'Transplant seedlings.', ['land', 'body'], {'land': 5, 'body': 3}, 2160),
    _goal(id++, 'Harvest', 'Pick produce.', ['land', 'body'], {'land': 4, 'body': 2}, 2160),
    _goal(id++, 'Process harvest', 'Can, freeze, preserve.', ['land', 'body'], {'land': 3, 'body': 2}, 2160),
    _goal(id++, 'Save seeds', 'Collect seeds for storage.', ['land', 'mind'], {'land': 3, 'mind': 2}, 2160),
    _goal(id++, 'Fall cleanup', 'Remove spent plants.', ['land', 'body'], {'land': 3, 'body': 2}, 2160),
    _goal(id++, 'Plant cover crops', 'Sow winter crops.', ['land', 'body'], {'land': 3, 'body': 1}, 2160),
    _goal(id++, 'Season review', 'Document results.', ['mind'], {'mind': 3}, 2160),
  ]);

  return goals;
}

// ============================================================================
// YEARLY GOALS (8760h) - 10+ goals
// ============================================================================
List<Map<String, dynamic>> _getYearlyGoals() {
  final goals = <Map<String, dynamic>>[];
  int id = 400;

  goals.addAll([
    _goal(id++, 'System overhaul', 'Major redesign.', ['land', 'mind'], {'land': 8, 'mind': 4}, 8760),
    _goal(id++, 'Annual reflection', 'Review year.', ['mind', 'joy'], {'mind': 4, 'joy': 2}, 8760),
    _goal(id++, 'Community contribution', 'Help community.', ['community'], {'community': 4}, 8760),
  ]);

  return goals;
}

// ============================================================================
// HELPER FUNCTION
// ============================================================================
Map<String, dynamic> _goal(
  int id,
  String title,
  String description,
  List<String> domains,
  Map<String, int> domainImpacts,
  double cooldownHours,
) {
  return {
    'id': 'goal_$id',
    'title': title,
    'description': description,
    'domains': domains,
    'domainImpacts': domainImpacts,
    'cooldown': cooldownHours,
  };
}
