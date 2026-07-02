import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LogoWidgetDrawer extends StatelessWidget {
  const LogoWidgetDrawer({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'fonts/striga.svg',
      width: size,
      height: size * 0.4195859872611465,
      fit: BoxFit.contain,
      colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
    );
  }
}
