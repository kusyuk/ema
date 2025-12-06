import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:hive/hive.dart';
import '../../core/di/injection_container.dart' as di;
import '../../core/theme/app_theme.dart';
import 'root_page.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  void _complete(BuildContext context) async {
    final box = di.sl<Box<dynamic>>();
    await box.put('onboarding_seen', true);
    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const RootPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      globalBackgroundColor: AppTheme.backgroundBase,
      pages: [
        _page(
          title: 'Capture the visit',
          body: 'Start a recording with one tap. Low file size, clear speech.',
          icon: Icons.mic,
        ),
        _page(
          title: 'Understand easily',
          body: 'Transcribe and summarize into simple terms, then listen with TTS.',
          icon: Icons.auto_awesome,
        ),
        _page(
          title: 'Stay organized',
          body: 'See appointments on the calendar, get reminders, and share summaries.',
          icon: Icons.calendar_today,
        ),
      ],
      showSkipButton: true,
      skip: const Text('Skip'),
      next: const Icon(Icons.arrow_forward),
      done: const Text('Done'),
      onDone: () => _complete(context),
      onSkip: () => _complete(context),
      curve: Curves.easeInOut,
      dotsDecorator: const DotsDecorator(
        activeColor: AppTheme.accent,
        color: AppTheme.iconDefault,
        size: Size(10, 10),
        activeSize: Size(20, 10),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25)),
        ),
      ),
    );
  }

  PageViewModel _page({
    required String title,
    required String body,
    required IconData icon,
  }) {
    return PageViewModel(
      titleWidget: Text(
        title,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppTheme.primaryDark,
        ),
      ),
      bodyWidget: Text(
        body,
        style: const TextStyle(
          fontSize: 16,
          color: AppTheme.textSecondary,
        ),
      ),
      decoration: const PageDecoration(
        imagePadding: EdgeInsets.only(top: 32),
        contentMargin: EdgeInsets.symmetric(horizontal: 24),
      ),
      image: Container(
        margin: const EdgeInsets.only(top: 32),
        height: 180,
        width: 180,
        decoration: BoxDecoration(
          color: AppTheme.primaryDark.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Icon(
          icon,
          size: 72,
          color: AppTheme.accent,
        ),
      ),
    );
  }
}

