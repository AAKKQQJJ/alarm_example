import 'dart:async';

import 'package:alarm/alarm.dart';
import 'package:alarm/utils/alarm_set.dart';
import 'package:alarm_practice/Screen/edit_alarm.dart';
import 'package:alarm_practice/Screen/ring.dart';
import 'package:alarm_practice/widgets/tile.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<AlarmSettings> alarms = [];

  //알람 불러오기 & 알람 순서 정렬//
  Future<void> loadAlarms() async {
    final updatedAlarms = await Alarm.getAlarms();
    updatedAlarms.sort((a, b) => a.dateTime.isBefore(b.dateTime) ? 0 : 1);
    setState(() {
      alarms = updatedAlarms;
    });
  }

  Future<void> ringAlarmsChanged(AlarmSet alarms) async {
    if (alarms.alarms.isEmpty) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExampleAlarmRingScreen(alarmSettings: alarms.alarms.first),
      ),
    );
    unawaited(loadAlarms());
  }

  Future<void> navigateToAlarmScreen(AlarmSettings? settings) async {
    final res = showModalBottomSheet<bool?>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.05,
          child: AlarmEditScreen(
            alarmSettings: settings,
          ),
        );
      },
    );
    if (res != null && res == true) unawaited(loadAlarms());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "알람",
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.grey.shade400,
      ),
      body: SafeArea(
          child: Column(
        children: [
          Expanded(
            child: alarms.isNotEmpty
                ? ListView.separated(
                    itemCount: alarms.length,
                    separatorBuilder: (context, index) => const Divider(
                      height: 1,
                    ),
                    itemBuilder: (context, index) {
                      return ExampleAlarmTile(
                        key: Key(alarms[index].id.toString()),
                        title: TimeOfDay(
                          hour: alarms[index].dateTime.hour,
                          minute: alarms[index].dateTime.minute,
                        ).format(context),
                        onPressed: () => navigateToAlarmScreen(alarms[index]),
                        onDismissed: () {},
                      );
                    },
                  )
                : Center(),
          ),
        ],
      )),
    );
  }
}
