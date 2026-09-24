import 'package:flutter/material.dart';
import 'package:templum_studdi/controllers/study_timer.controller.dart';
import 'package:templum_studdi/models/time.dart';
import 'package:templum_studdi/models/user.dart';
import 'package:templum_studdi/pages/login.page.dart';
import 'package:templum_studdi/services/token.services.dart';
import 'package:templum_studdi/services/user.services.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    super.key,
    required this.user,
    required this.timerController,
    this.serverTime,
  });

  final User user;
  final StudyTimerController timerController;
  final Time? serverTime;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Future<void> _logout() async {
    await TokenService.deleteToken();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  Future<void> _deleteAccount() async {
    try {
      await deleteme();
      await TokenService.deleteToken();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      debugPrint('ERRO ao deletar conta: $e');
    }
  }

  void _exitAccount() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text(
            'Sair da conta',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          ),
          content: Text(
            'Tem certeza que deseja sair da sua conta?',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFD4D4D8),
              ),
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              onPressed: () async {
                Navigator.pop(dialogContext);
                await _deleteAccount();
              },
              child: const Text('Sair'),
            ),
          ],
        );
      },
    );
  }

  void _comingSoon() {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Em breve')));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final user = widget.user;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 4,
              right: 4,
              child: PopupMenuButton<String>(
                icon: Icon(Icons.menu, size: 24, color: scheme.onSurface),
                onSelected: (value) {
                  if (value == 'logout') {
                    _logout();
                  } else if (value == 'exit') {
                    _exitAccount();
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: scheme.onSurface),
                        const SizedBox(width: 12),
                        const Text('Deslogar'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'exit',
                    child: Row(
                      children: [
                        Icon(Icons.exit_to_app, color: scheme.error),
                        const SizedBox(width: 12),
                        Text(
                          'Sair da conta',
                          style: TextStyle(color: scheme.error),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(
                  top: 70,
                  left: 24,
                  right: 24,
                  bottom: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: scheme.surface,
                      child: Icon(
                        Icons.person,
                        size: 60,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user.name,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: TextStyle(
                        fontSize: 15,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),
                    AnimatedBuilder(
                      animation: widget.timerController,
                      builder: (context, _) {
                        return Row(
                          children: [
                            Expanded(
                              child: _StatCard(
                                value: formatDuration(
                                  widget.timerController.current,
                                ),
                                label: 'estudado',
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    _CourseCard(studies: user.studies),
                    const SizedBox(height: 24),
                    OutlinedButton(
                      onPressed: _comingSoon,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        side: BorderSide(color: scheme.secondary, width: 1.5),
                        foregroundColor: scheme.secondary,
                        shape: const StadiumBorder(),
                      ),
                      child: const Text(
                        'Editar perfil',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: scheme.onSurface,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  const _CourseCard({required this.studies});

  final String? studies;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hasStudies = studies != null && studies!.isNotEmpty;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Estudando',
                style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 2),
              Text(
                hasStudies ? studies! : 'Não informado',
                style: TextStyle(fontSize: 15, color: scheme.onSurface),
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('Em breve')));
            },
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                'Adicionar',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: scheme.secondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
