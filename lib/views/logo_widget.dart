import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LogoWidget extends StatelessWidget {
  const LogoWidget({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    //height: size * 0.16968184653774174,
    return SvgPicture.asset(
      'fonts/striga.svg',
      width: size,
      height: size * 0.12,
      fit: BoxFit.contain,
      colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
    );
  }
}
