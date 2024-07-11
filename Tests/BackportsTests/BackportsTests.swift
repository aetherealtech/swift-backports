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

        let expectedResult = string.split_native(separator: ";;", omittingEmptySubsequences: false)
        let actualResult = string.split_backport(separator: ";;", omittingEmptySubsequences: false)
        
        XCTAssertEqual(actualResult, expectedResult)
    }
    
    func testSplitOmittingEmpty() throws {
        let string = "dfgdg;;dfgdgdfgdg;;;;gdfgdgdfgdg;;thfhnsdfs;;sef;;sdfhgh"
        
        let expectedResult = string.split_native(separator: ";;", omittingEmptySubsequences: true)
        let actualResult = string.split_backport(separator: ";;", omittingEmptySubsequences: true)
        
        XCTAssertEqual(actualResult, expectedResult)
    }
}

final class DateTests: XCTestCase {
    func testDistance() throws {
        let date = Date()
        let otherDate = date.addingTimeInterval(5)
        
        let expectedResult = otherDate.distance_native(to: date)
        let actualResult = otherDate.distance_backport(to: date)
        
        XCTAssertEqual(actualResult, expectedResult)
    }
    
    func testAdvanced() throws {
        let date = Date()
        
        let expectedResult = date.advanced_native(by: 5)
        let actualResult = date.advanced_backport(by: 5)
        
        XCTAssertEqual(actualResult, expectedResult)
    }
}
