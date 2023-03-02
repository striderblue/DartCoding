import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutterfly/SharedPrefs.dart';
import 'package:flutterfly/SharedPrefs.dart' as prefix0;

class TestWidget extends StatefulWidget {
  @override
  _TestWidgetState createState() => _TestWidgetState();
}

class _TestWidgetState extends State<TestWidget> {
  DateTime _lastButtonPress;
  String _pressDuration;
  Timer _ticker;
  Duration _maxDuration;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text("Time since button pressed"),
          Text(_pressDuration),
          Text("Maximal Duration"),
          Text(_formatDuration(_maxDuration)),
          RaisedButton(
            child: Text("Press me"),
            onPressed: () {
              _lastButtonPress = DateTime.now();
              _updateTimer();
              sharedPreferences.setString("lastButtonPress",_lastButtonPress.toIso8601String());
            },
          )
        ],
      ),
    );
  }


  @override
  void initState() {
    super.initState();
    //load max duration, if there is none start with 0
    _maxDuration = Duration(seconds:sharedPreferences.getInt("maxDuration")??0);
    final lastPressString = sharedPreferences.getString("lastButtonPress");
    _lastButtonPress = lastPressString!=null ? DateTime.parse(lastPressString) : DateTime.now();
    _updateTimer();
    _ticker = Timer.periodic(Duration(seconds:1),(_)=>_updateTimer());
  }


  @override
  void dispose() {
    _ticker.cancel();
    super.dispose();
  }



  void _updateTimer() {
    final duration = DateTime.now().difference(_lastButtonPress);
    //check for new max duration here
    Duration newMaxDuration = _maxDuration;
    if(duration> _maxDuration) {
      //save when current duration is a new max
      newMaxDuration = duration;
      sharedPreferences.setInt("maxDuration",newMaxDuration.inSeconds);
    }
    final newDuration =_formatDuration(duration);
    setState(() {
      _maxDuration = newMaxDuration;
      _pressDuration = newDuration;
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) {
      if (n >= 10) return "$n";
      return "0$n";
    }

    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }
}
