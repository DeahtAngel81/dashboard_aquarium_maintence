import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/models/task_entry.dart';
import '../../viewmodels/aquarium_view_model.dart';
import '../../widgets/aqua_ui.dart';

class MetricsScreen extends StatelessWidget {
  const MetricsScreen({required this.viewModel, super.key});

  final AquariumViewModel viewModel;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: viewModel,
    builder: (context, _) => ListView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      children: [
        PageHeading(
          eyebrow: 'Relatório de telemetria operacional',
          title: 'Métricas & Fechamento Diário',
          subtitle: 'Acompanhe o ritmo de trabalho e o balanço da jornada com o limite diário de foco.',
          trailing: Chip(
            avatar: const Icon(Icons.calendar_today_outlined, size: 17),
            label: Text(_dateLabel(DateTime.now())),
          ),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth > 1100
                ? 4
                : constraints.maxWidth > 700
                ? 2
                : 1;
            final width = (constraints.maxWidth - (columns - 1) * 12) / columns;
            final entries = viewModel.todayEntries;
            final count = entries.length;
            final average = count == 0
                ? Duration.zero
                : Duration(
                    seconds:
                        entries.fold<int>(
                          0,
                          (sum, entry) => sum + entry.duration.inSeconds,
                        ) ~/
                        count,
                  );
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: width,
                  child: _MetricTile(
                    label: 'Cota diária total',
                    value: durationLabel(viewModel.dailyTotal),
                    detail:
                        'Limite: ${viewModel.settings.dailyGoalHours}h · ${(viewModel.goalProgress * 100).round()}%',
                    icon: Icons.timelapse,
                    progress: viewModel.goalProgress,
                  ),
                ),
                SizedBox(
                  width: width,
                  child: _MetricTile(
                    label: 'Ritmo de execução',
                    value: '${average.inMinutes} min',
                    detail: '$count tarefas computadas no ciclo',
                    icon: Icons.speed,
                  ),
                ),
                SizedBox(
                  width: width,
                  child: _MetricTile(
                    label: 'Foco ativo',
                    value: '${_focusPercent(viewModel)}%',
                    detail: 'Tempo dedicado a tarefas registradas',
                    icon: Icons.psychology_outlined,
                  ),
                ),
                SizedBox(
                  width: width,
                  child: _MetricTile(
                    label: 'Integridade da jornada',
                    value: viewModel.remainingGoal.isNegative
                        ? 'Limite excedido'
                        : 'Dentro do teto',
                    detail:
                        'Restam ${durationLabel(viewModel.remainingGoal.isNegative ? Duration.zero : viewModel.remainingGoal)} de margem segura',
                    icon: Icons.verified_outlined,
                    highlighted: true,
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final distribution = SectionCard(
              child: _TagDistribution(entries: viewModel.todayEntries),
            );
            final weekly = SectionCard(
              child: _WeeklyChart(
                entries: viewModel.entries,
                goal: viewModel.goal,
              ),
            );
            if (constraints.maxWidth < 850) {
              return Column(
                children: [distribution, const SizedBox(height: 14), weekly],
              );
            }
            return Row(
              children: [
                Expanded(flex: 6, child: distribution),
                const SizedBox(width: 14),
                Expanded(flex: 4, child: weekly),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        _DayClosing(viewModel: viewModel),
      ],
    ),
  );
}

int _focusPercent(AquariumViewModel viewModel) {
  if (viewModel.dailyTotal.inSeconds == 0) return 0;
  return ((viewModel.dailyTotal.inSeconds / Duration(hours: 8).inSeconds) * 100)
      .round()
      .clamp(0, 100);
}

String _dateLabel(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.detail,
    required this.icon,
    this.progress,
    this.highlighted = false,
  });

  final String label;
  final String value;
  final String detail;
  final IconData icon;
  final double? progress;
  final bool highlighted;

  @override
  Widget build(BuildContext context) => SectionCard(
    padding: const EdgeInsets.all(18),
    child: Container(
      constraints: const BoxConstraints(minHeight: 145),
      padding: highlighted ? const EdgeInsets.all(8) : EdgeInsets.zero,
      decoration: highlighted
          ? BoxDecoration(
              color: aquaPale,
              borderRadius: BorderRadius.circular(12),
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Eyebrow(label)),
              Icon(icon, color: aquaTeal, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(color: aquaTeal, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 5),
          Text(
            detail,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
          ),
          if (progress != null) ...[
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: aquaPale,
              color: aquaTeal,
              borderRadius: BorderRadius.circular(5),
            ),
          ],
        ],
      ),
    ),
  );
}

class _TagDistribution extends StatelessWidget {
  const _TagDistribution({required this.entries});

  final List<TaskEntry> entries;

