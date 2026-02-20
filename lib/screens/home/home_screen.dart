import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:user/globalwidgets/qr_code_scanner.dart';
import 'package:user/localization/localisation.dart';
import 'package:user/main.dart';
import 'package:user/providers/init_provider.dart';
import 'package:user/providers/user_provider.dart';
import 'package:user/providers/machine_map_provider.dart';
import 'package:user/screens/home/machine_map_screen.dart';
import 'package:user/theme/apptheme.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:user/screens/machine_list/machine_list_screen.dart';
import 'package:user/screens/settings/screen/settings_screen.dart';
import 'package:user/screens/otp_screen/screen/otp_screen.dart';
import 'package:user/screens/signin_page/screen/access_denied_screen.dart';

import 'package:user/providers/navigation_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  final List<Widget> _pages = const [HomeContent(), SettingsScreen()];

  @override
  Widget build(BuildContext context) {
    final theme = Apptheme.of(context);
    final navProvider = Provider.of<NavigationProvider>(context);

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      body: _pages[navProvider.selectedIndex],
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: navProvider.selectedIndex,
        onItemSelected: (index) {
          navProvider.setIndex(index);
        },
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Apptheme.of(context);
    final t = FFLocalizations.of(context);
    final user = FirebaseAuth.instance.currentUser;

    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────
            _HomeHeader(user: user, t: t, theme: theme),

            const SizedBox(height: 24),

            // ── Balance Card ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _BalanceCard(t: t, theme: theme),
            ),

            const SizedBox(height: 24),

            // ── Quick Stats Row ──────────────────────────────────
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 20),
            //   child: Row(
            //     children: [
            //       Expanded(
            //         child: _StatTile(
            //           label: 'Purchases',
            //           value: '12',
            //           icon: HugeIcons.strokeRoundedShoppingCart01,
            //           theme: theme,
            //         ),
            //       ),
            //       const SizedBox(width: 12),
            //       Expanded(
            //         child: _StatTile(
            //           label: 'Deposits',
            //           value: '3',
            //           icon: HugeIcons.strokeRoundedArrowDownLeft01,
            //           theme: theme,
            //         ),
            //       ),
            //       const SizedBox(width: 12),
            //       Expanded(
            //         child: _StatTile(
            //           label: 'Pickups',
            //           value: '5',
            //           icon: HugeIcons.strokeRoundedArrowUpRight01,
            //           theme: theme,
            //         ),
            //       ),
            //     ],
            //   ),
            // ),

            // const SizedBox(height: 28),

            // ── Section Title ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Explore',
                style: TextStyle(
                  color: theme.primary,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ),

            const SizedBox(height: 14),

            // ── Action Buttons ────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: _HomeActionButton(
                      title: 'View In Map',
                      subtitle: 'Find nearby machines',
                      icon: HugeIcons.strokeRoundedLocation01,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChangeNotifierProvider(
                              create: (_) => MachineMapProvider(),
                              child: const MachineMapScreen(),
                            ),
                          ),
                        );
                      },
                      theme: theme,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _HomeActionButton(
                      title: 'All Machines',
                      subtitle: 'Browse all vending machines',
                      icon: HugeIcons.strokeRoundedSmartPhone01,
                      onTap: () {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => const MachineListScreen(),
                        //   ),
                        // );
                      },
                      theme: theme,
                    ),
                  ),
                ],
              ),
            ),

            // const SizedBox(height: 32),

            // // ── Activity section label ────────────────────────────
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 20),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //     children: [
            //       Text(
            //         'Recent Activity',
            //         style: TextStyle(
            //           color: theme.primary,
            //           fontSize: 20,
            //           fontWeight: FontWeight.w800,
            //           letterSpacing: 0.5,
            //         ),
            //       ),
            //       Text(
            //         'See all',
            //         style: TextStyle(
            //           color: theme.primary.withValues(alpha: 0.6),
            //           fontSize: 13,
            //           fontWeight: FontWeight.w600,
            //         ),
            //       ),
            //     ],
            //   ),
            // ),

            // const SizedBox(height: 14),

            // // ── Placeholder activity items ────────────────────────
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 20),
            //   child: _ActivityItem(
            //     label: 'Snack purchased',
            //     sublabel: 'Machine #A21 · Today, 10:45 AM',
            //     amount: '-Ɖ 12.00',
            //     icon: HugeIcons.strokeRoundedShoppingCart01,
            //     theme: theme,
            //   ),
            // ),
            // const SizedBox(height: 10),
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 20),
            //   child: _ActivityItem(
            //     label: 'Balance deposit',
            //     sublabel: 'Wallet top-up · Yesterday',
            //     amount: '+Ɖ 50.00',
            //     icon: HugeIcons.strokeRoundedArrowDownLeft01,
            //     theme: theme,
            //     isCredit: true,
            //   ),
            // ),
            // const SizedBox(height: 10),
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 20),
            //   child: _ActivityItem(
            //     label: 'Drink pickup',
            //     sublabel: 'Machine #B03 · 2 days ago',
            //     amount: '-Ɖ 8.50',
            //     icon: HugeIcons.strokeRoundedArrowUpRight01,
            //     theme: theme,
            //   ),
            // ),

            // const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ── Header Widget ──────────────────────────────────────────────────────────────

class _HomeHeader extends StatelessWidget {
  final User? user;
  final FFLocalizations t;
  final Apptheme theme;

