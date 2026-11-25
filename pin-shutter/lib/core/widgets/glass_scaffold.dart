import 'package:flutter/material.dart';

import '../design/text_styles.dart';
import '../design/tokens.dart';
import '../glass.dart';

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
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Insets.md,
                Insets.xs,
                Insets.md,
                Insets.xs,
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
                        Text(
                          title,
                          style: AppText.h1,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitle!,
                            style: AppText.label,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
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
