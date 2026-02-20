import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:user/localization/localisation.dart';
import 'package:user/services/constants.dart';
import 'package:user/theme/apptheme.dart';

class CustomIcon extends StatelessWidget {
  final void Function()? onPressed;
  final Widget? icon;

  const CustomIcon({super.key, this.onPressed, this.icon});

  @override
  Widget build(BuildContext context) {
    final borderColor = Apptheme.of(context).primaryText.withOpacity(0.8);
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return ClipOval(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed ?? () => Navigator.pop(context),
          customBorder: const CircleBorder(),
          child: Container(
            width: 50, // fixed size for uniform circle
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: borderColor),
            ),
            alignment: Alignment.center, // ensure centering
            child:
                icon ??
                HugeIcon(
                  icon: isRtl
                      ? HugeIcons.strokeRoundedArrowRight01
                      : HugeIcons.strokeRoundedArrowLeft01,
                  color: Apptheme.of(context).primaryText,
                  size: 24,
                ),
          ),
        ),
      ),
    );
  }
}

class HeaderWithIcon extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final Widget leading; // new parameter
  final bool iconFirst;
  final bool isSub;
  final bool needtoShow;

  const HeaderWithIcon({
    super.key,
    required this.title,
    this.trailing,
    this.leading = const SizedBox.shrink(), // default value
    this.isSub = false,
    this.needtoShow = true,
    this.iconFirst = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 35),
        Row(
          children: iconFirst
              ? [
                  leading,
                  SizedBox(width: needtoShow ? 15 : 0),
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Text(
                      title,
                      style: isSub
                          ? AppTextStyles.headingStyle2(context)
                          : AppTextStyles.headerTextstyle(context),
                    ),
                  ),
                  const Spacer(),
                  trailing ?? const SizedBox.shrink(),
                ]
              : [
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Text(
                      title,
                      style: isSub
                          ? AppTextStyles.headingStyle2(context)
                          : AppTextStyles.headerTextstyle(context),
                    ),
                  ),
                  const Spacer(),
                  trailing ?? const SizedBox.shrink(),
                ],
        ),
      ],
    );
  }
}

class AppButtonWithLabel extends StatelessWidget {
  final void Function()? onPressed;
  final String text;

  const AppButtonWithLabel({super.key, this.onPressed, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Apptheme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onPressed, // ✅ Properly assign the callback
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.alternate),
        ),
        child: Text(text, style: TextStyle(color: theme.primaryText)),
      ),
    );
  }
}

class AnimatedButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;

  const AnimatedButton({
    Key? key,
    required this.onPressed,
    required this.icon,
    required this.text,
    required this.backgroundColor,
    required this.textColor,
    required this.borderColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        height: 58,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(14),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [backgroundColor.withOpacity(0.9), backgroundColor],
          ),
          border: Border.all(color: borderColor.withOpacity(0.6), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Apptheme.of(context).primaryText.withOpacity(0.15),
              blurRadius: 6,
              offset: const Offset(0, 3),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Stack(
          children: [
            // Subtle shine effect
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    height: 20.0,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withOpacity(0.1),
                          Colors.white.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Button content
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: textColor, size: 22),
                  const SizedBox(width: 12),
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomTextfield extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final IconData icon;
  final ValueChanged<String>? onChanged; // 👈 Add this

  const CustomTextfield({
    super.key,
    required this.hintText,
    required this.icon,
    required this.controller,
    this.onChanged, // 👈 Accept it in constructor
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      cursorColor: Apptheme.of(context).primaryText,
      controller: controller,
      onChanged: onChanged, // 👈 Pass to TextField
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        hintText: hintText,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Apptheme.of(context).alternate),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: Apptheme.of(context).primaryText,
            width: 2,
          ),
        ),
      ),
    );
  }
}

class CustomLinkMenu extends StatelessWidget {
  final void Function()? onRandomLinkPressed;
  final void Function()? onCustomLinkPressed;

  const CustomLinkMenu({
    super.key,
    this.onRandomLinkPressed,
    this.onCustomLinkPressed,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      splashRadius: 13,
      offset: const Offset(-50, 30),
      elevation: 6,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      itemBuilder: (context) => [
        PopupMenuItem(
          padding: const EdgeInsets.all(10),
          value: 0,
          child: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(30)),
            padding: const EdgeInsets.symmetric(vertical: 8),
            alignment: Alignment.center,
            child: Text(FFLocalizations.of(context).getText("randomLink")),
          ),
        ),
        PopupMenuItem(
          padding: const EdgeInsets.all(10),
          value: 1,
          child: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(30)),
            padding: const EdgeInsets.symmetric(vertical: 8),
            alignment: Alignment.center,
            child: Text(FFLocalizations.of(context).getText("customLink")),
          ),
        ),
      ],
      onSelected: (value) {
        if (value == 0 && onRandomLinkPressed != null) {
          onRandomLinkPressed!();
        } else if (value == 1 && onCustomLinkPressed != null) {
          onCustomLinkPressed!();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Apptheme.of(context).alternate),
        ),
        child: Text(
          FFLocalizations.of(context).getText("newLink+"),
          style: TextStyle(color: Apptheme.of(context).primaryText),
        ),
      ),
    );
  }
}

class CustomWrapper extends StatelessWidget {
  final Widget child;
  const CustomWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Apptheme.of(context).secondaryText.withValues(alpha: 0.1),
      ),
      padding: const EdgeInsets.all(8),
      child: child,
    );
  }
}

class CustomtextfieldWrapper extends StatelessWidget {
  final Widget child;
  const CustomtextfieldWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Apptheme.of(context).alternate),
        borderRadius: BorderRadius.circular(10),
      ),
      child: child,
    );
  }
}

class NavIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color selectedColor;
  final Color unselectedColor;

  const NavIcon({
    super.key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.selectedColor,
    this.unselectedColor = const Color(0xFFBDBDBD), // default grey
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? selectedColor : unselectedColor,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? selectedColor : unselectedColor,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
