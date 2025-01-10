import 'package:flutter/material.dart';

class ReusableButton extends StatelessWidget {
  final String buttonText;
  final VoidCallback onPressed;
  final Color buttonColor;
  final Color textColor;
  final double borderRadius;
  final double padding;

  // Constructor to accept custom values for the button
  const ReusableButton({super.key, 
    required this.buttonText,
    required this.onPressed,
    this.buttonColor = Colors.blue, // Default button color
    this.textColor = Colors.white, // Default text color
    this.borderRadius = 8.0, // Default border radius
    this.padding = 16.0, // Default padding
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
        style: TextStyle(fontSize: 16),
      ),
    );
  }
}