import XCTest
@testable import Backports

func XCTAssertEqual<T: Equatable, Lhs: Sequence, Rhs: Sequence>(_ lhs: Lhs, _ rhs: Rhs) where Lhs.Element: Sequence, Rhs.Element: Sequence, Lhs.Element.Element == T, Rhs.Element.Element == T {
    XCTAssertTrue(lhs.elementsEqual(rhs, by: { innerLhs, innerRhs in
        innerLhs.elementsEqual(innerRhs)
    }))
}

final class CollectionTests: XCTestCase {
    func testSplit() throws {
        let string = "dfgdg;;dfgdgdfgdg;;;;gdfgdgdfgdg;;thfhnsdfs;;sef;;sdfhgh"
        
        let expectedResult = [
            "dfgdg",
            "dfgdgdfgdg",
            "",
            "gdfgdgdfgdg",
            "thfhnsdfs",
            "sef",
            "sdfhgh",
        ]
        
        let actualResult = string.split(separator: ";;", omittingEmptySubsequences: false)
        
        XCTAssertEqual(actualResult, expectedResult)
    }
    
    func testSplitOmittingEmpty() throws {
        let string = "dfgdg;;dfgdgdfgdg;;;;gdfgdgdfgdg;;thfhnsdfs;;sef;;sdfhgh"
        
        let expectedResult = [
            "dfgdg",
            "dfgdgdfgdg",
            "gdfgdgdfgdg",
            "thfhnsdfs",
            "sef",
            "sdfhgh",
        ]
        
        let actualResult = string.split(separator: ";;", omittingEmptySubsequences: true)
        
        XCTAssertEqual(actualResult, expectedResult)
    }
}
