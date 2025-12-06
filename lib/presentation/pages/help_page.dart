import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Help & FAQ',
          style: TextStyle(fontSize: AppConstants.defaultFontSize),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: const [
            _HelpCard(
              title: 'How do I record?',
              bullets: [
                'Ask the doctor for permission before recording.',
                'Tap "Record Session" from the appointments screen.',
                'Tap Stop when finished.',
              ],
            ),
            _HelpCard(
              title: 'How do I see the summary?',
              bullets: [
                'After processing, the summary appears on the transcription screen.',
                'You can also find it in the appointment detail page under Recordings.',
              ],
            ),
            _HelpCard(
              title: 'How do reminders work?',
              bullets: [
                'Reminders are set when you create or edit an appointment.',
                'You can change the lead time in the appointment form.',
              ],
            ),
            _HelpCard(
              title: 'Privacy',
              bullets: [
                'Audio stays on your device.',
                'Groq is used to transcribe and summarize.',
              ],
            ),
            _HelpCard(
              title: 'Need more help?',
              bullets: [
                'Contact support: support@example.com',
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HelpCard extends StatelessWidget {
  final String title;
  final List<String> bullets;

  const _HelpCard({
    required this.title,
    required this.bullets,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: AppConstants.defaultFontSize + 2,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimaryDark,
              ),
            ),
            const SizedBox(height: 8),
            ...bullets.map(
              (b) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• '),
                    Expanded(
                      child: Text(
                        b,
                        style: const TextStyle(
                          fontSize: AppConstants.defaultFontSize,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


