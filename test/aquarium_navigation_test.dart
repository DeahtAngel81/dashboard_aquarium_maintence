import 'package:dashboard_aquarium_manuntence/data/models/aquarium_settings.dart';
import 'package:dashboard_aquarium_manuntence/data/models/task_entry.dart';
import 'package:dashboard_aquarium_manuntence/data/repositories/aquarium_repository.dart';
import 'package:dashboard_aquarium_manuntence/viewmodels/aquarium_view_model.dart';
import 'package:dashboard_aquarium_manuntence/views/aquarium_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('navigates through all four screens on desktop and mobile', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1440, 900);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final viewModel = AquariumViewModel(_MemoryAquariumRepository());
    await viewModel.load();
    await tester.pumpWidget(AquaTimerApp(viewModel: viewModel));
    await tester.pumpAndSettle();

    expect(find.text('FOCO DA JORNADA ATUAL'), findsOneWidget);
    expect(tester.takeException(), isNull);

    for (final screen in [
      'Log Diário de Tarefas',
      'Métricas & Fechamento',
      'Configurações Simples',
      'Cronômetro',
    ]) {
      await tester.tap(find.text(screen).first);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }

    tester.view.physicalSize = const Size(390, 844);
    await tester.pumpAndSettle();
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(tester.takeException(), isNull);
    viewModel.dispose();
  });
}

class _MemoryAquariumRepository implements AquariumRepository {
  AquariumSettings settings = const AquariumSettings();
  List<TaskEntry> entries = [];

  @override
  Future<AquariumSettings> loadSettings() async => settings;

  @override
  Future<void> saveSettings(AquariumSettings value) async {
    settings = value;
  }

  @override
  Future<List<TaskEntry>> loadEntries() async => entries;

  @override
  Future<void> saveEntries(List<TaskEntry> value) async {
    entries = value;
  }
}
