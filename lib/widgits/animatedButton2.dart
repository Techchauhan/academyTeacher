import 'package:flutter/material.dart';

class AnimateButton2 extends StatefulWidget {
  final VoidCallback? onPress; // Callback function to handle button press

  AnimateButton2({this.onPress});

  @override
  _AnimateButton2State createState() => _AnimateButton2State();
}

class _AnimateButton2State extends State<AnimateButton2>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap() {
    widget.onPress?.call(); // Call the onPress callback if provided
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        _animationController.forward();
      },
      onTapUp: (_) {
        _handleTap();
      },
      onTapCancel: () {
        _handleTap();
      },
      child: Transform.scale(
        scale: _scaleAnimation.value,
        child: Container(
          width: 350, // Adjust the width as needed
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.purple,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.purple.withOpacity(0.5),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.upload,
                color: Colors.yellow,
                size: 28,
              ),
              SizedBox(width: 10),
              Text(
                'Upload Video',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
