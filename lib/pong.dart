import 'package:flutter/material.dart';
import 'dart:math';

import './ball.dart';
import './bat.dart';

enum Direction { up, down, left, right }

class Pong extends StatefulWidget {
  @override
  _PongState createState() => _PongState();
}

class _PongState extends State<Pong> with SingleTickerProviderStateMixin {
  double randX = 1;
  double randY = 1;
  double diameter = 50;
  double increment = 7;
  Direction vDir = Direction.down;
  Direction hDir = Direction.right;

  Animation<double> animation;
  AnimationController controller;

  double width; //screen available width
  double height;
  double posX = 0; // ball position
  double posY = 0;
  double batWidth = 0;
  double batHeight = 0;
  double batPosition = 0;

  double randomNumber() {
    //this is a number between 0.5 and 1.5;
    var ran = new Random();
    int myNum = ran.nextInt(101);
    return (50 + myNum) / 100;
  }

  void checkBorders() {
    double diameter = 50;
    if (posX <= 0 && hDir == Direction.left) {
      hDir = Direction.right;
      randX = randomNumber();
    }
    if (posX >= width - diameter && hDir == Direction.right) {
      hDir = Direction.left;
      randX = randomNumber();
    }
    //check the bat position as well
    if (posY >= height - diameter - batHeight && vDir == Direction.down) {
      //check if the bat is here, otherwise loose
      if (posX >= (batPosition - diameter) &&
          posX <= (batPosition + batWidth + diameter)) {
        vDir = Direction.up;
        randY = randomNumber();
      } else {
        controller.stop();
        dispose();
      }
    }
    if (posY <= 0 && vDir == Direction.up) {
      vDir = Direction.down;
      randY = randomNumber();
    }
  }

  @override
  void initState() {
    posX = 0;
    posY = 0;
    controller = AnimationController(
        duration: const Duration(minutes: 10000), vsync: this);
    animation = Tween<double>(begin: 0, end: 100).animate(controller);
    animation.addListener(() {
      safeSetState(() {
        (hDir == Direction.right)
            ? posX += ((increment * randX).round())
            : posX -= ((increment * randX).round());
        (vDir == Direction.down)
            ? posY += ((increment * randY).round())
            : posY -= ((increment * randY).round());
      });
      checkBorders();
    });
    controller.forward();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        height = constraints.maxHeight;
        width = constraints.maxWidth;
        batHeight = height / 20;
        batWidth = width / 5;
        return Stack(
          children: <Widget>[
            Positioned(
              child: Ball(),
              top: posY,
              left: posX,
            ),
            Positioned(
                child: GestureDetector(
                    onHorizontalDragUpdate: (DragUpdateDetails update) =>
                        moveBat(update),
                    child: Bat(batWidth, batHeight)),
                bottom: 0,
                left: batPosition)
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  moveBat(DragUpdateDetails update) {
    setState(() {
      batPosition += update.delta.dx;
    });
  }

  void safeSetState(Function function) {
    if (mounted && controller.isAnimating) {
      setState(() {
        function();
      });
    }
  }
}
