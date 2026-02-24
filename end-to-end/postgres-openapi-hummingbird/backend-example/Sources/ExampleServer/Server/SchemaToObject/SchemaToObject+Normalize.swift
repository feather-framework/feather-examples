import Foundation

private func normalizedText(_ value: String) -> String {
    value.split(whereSeparator: \.isWhitespace).joined(separator: " ")
}

private func normalizedIdentifier(_ value: String) -> String {
    value.trimmingCharacters(in: .whitespacesAndNewlines)
}

func normalizeListName(_ value: String) -> String {
    normalizedText(value)
}

func normalizeTodoName(_ value: String) -> String {
    normalizedText(value)
}

func normalizeListId(_ value: String) -> String {
    normalizedIdentifier(value)
}

