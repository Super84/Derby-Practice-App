import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const DerbyPracticeApp());

class DerbyPracticeApp extends StatelessWidget {
  const DerbyPracticeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Derby Practice Planner',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF006D5B),
      ),
      home: const PlannerScreen(),
    );
  }
}

// --- Models --- //

enum SkillLevel { beginner, intermediate, advanced }

enum FocusArea { agility, blocking, jamming, endurance, footwork, packwork }

enum ContactLevel { none, light, full }

extension NiceName on Enum {
  String get label => name[0].toUpperCase() + name.substring(1);
}

class Drill {
  final String id;
  final String name;
  final String description;
  final List<String> goals; // clear goals for the drill
  final int minMinutes;
  final int maxMinutes;
  final Set<SkillLevel> levels;
  final Set<FocusArea> focuses;
  final ContactLevel contact;
  final Set<String> equipment;

  const Drill({
    required this.id,
    required this.name,
    required this.description,
    required this.goals,
    required this.minMinutes,
    required this.maxMinutes,
    required this.levels,
    required this.focuses,
    required this.contact,
    this.equipment = const {},
  });
}

class PracticeInputs {
  final int durationMinutes;
  final int skaterCount;
  final SkillLevel level;
  final Set<FocusArea> focusAreas;
  final ContactLevel maxContact;
  final Set<String> equipment;

  const PracticeInputs({
    required this.durationMinutes,
    required this.skaterCount,
    required this.level,
    required this.focusAreas,
    required this.maxContact,
    required this.equipment,
  });
}

class PlannedDrill {
  final Drill drill;
  final int minutes;
  const PlannedDrill(this.drill, this.minutes);
}

class PracticePlan {
  final PlannedDrill warmup;
  final List<PlannedDrill> block;
  final PlannedDrill cooldown;
  const PracticePlan({required this.warmup, required this.block, required this.cooldown});
  int get totalMinutes => warmup.minutes + cooldown.minutes + block.fold(0, (a, b) => a + b.minutes);
}

// --- Drill Catalog --- //

