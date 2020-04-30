///

import Foundation

/// Languages supported by the app
enum Language: String {
    case german = "de"
    case english = "en"
    case italian = "it"
    case france = "fr"

    static var current: Language {
        let preferredLanguages = Locale.preferredLanguages

        for preferredLanguage in preferredLanguages {
            if let code = preferredLanguage.components(separatedBy: "-").first,
                let language = Language(rawValue: code) {
                return language
            }
        }

        return .german
    }
}
