import 'package:flutter/material.dart';
import 'constants/enums.dart';
import 'core/overlay_tooltip_container.dart';
import 'core/overlay_tooltip_item.dart';
import 'core/tooltip_controller.dart';

class TooltipController extends TooltipControllerImpl {}

class OverlayTooltipScaffold extends OverlayTooltipScaffoldImpl {
  final TooltipController controller;

  /// This future boolean function exposes the amount of instantiated
  /// widgets with tooltips, this future bool functions tells the overlay
  /// when to start automatically
  final Future<bool> Function(int instantiatedWidgetLength)? startWhen;

  final Widget child;

  final Color? overlayColor;

  OverlayTooltipScaffold(
      {Key? key,
      required this.controller,
      required this.child,
      this.overlayColor,
      this.startWhen})
      : super(
            key: key,
            controller: controller,
            child: child,
            overlayColor: overlayColor,
            startWhen: startWhen);
}

class OverlayTooltipItem extends OverlayTooltipItemImpl {
  final TooltipController controller;
  final Widget child;

  /// The tooltip widget to be displayed with the main widget
  final Widget Function(TooltipController) tooltip;

  /// The vertical positioning of the tooltip with relation to the widget
  /// [BOTTOM] or [TOP]
  final TooltipVerticalPosition tooltipVerticalPosition;

  /// The horizontal positioning of the tooltip
  /// [WITH_WIDGET] default, this aligns the tooltip to the alignment
  /// of the main widget.
  /// Other options are [LEFT], [RIGHT], [CENTER]
  final TooltipHorizontalPosition tooltipHorizontalPosition;

  /// This determines the order of display when overlay is started
  final int displayIndex;

  OverlayTooltipItem(
      {Key? key,
      required this.displayIndex,
      required this.controller,
      required this.child,
      required this.tooltip,
      this.tooltipVerticalPosition = TooltipVerticalPosition.BOTTOM,
      this.tooltipHorizontalPosition = TooltipHorizontalPosition.WITH_WIDGET})
      : super(
            key: key,
            child: child,
            controller: controller,
            displayIndex: displayIndex,
            tooltip: tooltip,
            tooltipVerticalPosition: tooltipVerticalPosition,
            tooltipHorizontalPosition: tooltipHorizontalPosition);
}
