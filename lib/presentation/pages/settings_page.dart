import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../core/constants/app_constants.dart';
import '../../core/di/injection_container.dart' as di;
import '../../core/utils/result.dart';
import '../../core/utils/usecase.dart';
import '../../domain/entities/tts_settings.dart';
import '../../domain/usecases/tts/load_tts_settings.dart';
import '../../domain/usecases/tts/save_tts_settings.dart';
import 'help_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _loading = true;
  bool _saving = false;
  String? _error;

  String _themeMode = 'system';
  String _language = 'en-US';
  double _rate = 0.7;
  double _pitch = 1.0;

  final _box = di.sl<Box<dynamic>>();
  final _loadTts = di.sl<LoadTtsSettings>();
  final _saveTts = di.sl<SaveTtsSettings>();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await _loadTts(const NoParams());
    if (!mounted) return;
    result.fold(
      onSuccess: (settings) {
        setState(() {
          _themeMode = (_box.get('theme_mode') as String?) ?? 'system';
          _language = settings.language;
          _rate = settings.rate;
          _pitch = settings.pitch;
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

  Future<void> _save() async {
    setState(() {
      _saving = true;
    });
    final settings = TtsSettings(
      language: _language,
      rate: _rate,
      pitch: _pitch,
    );
    final result = await _saveTts(SaveTtsSettingsParams(settings));
    if (!mounted) return;
    result.fold(
      onSuccess: (_) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Settings saved')));
      },
      onError: (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Save failed: ${failure.message}')),
        );
      },
    );
    setState(() {
      _saving = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontSize: AppConstants.defaultFontSize),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? _buildError()
            : _buildContent(),
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
          ElevatedButton(onPressed: _load, child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _Section(
          title: 'General',
          children: [
            _SettingTile(
              icon: Icons.brightness_6_outlined,
              title: 'Theme',
              subtitle: 'Light / Dark / System',
              trailing: DropdownButton<String>(
                value: _themeMode,
                items: const [
                  DropdownMenuItem(value: 'system', child: Text('System')),
                  DropdownMenuItem(value: 'light', child: Text('Light')),
                  DropdownMenuItem(value: 'dark', child: Text('Dark')),
                ],
                onChanged: (v) {
                  if (v == null) return;
                  setState(() => _themeMode = v);
                  _box.put('theme_mode', v);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Theme set to ${v[0].toUpperCase()}${v.substring(1)}',
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const _Section(
          title: 'About',
          children: [
            _SettingTile(
              icon: Icons.info_outline,
              title: 'App version',
              subtitle: AppConstants.appVersion,
              trailing: SizedBox.shrink(),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _Section(
          title: 'Text-to-Speech Defaults',
          children: [
            DropdownButtonFormField<String>(
              initialValue: _language,
              decoration: const InputDecoration(
                labelText: 'Language',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'en-US', child: Text('English (US)')),
                DropdownMenuItem(value: 'en-GB', child: Text('English (UK)')),
                DropdownMenuItem(value: 'es-ES', child: Text('Spanish')),
                DropdownMenuItem(value: 'fr-FR', child: Text('French')),
              ],
              onChanged: (v) {
                if (v != null) setState(() => _language = v);
              },
            ),
            const SizedBox(height: 16),
            Text('Rate (${_rate.toStringAsFixed(2)})'),
            Slider(
              value: _rate,
              min: 0.3,
              max: 1.0,
              divisions: 14,
              onChanged: (v) => setState(() => _rate = v),
            ),
            const SizedBox(height: 8),
            Text('Pitch (${_pitch.toStringAsFixed(2)})'),
            Slider(
              value: _pitch,
              min: 0.5,
              max: 2.0,
              divisions: 15,
              onChanged: (v) => setState(() => _pitch = v),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: Text(_saving ? 'Saving...' : 'Save defaults'),
                ),
                const SizedBox(width: 12),
                TextButton(
                  onPressed: _saving
                      ? null
                      : () {
                          setState(() {
                            _language = 'en-US';
                            _rate = 0.7;
                            _pitch = 1.0;
                          });
                        },
                  child: const Text('Reset'),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        _Section(
          title: 'Help & FAQ',
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.help_outline),
              title: const Text(
                'Open help',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: const Text('How to record, summaries, reminders, privacy'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const HelpPage()),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        const _Section(
          title: 'Recording & Storage',
          children: [
            _SettingTile(
              icon: Icons.mic_none,
              title: 'Recording settings',
              subtitle: 'Optimized for speech (16kHz/64kbps)',
            ),
            _SettingTile(
              icon: Icons.delete_outline,
              title: 'Manage storage',
              subtitle: 'Delete recordings via appointment detail',
            ),
          ],
        ),
        const SizedBox(height: 12),
        const _Section(
          title: 'Privacy',
          children: [
            _SettingTile(
              icon: Icons.lock_outline,
              title: 'Data handling',
              subtitle: 'Recordings local; Groq used for STT/LLM',
            ),
          ],
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: AppConstants.defaultFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;

  const _SettingTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      trailing:
          trailing ??
          const Padding(
            padding: EdgeInsets.only(right: 8.0),
            child: Text('Info', style: TextStyle(color: Colors.grey)),
          ),
    );
  }
}