  const _HomeHeader({required this.user, required this.t, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: theme.primaryBackground,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Avatar + greeting
          Row(
            children: [
              CircleAvatar(
                radius: 23,
                backgroundColor: theme.primary,
                backgroundImage: user?.photoURL != null
                    ? NetworkImage(user!.photoURL!)
                    : null,
                child: user?.photoURL == null
                    ? const Icon(
                        Icons.person_rounded,
                        color: Colors.white,
                        size: 22,
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${t.getText('welcome')} 👋',
                    style: TextStyle(
                      color: theme.primary.withValues(alpha: 0.7),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    user?.displayName ?? 'User',
                    style: TextStyle(
                      color: theme.primary,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Notification bell
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: HugeIcon(
              icon: HugeIcons.strokeRoundedNotification01,
              color: theme.primary,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Balance Card ───────────────────────────────────────────────────────────────

class _BalanceCard extends StatelessWidget {
  final FFLocalizations t;
  final Apptheme theme;

  const _BalanceCard({required this.t, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.primary,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Balance label
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  t.getText('totalBalance'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Balance value
          const Text(
            'KWD 125.50',
            style: TextStyle(
              color: Colors.white,
              fontSize: 38,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),

          const SizedBox(height: 24),

          // Action buttons row
          Row(
            children: [
              _CardAction(
                label: t.getText('deposit'),
                icon: HugeIcons.strokeRoundedArrowDownLeft01,
                theme: theme,
              ),
              const SizedBox(width: 10),
              _CardAction(
                label: t.getText('buy'),
                icon: HugeIcons.strokeRoundedShoppingCart01,
                theme: theme,
              ),
              const SizedBox(width: 10),
              _CardAction(
                label: t.getText('pickup'),
                icon: HugeIcons.strokeRoundedArrowUpRight01,
                theme: theme,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CardAction extends StatelessWidget {
  final String label;
  final dynamic icon;
  final Apptheme theme;

  const _CardAction({
    required this.label,
    required this.icon,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            HugeIcon(icon: icon, color: Colors.white, size: 18),
            const SizedBox(height: 5),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Stat Tile ─────────────────────────────────────────────────────────────────

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final dynamic icon;
  final Apptheme theme;

  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: theme.primary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.primary.withValues(alpha: 0.12)),
      ),
      child: Column(
        children: [
          HugeIcon(icon: icon, color: theme.primary, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: theme.primary,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: theme.primary.withValues(alpha: 0.6),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── Home Action Button ────────────────────────────────────────────────────────

class _HomeActionButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final dynamic icon;
  final VoidCallback onTap;
  final Apptheme theme;

  const _HomeActionButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: theme.primary,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(12),
              ),
              child: HugeIcon(icon: icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.65),
                fontSize: 11,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Activity Item ─────────────────────────────────────────────────────────────

class _ActivityItem extends StatelessWidget {
  final String label;
  final String sublabel;
  final String amount;
  final dynamic icon;
  final Apptheme theme;
  final bool isCredit;

  const _ActivityItem({
    required this.label,
    required this.sublabel,
    required this.amount,
    required this.icon,
    required this.theme,
    this.isCredit = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: theme.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.primary.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: HugeIcon(icon: icon, color: theme.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: theme.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  sublabel,
                  style: TextStyle(
                    color: theme.primary.withValues(alpha: 0.55),
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              color: isCredit ? const Color(0xFF34E19A) : theme.primary,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Bottom Nav Bar ────────────────────────────────────────────────────────────

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Apptheme.of(context);

    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: theme.primary,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Home tab
          _NavItem(
            icon: HugeIcons.strokeRoundedHome01,
            label: 'Home',
            isSelected: selectedIndex == 0,
            theme: theme,
            onTap: () => onItemSelected(0),
          ),

          // QR scan centre button
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ScannerPage((link) {
                    // Handle scanned link
                    print("Scanned: $link");
                  }),
                ),
              );
            },
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: theme.primaryBackground,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedQrCode,
                  color: theme.primary,
                  size: 28,
                ),
              ),
            ),
          ),

          // Settings tab
          _NavItem(
            icon: HugeIcons.strokeRoundedSettings01,
            label: 'Settings',
            isSelected: selectedIndex == 1,
            theme: theme,
            onTap: () => onItemSelected(1),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final dynamic icon;
  final String label;
  final bool isSelected;
  final Apptheme theme;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 70,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.18)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: HugeIcon(
                icon: icon,
                color: isSelected ? Colors.white : Colors.white60,
                size: 26,
              ),
            ),
            const SizedBox(height: 2),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white60,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}

// ── HomeWrapper ───────────────────────────────────────────────────────────────

class HomeWrapper extends StatefulWidget {
  const HomeWrapper({super.key});

  @override
  State<HomeWrapper> createState() => _HomeWrapperState();
}

class _HomeWrapperState extends State<HomeWrapper> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<InitilisationProvider>(
        context,
        listen: false,
      ).initializeCountry(context);
      Provider.of<UserProvider>(context, listen: false).checkUserStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        if (userProvider.isLoading) {
          return Scaffold(
            backgroundColor: Apptheme.of(context).primaryBackground,
            body: Center(
              child: CircularProgressIndicator(
                color: Apptheme.of(context).primary,
              ),
            ),
          );
        }

        if (FirebaseAuth.instance.currentUser == null) {
          return const CustomSplashScreen();
        }

        if (!userProvider.isAuthorized) {
          return const AccessDeniedScreen();
        }

        if (userProvider.isPhoneVerified) {
          return const HomeScreen();
        } else {
          return const OTPVerificationScreen();
        }
      },
    );
  }
}
