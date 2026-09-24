import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WeeklyTimePage extends StatefulWidget {
  const WeeklyTimePage({super.key, required this.initial});

  final Duration initial;

  @override
  State<WeeklyTimePage> createState() => _WeeklyTimePageState();
}

class _WeeklyTimePageState extends State<WeeklyTimePage> {
  late Duration _value = widget.initial;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tempo semanal'),
        backgroundColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              Text(
                'Defina o tempo de estudo semanal',
                style: TextStyle(
                  fontSize: 15,
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              CupertinoTheme(
                data: const CupertinoThemeData(brightness: Brightness.dark),
                child: SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: CupertinoTimerPicker(
                    mode: CupertinoTimerPickerMode.hms,
                    initialTimerDuration: _value,
                    backgroundColor: scheme.surface,
                    onTimerDurationChanged: (duration) {
                      setState(() {
                        _value = duration;
                      });
                    },
                  ),
                ),
              ),
              const Spacer(),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: FilledButton(
                  style: FilledButton.styleFrom(shape: const StadiumBorder()),
                  onPressed: () => Navigator.pop(context, _value),
                  child: const Text(
                    'Salvar tempo semanal',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}