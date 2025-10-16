/// App-wide dimension constants
/// All dimensions follow a 4px base unit system
class AppDimensions {
  // Base Unit
  static const double baseUnit = 4.0;

  // Spacing Scale
  static const double spacing2xs = baseUnit; // 4px
  static const double spacingXs = baseUnit * 2; // 8px
  static const double spacingSm = baseUnit * 3; // 12px
  static const double spacingMd = baseUnit * 4; // 16px
  static const double spacingLg = baseUnit * 6; // 24px
  static const double spacingXl = baseUnit * 8; // 32px
  static const double spacing2xl = baseUnit * 12; // 48px
  static const double spacing3xl = baseUnit * 16; // 64px

  // Padding
  static const double paddingXs = spacingXs; // 8px
  static const double paddingSm = spacingSm; // 12px
  static const double paddingMd = spacingMd; // 16px
  static const double paddingLg = spacingLg; // 24px
  static const double paddingXl = spacingXl; // 32px

  // Margin
  static const double marginXs = spacingXs; // 8px
  static const double marginSm = spacingSm; // 12px
  static const double marginMd = spacingMd; // 16px
  static const double marginLg = spacingLg; // 24px
  static const double marginXl = spacingXl; // 32px

  // Border Radius
  static const double radiusXs = baseUnit; // 4px
  static const double radiusSm = baseUnit * 2; // 8px
  static const double radiusMd = baseUnit * 3; // 12px
  static const double radiusLg = baseUnit * 4; // 16px
  static const double radiusXl = baseUnit * 5; // 20px
  static const double radius2xl = baseUnit * 6; // 24px
  static const double radiusFull = 9999; // Fully rounded

  // Button Dimensions
  static const double buttonHeightSm = baseUnit * 9; // 36px
  static const double buttonHeightMd = baseUnit * 12; // 48px
  static const double buttonHeightLg = baseUnit * 14; // 56px
  static const double buttonMinWidth = baseUnit * 16; // 64px
  static const double buttonPaddingHorizontal = paddingLg; // 24px

  // Input Field Dimensions
  static const double inputHeight = baseUnit * 14; // 56px
  static const double inputBorderWidth = 1.5;
  static const double inputBorderRadius = radiusMd; // 12px

  // Icon Sizes
  static const double iconXs = baseUnit * 4; // 16px
  static const double iconSm = baseUnit * 5; // 20px
  static const double iconMd = baseUnit * 6; // 24px
  static const double iconLg = baseUnit * 8; // 32px
  static const double iconXl = baseUnit * 12; // 48px
  static const double icon2xl = baseUnit * 16; // 64px
  static const double icon3xl = baseUnit * 20; // 80px

  // Avatar Sizes
  static const double avatarXs = baseUnit * 6; // 24px
  static const double avatarSm = baseUnit * 8; // 32px
  static const double avatarMd = baseUnit * 10; // 40px
  static const double avatarLg = baseUnit * 14; // 56px
  static const double avatarXl = baseUnit * 20; // 80px
  static const double avatar2xl = baseUnit * 25; // 100px

  // Card Dimensions
  static const double cardPadding = paddingMd; // 16px
  static const double cardRadius = radiusLg; // 16px
  static const double cardElevation = 2.0;

  // Message Bubble Dimensions
  static const double messageBubblePadding = paddingMd; // 16px
  static const double messageBubbleRadius = radiusXl; // 20px
  static const double messageBubbleMaxWidth = 280.0;
  static const double messageSpacing = spacingSm; // 12px

  // Touch Target
  static const double minTouchTarget = baseUnit * 12; // 48px (WCAG AA)

  // Elevation
  static const double elevation0 = 0;
  static const double elevation1 = 1;
  static const double elevation2 = 2;
  static const double elevation3 = 4;
  static const double elevation4 = 6;
  static const double elevation5 = 8;

  // App Bar
  static const double appBarHeight = baseUnit * 14; // 56px
  static const double appBarElevation = 0;

  // Bottom Navigation
  static const double bottomNavHeight = baseUnit * 14; // 56px
  static const double bottomNavElevation = elevation3;

  // Dialog
  static const double dialogRadius = radiusLg; // 16px
  static const double dialogPadding = paddingLg; // 24px
  static const double dialogMaxWidth = 400.0;

  // Snackbar
  static const double snackbarRadius = radiusSm; // 8px
  static const double snackbarPadding = paddingMd; // 16px

  // Divider
  static const double dividerThickness = 1.0;
  static const double dividerIndent = spacingMd; // 16px

  // List Tile
  static const double listTileHeight = baseUnit * 14; // 56px
  static const double listTileContentPadding = paddingMd; // 16px

  // Image Dimensions
  static const double imageSm = baseUnit * 16; // 64px
  static const double imageMd = baseUnit * 25; // 100px
  static const double imageLg = baseUnit * 50; // 200px

  // Max Width for Content
  static const double maxContentWidth = 600.0;
  static const double maxFormWidth = 400.0;
}
