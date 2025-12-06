import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/di/injection_container.dart' as di;
import '../../core/utils/result.dart';
import '../../domain/entities/appointment.dart';
import '../../domain/usecases/appointments/get_appointments.dart';
import '../../core/services/refresh_service.dart';
import 'appointment_detail_page.dart';

enum _HistoryFilter { all, upcoming, past }

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  bool _loading = true;
  String? _error;
  List<Appointment> _appointments = [];
  String _query = '';
  _HistoryFilter _filter = _HistoryFilter.all;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
    di.sl<RefreshService>().addListener(_onRefresh);
  }

  @override
  void dispose() {
    di.sl<RefreshService>().removeListener(_onRefresh);
    super.dispose();
  }

  void _onRefresh() {
    if (mounted) {
      _loadAppointments();
    }
  }

  Future<void> _loadAppointments() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final getAppointments = di.sl<GetAppointments>();
    final result = await getAppointments();

    if (!mounted) return;

    result.fold(
      onSuccess: (data) {
        data.sort((a, b) => b.dateTime.compareTo(a.dateTime));
        setState(() {
          _appointments = data;
          _loading = false;
        });
      },
      onError: (failure) {
        setState(() {
          _error = failure.message;
          _loading = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'History',
          style: TextStyle(fontSize: AppConstants.defaultFontSize),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? _buildError()
                : _buildList(),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 12),
          Text(_error ?? 'Error'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadAppointments,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    final filtered = _filteredAppointments();

    if (_appointments.isEmpty) {
      return const Center(
        child: Text('No history yet'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAppointments,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: filtered.length + 2,
        separatorBuilder: (_, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index == 0) return _buildFilters();
          if (index == 1) return _buildSearch();
          final appt = filtered[index - 2];
          return Card(
            child: ListTile(
              leading: const Icon(Icons.event),
              title: Text(
                appt.doctorName.isEmpty ? appt.hospitalName : appt.doctorName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '${appt.hospitalName}\n${_formatDateTime(appt.dateTime)}',
              ),
              isThreeLine: true,
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                final changed = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(
                    builder: (_) => AppointmentDetailPage(appointmentId: appt.id),
                  ),
                );
                if (changed == true && mounted) {
                  _loadAppointments();
                }
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilters() {
    return Wrap(
      spacing: 8,
      children: [
        ChoiceChip(
          label: const Text('All'),
          selected: _filter == _HistoryFilter.all,
          onSelected: (_) => setState(() => _filter = _HistoryFilter.all),
        ),
        ChoiceChip(
          label: const Text('Upcoming'),
          selected: _filter == _HistoryFilter.upcoming,
          onSelected: (_) => setState(() => _filter = _HistoryFilter.upcoming),
        ),
        ChoiceChip(
          label: const Text('Past'),
          selected: _filter == _HistoryFilter.past,
          onSelected: (_) => setState(() => _filter = _HistoryFilter.past),
        ),
      ],
    );
  }

  Widget _buildSearch() {
    return TextField(
      decoration: const InputDecoration(
        prefixIcon: Icon(Icons.search),
        hintText: 'Search doctor or hospital',
        border: OutlineInputBorder(),
      ),
      onChanged: (value) => setState(() => _query = value.trim().toLowerCase()),
    );
  }

  List<Appointment> _filteredAppointments() {
    final now = DateTime.now();
    return _appointments.where((appt) {
      final matchesFilter = switch (_filter) {
        _HistoryFilter.all => true,
        _HistoryFilter.upcoming => appt.dateTime.isAfter(now),
        _HistoryFilter.past => appt.dateTime.isBefore(now),
      };
      if (!matchesFilter) return false;

      if (_query.isEmpty) return true;
      final haystack = '${appt.doctorName} ${appt.hospitalName}'.toLowerCase();
      return haystack.contains(_query);
    }).toList();
  }

  String _formatDateTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} • $displayHour:$minute $period';
  }
}

