///감정일기 데이터 모델 정의 파일

import 'package:hive/hive.dart';

part 'diary_entry.g.dart';

@HiveType(typeId: 0)
class DiaryEntry extends HiveObject {
@HiveField(0)
DateTime date;         // 일기 날짜

@HiveField(1)
String emotion;        // 감정 (예: happy, sad)

@HiveField(2)
String weather;        // 날씨 (예: sunny, rainy)

@HiveField(3)
String? text;          // 일기 내용 (nullable)
  
  DiaryEntry({
    required this.date,
    required this.emotion,
    required this.weather,
    this.text,
  });
}
