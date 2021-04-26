import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:DigitalTraveler/app/top_level_providers.dart';
import 'package:DigitalTraveler/app/home/account/account_page.dart';
import 'package:DigitalTraveler/app/home/entries/entries_page.dart';
import 'package:DigitalTraveler/app/home/mct_maps/jobs_page.dart';
import 'package:DigitalTraveler/app/home/tab_item.dart';
import 'package:collapsible_sidebar/collapsible_sidebar.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<CollapsibleItem> _items;

  TabItem _currentTab = TabItem.mctmaps;

  @override
  void initState() {
    super.initState();
    _items = _generateItems;
  }

  List<CollapsibleItem> get _generateItems {
    return [
      CollapsibleItem(
        text: TabItemData.allTabs[TabItem.mctmaps]!.title,
        icon: TabItemData.allTabs[TabItem.mctmaps]!.icon,
        onPressed: () => _select(TabItem.mctmaps),
        isSelected: true,
      ),
      CollapsibleItem(
        text: TabItemData.allTabs[TabItem.travelers]!.title,
        icon: TabItemData.allTabs[TabItem.travelers]!.icon,
        onPressed: () => _select(TabItem.travelers),
      ),
      CollapsibleItem(
        text: TabItemData.allTabs[TabItem.account]!.title,
        icon: TabItemData.allTabs[TabItem.account]!.icon,
        onPressed: () => _select(TabItem.account),
      ),
    ];
  }

  final Map<TabItem, GlobalKey<NavigatorState>> navigatorKeys = {
    TabItem.mctmaps: GlobalKey<NavigatorState>(),
    TabItem.travelers: GlobalKey<NavigatorState>(),
    TabItem.account: GlobalKey<NavigatorState>(),
  };

  Map<TabItem, WidgetBuilder> get widgetBuilders {
    return {
      TabItem.mctmaps: (_) => MCTMapsPage(),
      TabItem.travelers: (_) => TravelersPage(),
      TabItem.account: (_) => AccountPage(),
    };
  }

  void _select(TabItem tabItem) {
    if (tabItem == _currentTab) {
      // pop to first route
      navigatorKeys[tabItem]!.currentState?.popUntil((route) => route.isFirst);
    } else {
      setState(() => _currentTab = tabItem);
    }
  }

  @override
  Widget build(BuildContext context) {
    final firebaseAuth = context.read(firebaseAuthProvider);
    final user = firebaseAuth.currentUser!;

    late String userName;
    if (user.displayName != null) {
      userName = user.displayName!;
    } else {
      userName = "Anonymous";
    }

    late ImageProvider userImage;
    if (user.photoURL != null) {
      userImage = NetworkImage(user.photoURL!);
    } else {
      userImage = AssetImage("images/anonymous.png");
    }

    return WillPopScope(
        onWillPop: () async =>
            !(await navigatorKeys[_currentTab]!.currentState?.maybePop() ??
                false),
        child: CollapsibleSidebar(
          items: _items,
          avatarImg: userImage,
          title: userName,
          backgroundColor: Colors.blue,
          selectedTextColor: Colors.white,
          selectedIconColor: Colors.white,
          body: widgetBuilders[_currentTab]!(context),
        ));
  }
}
