import 'package:flutter/material.dart';

import '../../viewmodels/aquarium_view_model.dart';
import '../../widgets/aqua_ui.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({required this.viewModel, super.key});

  final AquariumViewModel viewModel;

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  String? _selectedTag;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.viewModel.taskTitle);
    _descriptionController = TextEditingController(
      text: widget.viewModel.taskDescription,
    );
    _selectedTag = widget.viewModel.taskTag;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _syncTask() => widget.viewModel.updateTask(
    title: _titleController.text.trim(),
    tag: _selectedTag ?? 'Manutenção',
    description: _descriptionController.text.trim(),
  );

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.viewModel,
    builder: (context, _) => ListView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      children: [
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Eyebrow('Foco da jornada atual'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SizedBox(
                    width: 390,
                    child: TextField(
                      controller: _titleController,
                      onChanged: (_) => _syncTask(),
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.edit_note),
                        hintText: 'O que você vai fazer?',
                      ),
                    ),
                  ),
                  ...widget.viewModel.settings.tags.map(
                    (tag) => ChoiceChip(
                      label: Text('#$tag'),
                      selected: _selectedTag == tag,
                      onSelected: (_) {
                        setState(() => _selectedTag = tag);
                        _syncTask();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 850;
            final timer = _timerCard(context);
            final goal = _goalCard(context);
            return compact
                ? Column(children: [timer, const SizedBox(height: 16), goal])
                : Row(
                    children: [
                      Expanded(flex: 7, child: timer),
                      const SizedBox(width: 18),
                      Expanded(flex: 3, child: goal),
                    ],
                  );
          },
        ),
        const SizedBox(height: 20),
        _recentTasks(),
      ],
    ),
  );

  Widget _timerCard(BuildContext context) => SectionCard(
    padding: const EdgeInsets.all(24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          spacing: 12,
          runSpacing: 8,
          children: [
            const Eyebrow('Cronômetro de precisão'),
            _StatusPill(
              label: widget.viewModel.isRunning
                  ? 'Sessão em andamento'
                  : 'Pronto para focar',
              active: widget.viewModel.isRunning,
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          widget.viewModel.taskTitle,
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(color: aquaDark, fontWeight: FontWeight.w600),
        ),
        SizedBox(
          height: 230,
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                clockLabel(widget.viewModel.elapsed),
                style: const TextStyle(
                  fontSize: 82,
                  height: 1,
                  color: aquaTeal,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'monospace',
                  letterSpacing: -4,
                ),
              ),
            ),
          ),
        ),
        TextField(
          controller: _descriptionController,
          onChanged: (_) => _syncTask(),
          maxLines: 2,
          decoration: const InputDecoration(
            hintText: 'Notas rápidas sobre esta manutenção (opcional)',
            prefixIcon: Icon(Icons.notes_outlined),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            FilledButton.icon(
              onPressed: widget.viewModel.canStartSession
                  ? widget.viewModel.toggleSession
                  : null,
              icon: Icon(
                widget.viewModel.isRunning ? Icons.pause : Icons.play_arrow,
              ),
              label: Text(
                widget.viewModel.isRunning ? 'Pausar sessão' : 'Iniciar sessão',
              ),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
            ),
            OutlinedButton.icon(
              onPressed: widget.viewModel.discardTask,
              icon: const Icon(Icons.delete_outline),
              label: const Text('Descartar'),
            ),
            FilledButton.tonalIcon(
              onPressed:
                  widget.viewModel.elapsed > Duration.zero &&
                      widget.viewModel.taskTitle.trim().isNotEmpty
                  ? () async {
                      _syncTask();
                      await widget.viewModel.finishTask();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Tarefa salva no log diário.'),
                          ),
                        );
                      }
                    }
                  : null,
              icon: const Icon(Icons.task_alt),
              label: const Text('Finalizar tarefa'),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _goalCard(BuildContext context) {
    final total = widget.viewModel.dailyTotal;
    final remaining = widget.viewModel.remainingGoal;
    final safeRemaining = remaining.isNegative ? Duration.zero : remaining;
    final percent = (widget.viewModel.goalProgress * 100).round();

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Eyebrow('Jornada saudável'),
          const SizedBox(height: 6),
          Text(
            'Meta diária de ${widget.viewModel.settings.dailyGoalHours} horas',
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(color: aquaDark, fontWeight: FontWeight.w600),
          ),
          SizedBox(
            height: 230,
            child: Center(
              child: SizedBox(
                width: 190,
                height: 190,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 180,
                      height: 180,
                      child: CircularProgressIndicator(
                        value: widget.viewModel.goalProgress,
                        strokeWidth: 15,
                        backgroundColor: aquaPale,
                        color: aquaTeal,
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Eyebrow('Concluído'),
                        Text(
                          '$percent%',
                          style: const TextStyle(
                            fontSize: 44,
                            color: aquaTeal,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(durationLabel(total)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  label: 'Decorrido hoje',
                  value: durationLabel(total),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MiniStat(
                  label: 'Restante seguro',
                  value: durationLabel(safeRemaining),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: aquaPale,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              remaining <= Duration.zero
                  ? 'Limite diário atingido. Faça uma pausa antes de iniciar outra tarefa.'
                  : 'Você tem ${durationLabel(safeRemaining)} de foco produtivo antes de atingir o limite diário.',
            ),
          ),
        ],
      ),
    );
  }

  Widget _recentTasks() {
    final entries = widget.viewModel.todayEntries.take(3).toList();
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.history, color: aquaTeal),
              const SizedBox(width: 8),
              Text(
                'Últimas tarefas de hoje',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Spacer(),
              Text(
                '${widget.viewModel.todayEntries.length} atividades computadas',
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (entries.isEmpty)
            const Text('As tarefas finalizadas aparecerão aqui.')
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth > 900
                    ? 3
                    : constraints.maxWidth > 560
                    ? 2
                    : 1;
                final width =
                    (constraints.maxWidth - (columns - 1) * 12) / columns;
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: entries
                      .map(
                        (entry) => SizedBox(
                          width: width,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: aquaPale,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '#${entry.tag}',
                                  style: const TextStyle(color: aquaTeal),
                                ),
                                const SizedBox(height: 7),
                                Text(
                                  entry.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  entry.description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Duração · ${durationLabel(entry.duration)}',
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                      .toList(),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: aquaPale,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Eyebrow(label),
        const SizedBox(height: 5),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    ),
  );
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.active});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
    decoration: BoxDecoration(
      color: aquaPale,
      borderRadius: BorderRadius.circular(18),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.circle, size: 9, color: active ? aquaTeal : aquaMuted),
        const SizedBox(width: 7),
        Text(
          label.toUpperCase(),
          style: const TextStyle(fontSize: 10, letterSpacing: .7),
        ),
      ],
    ),
  );
}
