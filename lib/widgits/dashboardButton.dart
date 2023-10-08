import 'package:academyteacher/Dashboard/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';


class DashboardButton extends StatelessWidget {
  final GlobalKey<FlipCardState> cardKey = GlobalKey<FlipCardState>();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FlipCard(
        key: cardKey,
        flipOnTouch: false, // We'll manually control the flip
        direction: FlipDirection.HORIZONTAL, // You can change the flip direction
        front: GestureDetector(
          onTap: () {
            cardKey.currentState!.toggleCard();
            Future.delayed(const Duration(milliseconds: 500), () {
              Navigator.of(context).push(
                _createPageRoute(),
              );
            });
          },
          child: Container(
            width: 150,
            height: 50,
            color: Colors.blue,
            child: Center(
              child: Text(
                'Tap to Flip',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        back: Container(
          width: 150,
          height: 50,
          color: Colors.blue,
          child: Center(
            child: Text(
              'Tap to Flip',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  PageRouteBuilder _createPageRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) {
        return const Dashboard(); // Replace 'NextScreen()' with your target screen widget
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }
}

