import 'package:flutter/material.dart';

class CustomScaffold extends StatelessWidget {
  final Widget body;
  final Widget? bottomNavigationBar; 
  final PreferredSizeWidget? appBar; 

  const CustomScaffold({
    Key? key,
    required this.body,
    this.bottomNavigationBar, 
    this.appBar, 
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            colors: [
              Color(0xFF14072E),
              Color(0xFF0B041B),
              Color(0xFF000002),
            ],
          ),
        ),
        child: body,
      ),
      bottomNavigationBar: bottomNavigationBar,
      appBar: appBar,
    );
  }
}
