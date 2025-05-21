import 'package:hive/hive.dart';

part 'diary_entry.g.dart';

@HiveType(typeId: 0)
class DiaryEntry extends HiveObject {
  @HiveField(0)
  DateTime date;

  @HiveField(1)
  String emotion;

  @HiveField(2)
  String weather;

  @HiveField(3)
  String? text;

  DiaryEntry({
    required this.date,
    required this.emotion,
    required this.weather,
    this.text,
  });
}
