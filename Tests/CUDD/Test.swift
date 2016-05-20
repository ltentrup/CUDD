import XCTest
import CUDD

class CUDDTest: XCTestCase {
    func testInitialization() {
        let manager = CUDDManager()
    }
    
    func testOneEqual() {
        let manager = CUDDManager()
        let a = manager.One()
        let b = manager.One()
        XCTAssertEqual(a, b, "Constant One functions should be equal")
    }
}
