import 'package:DigitalTraveler/app/home/models/mct_step.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:DigitalTraveler/app/top_level_providers.dart';
import 'package:DigitalTraveler/app/home/models/entry.dart';
import 'package:DigitalTraveler/app/home/models/job.dart';
import 'package:alert_dialogs/alert_dialogs.dart';
import 'package:DigitalTraveler/routing/app_router.dart';
import 'package:DigitalTraveler/services/firestore_database.dart';
import 'package:pedantic/pedantic.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class NewEntryPage extends StatefulWidget {
  const NewEntryPage({required this.job});
  final Job job;

  static Future<void> show(
      {required BuildContext context, required Job job, Entry? entry}) async {
    await Navigator.of(context, rootNavigator: true).pushNamed(
      AppRoutes.newEntryPage,
      arguments: {
        'job': job,
      },
    );
  }

  @override
  State<StatefulWidget> createState() => _NewEntryPageState();
}

class _NewEntryPageState extends State<NewEntryPage> {
  late String _name;
  late DateTime _startDate;
  late TimeOfDay _startTime;
  late DateTime _endDate;
  late TimeOfDay _endTime;
  late List<MCTStep> _steps;
  late String _comment;
  late Color _color;
  late int _configIndex;

  final ValueChanged _onChanged = (dynamic val) => print(val);
  final _formKey = GlobalKey<FormBuilderState>();
  var colorOptions = ['Red', 'Yellow', 'Green'];
  bool _ageHasError = false;
  bool _colorHasError = false;

  @override
  void initState() {
    super.initState();
    _resetState();
    _configIndex = 0;
    initializeDateFormatting();
  }

  void _resetState() {
    final start = DateTime.now();
    _startDate = DateTime(start.year, start.month, start.day);
    _startTime = TimeOfDay.fromDateTime(start);

    final end = DateTime.now();
    _endDate = DateTime(end.year, end.month, end.day);
    _endTime = TimeOfDay.fromDateTime(end);

    _steps = [
      MCTStep(description: "Starting", color: MCTColor.red, timestamp: start)
    ];
    _comment = '';

    _color = Colors.red;
  }

  Entry _entryFromState() {
    final start = DateTime(_startDate.year, _startDate.month, _startDate.day,
        _startTime.hour, _startTime.minute);
    final end = DateTime(_endDate.year, _endDate.month, _endDate.day,
        _endTime.hour, _endTime.minute);
    final id = documentIdFromCurrentDate();
    return Entry(
      id: id,
      name: _name,
      jobId: widget.job.id,
      start: start,
      end: end,
      steps: _steps,
      comment: _comment,
    );
  }