class DrillRepo {
  static const drills = <Drill>[
    Drill(
      id: 'wu_dynamic',
      name: 'Dynamic Warm‑Up',
      description: 'Light laps, mobility (hips/ankles), edge checks, quick feet through cones.',
      goals: [
        'Raise core temperature safely',
        'Activate hips/ankles',
        'Prime edges and stride mechanics',
      ],
      minMinutes: 5,
      maxMinutes: 10,
      levels: {SkillLevel.beginner, SkillLevel.intermediate, SkillLevel.advanced},
      focuses: {FocusArea.agility, FocusArea.endurance, FocusArea.footwork},
      contact: ContactLevel.none,
      equipment: {'cones'},
    ),
    Drill(
      id: 'agility_zigzag',
      name: 'Zig‑Zag Edge Weaves',
      description: 'Weave through staggered cones, accelerate out of cuts, hold edges under speed.',
      goals: [
        'Improve edge control',
        'Quicker transitions left/right',
        'Explosive acceleration after cuts',
      ],
      minMinutes: 6,
      maxMinutes: 12,
      levels: {SkillLevel.beginner, SkillLevel.intermediate},
      focuses: {FocusArea.agility, FocusArea.footwork},
      contact: ContactLevel.none,
      equipment: {'cones'},
    ),
    Drill(
      id: 'endurance_pyramids',
      name: 'Endurance Pyramids',
      description: 'Timed laps pyramid (1‑2‑3‑2‑1) with 1‑min recovery. Track form and pacing.',
      goals: [
        'Build cardio base and repeatability',
        'Maintain form under fatigue',
        'Pacing strategy awareness',
      ],
      minMinutes: 10,
      maxMinutes: 20,
      levels: {SkillLevel.intermediate, SkillLevel.advanced},
      focuses: {FocusArea.endurance},
      contact: ContactLevel.none,
    ),
    Drill(
      id: 'footwork_jukes',
      name: 'Jukes & Stops Circuit',
      description: 'Rotate tomahawk/plow stops to sprint; add no‑contact jukes around blockers or cones.',
      goals: [
        'Reliable stopping repertoire',
        'Explode from stop to sprint',
        'Deceptive juking mechanics',
      ],
      minMinutes: 8,
      maxMinutes: 14,
      levels: {SkillLevel.beginner, SkillLevel.intermediate, SkillLevel.advanced},
      focuses: {FocusArea.footwork, FocusArea.agility},
      contact: ContactLevel.light,
      equipment: {'cones'},
    ),
    Drill(
      id: 'blocking_walls',
      name: '2‑Wall Communication',
      description: 'Pairs form two‑walls practicing lateral movement, bracing, and lane control with legal contact.',
      goals: [
        'Tight two‑wall spacing and bracing',
        'Synchronized lateral movement',
        'Verbal/non‑verbal comms under pressure',
      ],
      minMinutes: 8,
      maxMinutes: 15,
      levels: {SkillLevel.intermediate, SkillLevel.advanced},
      focuses: {FocusArea.blocking, FocusArea.packwork},
      contact: ContactLevel.full,
    ),
    Drill(
      id: 'pack_recycle',
      name: 'Recycle & Bridge',
      description: 'Small packs practice knock‑out, recycle, and bridging to maintain pack definition.',
      goals: [
        'Legal and efficient recycling',
        'Awareness of pack definition',
        'Smart bridging to avoid penalties',
      ],
      minMinutes: 8,
      maxMinutes: 16,
      levels: {SkillLevel.intermediate, SkillLevel.advanced},
      focuses: {FocusArea.packwork, FocusArea.blocking},
      contact: ContactLevel.full,
    ),
    Drill(
      id: 'jammer_offense',
      name: 'Jam Starts & Initial',
      description: 'Jammers work starts vs passive/active walls; blockers alternate offense sweeps and tips.',
      goals: [
        'Fast, legal starts and lane choice',
        'Blocker timing for sweeps/tips',
        'Reading defense to choose tactics',
      ],
      minMinutes: 10,
      maxMinutes: 18,
      levels: {SkillLevel.intermediate, SkillLevel.advanced},
      focuses: {FocusArea.jamming, FocusArea.blocking, FocusArea.packwork},
      contact: ContactLevel.full,
    ),
    Drill(
      id: 'no_contact_tracking',
      name: 'No‑Contact Lane Tracking',
      description: 'Track a ghost jammer through lanes; hips square, quick feet, constant communication.',
      goals: [
        'Lane discipline and footwork',
        'Communication without chaos',
        'Body positioning without contact',
      ],
      minMinutes: 6,
      maxMinutes: 10,
      levels: {SkillLevel.beginner, SkillLevel.intermediate},
      focuses: {FocusArea.packwork, FocusArea.footwork},
      contact: ContactLevel.none,
    ),
    Drill(
      id: 'cooldown_mobility',
      name: 'Cooldown + Mobility',
      description: 'Light laps, breathing, hip flexor/hamstring/ankle mobility, reflection.',
      goals: [
        'Heart‑rate downshift',
        'Restore range of motion',
        'Reflect on cues to retain',
      ],
      minMinutes: 5,
      maxMinutes: 10,
      levels: {SkillLevel.beginner, SkillLevel.intermediate, SkillLevel.advanced},
      focuses: {FocusArea.endurance},
      contact: ContactLevel.none,
    ),
  ];
}

// --- Planning Logic --- //

PracticePlan buildPracticePlan(PracticeInputs input, {int seed = 42}) {
  final rng = Random(seed);

  final warmup = DrillRepo.drills.firstWhere((d) => d.id == 'wu_dynamic');
  final cooldown = DrillRepo.drills.firstWhere((d) => d.id == 'cooldown_mobility');

  final candidates = DrillRepo.drills.where((d) {
    if (d.id == warmup.id || d.id == cooldown.id) return false;
    if (!d.levels.contains(input.level)) return false;
    if (d.contact.index > input.maxContact.index) return false;
    if (!input.equipment.containsAll(d.equipment)) return false;
    if (input.focusAreas.isNotEmpty && !d.focuses.any(input.focusAreas.contains)) return false;
    return true;
  }).toList();

  const warmMin = 6;
  const coolMin = 6;
  var remaining = max(0, input.durationMinutes - warmMin - coolMin);

  final selected = <PlannedDrill>[];
  final pool = [...candidates];

  while (remaining > 0 && pool.isNotEmpty) {
    final d = pool.removeAt(rng.nextInt(pool.length));
    final chunk = d.minMinutes + rng.nextInt(max(1, d.maxMinutes - d.minMinutes + 1));
    final minutes = min(chunk, remaining);
    if (minutes >= max(6, (d.minMinutes / 2).round())) {
      selected.add(PlannedDrill(d, minutes));
      remaining -= minutes;
    }
  }

  if (remaining >= 5 && candidates.isNotEmpty) {
    candidates.sort((a, b) => b.maxMinutes.compareTo(a.maxMinutes));
    selected.add(PlannedDrill(candidates.first, remaining));
    remaining = 0;
  }

  return PracticePlan(
    warmup: PlannedDrill(warmup, warmMin),
    block: selected,
    cooldown: PlannedDrill(cooldown, coolMin),
  );
}

