import 'package:flutter/material.dart';
import '../constants/extensions.dart';
import '../constants/enums.dart';
import '../impl.dart';
import '../model/tooltip_widget_model.dart';

abstract class OverlayTooltipScaffoldImpl extends StatelessWidget {
  final TooltipController controller;
  final Future<bool> Function(int instantiatedWidgetLength)? startWhen;
  final Widget child;
  final Color? overlayColor;

  OverlayTooltipScaffoldImpl({
    Key? key,
    required this.controller,
    required this.child,
    required this.overlayColor,
    required this.startWhen,
  }) : super(key: key) {
    if (startWhen != null) controller.startWhen(startWhen!);
    controller.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(child: child),
          StreamBuilder<OverlayTooltipModel?>(
              stream: controller.widgetsPlayStream,
              builder: (context, snapshot) {
                return snapshot.data == null ||
                        snapshot.data!.widgetKey.globalPaintBounds == null
                    ? SizedBox.shrink()
                    : Positioned.fill(
                        child: Container(
                        color: overlayColor ?? Colors.black.withOpacity(.5),
                        child: TweenAnimationBuilder(
                          key: ValueKey(snapshot.data!.displayIndex),
                          duration: Duration(milliseconds: 500),
                          tween: Tween<double>(begin: 0, end: 1),
                          curve: Curves.decelerate,
                          builder: (_, double val, child) => Opacity(
                            opacity: val,
                            child: _TooltipLayout(
                              model: snapshot.data!,
                              controller: controller,
                            ),
                          ),
                        ),
                      ));
              })
        ],
      ),
    );
  }
}

class _TooltipLayout extends StatelessWidget {
  final OverlayTooltipModel model;
  final TooltipController controller;

  const _TooltipLayout({
    Key? key,
    required this.model,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var topLeft = model.widgetKey.globalPaintBounds!.topLeft;
    var bottomRight = model.widgetKey.globalPaintBounds!.bottomRight;

    return LayoutBuilder(builder: (context, size) {
      if (topLeft.dx < 0) {
        bottomRight = Offset(bottomRight.dx + (0 - topLeft.dx), bottomRight.dy);
        topLeft = Offset(0, topLeft.dy);
      }

      if (bottomRight.dx > size.maxWidth) {
        topLeft =
            Offset(topLeft.dx - (bottomRight.dx - size.maxWidth), topLeft.dy);
        bottomRight = Offset(size.maxWidth, bottomRight.dy);
      }

      if (topLeft.dy < 0) {
        bottomRight = Offset(bottomRight.dx, bottomRight.dy + (0 - topLeft.dy));
        topLeft = Offset(topLeft.dx, 0);
      }

      if (bottomRight.dy > size.maxHeight) {
        topLeft =
            Offset(topLeft.dx, topLeft.dy - (bottomRight.dy - size.maxHeight));
        bottomRight = Offset(bottomRight.dx, size.maxHeight);
      }

      return Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: topLeft.dy,
            left: topLeft.dx,
            bottom: size.maxHeight - bottomRight.dy,
            right: size.maxWidth - bottomRight.dx,
            child: IgnorePointer(child: model.child),
          ),
          _buildBottomToolTip(topLeft, bottomRight, size)
        ],
      );
    });
  }

  Widget _buildBottomToolTip(
      Offset topLeft, Offset bottomRight, BoxConstraints size) {
    bool isTop = model.vertPosition == TooltipVerticalPosition.TOP;

    bool alignLeft = topLeft.dx <= (size.maxWidth - bottomRight.dx);

    final calculatedLeft = alignLeft ? topLeft.dx : null;
    final calculatedRight = alignLeft ? null : size.maxWidth - bottomRight.dx;
    final calculatedTop = isTop ? null : bottomRight.dy;
    final calculatedBottom = isTop ? (size.maxHeight - topLeft.dy) : null;
    return (model.horPosition == TooltipHorizontalPosition.WITH_WIDGET)
        ? Positioned(
            top: calculatedTop,
            left: calculatedLeft,
            right: calculatedRight,
            bottom: calculatedBottom,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                model.tooltip(controller),
              ],
            ),
          )
        : Positioned(
            top: calculatedTop,
            left: 0,
            right: 0,
            bottom: calculatedBottom,
            child: model.horPosition == TooltipHorizontalPosition.CENTER
                ? Center(
                    child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      model.tooltip(controller),
                    ],
                  ))
                : Align(
                    alignment:
                        model.horPosition == TooltipHorizontalPosition.RIGHT
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        model.tooltip(controller),
                      ],
                    ),
                  ),
          );
  }
}
