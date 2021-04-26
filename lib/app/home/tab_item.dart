import 'package:flutter/material.dart';
import 'package:DigitalTraveler/constants/keys.dart';
import 'package:DigitalTraveler/constants/strings.dart';

enum TabItem { mctmaps, travelers, account }

class TabItemData {
  const TabItemData(
      {required this.key, required this.title, required this.icon});

  final String key;
  final String title;
  final IconData icon;

  static const Map<TabItem, TabItemData> allTabs = {
    TabItem.mctmaps: TabItemData(
        key: Keys.mctTab, title: Strings.mct, icon: Icons.assessment_outlined),
    TabItem.travelers: TabItemData(
        key: Keys.travelerTab,
        title: Strings.traveler,
        icon: Icons.assignment_outlined),
    TabItem.account: TabItemData(
        key: Keys.accountTab,
        title: Strings.account,
        icon: Icons.person_outlined)
  };
}
