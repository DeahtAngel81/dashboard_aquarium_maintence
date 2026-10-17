import 'package:flutter/material.dart';

import '../viewmodels/aquarium_view_model.dart';

const aquaTeal = Color(0xff006c68);
const aquaDark = Color(0xff004e58);
const aquaPale = Color(0xffe4f5fb);
const aquaMuted = Color(0xff62777c);

class AquaLogo extends StatelessWidget {
  const AquaLogo({super.key});

  @override
  Widget build(BuildContext context) => Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: aquaPale,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.timer_outlined, color: aquaTeal),
      );
}

class GoalChip extends StatelessWidget {
  const GoalChip({required this.viewModel, super.key});

  final AquariumViewModel viewModel;

  @override
  Widget build(BuildContext context) => Container(
        constraints: const BoxConstraints(maxWidth: 205),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: aquaPale,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'META DIÁRIA  ${durationLabel(viewModel.dailyTotal)} / ${viewModel.settings.dailyGoalHours}h',
              style: const TextStyle(fontSize: 10, letterSpacing: 0.8),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 5),
            LinearProgressIndicator(
              value: viewModel.goalProgress,
              minHeight: 5,
              backgroundColor: const Color(0xffd2e8f1),
              color: aquaTeal,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
}

class PageHeading extends StatelessWidget {
  const PageHeading({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    this.trailing,
    super.key,
  });

  final String eyebrow;
  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    eyebrow.toUpperCase(),
                    style: const TextStyle(
                      color: aquaTeal,
                      fontFamily: 'monospace',
                      fontSize: 11,
                      letterSpacing: 1.4,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xff172d32),
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: aquaMuted,
                        ),
                  ),
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 16),
              trailing!,
            ],
          ],
        ),
      );
}

class SectionCard extends StatelessWidget {
  const SectionCard({required this.child, this.padding = const EdgeInsets.all(22), super.key});

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(padding: padding, child: child),
      );
}

class Eyebrow extends StatelessWidget {
  const Eyebrow(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 11,
          letterSpacing: 1,
          color: aquaMuted,
        ),
      );
}

String durationLabel(Duration duration) {
  final hours = duration.inHours.toString().padLeft(2, '0');
  final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
  return '${hours}h ${minutes}m';
}

String clockLabel(Duration duration) {
  final hours = duration.inHours.toString().padLeft(2, '0');
  final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
  final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
  return '$hours:$minutes:$seconds';
}
