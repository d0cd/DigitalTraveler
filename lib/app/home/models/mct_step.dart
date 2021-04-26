import 'package:equatable/equatable.dart';

enum MCTColor { red, yellow, green }

class MCTStep extends Equatable {
  const MCTStep({
    required this.description,
    required this.timestamp,
    required this.color,
  });

  final String description;
  final DateTime timestamp;
  final MCTColor color;

  @override
  List<Object> get props => [description, timestamp, color];

  @override
  bool get stringify => true;

  factory MCTStep.fromMap(Map<dynamic, dynamic> value) {
    final description = value['description'] as String;
    final millisecs = value['timestamp'] as int;
    late MCTColor color;
    switch (value['color']) {
      case 'RED':
        {
          color = MCTColor.red;
        }
        break;
      case 'YELLOW':
        {
          color = MCTColor.yellow;
        }
        break;
      case 'GREEN':
        {
          color = MCTColor.green;
        }
        break;
    }
    return MCTStep(
      description: description,
      timestamp: DateTime.fromMillisecondsSinceEpoch(millisecs),
      color: color,
    );
  }

  Map<String, dynamic> toMap() {
    late String color_string;

    if (color == MCTColor.red) {
      color_string = "RED";
    } else if (color == MCTColor.yellow) {
      color_string = "YELLOW";
    } else {
      color_string = "GREEN";
    }

    return <String, dynamic>{
      'description': description,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'color': color_string,
    };
  }

  MCTStep copy({
    String? description,
    DateTime? timestamp,
    MCTColor? color,
  }) =>
      MCTStep(
        description: description ?? this.description,
        timestamp: timestamp ?? this.timestamp,
        color: color ?? this.color,
      );
}
