import XCTest
@testable import shodo

final class shodoTests: XCTestCase {

    func makeStrings(@StringBuilder _ content: () -> [String]) -> [String] {
        content()
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

}
