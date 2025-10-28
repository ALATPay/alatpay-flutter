import '../core.dart';

class AlatPayTheme {
  final Color primaryColor;
  final Color secondaryColor;

  const AlatPayTheme({
    required this.primaryColor,
    required this.secondaryColor,
  });

  ThemeData toThemeData() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        primary: primaryColor,
        secondary: secondaryColor,
        seedColor: primaryColor,
      ),
      useMaterial3: true,
    );
  }

  static const AlatPayTheme defaultTheme = AlatPayTheme(
    primaryColor: Color(0xffA90736),
    secondaryColor: Color(0xffFBF5F7),
  );
}
