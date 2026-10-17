import 'package:flutter/material.dart';

import '../../viewmodels/aquarium_view_model.dart';
import '../../widgets/aqua_ui.dart';
import 'metrics_screen.dart';
import 'settings_screen.dart';
import 'task_log_screen.dart';
import 'timer_screen.dart';

class AquariumShell extends StatefulWidget {
  const AquariumShell({required this.viewModel, super.key});

  final AquariumViewModel viewModel;

  @override
  State<AquariumShell> createState() => _AquariumShellState();
}

class _AquariumShellState extends State<AquariumShell> {
  int _selectedIndex = 0;

  static const _titles = [
    'Cronômetro',
    'Log Diário de Tarefas',
    'Métricas & Fechamento',
    'Configurações Simples',
  ];

  @override
  Widget build(BuildContext context) {
    final screens = [
      TimerScreen(viewModel: widget.viewModel),
      TaskLogScreen(viewModel: widget.viewModel),
      MetricsScreen(viewModel: widget.viewModel),
      SettingsScreen(viewModel: widget.viewModel),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        titleSpacing: 20,
        title: Row(
          children: [
            const AquaLogo(),
            const SizedBox(width: 10),
            const Text(
              'AquaTimer',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            if (MediaQuery.sizeOf(context).width >= 1180)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (var index = 0; index < _titles.length; index++)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 3,
                              ),
                              child: TextButton(
                                onPressed: () =>
                                    setState(() => _selectedIndex = index),
                                style: TextButton.styleFrom(
                                  backgroundColor: _selectedIndex == index
                                      ? const Color(0xffe4f4fa)
                                      : Colors.transparent,
                                  foregroundColor: const Color(0xff18343a),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                ),
                                child: Text(_titles[index]),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            else
              const Spacer(),
            if (MediaQuery.sizeOf(context).width >= 500)
              AnimatedBuilder(
                animation: widget.viewModel,
                builder: (context, _) => GoalChip(viewModel: widget.viewModel),
              ),
          ],
        ),
        toolbarHeight: 76,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1500),
            child: IndexedStack(index: _selectedIndex, children: screens),
          ),
        ),
      ),
      bottomNavigationBar: MediaQuery.sizeOf(context).width < 1180
          ? NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) =>
                  setState(() => _selectedIndex = index),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.timer_outlined),
                  label: 'Cronômetro',
                ),
                NavigationDestination(
                  icon: Icon(Icons.list_alt_outlined),
                  label: 'Log',
                ),
                NavigationDestination(
                  icon: Icon(Icons.insights_outlined),
                  label: 'Métricas',
                ),
                NavigationDestination(icon: Icon(Icons.tune), label: 'Ajustes'),
              ],
            )
          : null,
    );
  }
}
