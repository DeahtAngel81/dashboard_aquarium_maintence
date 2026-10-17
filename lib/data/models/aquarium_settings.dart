class AquariumSettings {
  const AquariumSettings({
    this.dailyGoalHours = 6,
    this.tags = const ['Manutenção', 'TPA', 'Parâmetros', 'Limpeza', 'Clientes'],
    this.breakReminder = true,
    this.dailyLimitAlert = true,
    this.soundEnabled = false,
  });

  final int dailyGoalHours;
  final List<String> tags;
  final bool breakReminder;
  final bool dailyLimitAlert;
  final bool soundEnabled;

  AquariumSettings copyWith({
    int? dailyGoalHours,
    List<String>? tags,
    bool? breakReminder,
    bool? dailyLimitAlert,
    bool? soundEnabled,
  }) =>
      AquariumSettings(
        dailyGoalHours: dailyGoalHours ?? this.dailyGoalHours,
        tags: tags ?? this.tags,
        breakReminder: breakReminder ?? this.breakReminder,
        dailyLimitAlert: dailyLimitAlert ?? this.dailyLimitAlert,
        soundEnabled: soundEnabled ?? this.soundEnabled,
      );

  Map<String, Object?> toJson() => {
        'dailyGoalHours': dailyGoalHours,
        'tags': tags,
        'breakReminder': breakReminder,
        'dailyLimitAlert': dailyLimitAlert,
        'soundEnabled': soundEnabled,
      };

  factory AquariumSettings.fromJson(Map<String, Object?> json) =>
      AquariumSettings(
        dailyGoalHours: json['dailyGoalHours']! as int,
        tags: (json['tags']! as List<Object?>).cast<String>(),
        breakReminder: json['breakReminder']! as bool,
        dailyLimitAlert: json['dailyLimitAlert']! as bool,
        soundEnabled: json['soundEnabled']! as bool,
      );
}
