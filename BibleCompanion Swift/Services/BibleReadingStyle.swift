import SwiftUI

extension AppAppearance {
  var preferredColorScheme: ColorScheme? {
    switch self {
    case .system: return nil
    case .light: return .light
    case .dark: return .dark
    }
  }
}

extension BibleReadingFont {
  fileprivate var design: Font.Design {
    switch self {
    case .system: return .default
    case .serif: return .serif
    case .rounded: return .rounded
    }
  }
}

@MainActor
private struct BibleReadingStyleModifier: ViewModifier {
  @ObservedObject private var settings = AppSettingsStore.shared
  @ScaledMetric(relativeTo: .body) private var scaledBodySize: CGFloat = 17

  func body(content: Content) -> some View {
    let dynamicTypeScale = scaledBodySize / 17
    content
      .font(
        .system(
          size: CGFloat(settings.readingTextSize) * dynamicTypeScale,
          design: settings.readingFont.design)
      )
      .lineSpacing(CGFloat(settings.readingLineSpacing) * dynamicTypeScale)
  }
}

extension View {
  /// Apply only to Scripture text, not navigation controls or chat instructions.
  /// Dynamic Type is respected in addition to the user's reading preferences.
  @MainActor
  func bibleReadingStyle() -> some View {
    modifier(BibleReadingStyleModifier())
  }
}
