import 'package:flutter/material.dart';
import 'package:templum_studdi/controllers/study_timer.controller.dart';
import 'package:templum_studdi/pages/weekly_time.page.dart';
import 'package:templum_studdi/services/time.services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.controller});

  final StudyTimerController controller;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _submitting = false;

  Future<void> _onPrimaryPressed() async {
    final controller = widget.controller;
    if (_submitting) return;
    setState(() => _submitting = true);
    try {
      if (controller.isRunning) {
        final record = await StopTime();
        if (!mounted) return;
        controller.applyServerStop(record);
      } else {
        final record = await StartTime();
        if (!mounted) return;
        controller.applyServerStart(record);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao controlar tempo: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _openWeeklyTime() async {
    final controller = widget.controller;
    final next = await Navigator.push<Duration>(
      context,
      MaterialPageRoute(
        builder: (context) => WeeklyTimePage(initial: controller.goal),
      ),
    );
    if (next == null || !mounted) return;
    try {
      final record = await defineTime(next);
      if (!mounted) return;
      controller.setGoal(record.definedDuration);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tempo semanal atualizado')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar tempo semanal: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final scheme = Theme.of(context).colorScheme;
        final controller = widget.controller;
        final running = controller.isRunning;
        final paused = controller.isPaused;
        final showReset = paused && controller.current > Duration.zero;
        final reached = controller.goalReached;

        return SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              _buildRing(context, controller),
              const SizedBox(height: 32),
              _buildGoalCard(context, controller, blocked: running),
              SizedBox(
                height: 16,
                child: reached
                    ? Text(
                        'Meta atingida',
                        style: TextStyle(
                          fontSize: 13,
                          color: scheme.secondary,
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              const Spacer(flex: 2),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _submitting ? null : _onPrimaryPressed,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(60),
                          shape: const StadiumBorder(),
                        ),
                        icon: _submitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF05001A),
                                ),
                              )
                            : Icon(
                                running ? Icons.pause : Icons.play_arrow,
                              ),
                        label: Text(
                          running
                              ? 'Pausar'
                              : paused
                                  ? 'Continuar'
                                  : 'Iniciar',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRing(BuildContext context, StudyTimerController controller) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 280,
      height: 280,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: controller.progress,
            strokeWidth: 10,
            strokeCap: StrokeCap.round,
            backgroundColor: scheme.surface,
            color: scheme.secondary,
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Tempo atual',
                  style: TextStyle(
                    fontSize: 14,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formatDuration(controller.current),
                  style: TextStyle(
                    fontSize: 44,
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard(
    BuildContext context,
    StudyTimerController controller, {
    required bool blocked,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: blocked ? null : _openWeeklyTime,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.flag,
              size: 20,
              color: scheme.secondary,
            ),
            const SizedBox(width: 10),
            Text(
              'Meta semanal',
              style: TextStyle(
                fontSize: 15,
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              formatDuration(controller.goal),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: scheme.onSurface,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            if (!blocked) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.edit,
                size: 16,
                color: scheme.onSurfaceVariant,
              ),
            ],
          ],
        ),
      ),
    );
  }
}