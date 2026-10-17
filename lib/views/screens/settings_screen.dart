import 'package:flutter/material.dart';

import '../../data/models/aquarium_settings.dart';
import '../../viewmodels/aquarium_view_model.dart';
import '../../widgets/aqua_ui.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({required this.viewModel, super.key});

  final AquariumViewModel viewModel;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: viewModel,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          children: [
            const PageHeading(
              eyebrow: 'Armazenamento local · privacidade',
              title: 'Preferências & Ajustes de Operação',
              subtitle:
                  'Ajustes salvos neste dispositivo. Sem conta e sem envio de dados para servidores.',
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 900;
                final general = Column(
                  children: [
                    _goalCard(context),
                    const SizedBox(height: 14),
                    _remindersCard(context),
                  ],
                );
                final tags = _tagsCard(context);
                final privacy = _privacyCard(context);
                if (compact) {
                  return Column(
                    children: [
                      general,
                      const SizedBox(height: 14),
                      tags,
                      const SizedBox(height: 14),
                      privacy,
                    ],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 6, child: general),
                    const SizedBox(width: 14),
                    Expanded(
                      flex: 4,
                      child: Column(
                        children: [
                          tags,
                          const SizedBox(height: 14),
                          privacy,
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      );

  Widget _goalCard(BuildContext context) => SectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.timer_outlined, color: aquaTeal),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Meta diária de foco',
                          style: Theme.of(context).textTheme.titleLarge),
                      const Text('Limite seguro recomendado para a jornada'),
                    ],
                  ),
                ),
                const Chip(label: Text('PADRÃO RECOMENDADO')),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: aquaPale,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Text(
                    '${viewModel.settings.dailyGoalHours.toString().padLeft(2, '0')}:00',
                    style: const TextStyle(
                      fontSize: 46,
                      fontFamily: 'monospace',
                      color: aquaTeal,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('horas por dia'),
                  const Spacer(),
                  IconButton.filledTonal(
                    tooltip: 'Diminuir meta',
                    onPressed: viewModel.settings.dailyGoalHours <= 2
                        ? null
                        : () => _setGoal(viewModel.settings.dailyGoalHours - 1),
                    icon: const Icon(Icons.remove),
                  ),
                  const SizedBox(width: 5),
                  IconButton.filledTonal(
                    tooltip: 'Aumentar meta',
                    onPressed: viewModel.settings.dailyGoalHours >= 10
                        ? null
                        : () => _setGoal(viewModel.settings.dailyGoalHours + 1),
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('2h (mínimo recomendado)'),
                Text('6h (meta sugerida)'),
                Text('10h (máximo)'),
              ],
            ),
            Slider(
              value: viewModel.settings.dailyGoalHours.toDouble(),
              min: 2,
              max: 10,
              divisions: 8,
              label: '${viewModel.settings.dailyGoalHours}h',
              onChanged: (value) => _setGoal(value.round()),
            ),
          ],
        ),
      );

  Widget _remindersCard(BuildContext context) => SectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Lembretes & alertas',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            const Text('Ajuste os avisos que ajudam a manter uma rotina saudável.'),
            const SizedBox(height: 8),
            _SettingSwitch(
              title: 'Alerta de limite diário',
              subtitle: 'Aviso ao se aproximar do limite de foco da jornada.',
              value: viewModel.settings.dailyLimitAlert,
              onChanged: (value) => _update(
                viewModel.settings.copyWith(dailyLimitAlert: value),
              ),
            ),
            const Divider(height: 1),
            _SettingSwitch(
              title: 'Lembrete a cada 1 hora',
              subtitle: 'Pausa para hidratação, postura e checagem dos aquários.',
              value: viewModel.settings.breakReminder,
              onChanged: (value) => _update(
                viewModel.settings.copyWith(breakReminder: value),
              ),
            ),
            const Divider(height: 1),
            _SettingSwitch(
              title: 'Sinal sonoro',
              subtitle: 'Som curto ao iniciar ou pausar uma tarefa.',
              value: viewModel.settings.soundEnabled,
              onChanged: (value) => _update(
                viewModel.settings.copyWith(soundEnabled: value),
              ),
            ),
          ],
        ),
      );

  Widget _tagsCard(BuildContext context) => SectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.sell_outlined, color: aquaTeal),
                const SizedBox(width: 10),
                Expanded(
                  child: Text('Tags rápidas',
                      style: Theme.of(context).textTheme.titleLarge),
                ),
                Text('${viewModel.settings.tags.length} ativas'),
              ],
            ),
            const SizedBox(height: 4),
            const Text('Categorias para organizar rotinas e clientes.'),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: () => _showAddTagDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Adicionar tag'),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: viewModel.settings.tags
                  .map(
                    (tag) => InputChip(
                      label: Text('#$tag'),
                      onDeleted: () => viewModel.removeTag(tag),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      );

  Widget _privacyCard(BuildContext context) => SectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Eyebrow('Armazenamento local · AquaTimer'),
            const SizedBox(height: 10),
            Text('Seus dados ficam no dispositivo',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            const Text(
              'Preferências e registros são armazenados localmente. Nenhuma conta é necessária.',
            ),
            const SizedBox(height: 14),
            const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.privacy_tip_outlined, color: aquaTeal),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Sessões controladas e pausas regulares ajudam a preservar a clareza e evitam retrabalho.',
                  ),
                ),
              ],
            ),
          ],
        ),
      );

  void _setGoal(int hours) => _update(
        viewModel.settings.copyWith(dailyGoalHours: hours),
      );

  Future<void> _update(AquariumSettings settings) =>
      viewModel.updateSettings(settings);

  Future<void> _showAddTagDialog(BuildContext context) async {
    final controller = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Adicionar categoria'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Nome da tag',
            hintText: 'Ex.: Plantados',
            prefixText: '# ',
          ),
          onSubmitted: (_) async {
            await viewModel.addTag(controller.text);
            if (dialogContext.mounted) Navigator.pop(dialogContext);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              await viewModel.addTag(controller.text);
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
    controller.dispose();
  }
}

class _SettingSwitch extends StatelessWidget {
  const _SettingSwitch({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        value: value,
        onChanged: onChanged,
      );
}
