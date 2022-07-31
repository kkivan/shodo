import XCTest
@testable import shodo

final class shodoTests: XCTestCase {

    func makeStrings(@StringBuilder _ content: () -> [String]) -> [String] {
        content()
    }

    func printStrings(_ strings: [String]) {
        print(strings.joined(separator: "\n"))
    }

    func testBorders() throws {
        let r = makeStrings {
            Border {
                Border {
                    Border {
                        "three"
                    }
                    List(prefix: "+") {
                        StringGroup {
                            "another"
                            "1"
                        }
                    }
                }
                "one"
                "two"
                "three"
            }
        }

        let expected = """
        ╭───────────────╮
        │ ╭───────────╮ │
        │ │ ╭───────╮ │ │
        │ │ │ three │ │ │
        │ │ └───────┘ │ │
        │ │ + another │ │
        │ │ + 1       │ │
        │ └───────────┘ │
        │ one           │
        │ two           │
        │ three         │
        └───────────────┘
        """
        let joined = r.joined(separator: "\n")

        XCTAssertEqual(joined, expected)
    }

    func testTreeWithIndents() {
        let tree = ["LICENSE",
                    "Package.swift",
                    Files(name: "AutofixturesTests",
                          files: ["OneTests.swift",
                                  "TwoTests.swift"]),
                    "README.md",
                    Files(name: "Sources",
                          files: [.init(name: "Autofixtures",
                                        files: ["Autofixtures.swift",
                                                "FixtureDecoder.swift"])])]

        let r = makeStrings {
            TreeBuilder(trees: tree)
        }
        let expected = """
        LICENSE
        Package.swift
        AutofixturesTests
           OneTests.swift
           TwoTests.swift
        README.md
        Sources
           Autofixtures
              Autofixtures.swift
              FixtureDecoder.swift
        """
        printStrings(r)
        let joined = r.joined(separator: "\n")
        XCTAssertEqual(joined, expected)
    }
}

/*
    .
    ├── LICENSE
    ├── Package.swift
    ├── README.md
    ├── Sources
    │   └── Autofixtures
    │       ├── Autofixtures.swift
    │       └── FixtureDecoder.swift
    └── Tests
        └── AutofixturesTests
            └── AutofixturesTests.swift
 */

struct Files {
    var name: String
    var files: [Files] = []
}

extension Files: ExpressibleByStringLiteral {
    init(stringLiteral value: StringLiteralType) {
        self = .init(name: value)
    }
}

extension Files: Tree {
    var value: String {
        name
    }

    var children: [Files] {
        files
    }
}
