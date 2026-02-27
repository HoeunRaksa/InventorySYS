import 'package:flutter/material.dart';

class Responsive extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const Responsive({
    Key? key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  }) : super(key: key);

  // This size works for most mobile phones
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 768;

  // This size works for tablets and small laptops
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 768 &&
      MediaQuery.of(context).size.width < 1200;

  // This size works for medium and large desktop screens
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1200;

  @override
  Widget build(BuildContext context) {
    final Size _size = MediaQuery.of(context).size;
    // If our width is more than 1200 then we consider it a desktop
    if (_size.width >= 1200) {
      return desktop;
    }
    // If width it less than 1200 and more than 768 we consider it a tablet
    else if (_size.width >= 768 && tablet != null) {
      return tablet!;
    }
    // Or less than 768 we consider it a mobile
    else {
      return mobile;
    }
  }
}
