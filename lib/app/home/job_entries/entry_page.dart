import 'package:DigitalTraveler/app/home/models/mct_step.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:DigitalTraveler/app/top_level_providers.dart';
import 'package:DigitalTraveler/common_widgets/date_time_picker.dart';
import 'package:DigitalTraveler/app/home/job_entries/format.dart';
import 'package:DigitalTraveler/app/home/models/entry.dart';
import 'package:DigitalTraveler/app/home/models/job.dart';
import 'package:alert_dialogs/alert_dialogs.dart';
import 'package:DigitalTraveler/routing/app_router.dart';
import 'package:DigitalTraveler/services/firestore_database.dart';
import 'package:pedantic/pedantic.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class EntryPage extends StatefulWidget {
  const EntryPage({required this.job, required this.entry});
  final Job job;
  final Entry entry;

  static Future<void> show(
      {required BuildContext context, required Job job, Entry? entry}) async {
    await Navigator.of(context, rootNavigator: true).pushNamed(
      AppRoutes.entryPage,
      arguments: {
        'job': job,
        'entry': entry,
      },
    );
  }

  @override
  State<StatefulWidget> createState() => _EntryPageState();
}

class _EntryPageState extends State<EntryPage> {
  late String _name;
  late DateTime _startDate;
  late TimeOfDay _startTime;
  late DateTime _endDate;
  late TimeOfDay _endTime;
  late List<MCTStep> _steps;
  late String _comment;
  late Color _color;

  @override
  void initState() {
    super.initState();
    _name = widget.entry.name;
    final start = widget.entry.start;
    _startDate = DateTime(start.year, start.month, start.day);
    _startTime = TimeOfDay.fromDateTime(start);

    final end = widget.entry.end;
    _endDate = DateTime(end.year, end.month, end.day);
    _endTime = TimeOfDay.fromDateTime(end);

    _steps = widget.entry.steps;

    _comment = widget.entry.comment;

    _color = Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2.0,
        title: Text(widget.job.name),
        actions: <Widget>[
          FlatButton(
              child: Text(
                'Return',
                style: const TextStyle(fontSize: 18.0, color: Colors.white),
              ),
              onPressed: () => Navigator.of(context).pop()),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 8.0),
              Text(
                _name,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              _buildStaticEntry(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStaticEntry() {
    final columns = ['Description', 'Timestamp', 'Color'];

    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const SizedBox(height: 8.0),
          DataTable(columns: getColumns(columns), rows: getRows(_steps)),
          const SizedBox(height: 8.0),
          _buildChart(),
        ],
      ),
    );
  }

  List<DataColumn> getColumns(List<String> columns) {
    return columns.map((String column) {
      final isColor = column == columns[2];

      return DataColumn(
        label: Text(column),
        numeric: isColor,
      );
    }).toList();
  }

  static List<T> modelBuilder<M, T>(
          List<M> models, T Function(int index, M model) builder) =>
      models
          .asMap()
          .map<int, T>((index, model) => MapEntry(index, builder(index, model)))
          .values
          .toList();

  List<DataRow> getRows(List<MCTStep> steps) => steps.map((MCTStep step) {
        final cells = [step.description, step.timestamp, step.color];
        return DataRow(
          cells: modelBuilder(cells, (index, cell) {
            return DataCell(Text('$cell'));
          }),
        );
      }).toList();

  Widget _buildChart() {
    int beginning = _steps[0].timestamp.millisecondsSinceEpoch;
    List<RangeColumnSeries> series = [];
    int i = 0;
    while (i < _steps.length - 2) {
      late Color color;
      if (_steps[i].color == MCTColor.green) {
        color = Colors.green;
      } else if (_steps[i].color == MCTColor.yellow) {
        color = Colors.yellow;
      } else {
        color = Colors.red;
      }
      final ser = RangeColumnSeries<MCTStep, num>(
        dataSource: [_steps[i]],
        xValueMapper: (MCTStep step, _) =>
            //j_steps[i + 1].timestamp.millisecondsSinceEpoch -
            //_steps[i].timestamp.millisecondsSinceEpoch,
            0,
        highValueMapper: (MCTStep step, _) =>
            _steps[i + 1].timestamp.millisecondsSinceEpoch,
        lowValueMapper: (MCTStep step, _) =>
            _steps[i].timestamp.millisecondsSinceEpoch,
        color: color,
      );
      i += 1;
      series.add(ser);
    }
    late Color color;
    if (_steps[_steps.length - 1].color == MCTColor.green) {
      color = Colors.green;
    } else if (_steps[_steps.length - 1].color == MCTColor.yellow) {
      color = Colors.yellow;
    } else {
      color = Colors.red;
    }

    series.add(RangeColumnSeries<MCTStep, num>(
      dataSource: [_steps[_steps.length - 1]],
      xValueMapper: (MCTStep step, _) => 0,
      highValueMapper: (MCTStep step, _) =>
          _steps[_steps.length - 1].timestamp.millisecondsSinceEpoch,
      lowValueMapper: (MCTStep step, _) =>
          _steps[_steps.length - 2].timestamp.millisecondsSinceEpoch,
      color: color,
    ));
    return Center(
        child: Container(
      child: SfCartesianChart(
        title: ChartTitle(
            text: 'Manufacturing Critical Path Analysis',
            // Aligns the chart title to left
            alignment: ChartAlignment.center,
            textStyle: TextStyle(
              color: Colors.red,
              fontFamily: 'Roboto',
              fontStyle: FontStyle.italic,
              fontSize: 18,
            )),
        isTransposed: false,
        primaryXAxis: NumericAxis(
            isVisible: false,
            title: AxisTitle(
                text: 'Elapsed Time',
                textStyle: TextStyle(
                    color: Colors.deepOrange,
                    fontFamily: 'Roboto',
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w300))),
        primaryYAxis: NumericAxis(isVisible: false),
        series: series,
        annotations: [],
      ),
    ));
  }
}
