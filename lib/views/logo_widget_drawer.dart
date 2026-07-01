import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class LogoWidgetDrawer extends StatelessWidget {
  const LogoWidgetDrawer({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: LogoCustomPainterDrawer(),
      size: Size(size, size * 0.4195859872611465),
    );
  }
}

class LogoCustomPainterDrawer extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'Striga',
        style: TextStyle(
          color: Colors.white,
          fontSize: size.height * 0.65,
          fontFamily: 'Roboto',
        ),
      ),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(maxWidth: size.width);

    final offsetX = (size.width - textPainter.width) / 2;
    final offsetY = (size.height + textPainter.height) / 2;

    textPainter.paint(canvas, Offset(offsetX, offsetY));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
