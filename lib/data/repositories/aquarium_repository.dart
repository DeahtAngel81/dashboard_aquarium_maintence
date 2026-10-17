import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/aquarium_settings.dart';
import '../models/task_entry.dart';

abstract class AquariumRepository {
  Future<AquariumSettings> loadSettings();
  Future<void> saveSettings(AquariumSettings settings);
  Future<List<TaskEntry>> loadEntries();
  Future<void> saveEntries(List<TaskEntry> entries);
}

class SharedPreferencesAquariumRepository implements AquariumRepository {
  SharedPreferencesAquariumRepository({SharedPreferencesAsync? preferences})
      : _preferences = preferences ?? SharedPreferencesAsync();

  static const _settingsKey = 'aquatimer.settings';
  static const _entriesKey = 'aquatimer.entries';

  final SharedPreferencesAsync _preferences;

  @override
  Future<AquariumSettings> loadSettings() async {
    final value = await _preferences.getString(_settingsKey);
    if (value == null) return const AquariumSettings();

    return AquariumSettings.fromJson(
      jsonDecode(value) as Map<String, Object?>,
    );
  }

  @override
  Future<void> saveSettings(AquariumSettings settings) =>
      _preferences.setString(_settingsKey, jsonEncode(settings.toJson()));

  @override
  Future<List<TaskEntry>> loadEntries() async {
    final value = await _preferences.getString(_entriesKey);
    if (value == null) return _sampleEntries();

    return (jsonDecode(value) as List<Object?>)
        .map((entry) => TaskEntry.fromJson(entry! as Map<String, Object?>))
        .toList();
  }

  @override
  Future<void> saveEntries(List<TaskEntry> entries) =>
      _preferences.setString(
        _entriesKey,
        jsonEncode(entries.map((entry) => entry.toJson()).toList()),
      );

  List<TaskEntry> _sampleEntries() {
    final now = DateTime.now();
    return [
      TaskEntry(
        title: 'Calibração Sonda pH & Teste GH/KH',
        tag: 'Testes',
        description: 'Amostras coletadas da bateria de aquários.',
        duration: const Duration(minutes: 55),
        completedAt: DateTime(now.year, now.month, now.day, 14, 5),
      ),
      TaskEntry(
        title: 'Troca de Perlon e Carvão Ativado',
        tag: 'Manutenção',
        description: 'Canister externo limpo e rotor inspecionado.',
        duration: const Duration(hours: 1, minutes: 10),
        completedAt: DateTime(now.year, now.month, now.day, 11, 50),
      ),
      TaskEntry(
        title: 'Relatório Técnico - Aquário Recife',
        tag: 'Clientes',
        description: 'Relatório semanal de reposição de minerais.',
        duration: const Duration(minutes: 40),
        completedAt: DateTime(now.year, now.month, now.day, 9, 40),
      ),
      TaskEntry(
        title: 'TPA 30% e Sifonagem Aquário Plantado 240L',
        tag: 'Manutenção',
        description: 'Aquário da sala principal.',
        duration: const Duration(hours: 1, minutes: 15),
        completedAt: DateTime(now.year, now.month, now.day, 9, 45),
      ),
      TaskEntry(
        title: 'Limpeza de Canister & Troca de Carvão Ativado',
        tag: 'Equipamentos',
        description: 'Filtro Fluval FX4 e mídia cerâmica.',
        duration: const Duration(minutes: 55),
        completedAt: DateTime(now.year, now.month, now.day, 10, 55),
      ),
      TaskEntry(
        title: 'Bateria de Testes Químicos (pH, kH, Amônia, Nitrito)',
        tag: 'Parâmetros',
        description: 'pH 6.8 · NH3 0.0 ppm · NO2 0.0',
        duration: const Duration(minutes: 32),
        completedAt: DateTime(now.year, now.month, now.day, 11, 47),
      ),
    ];
  }
}
