import 'package:flutter/material.dart';

class ReusableButton extends StatelessWidget {
  final String buttonText;
  final VoidCallback onPressed;
  final Color buttonColor;
  final Color textColor;
  final double borderRadius;
  final double padding;
  final FontWeight weight;

  // Constructor to accept custom values for the button
  const ReusableButton({super.key, 
    required this.buttonText,
    required this.onPressed,
    this.buttonColor = Colors.blue, 
    this.textColor = Colors.white, 
    this.borderRadius = 8.0, 
    this.padding = 16.0, 
    this.weight = FontWeight.normal
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: textColor, backgroundColor: buttonColor, 
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius), 
        ),
        padding: EdgeInsets.all(padding), // Button padding
      ),
      child: Text(
        buttonText,
        style: TextStyle(fontSize: 20,fontWeight: weight),
      ),
    );
  }
}