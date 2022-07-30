public protocol ToString {
    var asStrings: [String] { get }
}

extension String: ToString {
    public var asStrings: [String] {
        [self]
    }
}

@resultBuilder
public struct StringBuilder {
    public static func buildBlock(_ parts: ToString...) -> [String] {
        parts.flatMap(\.asStrings)
    }

    static func buildBlock(_ values: StringGroup...) -> [String] {
        values.flatMap {
            $0.strings()
        }
    }
}

struct StringGroup: ToString {
    @StringBuilder var strings: () -> [String]
    var asStrings: [String] {
        strings()
    }
}

struct List: ToString {
    var prefix: String
    @StringBuilder var strings: () -> [String]

    var asStrings: [String] {
        strings().map { "\(prefix) \($0)" }
    }
}

struct Border: ToString {
    @StringBuilder var strings: () -> [String]

    var asStrings: [String] {
        let s = strings()
        let length = s.map(\.count).max()! + 2
        let horizontal = "─".repeating(length)
        let top = "╭" + horizontal + "╮"
        let bottom = "└" + horizontal + "┘"
        let body = s.map { "│ " + $0.fixed(length - 2) + " │"}
        return [top] + body + [bottom]
    }
}

extension String {
    func repeating(_ times: Int) -> String {
        let arr = Array(repeating: self, count: times)
        return arr.reduce("", +)
    }
    func fixed(_ length: Int) -> String {
        if count < length {
            return self + " ".repeating(length - count)
        }

        return self
    }
}
