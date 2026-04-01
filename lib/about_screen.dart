import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';

// ─── Color constants ────────────────────────────────────────────────────────
class AppColors {
  static const orange = Color(0xFFFF6B35);
  static const yellow = Color(0xFFFFD23F);
  static const teal   = Color(0xFF4ECDC4);
  static const green  = Color(0xFF06D6A0);
  static const red    = Color(0xFFEF476F);
  static const bg     = Color(0xFF0D0D14);
  static const card   = Color(0xFF16213E);
  static const border = Color(0xFF2A2A4A);
  static const text   = Color(0xFFF0F0FF);
  static const sub    = Color(0xFF8888AA);
}

// ─── About Screen ───────────────────────────────────────────────────────────
class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen>
    with TickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 48),
          child: Column(
            children: [
              _buildHero(),
              const SizedBox(height: 8),
              _buildAboutCard(),
              _buildFeaturesCard(),
              _buildPointsCard(),
              _buildLevelsCard(),
              _buildContactCard(),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  // ── Hero ──────────────────────────────────────────────────────────────────
  Widget _buildHero() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          SizedBox(
            width: 180,
            height: 150,
            child: Lottie.asset(
              'assets/checked.json',
              repeat: true,
              errorBuilder: (_, __, ___) => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  3,
                      (i) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.orange,
                      shape: BoxShape.circle,
                    ),
                  )
                      .animate(onPlay: (c) => c.repeat())
                      .fadeIn(
                      duration: 400.ms,
                      delay: Duration(milliseconds: 1200 + i * 200))
                      .then()
                      .fadeOut(duration: 400.ms)
                      .then()
                      .fadeIn(duration: 400.ms),
                ),
              ),
            ),
          ).animate().fadeIn(delay: 300.ms).scale(
            begin: const Offset(0.5, 0.5),
            end: const Offset(1, 1),
            delay: 300.ms,
            curve: Curves.elasticOut,
          ),
          const SizedBox(height: 12),

          // Shimmer app name
          AnimatedBuilder(
            animation: _shimmerController,
            builder: (_, __) {
              return ShaderMask(
                shaderCallback: (bounds) {
                  return LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: const [
                      AppColors.orange,
                      AppColors.yellow,
                      AppColors.orange,
                    ],
                    stops: [
                      (_shimmerController.value - 0.3).clamp(0.0, 1.0),
                      _shimmerController.value.clamp(0.0, 1.0),
                      (_shimmerController.value + 0.3).clamp(0.0, 1.0),
                    ],
                  ).createShader(bounds);
                },
                child: const Text(
                  'TaskNestX',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 6),
          const Text(
            'NEST · COMPLETE · CONQUER',
            style: TextStyle(
              color: AppColors.sub,
              fontSize: 12,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  // ── About Card ────────────────────────────────────────────────────────────
  Widget _buildAboutCard() {
    return _AppCard(
      iconEmoji: '🚀',
      iconColor: AppColors.orange,
      title: 'About the App',
      subtitle: 'Your gamified productivity companion',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _BodyText(
            'TaskNestX is a fun, offline-first to-do app that turns productivity into a game. Create tasks, complete them, earn points, unlock badges, and level up — all without ever needing an account or internet connection.',
          ),
          SizedBox(height: 8),
          _BodyText(
            'Every task you finish brings you closer to the next level. Build streaks, conquer your priorities, and become the ultimate productivity champion!',
          ),
        ],
      ),
    );
  }

  // ── Features Card ─────────────────────────────────────────────────────────
  Widget _buildFeaturesCard() {
    const features = [
      ('📋', 'Smart Tasks',   'Priority levels, tags, due dates & descriptions'),
      ('⚡', 'Points System', 'Earn points on every task you complete'),
      ('🏅', 'Badges',        '10 unique badges to unlock'),
      ('🔥', 'Streaks',       'Daily streaks to build great habits'),
      ('📊', 'Statistics',    'Daily, weekly & monthly trends'),
      ('🌙', 'Dark & Light',  'Beautiful theme options'),
    ];

    return _AppCard(
      iconEmoji: '✨',
      iconColor: AppColors.teal,
      title: 'Key Features',
      subtitle: "Everything you need, nothing you don't",
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.3,
        ),
        itemCount: features.length,
        itemBuilder: (_, i) {
          final (emoji, title, desc) = features[i];
          return _FeatureItem(emoji: emoji, title: title, desc: desc);
        },
      ),
    );
  }

  // ── Points Card ───────────────────────────────────────────────────────────
  Widget _buildPointsCard() {
    return _AppCard(
      iconEmoji: '⚡',
      iconColor: AppColors.yellow,
      title: 'Points System',
      subtitle: 'More challenging = more rewarding',
      child: Column(
        children: [
          _PointsRow(
            emoji: '🌿',
            label: 'Low Priority Task',
            pts: '+10 pts',
            color: AppColors.teal,
          ),
          _PointsRow(
            emoji: '⚡',
            label: 'Medium Priority Task',
            pts: '+20 pts',
            color: AppColors.yellow,
          ),
          _PointsRow(
            emoji: '🔥',
            label: 'High Priority Task',
            pts: '+40 pts',
            color: AppColors.red,
            isLast: true,
          ),
        ],
      ),
    );
  }

  // ── Levels Card ───────────────────────────────────────────────────────────
  Widget _buildLevelsCard() {
    const levels = [
      ('🐣', 'Hatchling', 'Level 1 · 0–99 points'),
      ('🐥', 'Nestling',  'Level 2 · 100–249 points'),
      ('🐦', 'Fledgling', 'Level 3 · 250–499 points'),
      ('🦅', 'Soarer',    'Level 4 · 500–999 points'),
      ('🦁', 'Eagle',     'Level 5 · 1000–1999 points'),
      ('🔥', 'Phoenix',   'Level 6 · 2000+ points'),
    ];

    return _AppCard(
      iconEmoji: '👑',
      iconColor: AppColors.green,
      title: 'Levels',
      subtitle: 'Rise through the ranks',
      child: Column(
        children: [
          for (int i = 0; i < levels.length; i++)
            _LevelItem(
              emoji: levels[i].$1,
              name:  levels[i].$2,
              range: levels[i].$3,
              isLast: i == levels.length - 1,
            ),
        ],
      ),
    );
  }

  // ── Contact Card ──────────────────────────────────────────────────────────
  Widget _buildContactCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.orange.withOpacity(0.12),
            AppColors.yellow.withOpacity(0.06),
          ],
        ),
        border: Border.all(color: AppColors.orange.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text(
            '👋 ZaraGamesHub',
            style: TextStyle(
              color: AppColors.text,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Crafting fun & productive apps for everyone',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.sub, fontSize: 13),
          ),
          const SizedBox(height: 8),
          const Text(
            "Have feedback, ideas, or found a bug?\nWe'd love to hear from you!",
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.sub, fontSize: 13),
          ),
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.orange, AppColors.yellow],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.orange.withOpacity(0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () {
                  // launch email
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Text(
                    '✉️  zarakhangpc@gmail.com',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Footer ────────────────────────────────────────────────────────────────
  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.only(top: 20),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: const [

          SizedBox(height: 6),
          Text('© 2025 ZaraGamesHub · All rights reserved',
              style: TextStyle(color: AppColors.sub, fontSize: 12)),

        ],
      ),
    );
  }
}

