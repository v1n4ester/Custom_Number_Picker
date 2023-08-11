import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

class CustomWidget extends StatefulWidget {
  final int from;
  final int max;
  final int initialValue;
  final Function(int) onChanged;
  final double widgetHeight;
  final Color widgetColor;
  final double littleItemHeight;
  final double mediumItemHeight;
  final double selectedItemHeight;
  final Color itemColor;
  final double itemThickness;

  const CustomWidget({
    required this.from,
    required this.max,
    required this.initialValue,
    required this.onChanged,
    required this.widgetHeight,
    required this.littleItemHeight,
    required this.mediumItemHeight,
    required this.selectedItemHeight,
    required this.itemColor,
    required this.itemThickness,
    required this.widgetColor,
    super.key,
  });

  @override
  State<CustomWidget> createState() => _CustomWidgetState();
}

class _CustomWidgetState extends State<CustomWidget> {
  PageController? numbersController;
  late int value;

  @override
  void initState() {
    value = widget.initialValue;
    super.initState();
  }

  void _updateValue() {
    final newValue = ((numbersController?.page ?? 0) + widget.from)
        .clamp(widget.from.toDouble(), widget.max.toDouble())
        .toInt();

    setState(() {
      value = newValue;
    });

    widget.onChanged(newValue);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final viewPortFraction = 2 / constraints.maxWidth;
        numbersController = PageController(
          initialPage: widget.initialValue.toInt(),
          viewportFraction: viewPortFraction * 8,
        );
        numbersController?.addListener(_updateValue);
        return Container(
          color: widget.widgetColor,
          height: widget.widgetHeight,
          child: PageView.builder(
            pageSnapping: false,
            controller: numbersController,
            physics: _CustomPageScrollPhysics(
              start: widget.from,
              end: widget.max,
            ),
            scrollDirection: Axis.horizontal,
            itemCount: widget.max - widget.from + 1,
            itemBuilder: (context, rawIndex) {
              final index = rawIndex + widget.from;
              return _getDivider(index);
            },
          ),
        );
      },
    );
  }

  Widget _getDivider(int index) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SizedBox(
          height: _getDividerHeight(index: index),
          child: VerticalDivider(
            thickness: widget.itemThickness,
            color: widget.itemColor.withOpacity(_getOpacity(index: index)),
          ),
        )
      ],
    );
  }

  double _getOpacity({required int index}) {
  final difference = (index - value).abs() / 10;
  final opacity = (1 - difference) > 0.4 ? 1.0 : (1 - difference) <= 0.2 ? (1 - difference) + 0.2 : (1 - difference) + 0.4;
  
  return index == value ? 1 : opacity.clamp(0, 1);
}

  double _getDividerHeight({required int index}) {
    if (value == index) {
      return widget.selectedItemHeight;
    } else if (index % 5 == 0) {
      return widget.mediumItemHeight;
    } else {
      return widget.littleItemHeight;
    }
  }

  @override
  void dispose() {
    numbersController?.removeListener(_updateValue);
    numbersController?.dispose();
    super.dispose();
  }
}

class _CustomPageScrollPhysics extends ScrollPhysics {
  final int start;
  final int end;

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

    double newPosition = (frictionSimulation.finalX / 16).round() * 16;

    final double itemExtent =
        100; // Припустима ширина однієї сторінки в PageView
    final double itemCount = end - start + 1; // Кількість сторінок
    final double maxScrollExtent = itemCount * itemExtent;
    final double minScrollExtent = 0;

    if (newPosition > maxScrollExtent) {
      newPosition = maxScrollExtent;
    } else if (newPosition < minScrollExtent) {
      newPosition = minScrollExtent;
    }
    if (oldPosition == newPosition) {
      return null;
    }
    return ScrollSpringSimulation(
      spring,
      position.pixels,
      newPosition,
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
