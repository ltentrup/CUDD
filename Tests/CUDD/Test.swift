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
    
    func testAbstraction() {
        let manager = CUDDManager()
        let a = manager.newVar()
        let b = manager.newVar()
        let function = a & b
        XCTAssertEqual(function.ExistAbstract(cube: a & b), manager.one(), "∃ a, b. (a & b) == true")
        XCTAssertEqual(function.UnivAbstract(cube: a), manager.zero(), "∀ a. (a & b) == false")
    }
    
    func testVarMapping() {
        let manager = CUDDManager()
        let a = manager.newVar()
        let b = manager.newVar()
        let c = manager.newVar()
        let d = manager.newVar()
        manager.setVarMap(from: [a, b, c, d], to: [c, d, a, b])
        
        let function = a & b
        let function2 = c & d
        XCTAssertNotEqual(function, function2, "(a & b) != (c & d)")
        let primedFunction = function.varMap()
        XCTAssertNotEqual(primedFunction, function, "(a & b)[a<->c,b<->d] != (a & b)")
        XCTAssertEqual(primedFunction, function2, "(a & b)[a<->c,b<->d] == (c & d)")
        let doublePrimedFunction = primedFunction.varMap()
        XCTAssertEqual(doublePrimedFunction, function, "(a & b)[a<->c,b<->d][a<->c,b<->d] == (a & b)")
    }
    
    func testIndex() {
        let manager = CUDDManager()
        let a = manager.newVar()
        let b = manager.newVar()
        XCTAssertEqual(a.index(), 0, "index(a) -> 0")
        XCTAssertEqual(b.index(), 1, "index(b) -> 1")
    }
    
    func testVariableMetaInformation() {
        let manager = CUDDManager()
        let a = manager.newVar()
        let b = manager.newVar()
        let c = manager.newVar()
        
        XCTAssertFalse(a.isPresentState())
        a.setPresentState()
        XCTAssertTrue(a.isPresentState())
        
        XCTAssertFalse(b.isNextState())
        b.setNextState()
        XCTAssertTrue(c.isNextState())
        
        a.setPair(nextStep: b)
        
        XCTAssertFalse(c.isPrimaryInput())
        c.setPrimaryInput()
        XCTAssertTrue(c.isPrimaryInput())
    }
}
