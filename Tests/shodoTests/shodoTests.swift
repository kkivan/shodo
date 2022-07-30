import XCTest
@testable import shodo

final class shodoTests: XCTestCase {

    func makeSettings(@StringBuilder _ content: () -> [String]) -> [String] {
        content()
    }

    func testExample() throws {

        let r = makeSettings {
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

        XCTAssertEqual(r.joined(separator: "\n"), expected)
    }

}
