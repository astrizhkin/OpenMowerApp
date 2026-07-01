import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class LogoWidget extends StatelessWidget {
  const LogoWidget({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: LogoCustomPainter(),
      size: Size(size, size * 0.16968184653774174),
    );
  }
}

class LogoCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'Striga',
        style: TextStyle(
          color: Colors.white,
          fontSize: size.height * 0.75,
          fontFamily: 'Roboto',
        ),
      ),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(maxWidth: size.width);

    //final offsetX = (size.width - textPainter.width) / 2;
    final offsetY = (size.height - textPainter.height) / 2;

    textPainter.paint(canvas, Offset(0, offsetY));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
