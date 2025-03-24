import 'package:alarm/alarm.dart';
import 'package:alarm/model/volume_settings.dart';
import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();

    ///기존의 알람인지 새로 생성한 알람인지 비교///

    creating = widget.alarmSettings == null;

    if (creating) {
      selectedDateTime = DateTime.now().add(const Duration(minutes: 1));
      selectedDateTime = selectedDateTime.copyWith(second: 0, millisecond: 0);
      loopAudio = true;
      vibrate = true;
      volume = null;
      fadeDuration = null;
      staircaseFade = false;
      assetAudio = 'assets/marimba.mp3';
    } else {
      selectedDateTime = widget.alarmSettings!.dateTime;
      loopAudio = widget.alarmSettings!.loopAudio;
      vibrate = widget.alarmSettings!.vibrate;
      volume = widget.alarmSettings!.volumeSettings.volume;
      fadeDuration = widget.alarmSettings!.volumeSettings.fadeDuration;
      staircaseFade = widget.alarmSettings!.volumeSettings.fadeSteps.isNotEmpty;
      assetAudio = widget.alarmSettings!.assetAudioPath;
    }
  }

  String getDay() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final difference = selectedDateTime.difference(today).inDays;

    switch (difference) {
      case 0:
        return '오늘';
      case 1:
        return '내일';
      case 2:
        return '내일 모레';
      default:
        return '$difference일 뒤';
    }
  }

  Future<void> pickTime() async {
    final res = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(selectedDateTime),
    );
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
    final id =
        creating ? DateTime.now().millisecondsSinceEpoch % 10000 + 1 : widget.alarmSettings!.id;

    final VolumeSettings volumeSettings;

    /// 계단식 소리 증폭 기능 ///
    if (staircaseFade) {
      volumeSettings = VolumeSettings.staircaseFade(volume: volume, fadeSteps: [
        VolumeFadeStep(Duration.zero, 0),
        VolumeFadeStep(const Duration(seconds: 15), 0.03),
        VolumeFadeStep(const Duration(seconds: 20), 0.5),
        VolumeFadeStep(const Duration(seconds: 30), 1),
      ]);
    } else if (fadeDuration != null) {
      volumeSettings = VolumeSettings.fade(
        volume: volume,
        fadeDuration: fadeDuration!,
      );
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
    Alarm.set(alarmSettings: buildAlarmSetting()).then((res) {
      if (res && mounted) Navigator.pop(context, true);
      setState(() => loading = false);
    });
  }

  void deleteAlarm() {
    Alarm.stop(widget.alarmSettings!.id).then((res) {
      if (res && mounted) Navigator.pop(context, true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  "취소",
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Colors.grey),
                ),
              ),
              TextButton(
                onPressed: saveAlarm,
                child: Text(
                  "저장",
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Colors.grey),
                ),
              ),
            ],
          ),
          Text(
            getDay(),
            style: Theme.of(context)
                .textTheme
                .titleMedium!
                .copyWith(color: Colors.grey.shade500.withValues(alpha: 0.8)),
          ),
          RawMaterialButton(
            onPressed: pickTime,
            fillColor: Colors.black12,
            child: Container(
              margin: const EdgeInsets.all(20),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "알람 반복",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Switch(
                value: loopAudio,
                onChanged: (value) => setState(() => loopAudio = value),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '진동',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Switch(
                value: vibrate,
                onChanged: (value) => setState(() => vibrate = value),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '음악',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              DropdownButton(
                value: assetAudio,
                items: const [
                  DropdownMenuItem<String>(
                    value: 'assets/marimba.mp3',
                    child: Text('Marimba'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'assets/mozart.mp3',
                    child: Text('mozart'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'assets/nokia.mp3',
                    child: Text('nokia'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'assets/one_piece.mp3',
                    child: Text('One piece'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'assets/star_wars.mp3',
                    child: Text('star wars'),
                  ),
                ],
                onChanged: (value) => setState(() => assetAudio = value!),
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '커스텀 볼륨',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Switch(
                value: volume != null,
                onChanged: (value) => setState(() => volume = value ? 0.5 : null),
              )
            ],
          ),
          if (volume != null)
            SizedBox(
              height: 45,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    volume! > 0.7
                        ? Icons.volume_up_rounded
                        : volume! > 0.1
                            ? Icons.volume_down_rounded
                            : Icons.volume_off_rounded,
                  ),
                  Expanded(
                    child: Slider(
                      value: volume!,
                      onChanged: (value) => setState(() => volume = value),
                    ),
                  ),
                ],
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '지속 시간',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              DropdownButton<int>(
                value: fadeDuration?.inSeconds ?? 0,
                //null 이면 0을 반환, not null 이면 fadeDuration,inSeconds 반환
                items: List.generate(
                  6,
                  (index) => DropdownMenuItem(
                    value: index * 5,
                    child: Text('${index * 5}초'),
                  ),
                ),
                onChanged: (value) => setState(
                  () => fadeDuration = value != null ? Duration(seconds: value) : null,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                "계단식 소리 증폭",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Switch(
                value: staircaseFade,
                onChanged: (value) => setState(() => staircaseFade = value),
              )
            ],
          ),
          if (!creating)
            TextButton(
              onPressed: deleteAlarm,
              child: Text(
                '알람 삭제',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(color: Colors.red),
              ),
            ),
          const SizedBox(),
        ],
      ),
    );
  }
}
