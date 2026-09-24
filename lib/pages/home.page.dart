import 'package:flutter/material.dart';
import 'package:templum_studdi/models/time.dart';
import 'package:templum_studdi/models/user.dart';
import 'package:templum_studdi/controllers/study_timer.controller.dart';
import 'package:templum_studdi/pages/home.screen.dart';
import 'package:templum_studdi/pages/login.page.dart';
import 'package:templum_studdi/pages/profile.page.dart';
import 'package:templum_studdi/services/time.services.dart';
import 'package:templum_studdi/services/token.services.dart';
import 'package:templum_studdi/services/user.services.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final StudyTimerController _timerController = StudyTimerController();
  bool _checkedToken = false;
  User? _user;
  Time? _serverTime;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  void dispose() {
    _timerController.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    final token = await TokenService.getToken();
    if (token == null) {
      if (!mounted) return;
      _goToLogin();
      return;
    }
    if (!mounted) return;
    try {
      final user = await requestme();
      if (!mounted) return;
      setState(() {
        _checkedToken = true;
        _user = user;
      });
      _loadTime();
    } catch (e) {
      print('ERRO requestme: $e');
      if (!mounted) return;
      _goToLogin();
    }
  }

  Future<void> _loadTime() async {
    try {
      final time = await getTime();
      if (!mounted) return;
      setState(() {
        _serverTime = time;
      });
      _timerController.syncFromServer(time);
    } catch (e) {
      print('ERRO getTime: $e');
    }
  }

  void _goToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_checkedToken) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final user = _user!;
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeScreen(controller: _timerController),
          ProfilePage(
            user: user,
            timerController: _timerController,
            serverTime: _serverTime,
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Início',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}