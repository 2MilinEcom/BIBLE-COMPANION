import Combine
import Foundation

// =========================================================
// MARK: - Daily Study View Model
// =========================================================

@MainActor
final class DailyStudyViewModel: ObservableObject {

  @Published private(set) var passageText = ""
  @Published private(set) var content: DailyStudyContent?
  @Published var reflection = ""
  @Published private(set) var isLoading = false
  @Published private(set) var isCompleted = false
  @Published private(set) var errorMessage: String?

  let plan: DailyStudyPlan

  private let store: DailyStudyStore
  private let service: DailyStudyService
  private let bibleService: BibleService
  private let historyService: StudyHistoryService

  private var didLoad = false
  private var didLoadReflection = false

  init(
    plan: DailyStudyPlan,
    store: DailyStudyStore? = nil,
    service: DailyStudyService? = nil,
    bibleService: BibleService = .shared,
    historyService: StudyHistoryService = .shared
  ) {
    self.plan = plan
    self.store = store ?? .shared
    self.service = service ?? .shared
    self.bibleService = bibleService
    self.historyService = historyService
  }

  var fullPassage: String {
    guard !passageText.isEmpty else { return plan.reference }
    return plan.reference + "\n\n" + passageText
  }

  var isUsingFallback: Bool {
    content?.source == .fallback
  }

  func load(profile: SpiritualProfile) async {
    guard !didLoad else { return }
    didLoad = true

    let record = store.ensurePlan(plan)
    reflection = record.reflection
    didLoadReflection = true
    isCompleted = record.completedAt != nil

    do {
      passageText = try loadPassageText()
    } catch {
      errorMessage = error.localizedDescription
      content = DailyStudyContent.fallback()
      return
    }

    if let saved = record.content {
      content = saved
      return
    }

    await generate(profile: profile)
  }

  func retry(profile: SpiritualProfile) async {
    await generate(profile: profile)
  }

  func reflectionChanged() {
    guard didLoadReflection else { return }
    _ = store.saveReflection(reflection, dateKey: plan.dateKey)
  }

  func markComplete() {
    let newlyCompleted = store.markCompleted(dateKey: plan.dateKey)
    isCompleted = store.record(dateKey: plan.dateKey)?.completedAt != nil

    guard newlyCompleted else { return }

    historyService.record(
      StudyActivity(
        type: .passageStudy,
        title: "Daily Study: \(plan.title)",
        passage: plan.reference,
        topic: plan.focusLabel
      )
    )
  }

  // =====================================================
  // MARK: - Generate
  // =====================================================

  private func generate(profile: SpiritualProfile) async {
    guard !passageText.isEmpty else { return }
    guard !isLoading else { return }

    isLoading = true
    errorMessage = nil

    defer { isLoading = false }

    do {
      let generated = try await service.generate(
        plan: plan,
        passage: fullPassage,
        profile: profile
      )
      content = generated
      _ = store.saveContent(generated, dateKey: plan.dateKey)
    } catch {
      errorMessage = "Companion couldn't personalize today's guide right now. You can still read and reflect, or try again."
      content = DailyStudyContent.fallback()
    }
  }

  // =====================================================
  // MARK: - Passage Loading
  // =====================================================

  private func loadPassageText() throws -> String {
    guard let location = plan.location else {
      throw DailyStudyError.invalidReference
    }

    let bible = try bibleService.loadBible()
    let requested = Set(location.verses)

    let verses = bible.filter { verse in
      verse.book.caseInsensitiveCompare(location.book) == .orderedSame
        && verse.chapter == location.chapter
        && (requested.isEmpty || requested.contains(verse.verse))
    }
    .sorted { $0.verse < $1.verse }

    guard !verses.isEmpty else {
      throw DailyStudyError.passageUnavailable
    }

    return verses
      .map { "\($0.verse) \($0.text)" }
      .joined(separator: "\n")
  }
}

enum DailyStudyError: LocalizedError {
  case invalidReference
  case passageUnavailable

  var errorDescription: String? {
    switch self {
    case .invalidReference:
      return "Today's Bible reference could not be opened."
    case .passageUnavailable:
      return "Today's passage is not available in the bundled Bible."
    }
  }
}
