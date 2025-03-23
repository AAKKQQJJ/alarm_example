import 'package:alarm/model/volume_settings.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:alarm/alarm.dart';

class AlarmEditScreen extends StatefulWidget {
  const AlarmEditScreen({super.key, this.alarmSettings});

  final AlarmSettings? alarmSettings;

  @override
  State<AlarmEditScreen> createState() => _AlarmEditScreenState();
}

class _AlarmEditScreenState extends State<AlarmEditScreen> {
  bool loading = false;

  late bool creating;
  late double? volume;
  late bool staircaseFade;
  late Duration? fadeDuration;
  late DateTime selectedDateTime;
  late bool vibrate;
  late bool loopAudio;
  late String assetAudio;


  Future<void> pickTime() async {
    final res = await showTimePicker(
      context: context, initialTime: TimeOfDay.fromDateTime(selectedDateTime),);
    if (res != null) {
      setState(() {
        final now = DateTime.now();
        selectedDateTime = now.copyWith(
          hour: res.hour,
          minute: res.minute,
          second: 0,
          millisecond: 0,
          microsecond: 0,
        );
        if (selectedDateTime.isBefore(now)) {
          selectedDateTime = selectedDateTime.add(const Duration(days: 1));
        }
      });
    }
  }

  AlarmSettings buildAlarmSetting() {
    final id = creating ? DateTime
        .now()
        .millisecondsSinceEpoch % 10000 + 1 : widget.alarmSettings!.id;

    final VolumeSettings volumeSettings;

    /// 계단식 소리 증폭 기능 ///
    if (staircaseFade) {
      volumeSettings = VolumeSettings.staircaseFade(volume: volume, fadeSteps: [
        VolumeFadeStep(Duration.zero, 0),
        VolumeFadeStep(const Duration(seconds: 15), 0.03),
        VolumeFadeStep(const Duration(seconds: 20), 0.5),
        VolumeFadeStep(const Duration(seconds: 30), 1),
      ]);
    }
    else if (fadeDuration != null) {
      volumeSettings = VolumeSettings.fade(volume: volume, fadeDuration: fadeDuration!,);
    } else {
      volumeSettings = VolumeSettings.fixed(volume: volume);
    }

    final alarmSettings = AlarmSettings(
      id: id,
      dateTime: selectedDateTime,
      vibrate: vibrate,
      loopAudio: loopAudio,
      assetAudioPath: assetAudio,
      volumeSettings: volumeSettings,
      notificationSettings: NotificationSettings(
        title: 'Alarm example',
        body: 'Your alarm ($id) is ringing',
        stopButton: 'stop the alarm',
        icon: 'notification_icon',
      ),
    );
    return alarmSettings;
  }

  ///알람 저장 ///
  void saveAlarm() {
    if (loading) return;
    setState(() => loading = true);
    Alarm.set(alarmSettings: buildAlarmSetting()).then(res){

    };
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                "cancel",
                style: Theme
                    .of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: saveAlarm,
              child: Text(
                "save",
                style: Theme
                    .of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(color: Colors.grey),
              ),
            ),
          ],
        )
      ],
    );
  }
}
