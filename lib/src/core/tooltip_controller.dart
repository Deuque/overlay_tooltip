import 'dart:async';
import 'package:flutter/material.dart';
import '../model/tooltip_widget_model.dart';

abstract class TooltipControllerImpl {
  final _playableWidgets = <OverlayTooltipModel>[];
  final _widgetsPlayController =
      StreamController<OverlayTooltipModel?>.broadcast();

  Stream<OverlayTooltipModel?> get widgetsPlayStream =>
      _widgetsPlayController.stream.map((event) {
        _notifyChangeTooltip();
        return event;
      });
  final _onChangeTooltipListeners = <VoidCallback>[];
  final _onDismissListeners = <VoidCallback>[];
  Future<bool> Function(int instantiatedWidgetLength)? _startWhenCallback;
  int _nextPlayIndex = 0;

  int get nextPlayIndex => _nextPlayIndex;
  int get playWidgetLength => _playableWidgets.length;

  void start({int startFrom = 0}) {
    if (_playableWidgets.isEmpty) {
      throw ('No overlay tooltip item has been '
          'initialized, consider inserting controller.start() in a button '
          'callback or using the startWhen method');
    }

    _nextPlayIndex = startFrom;
    _playableWidgets.sort((a, b) => a.displayIndex.compareTo(b.displayIndex));
    _widgetsPlayController.sink.add(_playableWidgets[_nextPlayIndex]);
  }

  void startWhen(Future<bool> Function(int initializedWidgetLength) callback) {
    _startWhenCallback = callback;
  }

  void reset() {
    _nextPlayIndex = 0;
    _playableWidgets.clear();
    _widgetsPlayController.sink.add(null);
  }

  next() {
    _nextPlayIndex++;
    if (_nextPlayIndex < _playableWidgets.length) {
      _widgetsPlayController.sink.add(_playableWidgets[_nextPlayIndex]);
    } else {
      _widgetsPlayController.sink.add(null);
      dismiss();
    }
  }

  previous() {
    if (_nextPlayIndex > 0) {
      _nextPlayIndex--;
      _widgetsPlayController.sink.add(_playableWidgets[_nextPlayIndex]);
    } else {
      dismiss();
    }
  }

  dismiss() {
    _widgetsPlayController.sink.add(null);
    _notifyDismissTooltip();
  }

  void addPlayableWidget(OverlayTooltipModel model) async {
    if (_playableWidgets
        .map((e) => e.displayIndex)
        .toList()
        .contains(model.displayIndex)) {
      int prevIndex = _playableWidgets.indexOf(model);
      _playableWidgets[prevIndex] = model;
      return;
    }
    _playableWidgets.add(model);
    if ((await _startWhenCallback?.call(_playableWidgets.length)) ?? false) {
      start();
    }
  }

  void addChangeTooltipListener(Function() listener) {
    _onChangeTooltipListeners.add(listener);
  }

  void removeChangeTooltipListener(Function() listener) {
    _onChangeTooltipListeners.remove(listener);
  }

  void addDismissListener(Function() listener) {
    _onDismissListeners.add(listener);
  }

  void removeDismissListener(Function() listener) {
    _onDismissListeners.remove(listener);
  }

  void _notifyChangeTooltip() {
    for (var item in _onChangeTooltipListeners) {
      item.call();
    }
  }

  void _notifyDismissTooltip() {
    for (var item in _onDismissListeners) {
      item.call();
    }
  }

  void dispose() {
    _onChangeTooltipListeners.clear();
    _onDismissListeners.clear();
    _widgetsPlayController.close();
  }
}
