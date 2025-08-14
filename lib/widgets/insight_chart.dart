import 'package:flutter/material.dart';

class ChartExample extends StatelessWidget {
  final Color chartPrimaryColor = Colors.blue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          height: 200,
          width: 200,
          decoration: BoxDecoration(
            color: chartPrimaryColor.withValues(
              red: chartPrimaryColor.r.toDouble(),
              green: chartPrimaryColor.g.toDouble(),
              blue: chartPrimaryColor.b.toDouble(),
              alpha: 0.1, // 10% opacity
            ),
            border: Border.all(
              color: chartPrimaryColor.withValues(
                red: chartPrimaryColor.r.toDouble(),
                green: chartPrimaryColor.g.toDouble(),
                blue: chartPrimaryColor.b.toDouble(),
                alpha: 0.3, // 30% opacity
              ),
              width: 3,
            ),
          ),
          child: Center(
            child: Text(
              'Chart Box',
              style: TextStyle(
                color: chartPrimaryColor.withValues(
                  red: chartPrimaryColor.r.toDouble(),
                  green: chartPrimaryColor.g.toDouble(),
                  blue: chartPrimaryColor.b.toDouble(),
                  alpha: 0.8, // 80% opacity
                ),
                fontSize: 18,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
