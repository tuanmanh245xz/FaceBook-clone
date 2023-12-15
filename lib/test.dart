import 'package:fake_app/utils/constants/constants_colors.dart';
import 'package:fake_app/utils/helper/color_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/scheduler/ticker.dart';


class Test extends StatefulWidget  {
  static String route = "/test";
  Test({Key key}) : super(key: key);

  @override
  _TestState createState() => _TestState();
}

class _TestState extends State<Test> with SingleTickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final title = 'Floating App Bar';
    final double default_tab_size = 28;

    return MaterialApp(
      title: title,
      home: Scaffold(
        // No appbar provided to the Scaffold, only a body with a
        // CustomScrollView.
        body: CustomScrollView(
          slivers: <Widget>[
            // Add the app bar to the CustomScrollView.
            SliverAppBar(
              // Provide a standard title.
              title: Text(title),
              // Allows the user to reveal the app bar if they begin scrolling
              // back up the list of items.
              floating: true,
              // Display a placeholder widget to visualize the shrinking size.
              flexibleSpace: Placeholder(),
              // Make the initial height of the SliverAppBar larger than normal.
              expandedHeight: 200,
              pinned: true,
              bottom: TabBar(
                labelColor: Theme.of(context).iconTheme.color,
                unselectedLabelColor: HexColor(ConstColor.text_color_grey),
                tabs: <Widget>[
                  Tab(
                    icon: Icon(Icons.home, size: default_tab_size,),
                  ),
                  Tab(
                    icon: Icon(Icons.group, size: default_tab_size,),
                  ),
                  Tab(
                    icon: Icon(Icons.ondemand_video, size: default_tab_size,),
                  ),
                  Tab(
                    icon: Icon(Icons.notifications),
                  ),
                  Tab(
                    icon: Icon(Icons.menu),
                  )
                ],
                controller: _tabController,
              ),
            ),
            // Next, create a SliverList
            SliverList(
              // Use a delegate to build items as they're scrolled on screen.
              delegate: SliverChildBuilderDelegate(
                // The builder function returns a ListTile with a title that
                // displays the index of the current item.
                    (context, index) => ListTile(title: Text('Item #$index')),
                // Builds 1000 ListTiles
                childCount: 1000,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Ticker createTicker(void Function(Duration elapsed) onTick) {
    // TODO: implement createTicker
    throw UnimplementedError();
  }
}