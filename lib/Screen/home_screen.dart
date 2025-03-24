import 'package:alarm/alarm.dart';
import 'package:alarm_practice/widgets/tile.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<AlarmSettings> alarms = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("알람 앱 연습"),
        backgroundColor: Colors.grey.shade400,
      ),
      body: SafeArea(
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
                      onPressed: () {},
                      onDismissed: () {},
                    );
                  },
                )
              : Center()),
    );
  }
}
