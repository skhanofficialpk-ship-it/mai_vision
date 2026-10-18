import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_theme.dart';
import '../core/constants/app_constants.dart';
import 'package:url_launcher/url_launcher.dart';

class PublicShell extends StatelessWidget {
  final Widget child;
  const PublicShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const _NavBar(),
          Expanded(
            child: child,
          ),
        ],
      ),
    );
  }
}

class _NavBar extends StatefulWidget {
  const _NavBar();

  @override
  State<_NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<_NavBar> {
  bool _scrolled = false;

  final List<_NavItem> _items = const [
    _NavItem('Home', '/'),
    _NavItem('Gaming Studio', '/gaming-studio'),
    _NavItem('About', '/about'),
    _NavItem('Courses', '/courses'),
    _NavItem('Admissions', '/admissions'),
    _NavItem('Gallery', '/gallery'),
    _NavItem('Contact', '/contact'),
    _NavItem('Verify Certificate', '/verify-certificate'),
  ];

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    // Raised from 768 to 1100 — at 768-1100px, 7 nav links + logo + button
    // don't fit in a single Row without overflowing. Hamburger menu below
    // 1100px guarantees no horizontal overflow on any real device width.
    final isMobile = w < 1100;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: _scrolled
            ? [
                BoxShadow(
                    color: AppColors.cardShadow,
                    blurRadius: 16,
                    offset: const Offset(0, 4))
              ]
            : [
                BoxShadow(
                    color: AppColors.border,
                    blurRadius: 0,
                    offset: const Offset(0, 1))
              ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 16 : 40,
            vertical: 0,
          ),
          child: SizedBox(
            height: 68,
            child: Row(
              children: [
                const Flexible(child: _Logo()),
                const Spacer(),
                if (!isMobile) ...[
                  ..._items.map((item) => _NavLink(item: item)),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () => context.go('/admissions'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: AppColors.text,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      textStyle: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                    child: const Text('Apply Now'),
                  ),
                ],
                if (isMobile)
                  IconButton(
                    icon: const Icon(Icons.menu, color: AppColors.text),
                    onPressed: () => _showMobileMenu(context),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showMobileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _MobileMenu(items: _items),
    );
  }
}

class _NavItem {
  final String label;
  final String path;
  const _NavItem(this.label, this.path);
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/'),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.contain,
              errorBuilder: (c, e, s) => Container(
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text('M',
                      style: TextStyle(
                          color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Using IntrinsicWidth to prevent character-by-character wrapping on small screens
          IntrinsicWidth(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  'MAI COACHING',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                    height: 1.1,
                  ),
                ),
                Text(
                  'ACADEMY',
                  style: TextStyle(
                    color: AppColors.accent,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavLink extends StatefulWidget {
  final _NavItem item;
  const _NavLink({required this.item});

  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final current = GoRouterState.of(context).matchedLocation;
    final isActive = current == widget.item.path ||
        (widget.item.path != '/' && current.startsWith(widget.item.path));

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: () => context.go(widget.item.path),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            widget.item.label,
            style: TextStyle(
              color: isActive
                  ? AppColors.primary
                  : _hover
                      ? AppColors.primary
                      : AppColors.text,
              fontSize: 13,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _MobileMenu extends StatelessWidget {
  final List<_NavItem> items;
  const _MobileMenu({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(24),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            ...items.map((item) => ListTile(
                  title: Text(
                    item.label,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, color: AppColors.text),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    context.go(item.path);
                  },
                )),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.go('/admissions');
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.text),
                child: const Text('Apply Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isMobile = w < 768;

    return Container(
      color: AppColors.text,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 80,
        vertical: 48,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _footerColumns(context, isMobile),
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _footerColumns(context, isMobile)
                      .map((w) => Expanded(child: w))
                      .toList(),
                ),
          const SizedBox(height: 40),
          const Divider(color: Color(0xFF1E293B)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Text(
                  '© ${DateTime.now().year} MAI Coaching Academy. All rights reserved.',
                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                ),
              ),
              GestureDetector(
                onTap: () => context.go('/login'),
                child: const Text(
                  'Admin Login',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 13,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _footerColumns(BuildContext context, bool isMobile) {
    return [
      _FooterAbout(isMobile: isMobile),
      SizedBox(height: isMobile ? 32 : 0),
      _FooterLinks(),
      SizedBox(height: isMobile ? 32 : 0),
      _FooterContact(),
    ];
  }
}

class _FooterAbout extends StatelessWidget {
  final bool isMobile;
  const _FooterAbout({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(
              width: 32,
              height: 32,
              child: Image.asset(
                'assets/images/logo.png',
                fit: BoxFit.contain,
                errorBuilder: (c, e, s) => Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Center(
                    child: Text('M',
                        style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'MAI Coaching Academy',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          'Build Your Future with modern AI',
          style: TextStyle(
            color: AppColors.accent,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Professional certification in AI tools, digital skills, and computer sciences.',
          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13, height: 1.6),
        ),
      ],
    );
  }
}

class _FooterLinks extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final links = [
      ('Home', '/'),
      ('MAI Gaming Studio', '/gaming-studio'),
      ('About', '/about'),
      ('Courses', '/courses'),
      ('Admissions', '/admissions'),
      ('Gallery', '/gallery'),
      ('Contact', '/contact'),
      ('Verify Certificate', '/verify-certificate'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Quick Links',
            style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700)),
        const SizedBox(height: 16),
        ...links.map((l) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                onTap: () => context.go(l.$2),
                child: Text(
                  l.$1,
                  style: const TextStyle(
                      color: Color(0xFF94A3B8), fontSize: 13),
                ),
              ),
            )),
      ],
    );
  }
}

class _FooterContact extends StatelessWidget {
  void _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Contact Us',
            style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700)),
        const SizedBox(height: 16),
        _ContactItem(Icons.location_on, AppConstants.location, null),
        const SizedBox(height: 8),
        _ContactItem(Icons.phone, AppConstants.phoneFormatted,
            () => _launch(AppConstants.callUrl)),
        const SizedBox(height: 8),
        _ContactItem(Icons.email, AppConstants.email,
            () => _launch(AppConstants.emailUrl)),
        const SizedBox(height: 8),
        _ContactItem(Icons.chat, 'WhatsApp: ${AppConstants.phoneFormatted}',
            () => _launch(AppConstants.whatsappUrl)),
      ],
    );
  }
}

class _ContactItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback? onTap;
  const _ContactItem(this.icon, this.text, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.accent, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
