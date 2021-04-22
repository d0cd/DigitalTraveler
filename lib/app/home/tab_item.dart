import 'package:flutter/material.dart';
import 'package:DigitalTraveler/constants/keys.dart';
import 'package:DigitalTraveler/constants/strings.dart';

enum TabItem { jobs, account }

class TabItemData {
  const TabItemData(
      {required this.key, required this.title, required this.icon});

  final String key;
  final String title;
  final IconData icon;

  static const Map<TabItem, TabItemData> allTabs = {
    TabItem.jobs: TabItemData(
      key: Keys.jobsTab,
      title: Strings.jobs,
      icon: Icons.work,
    ),
    TabItem.account: TabItemData(
      key: Keys.accountTab,
      title: Strings.account,
      icon: Icons.person,
    ),
  };
}
