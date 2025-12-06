import 'package:flutter/material.dart';
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';
import '../../core/theme/app_theme.dart';
import 'calendar_home_page.dart';
import 'history_page.dart';
import 'settings_page.dart';

/// Root page with bottom navigation (Home/Calendar, History, Settings)
class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  int _index = 0;

  final GlobalKey<CalendarHomePageState> _calendarKey = GlobalKey<CalendarHomePageState>();

  late final List<Widget> _pages = [
    CalendarHomePage(key: _calendarKey),
    const HistoryPage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: _pages,
      ),
      floatingActionButton: _calendarFab(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.endContained,
      bottomNavigationBar: StylishBottomBar(
        option: BubbleBarOptions(
          barStyle: BubbleBarStyle.horizontal,
          bubbleFillStyle: BubbleFillStyle.fill,
          opacity: 0.12,
        ),
        currentIndex: _index,
        backgroundColor: AppTheme.primaryLight,
        items: [
          BottomBarItem(
            icon: const Icon(Icons.calendar_month),
            selectedIcon: const Icon(Icons.calendar_month),
            title: const Text('Home'),
            selectedColor: AppTheme.accent,
            unSelectedColor: AppTheme.iconDefault,
          ),
          BottomBarItem(
            icon: const Icon(Icons.history),
            selectedIcon: const Icon(Icons.history),
            title: const Text('History'),
            selectedColor: AppTheme.accent,
            unSelectedColor: AppTheme.iconDefault,
          ),
          BottomBarItem(
            icon: const Icon(Icons.settings),
            selectedIcon: const Icon(Icons.settings),
            title: const Text('Settings'),
            selectedColor: AppTheme.accent,
            unSelectedColor: AppTheme.iconDefault,
          ),
        ],
        onTap: (i) => setState(() => _index = i),
        fabLocation: StylishBarFabLocation.end,
        hasNotch: false,
      ),
    );
  }

  Widget _calendarFab(BuildContext context) {
    return FloatingActionButton(
      onPressed: () async {
        final state = _calendarKey.currentState;
        if (state != null) {
          await state.createAppointment();
        } else {
          setState(() => _index = 0);
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            if (_calendarKey.currentState != null) {
              await _calendarKey.currentState!.createAppointment();
            }
          });
        }
      },
      child: const Icon(Icons.add),
    );
  }
}