  @override
  Widget build(BuildContext context) {
    final durations = <String, Duration>{};
    for (final entry in entries) {
      durations.update(
        entry.tag,
        (value) => value + entry.duration,
        ifAbsent: () => entry.duration,
      );
    }
    final totalSeconds = durations.values.fold<int>(
      0,
      (sum, value) => sum + value.inSeconds,
    );
    final sorted = durations.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final colors = [
      aquaDark,
      aquaTeal,
      const Color(0xff128b80),
      const Color(0xff9bb0b6),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Distribuição operacional por tag',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Chip(
              label: Text(
                'Total: ${durationLabel(Duration(seconds: totalSeconds))}',
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        const Text('Tempo dedicado às frentes técnicas de hoje.'),
        const SizedBox(height: 18),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            height: 16,
            child: Row(
              children: [
                if (totalSeconds == 0)
                  const Expanded(child: ColoredBox(color: aquaPale))
                else
                  for (var index = 0; index < sorted.length; index++)
                    Expanded(
                      flex: sorted[index].value.inSeconds,
                      child: ColoredBox(color: colors[index % colors.length]),
                    ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (sorted.isEmpty)
          const Text('Conclua tarefas para visualizar a distribuição.')
        else
          ...sorted.indexed.map((item) {
            final (index, entry) = item;
            final share = totalSeconds == 0
                ? 0
                : entry.value.inSeconds * 100 ~/ totalSeconds;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: aquaPale,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.circle,
                      size: 11,
                      color: colors[index % colors.length],
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(entry.key)),
                    Text(
                      durationLabel(entry.value),
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '$share%',
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                  ],
                ),
              ),
            );
          }),
        const SizedBox(height: 8),
        const Text(
          'Todas as atividades são consideradas na distribuição por categoria.',
          style: TextStyle(color: aquaMuted, fontSize: 12),
        ),
      ],
    );
  }
}

class _WeeklyChart extends StatelessWidget {
  const _WeeklyChart({required this.entries, required this.goal});

  final List<TaskEntry> entries;
  final Duration goal;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final days = List.generate(5, (index) {
      final date = DateTime(
        today.year,
        today.month,
        today.day,
      ).subtract(Duration(days: 4 - index));
      final total = entries
          .where(
            (entry) =>
                entry.completedAt.year == date.year &&
                entry.completedAt.month == date.month &&
                entry.completedAt.day == date.day,
          )
          .fold<Duration>(Duration.zero, (sum, entry) => sum + entry.duration);
      return (date, total);
    });
    final labels = ['SEG', 'TER', 'QUA', 'QUI', 'SEX', 'SÁB', 'DOM'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Consistência semanal',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Chip(label: Text('Teto: ${goal.inHours}h/dia')),
          ],
        ),
        const SizedBox(height: 5),
        const Text('Horas registradas nos últimos cinco dias.'),
        const SizedBox(height: 18),
        SizedBox(
          height: 190,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (var index = 0; index < days.length; index++)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (days[index].$2 > Duration.zero)
                          Text(
                            durationLabel(days[index].$2),
                            style: const TextStyle(fontSize: 10),
                          ),
                        const SizedBox(height: 5),
                        Flexible(
                          child: FractionallySizedBox(
                            heightFactor:
                                (days[index].$2.inSeconds /
                                        (goal.inSeconds == 0
                                            ? 1
                                            : goal.inSeconds))
                                    .clamp(0.03, 1),
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              width: 32,
                              decoration: BoxDecoration(
                                color: days[index].$1.day == today.day
                                    ? aquaTeal
                                    : const Color(0xffd3eaf3),
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          labels[days[index].$1.weekday - 1],
                          style: const TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        const Divider(height: 24),
        Row(
          children: [
            const Icon(Icons.check_circle_outline, color: aquaTeal, size: 18),
            const SizedBox(width: 8),
            const Expanded(child: Text('Jornada monitorada sem sobrecarga')),
            Text('${days.where((day) => day.$2 <= goal).length}/5 dias'),
          ],
        ),
      ],
    );
  }
}

class _DayClosing extends StatelessWidget {
  const _DayClosing({required this.viewModel});

  final AquariumViewModel viewModel;

  @override
  Widget build(BuildContext context) => SectionCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.assignment_turned_in_outlined, color: aquaTeal),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Fechamento do dia & registro',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Gere um comprovante de texto para compartilhar com o cliente ou guardar nas notas.',
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            FilledButton.icon(
              onPressed: () => _showReport(context, viewModel),
              icon: const Icon(Icons.done_all),
              label: const Text('Encerrar expediente de hoje'),
            ),
          ],
        ),
        const SizedBox(height: 18),
        const Eyebrow('Verificação de qualidade'),
        const SizedBox(height: 10),
        const Wrap(
          spacing: 16,
          runSpacing: 8,
          children: [
            _QualityItem('Balanço de água: seguro'),
            _QualityItem('Tolerância térmica: estável'),
            _QualityItem('Registros de manutenção arquivados'),
          ],
        ),
      ],
    ),
  );

  Future<void> _showReport(
    BuildContext context,
    AquariumViewModel model,
  ) async {
    final report = StringBuffer()
      ..writeln('AQUATIMER · RELATÓRIO DE MANUTENÇÃO DIÁRIA')
      ..writeln('Data: ${_dateLabel(DateTime.now())}')
      ..writeln(
        'Horas trabalhadas: ${durationLabel(model.dailyTotal)} / Limite: ${model.settings.dailyGoalHours}h',
      )
      ..writeln()
      ..writeln('ATIVIDADES CONCLUÍDAS:');
    for (final entry in model.todayEntries) {
      report.writeln(
        '• ${entry.title} (#${entry.tag}) · ${durationLabel(entry.duration)}',
      );
      if (entry.description.isNotEmpty) {
        report.writeln('  ${entry.description}');
      }
    }

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Relatório diário'),
        content: SizedBox(
          width: 560,
          child: SingleChildScrollView(
            child: SelectableText(report.toString()),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Fechar'),
          ),
          FilledButton.icon(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: report.toString()));
              if (!dialogContext.mounted) return;
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Relatório copiado para a área de transferência.',
                  ),
                ),
              );
            },
            icon: const Icon(Icons.copy),
            label: const Text('Copiar relatório'),
          ),
        ],
      ),
    );
  }
}

class _QualityItem extends StatelessWidget {
  const _QualityItem(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      const Icon(Icons.check_circle_outline, color: aquaTeal, size: 18),
      const SizedBox(width: 6),
      Text(label),
    ],
  );
}
