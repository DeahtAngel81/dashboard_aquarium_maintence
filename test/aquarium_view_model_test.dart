import 'package:flutter_test/flutter_test.dart';
import 'package:dashboard_aquarium_manuntence/data/models/aquarium_settings.dart';
import 'package:dashboard_aquarium_manuntence/data/models/task_entry.dart';
import 'package:dashboard_aquarium_manuntence/data/repositories/aquarium_repository.dart';
import 'package:dashboard_aquarium_manuntence/viewmodels/aquarium_view_model.dart';

void main() {
  late _MemoryAquariumRepository repository;
  late AquariumViewModel viewModel;

  setUp(() async {
    repository = _MemoryAquariumRepository();
    viewModel = AquariumViewModel(repository);
    await viewModel.load();
  });

  tearDown(() => viewModel.dispose());

  test('persists preference changes through the repository', () async {
    final updated = viewModel.settings.copyWith(dailyGoalHours: 8);

    await viewModel.updateSettings(updated);

    expect(viewModel.settings.dailyGoalHours, 8);
    expect(repository.savedSettings.dailyGoalHours, 8);
  });

  test('adds a manual task and persists the updated log', () async {
    await viewModel.addManualEntry(
      title: 'Limpeza do filtro',
      tag: 'Manutenção',
      description: 'Mídia enxaguada com água do aquário.',
      duration: const Duration(minutes: 25),
    );

    expect(viewModel.entries, hasLength(1));
    expect(viewModel.entries.first.title, 'Limpeza do filtro');
    expect(repository.savedEntries, hasLength(1));
  });

  test('does not add an empty task to the log', () async {
    await viewModel.addManualEntry(
      title: ' ',
      tag: 'Manutenção',
      description: '',
      duration: const Duration(minutes: 25),
    );

    expect(viewModel.entries, isEmpty);
    expect(repository.savedEntries, isNull);
  });

  test('adds and removes custom categories', () async {
    await viewModel.addTag('#Plantados');

    expect(viewModel.settings.tags, contains('Plantados'));
    await viewModel.removeTag('Plantados');
    expect(viewModel.settings.tags, isNot(contains('Plantados')));
  });
}

class _MemoryAquariumRepository implements AquariumRepository {
  AquariumSettings savedSettings = const AquariumSettings();
  List<TaskEntry> entries = [];
  List<TaskEntry>? savedEntries;

  @override
  Future<AquariumSettings> loadSettings() async => savedSettings;

  @override
  Future<List<TaskEntry>> loadEntries() async => entries;

  @override
  Future<void> saveSettings(AquariumSettings settings) async {
    savedSettings = settings;
  }

  @override
  Future<void> saveEntries(List<TaskEntry> updatedEntries) async {
    savedEntries = updatedEntries;
    entries = updatedEntries;
  }
}
