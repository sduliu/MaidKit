import 'package:material_ui/material_ui.dart';

import '../../servers/server_models.dart';
import '../../theme.dart';

/// What a host or service is currently doing.
///
/// Replaces the `(connected, connecting, failed)` boolean triples that were
/// spread across the server, container and daemon pages. Three independent
/// booleans encode contradictory states — `connected && failed` was reachable
/// and each page resolved it differently — so the state is a single value.
enum MaidKitConnState {
  /// Reachable and healthy.
  online,

  /// Reachable but unhappy: slow, stale, or partially failing.
  degraded,

  /// In flight: connecting, restarting, provisioning.
  connecting,

  /// Unreachable or stopped, with no error to report.
  offline,

  /// Unreachable because something went wrong.
  failed,
}

/// Maps the SSH session lifecycle onto the presentation state.
///
/// Lives here so the mapping is made once. Every page that showed session
/// status had its own switch, and they disagreed: some treated `closed` as a
/// failure, others as idle.
MaidKitConnState maidKitConnStateOfSession(SessionStatus? status) =>
    switch (status) {
      SessionStatus.connected => MaidKitConnState.online,
      SessionStatus.connecting => MaidKitConnState.connecting,
      SessionStatus.failed => MaidKitConnState.failed,
      // A closed session was deliberately ended. That is idle, not broken.
      SessionStatus.closed => MaidKitConnState.offline,
      null => MaidKitConnState.offline,
    };

/// Resolved presentation for one [MaidKitConnState].
@immutable
class MaidKitConnStyle {
  const MaidKitConnStyle({
    required this.color,
    required this.surface,
    required this.filled,
  });

  /// Dot and label colour.
  final Color color;

  /// Backdrop when the state is shown as a chip.
  final Color surface;

  /// Whether the dot is solid or a ring. Shape carries the same information as
  /// hue so the state survives a colour-vision deficiency and a greyscale
  /// screenshot — hue alone would not.
  final bool filled;

  static MaidKitConnStyle of(BuildContext context, MaidKitConnState state) {
    final s = context.semantics;
    return switch (state) {
      MaidKitConnState.online => MaidKitConnStyle(
        color: s.online,
        surface: s.onlineSurface,
        filled: true,
      ),
      MaidKitConnState.degraded => MaidKitConnStyle(
        color: s.degraded,
        surface: s.degradedSurface,
        filled: true,
      ),
      MaidKitConnState.connecting => MaidKitConnStyle(
        color: s.connecting,
        surface: s.connecting.withValues(alpha: 0.16),
        filled: false,
      ),
      MaidKitConnState.offline => MaidKitConnStyle(
        color: context.scheme.onSurfaceVariant,
        surface: context.scheme.surfaceContainerHigh,
        filled: false,
      ),
      MaidKitConnState.failed => MaidKitConnStyle(
        color: s.offline,
        surface: s.offlineSurface,
        filled: true,
      ),
    };
  }
}

/// The status dot.
///
/// Deliberately not animated on its own. A pulsing dot on every row of a host
/// list turns a dense table into a christmas tree and trains the eye to ignore
/// it, which defeats the point. Only [MaidKitConnState.connecting] moves,
/// because that is the one state that is genuinely transient.
class MaidKitStatusDot extends StatefulWidget {
  const MaidKitStatusDot({super.key, required this.state, this.size = 8});

  final MaidKitConnState state;
  final double size;

  @override
  State<MaidKitStatusDot> createState() => _MaidKitStatusDotState();
}

class _MaidKitStatusDotState extends State<MaidKitStatusDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );

  @override
  void initState() {
    super.initState();
    _syncPulse();
  }

  @override
  void didUpdateWidget(MaidKitStatusDot old) {
    super.didUpdateWidget(old);
    if (old.state != widget.state) _syncPulse();
  }

  void _syncPulse() {
    if (widget.state == MaidKitConnState.connecting) {
      if (!_pulse.isAnimating) _pulse.repeat(reverse: true);
    } else {
      _pulse.stop();
      _pulse.value = 0;
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = MaidKitConnStyle.of(context, widget.state);
    final ring = !style.filled;

    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, _) {
        final t = Curves.easeInOut.transform(_pulse.value);
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: ring
                ? style.color.withValues(alpha: 0.10 + 0.28 * t)
                : style.color,
            border: ring
                ? Border.all(
                    color: style.color.withValues(alpha: 0.55 + 0.45 * t),
                    width: 1.5,
                  )
                : null,
          ),
        );
      },
    );
  }
}

/// Dot plus label, for a row or header that has room for words.
///
/// [trailing] carries the measurement that belongs with the state — latency
/// when online, an error summary when failed. Keeping it in the same widget
/// stops each page from re-deciding how a latency reading sits next to a dot.
class MaidKitStatusLabel extends StatelessWidget {
  const MaidKitStatusLabel({
    super.key,
    required this.state,
    required this.label,
    this.trailing,
    this.tooltip,
  });

  final MaidKitConnState state;
  final String label;
  final Widget? trailing;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final style = MaidKitConnStyle.of(context, state);
    final row = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        MaidKitStatusDot(state: state),
        const SizedBox(width: MaidKitSpace.sm),
        Text(
          label,
          style: context.type.labelLarge?.copyWith(color: style.color),
        ),
        if (trailing != null) ...[
          const SizedBox(width: MaidKitSpace.sm),
          DefaultTextStyle.merge(
            style: context.type.labelLarge?.copyWith(
              color: context.scheme.onSurfaceVariant,
            ),
            child: trailing!,
          ),
        ],
      ],
    );
    final message = tooltip;
    return message == null ? row : Tooltip(message: message, child: row);
  }
}

/// Compact filled variant, for a dense list row or a card corner where a
/// coloured word on its own would not read as a state.
class MaidKitStatusChip extends StatelessWidget {
  const MaidKitStatusChip({
    super.key,
    required this.state,
    required this.label,
    this.tooltip,
  });

  final MaidKitConnState state;
  final String label;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final style = MaidKitConnStyle.of(context, state);
    final chip = AnimatedContainer(
      duration: MaidKitMotion.quick,
      curve: MaidKitMotion.standard,
      padding: const EdgeInsets.symmetric(
        horizontal: MaidKitSpace.sm,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: style.surface,
        borderRadius: BorderRadius.circular(MaidKitRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          MaidKitStatusDot(state: state, size: 6),
          const SizedBox(width: MaidKitSpace.xs + 2),
          Text(
            label,
            style: context.type.labelSmall?.copyWith(color: style.color),
          ),
        ],
      ),
    );
    final message = tooltip;
    return message == null ? chip : Tooltip(message: message, child: chip);
  }
}
