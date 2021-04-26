import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:DigitalTraveler/app/home/job_entries/job_entries_page.dart';
import 'package:DigitalTraveler/app/home/mct_maps/edit_job_page.dart';
import 'package:DigitalTraveler/app/home/mct_maps/job_list_tile.dart';
import 'package:DigitalTraveler/app/home/mct_maps/list_items_builder.dart';
import 'package:DigitalTraveler/app/home/models/job.dart';
import 'package:alert_dialogs/alert_dialogs.dart';
import 'package:DigitalTraveler/app/top_level_providers.dart';
import 'package:DigitalTraveler/constants/strings.dart';
import 'package:pedantic/pedantic.dart';
import 'package:DigitalTraveler/services/firestore_database.dart';

final jobsStreamProvider = StreamProvider.autoDispose<List<Job>>((ref) {
  final database = ref.watch(databaseProvider);
  return database.jobsStream();
});

// watch database
class MCTMapsPage extends ConsumerWidget {
  Future<void> _delete(BuildContext context, Job job) async {
    try {
      final database = context.read<FirestoreDatabase>(databaseProvider);
      await database.deleteJob(job);
    } catch (e) {
      unawaited(showExceptionAlertDialog(
        context: context,
        title: 'Operation failed',
        exception: e,
      ));
    }
  }

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(Strings.mct),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => EditJobPage.show(context),
          ),
        ],
      ),
      body: _buildContents(context, watch),
    );
  }

  Widget _buildContents(BuildContext context, ScopedReader watch) {
    final jobsAsyncValue = watch(jobsStreamProvider);
    return ListItemsBuilder<Job>(
      data: jobsAsyncValue,
      itemBuilder: (context, job) => Dismissible(
        key: Key('job-${job.id}'),
        background: Container(color: Colors.red),
        direction: DismissDirection.endToStart,
        onDismissed: (direction) => _delete(context, job),
        child: JobListTile(
          job: job,
          onTap: () => JobEntriesPage.show(context, job),
        ),
      ),
    );
  }
}
