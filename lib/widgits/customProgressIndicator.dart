import 'package:flutter/material.dart';


class CustomProgressIndicator extends StatelessWidget {
  final double value;

  CustomProgressIndicator(this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircularProgressIndicator(value: value),
        SizedBox(height: 16),
        Text('${(value * 100).toStringAsFixed(2)}%', style: TextStyle(fontSize: 20)),
      ],
    );
  }
}