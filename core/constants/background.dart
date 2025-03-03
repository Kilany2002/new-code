import 'package:flutter/material.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;

  const GradientBackground({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          colors: [
            Color(0xFF14072E),
            Color(0xFF0B041B),
            Color(0xFF000002)
          ],
          center: Alignment.center,
          radius: 1.0,
          stops: [0.14, 0.5, 1.0],
        ),
      ),
      child: child,
    );
  }
}
