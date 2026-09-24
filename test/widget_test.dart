import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:templum_studdi/controllers/study_timer.controller.dart';

import 'package:templum_studdi/main.dart';
import 'package:templum_studdi/pages/home.screen.dart';

void main() {
  group('StudyTimerController', () {
    test('formatDuration pads with zeros', () {
      expect(formatDuration(const Duration(hours: 1, minutes: 30)), '01:30:00');
      expect(formatDuration(const Duration(seconds: 5)), '00:00:05');
      expect(formatDuration(Duration.zero), '00:00:00');
    });

    test('state transitions', () {
      final controller = StudyTimerController();
      expect(controller.isRunning, isFalse);
      expect(controller.isPaused, isFalse);

      controller.start();
      expect(controller.isRunning, isTrue);

      controller.pause();
      expect(controller.isRunning, isFalse);
      expect(controller.isPaused, isTrue);

      controller.reset();
      expect(controller.isRunning, isFalse);
      expect(controller.isPaused, isFalse);

      controller.dispose();
    });

    test('setGoal is blocked while running', () {
      final controller = StudyTimerController();
      const custom = Duration(minutes: 30);
      controller.setGoal(custom);
      expect(controller.goal, custom);

      controller.start();
      controller.setGoal(const Duration(minutes: 45));
      expect(controller.goal, custom);

      controller.dispose();
    });
  });

  testWidgets('HomeScreen renders initial state', (tester) async {
    final controller = StudyTimerController();
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: Scaffold(body: HomeScreen(controller: controller)),
      ),
    );

    expect(find.text('Tempo atual'), findsOneWidget);
    expect(find.text('00:00:00'), findsOneWidget);
    expect(find.text('Meta semanal'), findsOneWidget);
    expect(find.text('00:01:00'), findsOneWidget);
    expect(find.text('Iniciar'), findsOneWidget);

    controller.dispose();
    await tester.pumpWidget(const SizedBox());
  });
}