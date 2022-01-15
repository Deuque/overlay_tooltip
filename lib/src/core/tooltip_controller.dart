import 'dart:async';

import 'package:flutter/material.dart';

import '../model/tooltip_widget_model.dart';

abstract class TooltipControllerImpl {
  List<OverlayTooltipModel> _playableWidgets = [];
  StreamController<OverlayTooltipModel?> _widgetsPlayController =
      StreamController();
  late Stream<OverlayTooltipModel?> _widgetsPlayStream =
      _widgetsPlayController.stream.asBroadcastStream();

  Stream<OverlayTooltipModel?> get widgetsPlayStream => _widgetsPlayStream;
  VoidCallback? _onDoneCallback;
  Future<bool> Function(int instantiatedWidgetLength)? _startWhenCallback;
  int _nextPlayIndex = 0;

  int get nextPlayIndex => _nextPlayIndex;

  int get playWidgetLength => _playableWidgets.length;

  void start() {
    if (_playableWidgets.isEmpty) {
      throw ('$playWidgetLength No overlay tooltip item has been '
          'initialized, consider inserting controller.start() in a button '
          'callback or using the startWhen method');
    }

    _nextPlayIndex = 0;
    _playableWidgets.sort((a, b) => a.displayIndex.compareTo(b.displayIndex));
    _widgetsPlayController.sink.add(_playableWidgets[_nextPlayIndex]);
  }

  void startWhen(Future<bool> Function(int initializedWidgetLength) callback) {
    _startWhenCallback = callback;
  }

  // void reset() {
  //   _nextPlayIndex = 0;
  //   _playableWidgets = [];
  //   _widgetsPlayController.sink.add(null);
  // }

  next() {
    _nextPlayIndex++;
    if (_nextPlayIndex < _playableWidgets.length) {
      _widgetsPlayController.sink.add(_playableWidgets[_nextPlayIndex]);
    } else {
      _widgetsPlayController.sink.add(null);
      _onDoneCallback?.call();
    }
  }

  previous() {
    if (_nextPlayIndex > 0) {
      _nextPlayIndex--;
      _widgetsPlayController.sink.add(_playableWidgets[_nextPlayIndex]);
    }
  }

  dismiss() {
    _widgetsPlayController.sink.add(null);
    _onDoneCallback?.call();
  }

  void addPlayableWidget(OverlayTooltipModel model) async {
    if (_playableWidgets
        .map((e) => e.displayIndex)
        .toList()
        .contains(model.displayIndex)) {
      int prevIndex = _playableWidgets.indexOf(model);
      _playableWidgets[prevIndex] = model;
    }else {
      _playableWidgets.add(model);
    }

    if ((await _startWhenCallback?.call(_playableWidgets.length)) ?? false) {
      start();
    }
  }

  void onDone(Function() onDone) {
    _onDoneCallback = onDone;
  }

  void dispose() {
    _widgetsPlayController.close();
  }
}
