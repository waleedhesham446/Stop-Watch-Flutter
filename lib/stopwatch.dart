import 'dart:async';
import 'package:flutter/material.dart';
import './platform_alert.dart';

class StopWatch extends StatefulWidget {
  static const route = '/stopwatch';

  // final String name;
  // final String email;
  // const StopWatch({Key key, this.name, this.email}): super(key: key);

  @override
  _StopWatchState createState() => _StopWatchState();
}

class _StopWatchState extends State<StopWatch> {
  final laps = <int>[];
  final itemHeight = 60.0;
  final scrollController = ScrollController();
  int milliseconds = 0;
  Timer timer;
  bool isTicking = false;

  // @override
  // void initState() {
  //   super.initState();

  //   seconds = 0;
  //   timer = Timer.periodic(Duration(seconds: 1), _onTick);
  // }

  void _lap() {
    setState(() {
      laps.add(milliseconds);
      milliseconds = 0;
    });

    scrollController.animateTo(
      itemHeight * laps.length,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeIn,
    );
  }

  void _onTick(Timer time) {
    setState(() {
      milliseconds += 100;
    });
  }

  @override
  Widget build(BuildContext context) {
    String name = ModalRoute.of(context).settings.arguments ?? '';
    return Scaffold(
      appBar: AppBar(
        title: Text(name),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: _buildCounter(context),
          ),
          Expanded(
            child: _buildLapDisplay(),
          ),
        ],
      ),
    );
  }

  Widget _buildCounter(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Lap ${laps.length + 1}',
            style: Theme.of(context).textTheme.subtitle.copyWith(color: Colors.white),
          ),
          Text(
            _secondsText(milliseconds),
            style: Theme.of(context).textTheme.headline5.copyWith(color: Colors.white),
          ),
          SizedBox(height: 20),
          _buildControls(),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
              ),
              child: Text('Start'),
              onPressed: isTicking ? null : _startTimer,
            ),
            SizedBox(width: 20),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.orange),
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
              ),
              child: Text('Continue'),
              onPressed: (isTicking || milliseconds == 0) ? null : _continueTimer,
            ),
            SizedBox(width: 20),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.yellow),
                foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
              ),
              child: Text('Lap'),
              onPressed: milliseconds > 0 ? _lap : null,
            ),
            SizedBox(width: 20),
            TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
              ),
              child: Text('Stop'),
              onPressed: isTicking ? _stopTimer : null,
            ),
          ],
        ),
        SizedBox(height: 20),
        Builder(
          builder: (context) => ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.purple),
              foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
            ),
            child: Text('Clear Laps'),
            onPressed: laps.length > 0 ? () => _clearLaps(context) : null,
          ),
        ),
      ],
    );
  }

  void _startTimer() {
    timer = Timer.periodic(Duration(milliseconds: 100), _onTick);
    setState(() {
      // laps.clear();
      milliseconds = 0;
      isTicking = true;
    });
  }

  void _continueTimer() {
    timer = Timer.periodic(Duration(milliseconds: 100), _onTick);
    setState(() {
      isTicking = true;
    });
  }

  void _stopTimer() {
    timer.cancel();
    setState(() {
      isTicking = false;
    });
  }

  void _clearLaps(BuildContext context) {
    // final totalRuntime = laps.fold(milliseconds, (total, lap) => total + lap);
    // final alert = PlatformAlert(
    //   title: 'Run Completed!',
    //   message: 'Total Run Time is ${_secondsText(totalRuntime)}.',
    // );
    // alert.show(context);

    final controller = showBottomSheet(
      context: context,
      builder: _buildRunCompleteSheet,
    );

    Future.delayed(Duration(seconds: 5)).then((_) {
      controller.close();
      setState(() {
        laps.clear();
      });
    });
  }

  Widget _buildRunCompleteSheet(BuildContext context) {
    final totalRuntime = laps.fold(milliseconds, (total, lap) => total + lap);
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: Container(
        color: Theme.of(context).cardColor,
        width: double.infinity,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 30.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Run Finished!',
                style: textTheme.headline6,
              ),
              Text('Total Runtime is ${_secondsText(totalRuntime)}'),
            ],
          ),
        ),
      ),
    );
  }

  String _secondsText(int milliseconds) {
    final seconds = milliseconds / 1000;
    return '$seconds Seconds';
  }

  Widget _buildLapDisplay() {
    return Scrollbar(
      child: ListView.builder(
          controller: scrollController,
          itemExtent: itemHeight,
          itemCount: laps.length,
          itemBuilder: (context, index) {
            return ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 50),
              title: Text('Lap ${index + 1}'),
              trailing: Text(_secondsText(laps[index])),
            );
          }),
    );
    // ListView(
    //   children: [
    //     for (int milliseconds in laps)
    //       ListTile(
    //         title: Text(
    //           _secondsText(milliseconds),
    //         ),
    //       ),
    //   ],
    // );
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }
}
