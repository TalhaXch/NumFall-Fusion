import 'dart:ui';

/// Responsive size utilities for adaptive layouts
class ResponsiveUtils {
  const ResponsiveUtils._();

  /// Screen size breakpoints
  static const double mobileMaxWidth = 600;
  static const double tabletMaxWidth = 900;

  /// Check if screen is mobile size
  static bool isMobile(double width) => width < mobileMaxWidth;

  /// Check if screen is tablet size
  static bool isTablet(double width) =>
      width >= mobileMaxWidth && width < tabletMaxWidth;

  /// Check if screen is desktop size
  static bool isDesktop(double width) => width >= tabletMaxWidth;

  /// Get responsive value based on screen width
  static T responsive<T>({
    required double width,
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop(width)) {
      return desktop ?? tablet ?? mobile;
    } else if (isTablet(width)) {
      return tablet ?? mobile;
    }
    return mobile;
  }

  /// Calculate board scale factor based on screen size
  static double getBoardScale(Size screenSize) {
    final width = screenSize.width;
    final height = screenSize.height;

    // Calculate available space for board
    const boardWidth = 7 * 48.0 + 6 * 4.0; // 7 tiles + spacing
    const boardHeight = 12 * 48.0 + 11 * 4.0; // 12 tiles + spacing

    // Add padding
    final availableWidth = width - 32;
    final availableHeight = height * 0.65; // Reserve space for UI

    // Calculate scale to fit
    final scaleX = availableWidth / boardWidth;
    final scaleY = availableHeight / boardHeight;

    return (scaleX < scaleY ? scaleX : scaleY).clamp(0.6, 1.2);
  }
}

/// Extension on num for responsive sizing
extension ResponsiveSizing on num {
  /// Get responsive size value
  double responsive(double screenWidth) {
    return ResponsiveUtils.responsive<double>(
      width: screenWidth,
      mobile: toDouble(),
      tablet: toDouble() * 1.2,
      desktop: toDouble() * 1.4,
    );
  }
}
