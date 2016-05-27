import XCTest
import CUDD

class CUDDTest: XCTestCase {
    func testInitialization() {
        let manager = CUDDManager()
    }
    
    func testOneEqual() {
        let manager = CUDDManager()
        let a = manager.one()
        let b = manager.one()
        XCTAssertEqual(a, b, "Constant one functions should be equal")
    }
    
    func testOneZeroUnequal() {
        let manager = CUDDManager()
        let a = manager.one()
        let b = manager.zero()
        XCTAssertNotEqual(a, b, "Constant one functions should be not equal to constant zero function")
    }
    
    func testConjunction() {
        let manager = CUDDManager()
        var a = manager.newVar()
        var b = manager.newVar()
        XCTAssertNotEqual(a, b, "Two freshly generated variables should not be equal")
        a &= b
        XCTAssertNotEqual(a, b, "(a & b) != b")
        b &= a
        XCTAssertEqual(a, b, "(a & b) = (a & b)")
    }
}
