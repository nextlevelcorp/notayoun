import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/progress_service.dart';
import '../theme/dimens.dart';
import '../widgets/mascot.dart';
import 'library_screen.dart';

/// İlk açılışta gösterilen tanıtım akışı.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _page = 0;

  static const _pages = <_OnboardData>[
    _OnboardData(
      emoji: '📸',
      mood: MascotMood.wave,
      title: 'Nota Kâğıdını Çek',
      body: 'Öğretmenin verdiği notayı fotoğrafla; biz onu oyuna çeviririz.',
    ),
    _OnboardData(
      emoji: '🎮',
      mood: MascotMood.happy,
      title: 'Düşen Notaları Çal',
      body: 'Notalar yukarıdan iner, doğru tuşa dokun ve şarkıyı çal!',
    ),
    _OnboardData(
      emoji: '⭐',
      mood: MascotMood.celebrate,
      title: 'Yıldız ve Rozet Kazan',
      body: 'Her gün çal, serini büyüt, rozetleri topla. İnternet gerekmez!',
    ),
  ];

  Future<void> _finish() async {
    await context.read<ProgressService>().setSeenOnboarding();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const LibraryScreen()),
    );
  }

  void _next() {
    if (_page < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      _finish();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _page == _pages.length - 1;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _finish,
                child: const Text('Atla'),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _page = i),
                itemCount: _pages.length,
                itemBuilder: (context, i) => _OnboardPage(data: _pages[i]),
              ),
            ),
            _dots(),
            const SizedBox(height: AppSpacing.lg),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.base),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _next,
                  child: Text(isLast ? 'Başla! 🎵' : 'Devam'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_pages.length, (i) {
        final active = i == _page;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 22 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outlineVariant,
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
        );
      }),
    );
  }
}

class _OnboardData {
  const _OnboardData({
    required this.emoji,
    required this.mood,
    required this.title,
    required this.body,
  });
  final String emoji;
  final MascotMood mood;
  final String title;
  final String body;
}

class _OnboardPage extends StatelessWidget {
  const _OnboardPage({required this.data});
  final _OnboardData data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Mascot(size: 140, mood: data.mood),
          const SizedBox(height: AppSpacing.xl),
          Text(data.emoji, style: const TextStyle(fontSize: 40)),
          const SizedBox(height: AppSpacing.md),
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            data.body,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}