  Future<void> _setEntryAndDismiss() async {
    try {
      _steps.add(MCTStep(
          description: "Finished",
          timestamp: DateTime.now().isAfter(_steps[_steps.length - 1].timestamp)
              ? DateTime.now()
              : _steps[_steps.length - 1].timestamp,
          color: MCTColor.red));
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
                  'Finish Mapping',
                  style: const TextStyle(fontSize: 18.0, color: Colors.white),
                ),
                onPressed: () {
                  if (_name != null && _color == Colors.red) {
                    _setEntryAndDismiss();
                  }
                }),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                TextField(
                  keyboardType: TextInputType.text,
                  maxLength: 50,
                  controller: TextEditingController(text: _comment),
                  decoration: const InputDecoration(
                    labelText: 'Name this mapping exercise...',
                    labelStyle:
                        TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500),
                  ),
                  keyboardAppearance: Brightness.light,
                  style: const TextStyle(fontSize: 20.0, color: Colors.black),
                  maxLines: null,
                  onChanged: (name) => _name = name,
                ),
                Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: ToggleSwitch(
                      initialLabelIndex: 0,
                      labels: ['Live', 'Manual'],
                      onToggle: (index) {
                        setState(() {
                          _resetState();
                          _configIndex = index;
                        });
                      }),
                ),
                _buildEntry(),
              ]),
        ));
  }

  Widget _buildEntry() {
    if (_configIndex == 0) {
      return _buildLiveEntry();
    } else {
      return _buildStaticEntry();
    }
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
          _buildForm(),
          const SizedBox(height: 8.0),
          DataTable(columns: getColumns(columns), rows: getRows(_steps))
        ],
      ),
    );
  }

  Widget _buildLiveEntry() {
    return Container(
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
    );
  }

  Widget _buildForm() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            FormBuilder(
              key: _formKey,
              // enabled: false,
              autovalidateMode: AutovalidateMode.disabled,
              initialValue: {'color': 'Red'},
              skipDisabled: true,
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 15),
                  FormBuilderTextField(
                    name: 'description',
                    decoration: InputDecoration(labelText: 'Description'),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(context),
                      FormBuilderValidators.minLength(context, 1)
                    ]),
                  ),
                  FormBuilderDateTimePicker(
                    name: 'timestamp',
                    initialValue: DateTime.now(),
                    inputType: InputType.both,
                    decoration: InputDecoration(
                      labelText: 'Timestamp',
                      suffixIcon: IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () {
                            _formKey.currentState!.fields['timestamp']
                                ?.didChange(null);
                          }),
                    ),
                    validator: (value) {
                      if (value != null) {
                        return "Timestamp cannot be null";
                      } else if (!value!
                          .isAfter(_steps[_steps.length - 1].timestamp)) {
                        return "Timestamp must be after the previously submitted one";
                      } else {
                        return null;
                      }
                    },
                  ),
                  FormBuilderDropdown<String>(
                    // autovalidate: true,
                    name: 'color',
                    decoration: InputDecoration(
                      labelText: 'MCT Color',
                      suffix: _colorHasError
                          ? const Icon(Icons.error)
                          : const Icon(Icons.check),
                    ),
                    initialValue: 'Red',
                    allowClear: true,
                    hint: Text('Select MCT Color'),
                    validator: FormBuilderValidators.compose(
                        [FormBuilderValidators.required(context)]),
                    items: colorOptions
                        .map((color) => DropdownMenuItem(
                              value: color,
                              child: Text(color),
                            ))
                        .toList(),
                    onChanged: (val) {
                      print(val);
                      setState(() {
                        _colorHasError = !(_formKey
                                .currentState?.fields['color']
                                ?.validate() ??
                            false);
                      });
                    },
                  ),
                ],
              ),
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: MaterialButton(
                    color: Theme.of(context).accentColor,
                    onPressed: () {
                      if (_formKey.currentState?.saveAndValidate() ?? false) {
                        print(_formKey.currentState?.value);
                      } else {
                        print(_formKey.currentState?.value);
                        print('validation failed');
                      }
                      late MCTColor color;
                      if (_formKey.currentState?.value['color'] == 'Green') {
                        color = MCTColor.green;
                      } else if (_formKey.currentState?.value['color'] ==
                          'Yellow') {
                        color = MCTColor.yellow;
                      } else {
                        color = MCTColor.red;
                      }
                      setState(() {
                        _steps.add(MCTStep(
                            description:
                                _formKey.currentState?.value['description'],
                            timestamp:
                                _formKey.currentState?.value['timestamp'],
                            color: color));
                      });
                      _formKey.currentState?.reset();
                    },
                    child: const Text(
                      'Submit',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _formKey.currentState?.reset();
                    },
                    // color: Theme.of(context).accentColor,
                    child: Text(
                      'Reset',
                      style: TextStyle(color: Theme.of(context).accentColor),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
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
        onPressed: () {
          if (_comment.isNotEmpty) {
            setState(() {
              _color = Colors.red;
              _steps.add(MCTStep(
                  description: _comment,
                  timestamp: DateTime.now(),
                  color: MCTColor.red));
              _comment = '';
            });
          }
        },
      ),
    );
  }

  Widget _buildYellowButton() {
    return Container(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        child: Text('Yellow'),
        onPressed: () {
          if (_comment.isNotEmpty) {
            setState(() {
              _color = Colors.yellow;
              _steps.add(MCTStep(
                  description: _comment,
                  timestamp: DateTime.now(),
                  color: MCTColor.yellow));
              _comment = '';
            });
          }
        },
      ),
    );
  }

  Widget _buildGreenButton() {
    return Container(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        child: Text('Green'),
        onPressed: () {
          if (_comment.isNotEmpty) {
            setState(() {
              _color = Colors.green;
              _steps.add(MCTStep(
                  description: _comment,
                  timestamp: DateTime.now(),
                  color: MCTColor.green));

              _comment = '';
            });
          }
        },
      ),
    );
  }

  Widget _buildComment() {
    return TextField(
      keyboardType: TextInputType.text,
      maxLength: 50,
      controller: TextEditingController(text: _comment),
      decoration: const InputDecoration(
        labelText: 'Describe step...',
        labelStyle: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500),
      ),
      keyboardAppearance: Brightness.light,
      style: const TextStyle(fontSize: 20.0, color: Colors.black),
      maxLines: null,
      onChanged: (comment) => _comment = comment,
    );
  }
}
