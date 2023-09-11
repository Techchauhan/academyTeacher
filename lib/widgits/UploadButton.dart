import 'package:flutter/material.dart';

class UploadButton extends StatefulWidget {
  final VoidCallback onPressed; // Callback function to execute on button press

  UploadButton({required this.onPressed});

  @override
  _UploadButtonState createState() => _UploadButtonState();
}

class _UploadButtonState extends State<UploadButton> with SingleTickerProviderStateMixin {
  bool isButtonPressed = false;
  late AnimationController animationController;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          isButtonPressed = true;
          animationController.forward();
        });
      },
      onTapUp: (_) {
        setState(() {
          isButtonPressed = false;
          animationController.reverse();
        });
        // Call the callback function when the button is released
        widget.onPressed();
      },
      child: ScaleTransition(
        scale: Tween<double>(
          begin: 1.0,
          end: 0.9,
        ).animate(
          CurvedAnimation(
            curve: Curves.easeOut,
            parent: animationController,
          ),
        ),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          width: 200,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            color: isButtonPressed ? Colors.blue : Colors.green,
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Select PDF',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                SizedBox(width: 10,),
                Icon(Icons.picture_as_pdf)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
