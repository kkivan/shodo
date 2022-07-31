import Foundation

public protocol ToString {
    var asStrings: [String] { get }
}

extension String: ToString {
    public var asStrings: [String] { [self] }
}

extension Array: ToString where Element == String {
    public var asStrings: [String] { self }
}

@resultBuilder
public struct StringBuilder {
    public static func buildBlock(_ parts: ToString...) -> [String] {
        parts.flatMap(\.asStrings)
    }
}

struct List: ToString {
    enum Prefix: ExpressibleByStringLiteral {
        init(stringLiteral value: StringLiteralType) {
            self = .literal(value)
        }
        case literal(String)
        case dashed
        case numbered
    }
    var prefix: Prefix
    @StringBuilder var strings: () -> [String]

    var asStrings: [String] {
        switch prefix {
            case .literal(let literal):
                return strings().map { "\(literal) \($0)" }
            case .dashed:
                return strings().map { "\("-") \($0)" }
            case .numbered:
                return compose { Numbered(".") { strings() }}
        }

    }
}

struct Border: ToString {
    @StringBuilder var strings: () -> [String]

    var asStrings: [String] {
        let s = strings()
        let length = s.map(\.count).max() ?? 1
        let horizontal = "─".repeating(length + 2)
        let top = "┌" + horizontal + "┐"
        let bottom = "└" + horizontal + "┘"
        let body = s.map { "│ " + $0.spaceRight(length) + " │"}
        return [top] + body + [bottom]
    }
}

extension String {
    func repeating(_ times: Int) -> String {
        let arr = Array(repeating: self, count: times)
        return arr.reduce("", +)
    }

    func spaceRight(_ length: Int) -> String {
        if count < length {
            return self + " ".repeating(length - count)
        }

        return self
    }

    func spaceLeft(_ length: Int) -> String {
        if count < length {
            return " ".repeating(length - count) + self
        }

        return self
    }
}

struct TreeBuilder: ToString {

    let trees: [Tree]

    var asStrings: [String] {
        compose {
            List(prefix: "  ") {
                trees.flatMap { root in
                    compose {
                        root.value
                        TreeBuilder(trees: root.children)
                    }
                }
            }
        }
    }
}

protocol Tree {
    var value: [String] { get }
    var children: [Self] { get }
}

func compose(@StringBuilder _ content: () -> [String]) -> [String] {
    content()
}

public struct Numbered: ToString {
    let separator: String
    @StringBuilder var strings: () -> [String]
    init(_ separator: String = " | ", strings: @escaping () -> [String]) {
        self.separator = separator
        self.strings = strings
    }

    public var asStrings: [String] {
        let numbered = zip(1..., strings()).map { (String($0.0), $0.1)}
        let width = numbered.map(\.0.count).max() ?? 0
        return numbered.map { "\($0.0.spaceLeft(width))\(separator)\($0.1)" }
    }
}