// --- UI --- //

class PlannerScreen extends StatefulWidget {
  const PlannerScreen({super.key});
  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  int minutes = 90;
  int skaters = 14;
  int currentIndex = 0;
  SkillLevel level = SkillLevel.intermediate;
  final Set<FocusArea> selectedFocus = {FocusArea.agility, FocusArea.packwork};
  ContactLevel maxContact = ContactLevel.full;
  final Set<String> equipment = {'cones', 'whistle'};

  PracticePlan? plan;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Derby Practice App")),
      bottomNavigationBar: NavigationBar (
        selectedIndex: currentIndex,
        destinations: const <Widget>[
          NavigationDestination(
            icon: Icon(Icons.star), 
            label: "Favorite"
          ),
          NavigationDestination(
            icon: Icon(Icons.cloud), 
            label: "Browse"
          ),
          NavigationDestination(
            icon: Icon(Icons.add), 
            label: "New Plan"
          ),
          NavigationDestination(
            icon: Icon(Icons.today), 
            label: "Calendar"
          ),
          NavigationDestination(
            icon: Icon(Icons.account_box), 
            label: "Account"
          )
        ],
        onDestinationSelected: (int index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
      body: <Widget>[
        Text("Screen Favorites"),
        SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _drillCatalogFull(),
            ]
          )
        ),
        SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text('Build Your Practice', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _numberField('Duration (min)', minutes, (v) => setState(() => minutes = v.clamp(30, 180)))),
                const SizedBox(width: 12),
                Expanded(child: _numberField('Skaters', skaters, (v) => setState(() => skaters = v.clamp(4, 40)))),
              ]),
              const SizedBox(height: 8),
              _dropdown<SkillLevel>('Skill level', level, SkillLevel.values, (v) => setState(() => level = v)),
              const SizedBox(height: 8),
              _focusChips(),
              const SizedBox(height: 8),
              _dropdown<ContactLevel>('Max contact', maxContact, ContactLevel.values, (v) => setState(() => maxContact = v)),
              const SizedBox(height: 8),
              _equipmentEditor(),
              const SizedBox(height: 12),
              Row(children: [
                FilledButton(
                  onPressed: () {
                    setState(() {
                      plan = buildPracticePlan(PracticeInputs(
                        durationMinutes: minutes,
                        skaterCount: skaters,
                        level: level,
                        focusAreas: selectedFocus,
                        maxContact: maxContact,
                        equipment: equipment,
                      ));
                    });
                  },
                  child: const Text('Generate Plan'),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: plan == null ? null : _copyToClipboard,
                  icon: const Icon(Icons.copy),
                  label: const Text('Copy Plan'),
                ),
              ]),
              const SizedBox(height: 16),
              if (plan != null) _planView(plan!),
              const SizedBox(height: 24),
              _drillCatalogFiltered(),
            ],
          ),
        ),
        Text("Screen Calendar"),
        Text("Screen Account"),
      ][currentIndex],
    );
  }

  Widget _numberField(String label, int value, ValueChanged<int> onChanged) {
    final controller = TextEditingController(text: value.toString());
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      onChanged: (text) {
        final digits = text.replaceAll(RegExp(r'[^0-9]'), '');
        onChanged(int.tryParse(digits) ?? value);
      },
    );
  }

  Widget _dropdown<T>(String label, T selected, List<T> options, ValueChanged<T> onSelect) {
    return InputDecorator(
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          isExpanded: true,
          value: selected,
          items: [
            for (final o in options)
              DropdownMenuItem<T>(value: o, child: Text((o as Enum).label)),
          ],
          onChanged: (v) => v == null ? null : onSelect(v),
        ),
      ),
    );
  }

  Widget _focusChips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Focus areas', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final fa in FocusArea.values)
            FilterChip(
              label: Text(fa.label),
              selected: selectedFocus.contains(fa),
              onSelected: (sel) => setState(() {
                if (sel) {
                  selectedFocus.add(fa);
                } else {
                  selectedFocus.remove(fa);
                }
              }),
            ),
        ]),
      ],
    );
  }

  Widget _equipmentEditor() {
    final controller = TextEditingController();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Equipment', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final item in equipment)
            InputChip(
              label: Text(item),
              onDeleted: () => setState(() => equipment.remove(item)),
            )
        ]),
        const SizedBox(height: 6),
        Row(children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(labelText: 'Add equipment', border: OutlineInputBorder()),
            ),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: () {
              final v = controller.text.trim().toLowerCase();
              if (v.isNotEmpty) setState(() => equipment.add(v));
              controller.clear();
            },
            child: const Text('Add'),
          ),
        ]),
      ],
    );
  }

  Widget _planView(PracticePlan plan) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Plan (${plan.totalMinutes} min)', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _plannedTile('Warm‑up', plan.warmup),
            const Divider(),
            for (final pd in plan.block) _plannedTile(null, pd),
            const Divider(),
            _plannedTile('Cooldown', plan.cooldown),
          ],
        ),
      ),
    );
  }

  Widget _plannedTile(String? header, PlannedDrill pd) {
    return ExpansionTile(
      title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (header != null) Text(header, style: const TextStyle(fontWeight: FontWeight.w600)),
        Text(pd.drill.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ]),
      trailing: Text('${pd.minutes} min', style: const TextStyle(fontWeight: FontWeight.w600)),
      childrenPadding: const EdgeInsets.only(bottom: 8, left: 16, right: 16),
      children: [
        _drillMeta(pd.drill),
        const SizedBox(height: 6),
        Text(pd.drill.description),
        const SizedBox(height: 6),
        const Text('Goals', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          for (final g in pd.drill.goals) Row(children: [const Text('• '), Expanded(child: Text(g))]),
        ]),
      ],
    );
  }

  Widget _drillMeta(Drill d) {
    return Wrap(spacing: 8, runSpacing: 8, children: [
      Chip(label: Text('Level: ${d.levels.map((e) => e.label).join('/') }')),
      Chip(label: Text('Contact: ${d.contact.label}')),
      Chip(label: Text('Focus: ${d.focuses.map((e) => e.label).join(', ')}')),
      if (d.equipment.isNotEmpty) Chip(label: Text('Eq: ${d.equipment.join(', ')}')),
    ]);
  }

  Widget _drillCatalogFull() {
    return _drillCatalogPreview(DrillRepo.drills);
  }

  Widget _drillCatalogFiltered() {
    // A filtered view of the catalog based on current filters
    final filtered = DrillRepo.drills.where((d) {
      if (!d.levels.contains(level)) return false;
      if (d.contact.index > maxContact.index) return false;
      if (selectedFocus.isNotEmpty && !d.focuses.any(selectedFocus.contains)) return false;
      if (!equipment.containsAll(d.equipment)) return false;
      return true;
    }).toList();

    return _drillCatalogPreview(filtered);
  }

  Widget _drillCatalogPreview(List<Drill> drills) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Matching Drills', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...drills.map((d) => Card(
              child: ListTile(
                title: Text(d.name),
                subtitle: Text(d.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(d.focuses.map((e) => e.label).join(', ')),
                    Text('Contact: ${d.contact.label}')
                  ],
                ),
                onTap: () => showModalBottomSheet(
                  context: context,
                  showDragHandle: true,
                  builder: (_) => _drillBottomSheet(d),
                ),
              ),
            )),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _drillBottomSheet(Drill d) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(d.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _drillMeta(d),
          const SizedBox(height: 8),
          Text(d.description),
          const SizedBox(height: 8),
          const Text('Goals', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          ...d.goals.map((g) => Row(children: [const Text('• '), Expanded(child: Text(g))])),
          const SizedBox(height: 16),
          Text('Suggested time: ${d.minMinutes}–${d.maxMinutes} min', style: const TextStyle(fontStyle: FontStyle.italic)),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          )
        ]),
      ),
    );
  }

  void _copyToClipboard() {
    if (plan == null) return;
    final p = plan!;
    final sb = StringBuffer('Derby Practice Plan — ${p.totalMinutes} min\n\n');
    void section(PlannedDrill pd, String label) {
      sb.writeln('$label — ${pd.minutes} min');
      sb.writeln('  • ${pd.drill.description}');
      for (final g in pd.drill.goals) {
        sb.writeln('  ◦ Goal: $g');
      }
      sb.writeln('  • Focus: ${pd.drill.focuses.map((e) => e.label).join(', ')}');
      sb.writeln('  • Contact: ${pd.drill.contact.label}\n');
    }

    section(p.warmup, 'Warm‑up: ${p.warmup.drill.name}');
    for (final pd in p.block) {
      section(pd, pd.drill.name);
    }
    section(p.cooldown, 'Cooldown: ${p.cooldown.drill.name}');

    Clipboard.setData(ClipboardData(text: sb.toString()));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Plan copied to clipboard')));
  }
}
