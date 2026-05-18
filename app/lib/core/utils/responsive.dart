import 'package:flutter/widgets.dart';

/// Helpery do responsive layout (portrait phone vs tablet portrait vs landscape).
class Responsive {
  Responsive._();

  /// Czy obecny rozmiar ekranu odpowiada tabletowi (krótki bok > 600 dp).
  static bool isTablet(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return size.shortestSide >= 600;
  }

  /// Czy ekran w trybie landscape.
  static bool isLandscape(BuildContext context) =>
      MediaQuery.orientationOf(context) == Orientation.landscape;

  /// Maksymalna szerokość zawartości — pozwala na szerokie tła ale
  /// trzyma content w czytelnej szerokości (np. dialog, menu).
  static double contentMaxWidth(BuildContext context) {
    if (isTablet(context)) return 600;
    return double.infinity;
  }

  /// Padding poziomy zależny od rozmiaru.
  static double horizontalPadding(BuildContext context) =>
      isTablet(context) ? 64 : 16;
}
