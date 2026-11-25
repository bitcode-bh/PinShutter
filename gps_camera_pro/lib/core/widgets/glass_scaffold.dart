import 'package:flutter/material.dart';

import '../design/palette.dart';
import '../design/text_styles.dart';
import '../design/tokens.dart';
import '../glass.dart';
import 'stash_backdrop.dart';

/// Shared Stash chrome for the secondary screens.
class GlassScaffold extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget body;
  final List<Widget> actions;
  final Widget? bottom;

  const GlassScaffold({
    super.key,
    required this.title,
    this.subtitle,
    required this.body,
    this.actions = const [],
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: Palette.ink,
      body: StashBackdrop(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                Insets.md,
                topPad + 10,
                Insets.md,
                6,
              ),
              child: Row(
                children: [
                  GlassIconButton(
                    icon: Icons.arrow_back,
                    label: 'Back',
                    onTap: () => Navigator.of(context).maybePop(),
                  ),
                  const SizedBox(width: Insets.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: AppText.h1),
                        if (subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(subtitle!, style: AppText.label),
                        ],
                      ],
                    ),
                  ),
                  ...actions,
                ],
              ),
            ),
            Expanded(child: body),
            ?bottom,
          ],
        ),
      ),
    );
  }
}
