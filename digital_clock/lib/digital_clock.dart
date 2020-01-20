// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum _Element { background, text, progressBarBackground, progressBarValue }

final _darkTheme = {
  _Element.background: Colors.black,
  _Element.text: Colors.white,
  _Element.progressBarBackground: Colors.white70,
  _Element.progressBarValue: Colors.white
};

final _lightTheme = {
  _Element.background: Colors.white,
  _Element.text: Colors.black,
  _Element.progressBarBackground: Colors.black12,
  _Element.progressBarValue: Colors.black
};

/// A digital clock.
class DigitalClock extends StatefulWidget {
  const DigitalClock(this.model);

  final ClockModel model;

  @override
  _DigitalClockState createState() => _DigitalClockState();
}

class _DigitalClockState extends State<DigitalClock> {
  DateTime _dateTime = DateTime.now();
  Timer _timer;

  @override
  void initState() {
    super.initState();
    widget.model.addListener(_updateModel);
    _updateTime();
    _updateModel();
  }

  @override
  void didUpdateWidget(DigitalClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.model.removeListener(_updateModel);
    widget.model.dispose();
    super.dispose();
  }

  void _updateModel() {
    setState(() {
      // Cause the clock to rebuild when the model changes.
    });
  }

  void _updateTime() {
    setState(() {
      _dateTime = DateTime.now();
      // Update once per second, but make sure to do it at the beginning of each
      // new second, so that the clock is accurate.
      _timer = Timer(
        Duration(seconds: 1) - Duration(milliseconds: _dateTime.millisecond),
        _updateTime,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).brightness == Brightness.light
        ? _lightTheme
        : _darkTheme;
    final hour =
        DateFormat(widget.model.is24HourFormat ? 'HH' : 'hh').format(_dateTime);
    final minute = DateFormat('mm').format(_dateTime);
    final seconds = DateFormat('ss').format(_dateTime);
    final fontSizeHour = MediaQuery.of(context).size.width / 2.9;
    final fontSizeMinute = MediaQuery.of(context).size.width / 5.8;

    final defaultStyleHour = TextStyle(
      color: colors[_Element.text],
      fontFamily: 'Roboto',
      fontSize: fontSizeHour,
    );
    final defaultStyleMinute = TextStyle(
      color: colors[_Element.text],
      fontFamily: 'Roboto',
      fontSize: fontSizeMinute,
    );
    final progressBarValueColor = colors[_Element.progressBarValue];
    final progressBarBackground = colors[_Element.progressBarBackground];
    final progressBarHeight = fontSizeMinute / 14;
    final progressBarWidth = fontSizeMinute;

    return Row(children: <Widget>[
      Expanded(
          flex: 1,
          child: Container(
              child: DefaultTextStyle(
            style: defaultStyleHour,
            textAlign: TextAlign.center,
            child: Text(hour),
          ))),
      Expanded(
          flex: 1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                  child: DefaultTextStyle(
                style: defaultStyleMinute,
                textAlign: TextAlign.center,
                child: Text(minute),
              )),
              Container(
                  width: progressBarWidth,
                  height: progressBarHeight,
                  child: LinearProgressIndicator(
                      backgroundColor: progressBarBackground,
                      value: int.parse(seconds) / 60,
                      valueColor: new AlwaysStoppedAnimation<Color>(
                          progressBarValueColor)))
            ],
          ))
    ]);
  }
}
