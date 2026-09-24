import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:templum_studdi/pages/home.page.dart';

const Color kBg = Color(0xFF05001A);
const Color kSurface = Color(0xFF1E1433);
const Color kAccent = Color(0xFFB4F01A);
const Color kText = Color(0xFFE6E0F0);
const Color kMuted = Color(0xFF8C84A0);
const Color kBorderInput = Color(0xFF2F2350);

ThemeData buildAppTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: kAccent,
    brightness: Brightness.dark,
  ).copyWith(
    primary: kAccent,
    onPrimary: kBg,
    secondary: kAccent,
    onSecondary: kBg,
    surface: kSurface,
    onSurface: kText,
    onSurfaceVariant: kMuted,
    outline: kBorderInput,
    surfaceContainerHighest: kSurface,
    surfaceTint: kSurface,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: kBg,
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: kSurface,
      indicatorColor: kAccent,
      indicatorShape: const StadiumBorder(),
      height: 72,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(color: selected ? kBg : kMuted);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: selected ? kText : kMuted,
        );
      }),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: kAccent,
        foregroundColor: kBg,
      ),
    ),
  );
}

void main() async {
  await dotenv.load(fileName: ".env");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Templum Studii',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const Home(),
    );
  }
}