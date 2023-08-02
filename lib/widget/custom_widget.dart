import 'package:flutter/material.dart';

class CustomPicker extends StatefulWidget {
  const CustomPicker({
    required this.width,
    required this.height,
    required this.containerWidth,
    required this.containerHeight,
    required this.gapScaleFactor,
    required this.childrenW,
    required this.onSnap,
  });

  final double width;
  final double height;
  final double containerWidth;
  final double containerHeight;
  final double gapScaleFactor;
  final List<Widget> childrenW;
  final Function(int) onSnap;

  @override
  State<CustomPicker> createState() => _CustomPickerState();
}

class _CustomPickerState extends State<CustomPicker>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late double currentScrollX;
  late double oldAnimScrollX;
  late double animDistance;
  late int currentSnap;
  late List<Positioned> scrollableContainer;

  @override
  void initState() {
    super.initState();
    initController();
    init();
  }

  void initController() {
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      lowerBound: 0,
      upperBound: 1,
    )..addListener(() {
        setState(() {
          currentScrollX = oldAnimScrollX + controller.value * animDistance;
          init();
        });
      });
  }

  void init() {
    scrollableContainer.clear();
    if (currentScrollX < 0) {
      currentScrollX = 0;
    }
    double scrollableLength =
        (widget.containerWidth + widget.containerWidth * widget.gapScaleFactor) *
                widget.childrenW.length -
            widget.containerWidth * widget.gapScaleFactor;

    if (currentScrollX > scrollableLength - widget.containerWidth) {
      currentScrollX = scrollableLength - widget.containerWidth;
    }
    for (int i = 0; i < widget.childrenW.length; i++) {
      double leftPos = widget.width / 2 -
          widget.containerWidth / 2 -
          currentScrollX +
          widget.containerWidth * i +
          widget.containerWidth * widget.gapScaleFactor * i;
      double mid = widget.width / 2 - widget.containerWidth / 2;
      double topPos = widget.containerHeight *
          0.9 *
          ((leftPos - mid).abs() / scrollableLength) /
          2;
      scrollableContainer.add(Positioned(
          //calculate X position
          left: leftPos,
          top: topPos,
          child: Container(
            height: widget.containerHeight -
                widget.containerHeight *
                    0.9 *
                    ((leftPos - mid).abs() / scrollableLength),
            width: widget.containerWidth -
                widget.containerWidth *
                    0.9 *
                    ((leftPos - mid).abs() / scrollableLength),
            child: widget.childrenW[i],
          )));
    }
  }

  void lookForSnappoint() {
    double distance = 1000000;
    double animVal = 0;
    int index = -2032;
    for (int i = 0; i < scrollableContainer.length; i++) {
      double snappoint = widget.width / 2 - widget.containerWidth / 2;
      double currentLeftPos = widget.width / 2 -
          widget.containerWidth / 2 -
          currentScrollX +
          widget.containerWidth * i +
          widget.containerWidth * widget.gapScaleFactor * i;
      if ((currentLeftPos - snappoint).abs() < distance) {
        distance = (currentLeftPos - snappoint).abs();
        animVal = currentLeftPos - snappoint;
        index = i;
      }
    }
    animDistance = animVal;
    oldAnimScrollX = currentScrollX;
    controller.reset();
    controller.forward();
    widget.onSnap(index);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      child: GestureDetector(
        onPanUpdate: (DragUpdateDetails dragUpdateDetails) {
          setState(() {
            currentScrollX -= dragUpdateDetails.delta.dx;
            init();
          });
        },
        onPanEnd: (DragEndDetails dragEndDetails) {
          lookForSnappoint();
        },
        behavior: HitTestBehavior.translucent,
        child: LayoutBuilder(builder: (context, constraint) {
          return Container(
            child: Stack(
              children: <Widget>[
                Stack(children: scrollableContainer),
              ],
            ),
          );
        }),
      ),
    );
  }
}