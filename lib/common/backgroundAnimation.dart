import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';


class BackgroundAnimation extends StatefulWidget {
  const BackgroundAnimation({
    Key? key,
    required this.size,
    required this.child,
  }) : super(key: key);
  final Size size;
  final Widget child;

  @override
  BackgroundAnimationState createState() => BackgroundAnimationState();
}

class BackgroundAnimationState extends State<BackgroundAnimation> {
  late Timer timer;
  double time = 0;

  @override
  void initState() {
    super.initState();
    const duration = Duration(milliseconds: 1000 ~/ 60); // 60fps
    timer = Timer.periodic(duration, (timer) {
      setState(() {
        time += 0.0025;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Stack(
      children: [
        CustomPaint(
          size: size,
          painter: AnimationPainter2(
            waveColor: Colors.blueAccent.withOpacity(0.8),
            height: 0.25,
            time: time,
          ),
        ),
        Center(
          child: widget.child,
        ),
      ],
    );
  }
}

class AnimationPainter2 extends CustomPainter {
  double height;
  Color waveColor;
  double time;
  AnimationPainter2({
    required this.waveColor,
    required this.height,
    required this.time,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Path path = Path();
    final double waveSpeed = time * 1080;
    final double fullSphere = time * pi * 2;
    final double normalizer = cos(fullSphere);
    const double waveWidth = pi / 270;
    const double waveHeight = 35.0;

    path.lineTo(0, size.height * height);
    for (int i = 0; i < size.width.toInt(); i++) {
      double calc = sin((waveSpeed - i) * waveWidth);
      path.lineTo(
        i.toDouble(),
        size.height * height + calc * waveHeight * normalizer,
      );
    }
    path.lineTo(size.width, 0);

    Paint wavePaint = Paint()..color = waveColor;
    canvas.drawPath(path, wavePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
