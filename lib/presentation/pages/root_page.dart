import 'package:flutter/material.dart';
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
      floatingActionButton: _index == 0
          ? _calendarFab(context)
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _calendarFab(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () async {
        final state = _calendarKey.currentState;
        if (state != null) {
          await state.createAppointment();
        }
      },
      icon: const Icon(Icons.add),
      label: const Text('New Appointment'),
    );
  }
}

