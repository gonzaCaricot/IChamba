import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Wraps content and makes it look better on wide screens (desktop/web).
///
/// Behavior:
/// - On screens narrower than [breakpoint] it simply returns the child unchanged.
/// - On screens wider or equal to [breakpoint] it centers the child and
///   constrains its maximum width to [maxWidth] and adds horizontal padding.
class DesktopResponsive extends StatelessWidget {
  final Widget child;
  final double breakpoint;
  final double maxWidth;

  const DesktopResponsive({
    super.key,
    required this.child,
    this.breakpoint = 800,
    this.maxWidth = 900,
  });

  bool get _isDesktopLike => kIsWeb;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (!_isDesktopLike && width < breakpoint) return child;

    // For web/desktop or very wide phones, center and constrain content.
    if (width >= breakpoint) {
      return Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: child,
          ),
        ),
      );
    }

    return child;
  }
}
