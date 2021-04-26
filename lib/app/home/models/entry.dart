import 'package:equatable/equatable.dart';
import 'package:DigitalTraveler/app/home/models/mct_step.dart';

class Entry extends Equatable {
  const Entry({
    required this.id,
    required this.name,
    required this.jobId,
    required this.start,
    required this.end,
    required this.steps,
    required this.comment,
  });

  final String id;
  final String name;
  final String jobId;
  final DateTime start;
  final DateTime end;
  final List<MCTStep> steps;
  final String comment;

  @override
  List<Object> get props => [id, jobId, start, end, steps, comment];

  @override
  bool get stringify => true;

  double get durationInHours =>
      end.difference(start).inMinutes.toDouble() / 60.0;

  factory Entry.fromMap(Map<dynamic, dynamic>? value, String id) {
    if (value == null) {
      throw StateError('missing data for entryId: $id');
    }
    final startMilliseconds = value['start'] as int;
    final endMilliseconds = value['end'] as int;
    final List<MCTStep> steps = (value['steps'] as List<dynamic>)
        .map((dynamic step) => MCTStep.fromMap(step) as MCTStep)
        .toList();
    return Entry(
      id: id,
      name: value['name'],
      jobId: value['jobId'],
      start: DateTime.fromMillisecondsSinceEpoch(startMilliseconds),
      end: DateTime.fromMillisecondsSinceEpoch(endMilliseconds),
      steps: steps,
      comment: value['comment'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'jobId': jobId,
      'name': name,
      'start': start.millisecondsSinceEpoch,
      'end': end.millisecondsSinceEpoch,
      'steps': steps.map((step) => step.toMap()).toList(),
      'comment': comment,
    };
  }
}
