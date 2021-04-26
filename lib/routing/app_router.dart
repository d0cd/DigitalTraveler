import 'package:email_password_sign_in_ui/email_password_sign_in_ui.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:DigitalTraveler/app/home/job_entries/entry_page.dart';
import 'package:DigitalTraveler/app/home/job_entries/new_entry_page.dart';
import 'package:DigitalTraveler/app/home/job_entries/job_entries_page.dart';
import 'package:DigitalTraveler/app/home/mct_maps/edit_job_page.dart';
import 'package:DigitalTraveler/app/home/models/entry.dart';
import 'package:DigitalTraveler/app/home/models/job.dart';

class AppRoutes {
  static const emailPasswordSignInPage = '/email-password-sign-in-page';
  static const editJobPage = '/edit-job-page';
  static const entryPage = '/entry-page';
  static const jobEntriesPage = '/job-entries-page';
  static const newEntryPage = '/new-entry-page';
}

class AppRouter {
  static Route<dynamic>? onGenerateRoute(
      RouteSettings settings, FirebaseAuth firebaseAuth) {
    final args = settings.arguments;
    switch (settings.name) {
      case AppRoutes.emailPasswordSignInPage:
        return MaterialPageRoute<dynamic>(
          builder: (_) => EmailPasswordSignInPage.withFirebaseAuth(firebaseAuth,
              onSignedIn: args as void Function()),
          settings: settings,
          fullscreenDialog: true,
        );
      case AppRoutes.editJobPage:
        return MaterialPageRoute<dynamic>(
          builder: (_) => EditJobPage(job: args as Job?),
          settings: settings,
          fullscreenDialog: true,
        );
      case AppRoutes.entryPage:
        final mapArgs = args as Map<String, dynamic>;
        final job = mapArgs['job'] as Job;
        final entry = mapArgs['entry'] as Entry;
        return MaterialPageRoute<dynamic>(
          builder: (_) => EntryPage(job: job, entry: entry),
          settings: settings,
          fullscreenDialog: true,
        );
      case AppRoutes.jobEntriesPage:
        final job = settings.arguments as Job;
        return MaterialPageRoute<dynamic>(
          builder: (_) => JobEntriesPage(job: job),
          settings: settings,
          fullscreenDialog: false,
        );
      case AppRoutes.newEntryPage:
        final mapArgs = args as Map<String, dynamic>;
        final job = mapArgs['job'] as Job;
        return MaterialPageRoute<dynamic>(
          builder: (_) => NewEntryPage(job: job),
          settings: settings,
          fullscreenDialog: true,
        );

      default:
        // TODO: Throw
        return null;
    }
  }
}
