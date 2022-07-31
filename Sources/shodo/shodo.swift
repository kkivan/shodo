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
        let length = s.map(\.count).max() ?? 1
        let horizontal = "─".repeating(length + 2)
        let top = "┌" + horizontal + "┐"
        let bottom = "└" + horizontal + "┘"
        let body = s.map { "│ " + $0.fixed(length) + " │"}
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
    @StringBuilder var strings: () -> [String]

    public var asStrings: [String] {
        zip(1..., strings()).map { "\($0.0) | \($0.1)" }
    }
}

