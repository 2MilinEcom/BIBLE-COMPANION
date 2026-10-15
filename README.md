# Bible Companion iOS

I keep the iOS development source for Bible Companion in this repository. I built the app around Scripture reading, personal reflection, and a companion interface that connects to my separate backend.

I included the app views, local models and services, bundled Scripture data, artwork, and the widget extension. I keep the app and backend in separate repositories so each has a clear entry point.

## Built with

I used Swift, SwiftUI, and Xcode.

## Inside the project

* `BibleCompanion Swift/`: app views, models, services, and bundled data.
* `DailyCompanionWidget/`: the widget extension.
* `BibleCompanion Swift.xcodeproj/`: the Xcode project.

## Running it

I open `BibleCompanion Swift.xcodeproj` in Xcode, select my development team and an iPhone simulator, and run the app. I set the service address in `BibleCompanion Swift/Services/config.swift` for my own backend.

I use the [backend repository](https://github.com/2MilinEcom/BIBLE-COMPANION-BACKEND) for the service. I keep a separate [portfolio copy](https://github.com/2MilinEcom/bible-companion-portfolio) with an overview and implementation notes.
