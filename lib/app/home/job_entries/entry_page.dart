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

class EntryPage extends StatefulWidget {
  const EntryPage({required this.job, this.entry});
  final Job job;
  final Entry? entry;

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
  late DateTime _startDate;
  late TimeOfDay _startTime;
  late DateTime _endDate;
  late TimeOfDay _endTime;
  late List<String> _steps;
  late String _comment;
  late Color _color;

  @override
  void initState() {
    super.initState();
    final start = widget.entry?.start ?? DateTime.now();
    _startDate = DateTime(start.year, start.month, start.day);
    _startTime = TimeOfDay.fromDateTime(start);

    final end = widget.entry?.end ?? DateTime.now();
    _endDate = DateTime(end.year, end.month, end.day);
    _endTime = TimeOfDay.fromDateTime(end);

    _steps = widget.entry?.steps ?? ["${start.toString()},RED"];

    _comment = widget.entry?.comment ?? '';

    _color = Colors.red;
  }

  Entry _entryFromState() {
    final start = DateTime(_startDate.year, _startDate.month, _startDate.day,
        _startTime.hour, _startTime.minute);
    final end = DateTime(_endDate.year, _endDate.month, _endDate.day,
        _endTime.hour, _endTime.minute);
    final id = widget.entry?.id ?? documentIdFromCurrentDate();
    return Entry(
      id: id,
      jobId: widget.job.id,
      start: start,
      end: end,
      steps: _steps,
      comment: _comment,
    );
  }

  Future<void> _setEntryAndDismiss() async {
    try {
      _steps.add("${DateTime.now().toString()},RED");
      final database = context.read<FirestoreDatabase>(databaseProvider);
      final entry = _entryFromState();
      await database.setEntry(entry);
      Navigator.of(context).pop();
    } catch (e) {
      unawaited(showExceptionAlertDialog(
        context: context,
        title: 'Operation failed',
        exception: e,
      ));
    }
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
              widget.entry != null ? 'Update' : 'Finish Mapping',
              style: const TextStyle(fontSize: 18.0, color: Colors.white),
            ),
            onPressed: () => _setEntryAndDismiss(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildActiveColor(),
              const SizedBox(height: 8.0),
              _buildRedButton(),
              const SizedBox(height: 8.0),
              _buildYellowButton(),
              const SizedBox(height: 8.0),
              _buildGreenButton(),
              const SizedBox(height: 8.0),
              _buildComment(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveColor() {
    return AnimatedContainer(
      duration: new Duration(milliseconds: 200),
      width: double.infinity,
      height: 300,
      color: _color,
    );
  }

  Widget _buildRedButton() {
    return Container(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        child: Text('Red'),
        onPressed: () => setState(() {
          _color = Colors.red;
          _steps.add("${DateTime.now().toString()},RED");
        }),
      ),
    );
  }

  Widget _buildYellowButton() {
    return Container(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        child: Text('Yellow'),
        onPressed: () => setState(() {
          _color = Colors.yellow;
          _steps.add("${DateTime.now().toString()},YELLOW");
        }),
      ),
    );
  }

  Widget _buildGreenButton() {
    return Container(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        child: Text('Green'),
        onPressed: () => setState(() {
          _color = Colors.green;
          _steps.add("${DateTime.now().toString()},GREEN");
        }),
      ),
    );
  }

  Widget _buildComment() {
    return TextField(
      keyboardType: TextInputType.text,
      maxLength: 50,
      controller: TextEditingController(text: _comment),
      decoration: const InputDecoration(
        labelText: 'Comment',
        labelStyle: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500),
      ),
      keyboardAppearance: Brightness.light,
      style: const TextStyle(fontSize: 20.0, color: Colors.black),
      maxLines: null,
      onChanged: (comment) => _comment = comment,
    );
  }
}
