import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/models/aquarium_settings.dart';
import '../data/models/task_entry.dart';
import '../data/repositories/aquarium_repository.dart';

class AquariumViewModel extends ChangeNotifier {
  AquariumViewModel(this._repository);

  final AquariumRepository _repository;
  AquariumSettings _settings = const AquariumSettings();
  List<TaskEntry> _entries = [];
  Timer? _ticker;
  DateTime? _startedAt;
  Duration _elapsed = Duration.zero;
  String _taskTitle = 'Manutenção Aquário 200L Plantado - Limpeza e TPA';
  String _taskTag = 'Manutenção';
  String _taskDescription = '';
  bool _isLoaded = false;

  AquariumSettings get settings => _settings;
  List<TaskEntry> get entries => List.unmodifiable(_entries);
  bool get isLoaded => _isLoaded;
  bool get isRunning => _startedAt != null;
  bool get canStartSession =>
      isRunning || (_taskTitle.trim().isNotEmpty && remainingGoal > Duration.zero);
  String get taskTitle => _taskTitle;
  String get taskTag => _taskTag;
  String get taskDescription => _taskDescription;
  Duration get elapsed =>
      _elapsed + (_startedAt == null ? Duration.zero : DateTime.now().difference(_startedAt!));
  Duration get dailyTotal =>
      todayEntries.fold(Duration.zero, (total, entry) => total + entry.duration) +
      elapsed;
  Duration get goal => Duration(hours: _settings.dailyGoalHours);
  List<TaskEntry> get todayEntries => _entries.where(_isToday).toList();
  double get goalProgress =>
      goal.inSeconds == 0 ? 0 : (dailyTotal.inSeconds / goal.inSeconds).clamp(0, 1);
  Duration get remainingGoal => goal - dailyTotal;

  Future<void> load() async {
    _settings = await _repository.loadSettings();
    _entries = await _repository.loadEntries();
    _isLoaded = true;
    notifyListeners();
  }

  void updateTask({
    required String title,
    required String tag,
    required String description,
  }) {
    _taskTitle = title;
    _taskTag = tag;
    _taskDescription = description;
    notifyListeners();
  }

  void toggleSession() {
    if (_startedAt != null) {
      _elapsed = elapsed;
      _startedAt = null;
      _ticker?.cancel();
      _ticker = null;
    } else {
      if (!canStartSession) return;
      _startedAt = DateTime.now();
      _ticker ??= Timer.periodic(const Duration(seconds: 1), (_) {
        if (remainingGoal <= Duration.zero) {
          _elapsed = goal -
              todayEntries.fold(Duration.zero, (total, entry) => total + entry.duration);
          _startedAt = null;
          _ticker?.cancel();
          _ticker = null;
        }
        notifyListeners();
      });
    }
    notifyListeners();
  }

  Future<void> finishTask() async {
    if (elapsed <= Duration.zero) return;
    _entries = [
      TaskEntry(
        title: _taskTitle,
        tag: _taskTag,
        description: _taskDescription,
        duration: elapsed,
        completedAt: DateTime.now(),
      ),
      ..._entries,
    ];
    _resetTimer();
    await _repository.saveEntries(_entries);
    notifyListeners();
  }

  Future<void> addManualEntry({
    required String title,
    required String tag,
    required String description,
    required Duration duration,
  }) async {
    if (title.trim().isEmpty || duration <= Duration.zero) return;
    _entries = [
      TaskEntry(
        title: title.trim(),
        tag: tag,
        description: description.trim(),
        duration: duration,
        completedAt: DateTime.now(),
      ),
      ..._entries,
    ];
    await _repository.saveEntries(_entries);
    notifyListeners();
  }

  Future<void> removeEntry(TaskEntry entry) async {
    _entries = [..._entries]..remove(entry);
    await _repository.saveEntries(_entries);
    notifyListeners();
  }

  void discardTask() {
    _resetTimer();
    notifyListeners();
  }

  Future<void> updateSettings(AquariumSettings settings) async {
    _settings = settings;
    await _repository.saveSettings(settings);
    notifyListeners();
  }

  Future<void> addTag(String tag) async {
    final normalized = tag.trim().replaceFirst(RegExp(r'^#'), '');
    if (normalized.isEmpty ||
        _settings.tags.any((existing) => existing.toLowerCase() == normalized.toLowerCase())) {
      return;
    }
    await updateSettings(_settings.copyWith(tags: [..._settings.tags, normalized]));
  }

  Future<void> removeTag(String tag) async {
    await updateSettings(
      _settings.copyWith(tags: _settings.tags.where((item) => item != tag).toList()),
    );
  }

  bool _isToday(TaskEntry entry) {
    final now = DateTime.now();
    return entry.completedAt.year == now.year &&
        entry.completedAt.month == now.month &&
        entry.completedAt.day == now.day;
  }

  void _resetTimer() {
    _ticker?.cancel();
    _ticker = null;
    _startedAt = null;
    _elapsed = Duration.zero;
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}
