import 'package:flutter/widgets.dart';

/// Width at which the layout switches to a desktop/laptop layout.
const double kDesktopBreakpoint = 900.0;

/// Maximum width for main content on large screens.
const double kMaxContentWidth = 720.0;

/// Returns true when the current screen is wide enough to use a desktop layout.
bool isDesktop(BuildContext context) =>
    MediaQuery.of(context).size.width >= kDesktopBreakpoint;

/// Wraps [child] so it is horizontally centered with a max width of
/// [kMaxContentWidth]. On narrow screens the child expands normally.
Widget centeredContent(Widget child) => Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: kMaxContentWidth),
        child: child,
      ),
    );
