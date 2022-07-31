import XCTest
import Shodo
import CustomDump

final class shodoTests: XCTestCase {

    func printStrings(_ strings: [String]) {
        print(strings.joined(separator: "\n"))
    }

    func testBorders() throws {
        let r = compose {
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
        }

        let expected = """
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
        
        let r = compose {
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

        let joined = r.joined(separator: "\n")
        XCTAssertEqual(joined, expected)
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

        XCTAssertEqual(r, input + input + input)
    }

    func testNumbered() {
        let r = compose {
            Numbered {
                Array(repeating: "line", count: 10)
            }
        }

        let expected = """
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
        """
        XCTAssertEqual(r.joined(separator: "\n"), expected)
    }

    func testList() {
        let r = compose {
            List(prefix: .dashed) {
                "one"
                "two"
                "three"
            }
        }
        printStrings(r)
        let expected = """
        - one
        - two
        - three
        """
        XCTAssertEqual(r.joined(separator: "\n"), expected)
    }

    func testNumberedList() {
        let r = compose {
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
        }
        let expected = """
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
        """
        XCTAssertEqual(r.joined(separator: "\n"), expected)
    }

    func testTable() {
        let expected = """
        ┼─────┼───────┼────────────────────┼
        |  Id |  Name |              Email |
        ┼─────┼───────┼────────────────────┼
        |   1 |  John |      mail@mail.com |
        ┼─────┼───────┼────────────────────┼
        |   2 |  Jack |      mail@mail.com |
        ┼─────┼───────┼────────────────────┼
        | 300 | Maria | mail@mail-mail.com |
        ┼─────┼───────┼────────────────────┼
        """

        struct User {
            let id: Int
            let email: String
            let name: String
        }

        let users: [User] = [User(id: 1, email: "mail@mail.com", name: "John"),
                             User(id: 2, email: "mail@mail.com", name: "Jack"),
                             User(id: 300, email: "mail@mail-mail.com", name: "Maria")]

        let r = compose {
            Table(rows: users) {
                Column(header: "Id", value: \User.id.string)
                Column(header: "Name", value: \User.name)
                Column(header: "Email", value: \User.email)
            }
        }
        XCTAssertNoDifference(r.joined(separator: "\n"), expected)
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
