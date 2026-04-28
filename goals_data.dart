// Default goals dataset for Earthling Root
// This file is used to generate the comprehensive goal list
// Format: Goal definitions with domain-specific impacts

final defaultGoalsData = [
  // ============================================================================
  // DAILY GOALS (24h) - LAND FOCUS
  // ============================================================================
  {
    'id': 'goal_water_daily',
    'title': 'Water plants & garden',
    'description': 'Check soil moisture and water all active growing areas.',
    'domains': ['land', 'body'],
    'domainImpacts': {'land': 3, 'body': 1},
    'cooldown': 24.0,
  },
  {
    'id': 'goal_observe_land',
    'title': 'Walk and observe',
    'description': 'Spend 20 min walking your property, noting changes and issues.',
    'domains': ['land', 'body', 'joy'],
    'domainImpacts': {'land': 2, 'body': 2, 'joy': 1},
    'cooldown': 24.0,
  },
  {
    'id': 'goal_inspect_plants',
    'title': 'Check for pests/disease',
    'description': 'Look for signs of pest damage, disease, or stress on plants.',
    'domains': ['land', 'mind'],
    'domainImpacts': {'land': 2, 'mind': 2},
    'cooldown': 24.0,
  },
  {
    'id': 'goal_mulch_task',
    'title': 'Mulch or weeding task',
    'description': 'Spend 15 min on mulching, pulling weeds, or light garden maintenance.',
    'domains': ['land', 'body'],
    'domainImpacts': {'land': 2, 'body': 3},
    'cooldown': 24.0,
  },

  // ============================================================================
  // DAILY GOALS (24h) - BODY & MOVEMENT FOCUS
  // ============================================================================
  {
    'id': 'goal_stretch',
    'title': 'Stretch (5-10 min)',
    'description': 'Do basic stretching, yoga, or light mobility work.',
    'domains': ['body'],
    'domainImpacts': {'body': 1},
    'cooldown': 24.0,
  },
  {
    'id': 'goal_walk',
    'title': 'Walk (20 min)',
    'description': 'Take a casual walk for fresh air and movement.',
    'domains': ['body', 'joy'],
    'domainImpacts': {'body': 2, 'joy': 1},
    'cooldown': 24.0,
  },
  {
    'id': 'goal_carry_lift',
    'title': 'Carry or lift something',
    'description': 'Move materials, carry water, lift tools - builds strength.',
    'domains': ['body', 'land'],
    'domainImpacts': {'body': 3, 'land': 1},
    'cooldown': 24.0,
  },
  {
    'id': 'goal_hands_on_work',
    'title': 'Hands-on work (30 min)',
    'description': 'Dig, plant, harvest, build - physical garden work.',
    'domains': ['body', 'land', 'joy'],
    'domainImpacts': {'body': 3, 'land': 3, 'joy': 1},
    'cooldown': 24.0,
  },

  // ============================================================================
  // DAILY GOALS (24h) - MIND & LEARNING FOCUS
  // ============================================================================
  {
    'id': 'goal_read',
    'title': 'Read (10 pages)',
    'description': 'Read about gardening, ecology, or related topics.',
    'domains': ['mind'],
    'domainImpacts': {'mind': 2},
    'cooldown': 24.0,
  },
  {
    'id': 'goal_journal',
    'title': 'Journal or reflect',
    'description': 'Write about observations, plans, or progress.',
    'domains': ['mind', 'joy'],
    'domainImpacts': {'mind': 2, 'joy': 1},
    'cooldown': 24.0,
  },
  {
    'id': 'goal_learn_skill',
    'title': 'Learn a skill',
    'description': 'Watch a tutorial, research a technique, practice something new.',
    'domains': ['mind'],
    'domainImpacts': {'mind': 3},
    'cooldown': 24.0,
  },
  {
    'id': 'goal_plan',
    'title': 'Plan next actions',
    'description': 'Sketch designs, plan planting schedule, organize tasks.',
    'domains': ['mind', 'land'],
    'domainImpacts': {'mind': 2, 'land': 2},
    'cooldown': 24.0,
  },

  // ============================================================================
  // DAILY GOALS (24h) - COMMUNITY & JOY FOCUS
  // ============================================================================
  {
    'id': 'goal_connect',
    'title': 'Connect with someone',
    'description': 'Share a meal, have a conversation, message a friend.',
    'domains': ['community', 'joy'],
    'domainImpacts': {'community': 2, 'joy': 2},
    'cooldown': 24.0,
  },
  {
    'id': 'goal_share_produce',
    'title': 'Share harvest or knowledge',
    'description': 'Give away extra produce, share photos, offer advice.',
    'domains': ['community', 'land', 'joy'],
    'domainImpacts': {'community': 2, 'land': 1, 'joy': 2},
    'cooldown': 24.0,
  },
  {
    'id': 'goal_play',
    'title': 'Play or create',
    'description': 'Music, art, games, or any creative/playful activity.',
    'domains': ['joy'],
    'domainImpacts': {'joy': 3},
    'cooldown': 24.0,
  },
  {
    'id': 'goal_rest',
    'title': 'Rest or relax',
    'description': 'Take 30 min to rest without guilt. Nap, sit, enjoy stillness.',
    'domains': ['body', 'joy'],
    'domainImpacts': {'body': 1, 'joy': 2},
    'cooldown': 24.0,
  },

  // ============================================================================
  // WEEKLY GOALS (168h) - LAND INFRASTRUCTURE
  // ============================================================================
  {
    'id': 'goal_repair_fence',
    'title': 'Repair fence or gate',
    'description': 'Fix damaged fencing, replace posts, repair hinges.',
    'domains': ['land', 'mind', 'body'],
    'domainImpacts': {'land': 5, 'mind': 2, 'body': 3},
    'cooldown': 168.0,
  },
  {
    'id': 'goal_soil_work',
    'title': 'Soil amendment work',
    'description': 'Add compost, mulch, manure. Build or turn compost pile.',
    'domains': ['land', 'body'],
    'domainImpacts': {'land': 5, 'body': 3},
    'cooldown': 168.0,
  },
  {
    'id': 'goal_irrigation_check',
    'title': 'Check irrigation system',
    'description': 'Inspect hoses, drip lines, timers. Repair leaks.',
    'domains': ['land', 'mind'],
    'domainImpacts': {'land': 4, 'mind': 2},
    'cooldown': 168.0,
  },
  {
    'id': 'goal_tool_maintenance',
    'title': 'Service tools',
    'description': 'Clean, sharpen, or oil tools. Fix or replace broken items.',
    'domains': ['land', 'body', 'mind'],
    'domainImpacts': {'land': 3, 'body': 1, 'mind': 2},
    'cooldown': 168.0,
  },
  {
    'id': 'goal_path_maint',
    'title': 'Maintain paths',
    'description': 'Rake, weed, or improve pathways. Check for hazards.',
    'domains': ['land', 'body'],
    'domainImpacts': {'land': 3, 'body': 2},
    'cooldown': 168.0,
  },

  // ============================================================================
  // WEEKLY GOALS (168h) - COMMUNITY & LEARNING
  // ============================================================================
  {
    'id': 'goal_deep_work',
    'title': 'Deep work session',
    'description': '2+ hours of focused work on a significant project.',
    'domains': ['mind', 'land', 'joy'],
    'domainImpacts': {'mind': 4, 'land': 2, 'joy': 1},
    'cooldown': 168.0,
  },
  {
    'id': 'goal_community_event',
    'title': 'Community involvement',
    'description': 'Attend event, help neighbor, join a group or class.',
    'domains': ['community', 'mind', 'body'],
    'domainImpacts': {'community': 4, 'mind': 1, 'body': 1},
    'cooldown': 168.0,
  },
  {
    'id': 'goal_neighbor_check',
    'title': 'Check on neighbors',
    'description': 'Visit or call neighbors. Share resources or knowledge.',
    'domains': ['community', 'joy'],
    'domainImpacts': {'community': 3, 'joy': 2},
    'cooldown': 168.0,
  },
  {
    'id': 'goal_research',
    'title': 'Research topic',
    'description': 'Deep dive into a gardening/land topic. Take notes.',
    'domains': ['mind', 'land'],
    'domainImpacts': {'mind': 4, 'land': 2},
    'cooldown': 168.0,
  },

  // ============================================================================
  // MONTHLY GOALS (720h) - LARGE PROJECTS
  // ============================================================================
  {
    'id': 'goal_bed_expansion',
    'title': 'Expand growing space',
    'description': 'Build a new bed, expand an existing one, or prepare new area.',
    'domains': ['land', 'body', 'mind'],
    'domainImpacts': {'land': 8, 'body': 4, 'mind': 2},
    'cooldown': 720.0,
  },
  {
    'id': 'goal_infrastructure',
    'title': 'Install infrastructure',
    'description': 'Trellis, pergola, shed, water storage, or permanent structure.',
    'domains': ['land', 'body', 'mind'],
    'domainImpacts': {'land': 10, 'body': 5, 'mind': 3},
    'cooldown': 720.0,
  },
  {
    'id': 'goal_system_overhaul',
    'title': 'System overhaul',
    'description': 'Major improvement: redesign beds, upgrade irrigation, reorganize layout.',
    'domains': ['land', 'mind', 'body'],
    'domainImpacts': {'land': 10, 'mind': 5, 'body': 3},
    'cooldown': 720.0,
  },
  {
    'id': 'goal_document_system',
    'title': 'Document your system',
    'description': 'Map layout, photograph beds, create records. Build knowledge base.',
    'domains': ['mind', 'land'],
    'domainImpacts': {'mind': 6, 'land': 3},
    'cooldown': 720.0,
  },
  {
    'id': 'goal_pest_solution',
    'title': 'Implement pest solution',
    'description': 'Deploy traps, introduce beneficial insects, or create barriers.',
    'domains': ['land', 'mind'],
    'domainImpacts': {'land': 6, 'mind': 3},
    'cooldown': 720.0,
  },

  // ============================================================================
  // SEASONAL GOALS (2160h) - PLANTING & HARVESTING
  // ============================================================================
  {
    'id': 'goal_seed_start',
    'title': 'Start seeds',
    'description': 'Start seeds indoors or direct sow for season.',
    'domains': ['land', 'mind', 'joy'],
    'domainImpacts': {'land': 8, 'mind': 2, 'joy': 2},
    'cooldown': 2160.0,
  },
  {
    'id': 'goal_major_plant',
    'title': 'Major planting',
    'description': 'Transplant seedlings or plant crops for upcoming season.',
    'domains': ['land', 'body', 'joy'],
    'domainImpacts': {'land': 8, 'body': 4, 'joy': 2},
    'cooldown': 2160.0,
  },
  {
    'id': 'goal_harvest_preserve',
    'title': 'Harvest and preserve',
    'description': 'Pick ripe produce and process for storage.',
    'domains': ['land', 'body', 'community', 'joy'],
    'domainImpacts': {'land': 8, 'body': 3, 'community': 2, 'joy': 3},
    'cooldown': 2160.0,
  },
  {
    'id': 'goal_seed_save',
    'title': 'Save seeds',
    'description': 'Collect and store seeds from mature plants.',
    'domains': ['land', 'mind', 'joy'],
    'domainImpacts': {'land': 6, 'mind': 3, 'joy': 2},
    'cooldown': 2160.0,
  },
  {
    'id': 'goal_bed_prep',
    'title': 'Prepare beds for season',
    'description': 'Clear old plants, amend soil, prep for planting.',
    'domains': ['land', 'body', 'mind'],
    'domainImpacts': {'land': 8, 'body': 4, 'mind': 1},
    'cooldown': 2160.0,
  },

  // ============================================================================
  // YEARLY GOALS (8760h) - SEASONAL TRANSITIONS
  // ============================================================================
  {
    'id': 'goal_winter_prep',
    'title': 'Prepare for dormancy',
    'description': 'Protect perennials, drain systems, process final harvest.',
    'domains': ['land', 'body', 'community'],
    'domainImpacts': {'land': 10, 'body': 3, 'community': 1},
    'cooldown': 8760.0,
  },
  {
    'id': 'goal_season_review',
    'title': 'Seasonal reflection',
    'description': 'Review season, celebrate wins, plan improvements for next cycle.',
    'domains': ['mind', 'joy', 'community'],
    'domainImpacts': {'mind': 5, 'joy': 3, 'community': 2},
    'cooldown': 8760.0,
  },
];
