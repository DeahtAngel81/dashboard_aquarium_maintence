import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/models/task_entry.dart';
import '../../viewmodels/aquarium_view_model.dart';
import '../../widgets/aqua_ui.dart';

class TaskLogScreen extends StatefulWidget {
  const TaskLogScreen({required this.viewModel, super.key});

  final AquariumViewModel viewModel;

  @override
  State<TaskLogScreen> createState() => _TaskLogScreenState();
}

class _TaskLogScreenState extends State<TaskLogScreen> {
  final _searchController = TextEditingController();
  String? _selectedTag;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: widget.viewModel,
        builder: (context, _) {
          final entries = widget.viewModel.entries.where((entry) {
            final matchesSearch =
                '${entry.title} ${entry.description} ${entry.tag}'
                    .toLowerCase()
                    .contains(_searchController.text.toLowerCase());
            return matchesSearch &&
                (_selectedTag == null || entry.tag == _selectedTag);
          }).toList();
          final total = widget.viewModel.todayEntries.fold<Duration>(
            Duration.zero,
            (sum, entry) => sum + entry.duration,
          );

          return ListView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            children: [
              const PageHeading(
                eyebrow: 'Registro de atividades',
                title: 'Log Diário de Tarefas',
                subtitle:
                    'Histórico operacional, observações técnicas e tempo investido em cada aquário.',
              ),
              Wrap(
                spacing: 14,
                runSpacing: 14,
                children: [
                  _SummaryTile(
                    label: 'Tempo focado hoje',
                    value: durationLabel(total),
                    icon: Icons.timer_outlined,
                  ),
                  _SummaryTile(
                    label: 'Tarefas registradas',
                    value: '${widget.viewModel.todayEntries.length}',
                    icon: Icons.checklist,
                  ),
                  _SummaryTile(
                    label: 'Meta da jornada',
                    value: '${widget.viewModel.settings.dailyGoalHours}h',
                    icon: Icons.flag_outlined,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              LayoutBuilder(
                builder: (context, constraints) {
                  final narrow = constraints.maxWidth < 1000;
                  final log = Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SectionCard(
                        padding: const EdgeInsets.all(16),
                        child: Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            SizedBox(
                              width: narrow ? double.infinity : 360,
                              child: TextField(
                                controller: _searchController,
                                onChanged: (_) => setState(() {}),
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(Icons.search),
                                  hintText: 'Buscar tarefa, nota ou aquário',
                                ),
                              ),
                            ),
                            DropdownButton<String?>(
                              value: _selectedTag,
                              hint: const Text('Todas as categorias'),
                              items: [
                                const DropdownMenuItem<String?>(
                                  value: null,
                                  child: Text('Todas as categorias'),
                                ),
                                ...{
                                  ...widget.viewModel.entries.map((entry) => entry.tag),
                                  ...widget.viewModel.settings.tags,
                                }.map(
                                  (tag) => DropdownMenuItem<String?>(
                                    value: tag,
                                    child: Text(tag),
                                  ),
                                ),
                              ],
                              onChanged: (value) =>
                                  setState(() => _selectedTag = value),
                            ),
                            FilledButton.icon(
                              onPressed: () => _showAddEntryDialog(context),
                              icon: const Icon(Icons.add),
                              label: const Text('Novo registro'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      if (entries.isEmpty)
                        const SectionCard(
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.all(24),
                              child: Text('Nenhuma tarefa encontrada.'),
                            ),
                          ),
                        )
                      else
                        ...entries.map((entry) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _TaskRow(
                                entry: entry,
                                onDelete: () => _confirmDelete(context, entry),
                              ),
                            )),
                    ],
                  );
                  final side = _exportPanel(context, entries);
                  if (narrow) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [log, const SizedBox(height: 16), side],
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 7, child: log),
                      const SizedBox(width: 16),
                      Expanded(flex: 3, child: side),
                    ],
                  );
                },
              ),
            ],
          );
        },
      );

  Widget _exportPanel(BuildContext context, List<TaskEntry> entries) =>
      Column(
        children: [
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.water_drop_outlined, color: aquaTeal, size: 30),
                const SizedBox(height: 12),
                const Eyebrow('Aquário #01'),
                Text('Nature Aquarium 240L',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 18),
                const Divider(),
                const SizedBox(height: 8),
                const Eyebrow('Status biológico'),
                const SizedBox(height: 6),
                const Row(
                  children: [
                    Icon(Icons.circle, size: 9, color: aquaTeal),
                    SizedBox(width: 7),
                    Text('Equilíbrio estável'),
                  ],
                ),
                const SizedBox(height: 14),
                const Eyebrow('Tempo alocado hoje'),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: widget.viewModel.goalProgress,
                  minHeight: 8,
                  color: aquaTeal,
                  backgroundColor: aquaPale,
                  borderRadius: BorderRadius.circular(6),
                ),
                const SizedBox(height: 8),
                Text(durationLabel(widget.viewModel.dailyTotal)),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Exportar e relatórios',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                const Text(
                  'Copie o resumo ou os registros em CSV para compartilhar com o cliente.',
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _copyToClipboard(
                      context,
                      entries.map(_reportLine).join('\n'),
                      'Relatório copiado.',
                    ),
                    icon: const Icon(Icons.copy),
                    label: const Text('Copiar relatório'),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => _copyToClipboard(
                      context,
                      'Tarefa,Categoria,Descrição,Duração,Concluída em\n'
                      '${entries.map(_csvLine).join('\n')}',
                      'Dados CSV copiados.',
                    ),
                    icon: const Icon(Icons.table_view),
                    label: const Text('Copiar dados (CSV)'),
                  ),
                ),
              ],
            ),
          ),
        ],
      );

  String _reportLine(TaskEntry entry) =>
      '• ${entry.title} (#${entry.tag}) — ${durationLabel(entry.duration)}';

  String _csvLine(TaskEntry entry) =>
      '"${entry.title.replaceAll('"', '""')}",'
      '"${entry.tag.replaceAll('"', '""')}",'
      '"${entry.description.replaceAll('"', '""')}",'
      '"${durationLabel(entry.duration)}",'
      '"${entry.completedAt.toIso8601String()}"';

  Future<void> _copyToClipboard(
    BuildContext context,
    String value,
    String message,
  ) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _confirmDelete(BuildContext context, TaskEntry entry) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir registro?'),
        content: Text('O registro "${entry.title}" será removido do histórico local.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (shouldDelete == true) await widget.viewModel.removeEntry(entry);
  }

  Future<void> _showAddEntryDialog(BuildContext context) async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    var tag = widget.viewModel.settings.tags.firstOrNull ?? 'Geral';
    var minutes = 30;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Novo registro'),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  autofocus: true,
                  decoration: const InputDecoration(labelText: 'Atividade'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Observação'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: tag,
                  decoration: const InputDecoration(labelText: 'Categoria'),
                  items: widget.viewModel.settings.tags
                      .map((item) =>
                          DropdownMenuItem(value: item, child: Text(item)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) setDialogState(() => tag = value);
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('Duração'),
                    const Spacer(),
                    IconButton(
                      onPressed: minutes <= 5
                          ? null
                          : () => setDialogState(() => minutes -= 5),
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                    Text('$minutes min'),
                    IconButton(
                      onPressed: () => setDialogState(() => minutes += 5),
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () async {
                if (titleController.text.trim().isEmpty) return;
                await widget.viewModel.addManualEntry(
                  title: titleController.text,
                  description: descriptionController.text,
                  tag: tag,
                  duration: Duration(minutes: minutes),
                );
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              },
              child: const Text('Salvar registro'),
            ),
          ],
        ),
      ),
    );
    titleController.dispose();
    descriptionController.dispose();
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 230,
        child: SectionCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: aquaTeal),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Eyebrow(label),
                    const SizedBox(height: 4),
                    Text(value,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: aquaTeal,
                              fontWeight: FontWeight.w700,
                            )),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}

class _TaskRow extends StatelessWidget {
  const _TaskRow({required this.entry, required this.onDelete});

  final TaskEntry entry;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) => SectionCard(
        padding: EdgeInsets.zero,
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 6,
                decoration: const BoxDecoration(
                  color: aquaTeal,
                  borderRadius: BorderRadius.horizontal(left: Radius.circular(16)),
                ),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.water_drop_outlined, color: aquaTeal),
              const SizedBox(width: 14),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(entry.title,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  )),
                          Chip(
                            label: Text('#${entry.tag}'),
                            visualDensity: VisualDensity.compact,
                            backgroundColor: aquaPale,
                          ),
                        ],
                      ),
                      const SizedBox(height: 7),
                      Text(entry.description.isEmpty ? 'Sem observações adicionais.' : entry.description),
                      const SizedBox(height: 7),
                      Text(
                        '${TimeOfDay.fromDateTime(entry.completedAt).format(context)}  ·  ${durationLabel(entry.duration)}  ·  Finalizado',
                        style: const TextStyle(
                          color: aquaMuted,
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Excluir registro',
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      );
}
