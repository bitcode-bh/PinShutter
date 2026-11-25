import 'package:flutter/material.dart';

import '../../core/design/palette.dart';
import '../../core/design/text_styles.dart';
import '../../core/design/tokens.dart';
import '../camera/widgets/camera_design.dart';
import '../../core/widgets/pressable.dart';
import '../../core/widgets/transitions.dart';
import '../../models/geo_data.dart';
import '../../models/template.dart';
import '../../state/settings_controller.dart';
import '../../state/template_controller.dart';
import '../../widgets/geo_stamp.dart';
import 'custom_template_editor.dart';

class TemplatesScreen extends StatelessWidget {
  const TemplatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final templates = TemplateController.instance;
    final settings = SettingsController.instance;
    final geo = GeoData.demo();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Stamp designs'),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.of(
              context,
            ).push(SheetRoute(page: const CustomTemplateEditor())),
            icon: const Icon(Icons.tune, size: 20),
            label: const Text('Customize'),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ListenableBuilder(
          listenable: templates,
          builder: (context, _) {
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(Insets.md, 6, Insets.md, 32),
              itemCount: offeredTemplates.length,
              separatorBuilder: (_, _) => const SizedBox(height: Insets.md),
              itemBuilder: (context, i) {
                final t = offeredTemplates[i];
                return _TemplateCard(
                  template: t,
                  selected: templates.config.template == t,
                  geo: geo,
                  settings: settings,
                  onTap: () {
                    if (templates.config.template != t) {
                      templates.selectTemplate(t);
                    }
                    Navigator.of(context).maybePop();
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _TemplateCard extends StatelessWidget {
  final StampTemplate template;
  final bool selected;
  final GeoData geo;
  final SettingsController settings;
  final VoidCallback onTap;

  const _TemplateCard({
    required this.template,
    required this.selected,
    required this.geo,
    required this.settings,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cfg = selected
        ? TemplateController.instance.config
        : TemplateConfig.forTemplate(template);
    return Semantics(
      label: '${template.title} stamp design',
      button: true,
      selected: selected,
      child: Pressable(
        onTap: onTap,
        child: CameraGlass(
          radius: 28,
          padding: const EdgeInsets.all(Insets.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text(template.title, style: AppText.title)),
                  const SizedBox(width: 8),
                  if (template.isNew) const _NewBadge(),
                  const SizedBox(width: 8),
                  _SelectMark(selected: selected),
                ],
              ),
              const SizedBox(height: 2),
              Text(template.blurb, style: AppText.label),
              const SizedBox(height: 4),
              const Text('Sample location', style: AppText.label),
              const SizedBox(height: Insets.sm),
              // Preview over a faux-photo backdrop.
              ClipRSuperellipse(
                borderRadius: BorderRadius.circular(Corners.md),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF605A50),
                        Color(0xFF292A27),
                        Color(0xFF131413),
                      ],
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: GeoStamp(
                      geo: geo,
                      config: cfg,
                      settings: settings,
                      preview: true,
                      live: false,
                      realMap: false,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NewBadge extends StatelessWidget {
  const _NewBadge();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: ShapeDecoration(
        color: Palette.selectionFill,
        shape: Corners.shape(
          Corners.xs,
          side: const BorderSide(color: Palette.selectionStroke),
        ),
      ),
      child: Text(
        'NEW',
        style: AppText.caption.copyWith(
          color: cameraYellow,
          fontSize: 12,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _SelectMark extends StatelessWidget {
  final bool selected;
  const _SelectMark({required this.selected});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : Motion.normal,
      curve: Motion.emphasized,
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        gradient: selected ? Palette.selectionGradient : null,
        color: selected ? null : Palette.glassFillStrong,
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? Palette.selectionStroke : Palette.glassStroke,
        ),
      ),
      child: Icon(
        selected ? Icons.check : Icons.circle_outlined,
        size: selected ? 15 : 13,
        color: selected ? cameraYellow : Palette.textLo,
      ),
    );
  }
}
