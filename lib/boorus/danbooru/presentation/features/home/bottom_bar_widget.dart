// Flutter imports:
import 'package:flutter/material.dart';

class BottomBar extends StatefulWidget {
  const BottomBar({
    Key? key,
    required this.onTabChanged,
    this.initialValue = 0,
  }) : super(key: key);

  final ValueChanged<int> onTabChanged;
  final int initialValue;

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  late int currentIndex;

  final labels = [
    'Home',
    'Explore',
    'Pool',
    // "Favorites",
  ];

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialValue;
  }

  void changePage(int index) {
    setState(() {
      currentIndex = index;
    });
    widget.onTabChanged(index);
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      showUnselectedLabels: false,
      showSelectedLabels: false,
      landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
      items: [
        //TODO: stop using index as a selected indicator
        BottomNavigationBarItem(
          label: 'Home',
          icon: currentIndex == 0
              ? const Icon(Icons.dashboard)
              : const Icon(Icons.dashboard_outlined),
        ),
        BottomNavigationBarItem(
          label: 'Explore',
          icon: currentIndex == 1
              ? const Icon(Icons.explore)
              : const Icon(Icons.explore_outlined),
        ),
        BottomNavigationBarItem(
          label: 'Pool',
          icon: currentIndex == 2
              ? const Icon(Icons.photo_album)
              : const Icon(Icons.photo_album_outlined),
        ),
      ],
      currentIndex: currentIndex,
      onTap: changePage,
    );
  }
}
