import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

class PageViewPicker extends StatefulWidget {
  const PageViewPicker({super.key, required this.width});
  final double width;

  @override
  State<PageViewPicker> createState() => _PageViewPickerState();
}

class _PageViewPickerState extends State<PageViewPicker> {
  int initial = 100;
  late final PageController pageController;

  @override
  void initState() {
    pageController = PageController(
        initialPage: initial, viewportFraction: widget.width < 370 ? 1 / 4 : 1 / 5.5);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 15),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: const Color.fromRGBO(255, 255, 255, 0.20)),
              height: 69,
              width: double.infinity,
              child: PageView.builder(
                itemCount: 150,
                controller: pageController,
                itemBuilder: (context, index) {
                  final double fontSize = index == initial
                      ? 24
                      : index + 1 == initial || index - 1 == initial
                          ? 14
                          : index + 2 == initial || index - 2 == initial
                              ? 12
                              : 10;
                  final fontWeight =
                      index == initial ? FontWeight.w600 : FontWeight.w400;
                  final color = index == initial
                      ? Colors.white
                      : index + 1 == initial || index - 1 == initial
                          ? Colors.white.withOpacity(0.8)
                          : index + 2 == initial || index - 2 == initial
                              ? Colors.white.withOpacity(0.6)
                              : Colors.white.withOpacity(0.4);
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        index.toString(),
                        style: TextStyle(
                            fontSize: fontSize,
                            fontWeight: fontWeight,
                            height: 1,
                            color: color),
                      ),
                      if (index == initial)
                        const Padding(
                          padding: EdgeInsets.only(left: 5, top: 5),
                          child: Text(
                            'kg',
                            style: TextStyle(fontSize: 10, color: Colors.white),
                          ),
                        )
                    ],
                  );
                },
                onPageChanged: (value) => setState(() {
                  initial = value;
                }),
              ),
            ),
          ),
          Center(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 29,
                decoration: const BoxDecoration(
                    border: Border.symmetric(
                        vertical: BorderSide(color: Colors.red))),
              ),
              SizedBox(width: widget.width < 370 ? MediaQuery.of(context).size.width / 4 : MediaQuery.of(context).size.width / 5.2),
              Container(
                height: 29,
                decoration: const BoxDecoration(
                    border: Border.symmetric(
                        vertical: BorderSide(color: Colors.red))),
              )
            ],
          ))
        ],
      ),
    );
  }
}

class _CustomPageScrollPhysics extends ScrollPhysics {
  final double start;
  final double end;

  const _CustomPageScrollPhysics({
    required this.start,
    required this.end,
    ScrollPhysics? parent,
  }) : super(parent: parent);

  @override
  _CustomPageScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return _CustomPageScrollPhysics(
      parent: buildParent(ancestor),
      start: start,
      end: end,
    );
  }

  @override
  Simulation? createBallisticSimulation(
    ScrollMetrics position,
    double velocity,
  ) {
    final oldPosition = position.pixels;
    final frictionSimulation =
        FrictionSimulation(0.4, position.pixels, velocity * 0.2);

    double newPosition = (frictionSimulation.finalX / 10).round() * 10;

    final endPosition = end * 10 * 10;
    final startPosition = start * 10 * 10;
    if (newPosition > endPosition) {
      newPosition = endPosition;
    } else if (newPosition < startPosition) {
      newPosition = startPosition;
    }
    if (oldPosition == newPosition) {
      return null;
    }
    return ScrollSpringSimulation(
      spring,
      position.pixels,
      newPosition.toDouble(),
      velocity,
      tolerance: tolerance,
    );
  }

  @override
  SpringDescription get spring => const SpringDescription(
        mass: 20,
        stiffness: 100,
        damping: 0.8,
      );
}