// ─── Reusable Widgets ────────────────────────────────────────────────────────

class _AppCard extends StatelessWidget {
  final String iconEmoji;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget child;

  const _AppCard({
    required this.iconEmoji,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(iconEmoji, style: const TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(width: 12),
              // ✅ FIX: Expanded prevents header text overflow
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.sub,
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _BodyText extends StatelessWidget {
  final String text;
  const _BodyText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.sub,
        fontSize: 14,
        height: 1.7,
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final String emoji;
  final String title;
  final String desc;

  const _FeatureItem({
    required this.emoji,
    required this.title,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.orange.withOpacity(0.06),
        border: Border.all(color: AppColors.orange.withOpacity(0.15)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          // ✅ FIX: Expanded inside Column for feature description
          Expanded(
            child: Text(
              desc,
              style: const TextStyle(
                color: AppColors.sub,
                fontSize: 11,
                height: 1.5,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _PointsRow extends StatelessWidget {
  final String emoji;
  final String label;
  final String pts;
  final Color color;
  final bool isLast;

  const _PointsRow({
    required this.emoji,
    required this.label,
    required this.pts,
    required this.color,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ✅ FIX: Expanded prevents label from pushing pts badge off screen
          Expanded(
            child: Text(
              '$emoji  $label',
              style: const TextStyle(color: AppColors.text, fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              pts,
              style: TextStyle(
                color: color,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelItem extends StatelessWidget {
  final String emoji;
  final String name;
  final String range;
  final bool isLast;

  const _LevelItem({
    required this.emoji,
    required this.name,
    required this.range,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: Text(
              emoji,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 26),
            ),
          ),
          const SizedBox(width: 12),
          // ✅ FIX: Expanded prevents overflow in level name/range column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  range,
                  style: const TextStyle(
                    color: AppColors.sub,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}