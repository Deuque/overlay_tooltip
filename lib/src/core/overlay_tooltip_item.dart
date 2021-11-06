import 'package:flutter/material.dart';

import '../constants/enums.dart';
import '../impl.dart';
import '../model/tooltip_widget_model.dart';
import 'tooltip_controller.dart';

abstract class OverlayTooltipItemImpl extends StatefulWidget {
  final TooltipControllerImpl controller;
  final Widget child;
  final Widget Function(TooltipController) tooltip;
  final TooltipVerticalPosition tooltipVerticalPosition;
  final TooltipHorizontalPosition tooltipHorizontalPosition;
  final int displayIndex;

  OverlayTooltipItemImpl(
      {Key? key,
      required this.displayIndex,
      required this.controller,
      required this.child,
      required this.tooltip,
      required this.tooltipVerticalPosition,
      required this.tooltipHorizontalPosition})
      : super(key: key);

  @override
  _OverlayTooltipItemImplState createState() => _OverlayTooltipItemImplState();
}

class _OverlayTooltipItemImplState extends State<OverlayTooltipItemImpl> {
  final GlobalKey widgetKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        widget.controller.addPlayableWidget(OverlayTooltipModel(
            child: widget.child,
            tooltip: widget.tooltip,
            widgetKey: widgetKey,
            vertPosition: widget.tooltipVerticalPosition,
            horPosition: widget.tooltipHorizontalPosition,
            displayIndex: widget.displayIndex));
    });
    return Material(
      key: widgetKey,
      color: Colors.transparent,
      child: widget.child,
    );
  }
}
