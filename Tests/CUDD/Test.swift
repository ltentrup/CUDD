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
        XCTAssertNotEqual(a, b, "true != false")
        XCTAssertEqual(a & b, b, "true & false == false")
    }
    
    func testConjunction() {
        let manager = CUDDManager()
        var a = manager.newVar()
        var b = manager.newVar()
        
        let aCopy = a
        let bCopy = b
        
        XCTAssertNotEqual(a, b, "Two freshly generated variables should not be equal")
        a &= b
        XCTAssertNotEqual(a, b, "(a & b) != b")
        b &= a
        XCTAssertEqual(a, b, "(a & b) = (a & b)")
        
        let c = aCopy & bCopy
        XCTAssertEqual(c, a, "(a & b) = (a & b)")
    }
    
    func testNegation() {
        let manager = CUDDManager()
        let a = manager.newVar()
        XCTAssertNotEqual(a, !a, "a != !a")
        XCTAssertEqual(a, !(!a), "a == !!a")
    }
    
    func testXnor() {
        let manager = CUDDManager()
        let a = manager.newVar()
        let b = manager.newVar()
        XCTAssertEqual(a <-> b, b <-> a, "(a <-> b) == (b <-> a)")
    }
}
