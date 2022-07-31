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

public struct List: ToString {
    public enum Prefix: ExpressibleByStringLiteral {
        public init(stringLiteral value: StringLiteralType) {
            self = .literal(value)
        }
        case literal(String)
        case dashed
        case numbered
    }
    var prefix: Prefix
    @StringBuilder var strings: () -> [String]

    public init(prefix: Prefix, @StringBuilder strings: @escaping () -> [String]) {
        self.prefix = prefix
        self.strings = strings
    }

    public var asStrings: [String] {
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

public struct Border: ToString {
    @StringBuilder var strings: () -> [String]
    public init(@StringBuilder strings: @escaping () -> [String]) {
        self.strings = strings
    }

    public var asStrings: [String] {
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

public struct TreeBuilder: ToString {

    let trees: [Tree]

    public init(trees: [Tree]) {
        self.trees = trees
    }

    public var asStrings: [String] {
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

public protocol Tree {
    var value: [String] { get }
    var children: [Self] { get }
}

public func compose(@StringBuilder _ content: () -> [String]) -> [String] {
    content()
}

public struct Numbered: ToString {
    let separator: String
    @StringBuilder var strings: () -> [String]
    public init(_ separator: String = " | ", strings: @escaping () -> [String]) {
        self.separator = separator
        self.strings = strings
    }

    public var asStrings: [String] {
        let numbered = zip(1..., strings()).map { (String($0.0), $0.1)}
        let width = numbered.map(\.0.count).max() ?? 0
        return numbered.map { "\($0.0.spaceLeft(width))\(separator)\($0.1)" }
    }
}

public extension Int {
    var string: String {
        String(self)
    }
}

@resultBuilder
public struct TableBuilder {
    public static func buildBlock<A>(_ parts: Column<A>...) -> [Column<A>] {
        parts
    }
}

public struct Column<Row> {
    let header: String
    let value: KeyPath<Row, String>
    public init(header: String,
                value: KeyPath<Row, String>) {
        self.header = header
        self.value = value
    }
}

public struct Table<Row>: ToString {

    var rows: [Row]

    @TableBuilder var columns: () -> [Column<Row>]

    public init(rows: [Row], @TableBuilder columns: @escaping () -> [Column<Row>]) {
        self.rows = rows
        self.columns = columns
    }

    public var asStrings: [String] {
        let table = columns().map { column in
            [column.header] + rows.map { $0[keyPath: column.value] }
        }
        let widths = table.map { $0.map(\.count).max() ?? 0 }
        let a = zip(table, widths).map { column, width in column.map { $0.spaceLeft(width)}  }
        let z = (0...a.count).map { i in
            a.map { $0[i] }
        }

        let separator = "┼─" + widths.map { "─".repeating($0) }.joined(separator: "─┼─") + "─┼"
        let r = [separator] + z.map { "| " + $0.joined(separator: " | ") + " |" }.flatMap {
            [$0, separator]
        }
        return r
    }
}
