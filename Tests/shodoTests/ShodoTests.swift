import XCTest
import Shodo
import CustomDump

final class shodoTests: XCTestCase {

    func testBorders() throws {
        assert(compose {
            Border {
                Border {
                    Border {
                        "three"
                    }
                    List(prefix: "+") {
                        compose {
                            "another"
                            "1"
                        }
                    }
                }
                "one"
                "two"
                "three"
            }
        },
        """
        ┌───────────────┐
        │ ┌───────────┐ │
        │ │ ┌───────┐ │ │
        │ │ │ three │ │ │
        │ │ └───────┘ │ │
        │ │ + another │ │
        │ │ + 1       │ │
        │ └───────────┘ │
        │ one           │
        │ two           │
        │ three         │
        └───────────────┘
        """)
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

        assert(compose {
            TreeBuilder(trees: tree)
        },
        """
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
        """)
    }

    func testComposeArrays() {
        let input = ["one", "two", "three"]

        let r = compose {
            compose {
                input
                input
            }
            compose {
                input
            }
        }

        XCTAssertNoDifference(r, input + input + input)
    }

    func testNumbered() {
        assert(compose {
            Numbered {
                Array(repeating: "line", count: 10)
            }
        }, """
         1 | line
         2 | line
         3 | line
         4 | line
         5 | line
         6 | line
         7 | line
         8 | line
         9 | line
        10 | line
        """)
    }

    func testList() {
        assert(
            compose {
                List(prefix: .dashed) {
                    "one"
                    "two"
                    "three"
                }
            },
        """
        - one
        - two
        - three
        """)
    }

    func testNumberedList() {
        assert(
            compose {
                List(prefix:.numbered) {
                    "one"
                    "two"
                    "three"
                    "one"
                    "two"
                    "three"
                    "one"
                    "two"
                    "three"
                    "one"
                    "two"
                    "three"
                }
            },
        """
         1.one
         2.two
         3.three
         4.one
         5.two
         6.three
         7.one
         8.two
         9.three
        10.one
        11.two
        12.three
        """)
    }

    func testTable() {

        struct User {
            let id: Int
            let email: String
            let name: String
        }

        let users: [User] = [User(id: 1, email: "mail@mail.com", name: "John"),
                             User(id: 2, email: "mail@mail.com", name: "Jack"),
                             User(id: 300, email: "mail@mail-mail.com", name: "Maria")]

        assert(compose {
            Table(rows: users) {
                Column(header: "Id", value: \User.id.string)
                Column(header: "Name", value: \User.name)
                Column(header: "Email", value: \User.email)
            }
        },
        """
        ┼─────┼───────┼────────────────────┼
        |  Id |  Name |              Email |
        ┼─────┼───────┼────────────────────┼
        |   1 |  John |      mail@mail.com |
        ┼─────┼───────┼────────────────────┼
        |   2 |  Jack |      mail@mail.com |
        ┼─────┼───────┼────────────────────┼
        | 300 | Maria | mail@mail-mail.com |
        ┼─────┼───────┼────────────────────┼
        """)
    }

    func assert(_ strings: [String], _ expected: String) {
        XCTAssertNoDifference(strings.joined(separator: "\n"), expected)
    }

    func testWidth() {

    }
}

extension Array where Element == String {
    func print() -> String {
        let joined = joined(separator: "\n")
        Swift.print(joined)
        return joined
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
    var value: [String] {
        [name]
    }

    var children: [Files] {
        files
    }
}
